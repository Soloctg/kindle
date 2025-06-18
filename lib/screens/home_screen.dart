import 'package:flutter/material.dart';
import 'package:kindle/widgets/post_card.dart';
import 'package:kindle/widgets/wallet_card.dart';
import 'package:kindle/widgets/bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:solana/solana.dart';
import 'package:bip39/bip39.dart'
    as bip39; // Ensure this is in your pubspec.yaml

class Post {
  final String title;
  final String ticker;
  final String description;
  final double amountRaised;

  Post({
    required this.title,
    required this.ticker,
    required this.description,
    this.amountRaised = 0.0,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'ticker': ticker,
    'description': description,
    'amount_raised': amountRaised,
  };

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      title: map['title'],
      ticker: map['ticker'],
      description: map['description'],
      amountRaised: (map['amount_raised'] ?? 0).toDouble(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

const int lamportsPerSol = 1000000000;

class _HomeScreenState extends State<HomeScreen> {
  List<Post> posts = [];
  int currentIndex = 0;
  String? walletAddress;
  int? solBalance;

  @override
  void initState() {
    super.initState();
    _loadWalletAddress();
    fetchPosts();
  }

  Future<void> _loadWalletAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final address = prefs.getString('wallet_address');
    if (address != null) {
      setState(() => walletAddress = address);
      _fetchBalance(address);
    }
  }

  Future<void> _saveWalletAddress(String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wallet_address', address);
  }

  Future<void> _fetchBalance(String address) async {
    final rpcClient = RpcClient('https://api.mainnet-beta.solana.com');
    final balanceResult = await rpcClient.getBalance(address);
    if (!mounted) return;
    setState(() => solBalance = balanceResult.value ~/ lamportsPerSol);
  }

  Future<void> _connectWallet() async {
    try {
      final mnemonic = bip39.generateMnemonic(); // Or load from storage
      final wallet = await Ed25519HDKeyPair.fromMnemonic(mnemonic);

      final address = wallet.address;

      await _saveWalletAddress(address);
      setState(() => walletAddress = address);

      _fetchBalance(address);
      // Optionally save the mnemonic securely (NOT for production use)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('wallet_mnemonic', mnemonic);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Wallet connection failed: $e')));
    }
  }

  Future<void> fetchPosts() async {
    final response = await Supabase.instance.client.from('posts').select();
    final data = List<Map<String, dynamic>>.from(response);
    if (!mounted) return;
    setState(() => posts = data.map((e) => Post.fromMap(e)).toList());
  }

  void _navigateToCreatePost() async {
    final result = await Navigator.pushNamed(context, '/create-post');
    if (result != null && result is Post) {
      await Supabase.instance.client.from('posts').insert(result.toMap());
      fetchPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web3 GoFundMe'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'settings') {
                Navigator.pushNamed(context, '/settings');
              } else if (value == 'logout') {
                await Supabase.instance.client.auth.signOut();
                if (!mounted) return;
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            itemBuilder:
                (context) => const [
                  PopupMenuItem(value: 'settings', child: Text('Settings')),
                  PopupMenuItem(value: 'logout', child: Text('Logout')),
                ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchPosts,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildGreeting(),
            const SizedBox(height: 16),
            _buildCreatePostButton(),
            const SizedBox(height: 24),
            const Text(
              'Active Fundraisers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...posts.map((post) => PostCard(post: post)),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
      ),
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome 👋', style: Theme.of(context).textTheme.headlineSmall),
        if (walletAddress != null) ...[
          Text(
            'Wallet: $walletAddress',
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),
          WalletCard(walletAddress: walletAddress!, balance: solBalance),
        ] else
          ElevatedButton.icon(
            icon: const Icon(Icons.link),
            label: const Text('Connect Wallet'),
            onPressed: _connectWallet,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        const SizedBox(height: 8),
        const Text(
          'Create or explore fundraisers below!',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildCreatePostButton() {
    return ElevatedButton.icon(
      onPressed: _navigateToCreatePost,
      icon: const Icon(Icons.add),
      label: const Text('Create Fundraiser'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

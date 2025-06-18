import 'package:flutter/material.dart';
import 'package:kindle/widgets/post_card.dart';
import 'package:kindle/widgets/wallet_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/bottom_nav_bar.dart';

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

class _HomeScreenState extends State<HomeScreen> {
  List<Post> posts = [];
  int currentIndex = 0;
  String walletAddress =
      ''; // TODO: Replace with actual wallet address retrieval logic

  @override
  void initState() {
    super.initState();
    fetchPosts();
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
          //IconButton(icon: const Icon(Icons.qr_code_scanner),
          //onPressed: scanQR),
          //IconButton(icon: const Icon(Icons.send), onPressed: sendTransaction),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert), // 3 dots icon
            onSelected: (value) async {
              if (value == 'settings') {
                Navigator.pushNamed(context, '/settings');
              } else if (value == 'logout') {
                await Supabase.instance.client.auth.signOut();
                if (!mounted) return;
                Navigator.pushReplacementNamed(context, '/login');
              }
              // add more actions if needed
            },
            itemBuilder:
                (BuildContext context) => [
                  const PopupMenuItem(
                    value: 'settings',
                    child: Text('Settings'),
                  ),
                  const PopupMenuItem(value: 'logout', child: Text('Logout')),
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
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...posts.map((post) => _buildPostCard(post)),
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
        Text(
          //'Wallet: $address',
          'Wallet: ',
          style: TextStyle(color: Colors.grey[700]),
        ),
        const SizedBox(height: 16),

        WalletCard(walletAddress: walletAddress),
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

  Widget _buildPostCard(Post post) {
    return PostCard(post: post);
  }
}

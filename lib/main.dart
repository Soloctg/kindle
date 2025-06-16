import 'package:flutter/material.dart';
import 'package:kindle/src/features/donation/donation_history_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:solana/solana.dart';
import 'package:bip39/bip39.dart' as bip39;
//import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://jszaldpujukgyrufbkan.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpzemFsZHB1anVrZ3lydWZia2FuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk1NzQzMzgsImV4cCI6MjA2NTE1MDMzOH0.4fH0JqZtT7ArlRCrhV2aMfeQLOar2ag3xaabR1s1gBU',
  );
  runApp(const Kindle());
}

class Kindle extends StatelessWidget {
  const Kindle({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Web3 GoFundMe',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const HomeScreen(),
      routes: {'/create-post': (context) => const CreatePostScreen()},
    );
  }
}

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

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'ticker': ticker,
      'description': description,
      'amount_raised': amountRaised,
    };
  }

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
  Ed25519HDKeyPair? wallet;
  String? address;
  final rpcClient = RpcClient("https://api.devnet.solana.com");
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchPosts();
    loadWallet();
  }

  Future<void> fetchPosts() async {
    final response = await Supabase.instance.client.from('posts').select();
    final data = List<Map<String, dynamic>>.from(response);
    setState(() {
      posts = data.map((e) => Post.fromMap(e)).toList();
    });
  }

  Future<void> loadWallet() async {
    final prefs = await SharedPreferences.getInstance();
    final mnemonic = prefs.getString('wallet_mnemonic');
    if (mnemonic != null) {
      final loadedWallet = await Ed25519HDKeyPair.fromMnemonic(mnemonic);
      setState(() {
        wallet = loadedWallet;
        address = loadedWallet.address;
      });
    }
  }

  Future<void> connectWallet() async {
    final mnemonic = bip39.generateMnemonic();
    final newWallet = await Ed25519HDKeyPair.fromMnemonic(mnemonic);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wallet_mnemonic', mnemonic);
    setState(() {
      wallet = newWallet;
      address = newWallet.address;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Connected: $address')));
  }

  Future<void> sendTransaction() async {
    if (wallet == null) return;
    final lamports = lamportsPerSol ~/ 100; // 0.01 SOL
    final recipient = await Ed25519HDKeyPair.random();
    final signature = await rpcClient.requestAirdrop(
      recipient.address,
      lamports,
    );

    // Wait for transaction confirmation
    bool isConfirmed = false;
    while (!isConfirmed) {
      final statuses = await rpcClient.getSignatureStatuses([signature]);
      final confirmation = statuses.value.first;
      if (confirmation != null &&
          confirmation.confirmations != null &&
          confirmation.confirmations! > 0) {
        isConfirmed = true;
      } else {
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Minted and sent 0.01 SOL to: ${recipient.address}'),
      ),
    );
  }

  //Future<void> scanQR() async {
  //  final result = await FlutterBarcodeScanner.scanBarcode(
  //    "#ff6666",
  //    "Cancel",
  //    true,
  //    ScanMode.QR,
  //  );
  //  if (result != '-1') {
  //    ScaffoldMessenger.of(context).showSnackBar(
  //      SnackBar(content: Text('Scanned Wallet Address: $result')),
  //    );
  //  }
  //}

  Future<void> checkBalance() async {
    if (wallet == null) return;
    final balanceResult = await rpcClient.getBalance(address!);
    final balance = balanceResult.value;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Balance: ${balance / lamportsPerSol} SOL')),
    );
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
          IconButton(icon: const Icon(Icons.send), onPressed: sendTransaction),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchPosts,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (address != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome 👋',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Wallet: $address',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.indigo.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.indigo,
                      ),
                      title: const Text('SOL Balance'),
                      subtitle: FutureBuilder<int>(
                        future:
                            address != null
                                ? rpcClient
                                    .getBalance(address!)
                                    .then((result) => result.value)
                                : null,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Text('Loading...');
                          }
                          final sol = snapshot.data! / lamportsPerSol;
                          return Text('$sol SOL');
                        },
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: checkBalance,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed: connectWallet,
                icon: const Icon(Icons.account_balance_wallet),
                label: const Text('Connect Wallet'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.indigo,
                ),
              ),
            ElevatedButton.icon(
              onPressed: _navigateToCreatePost,
              icon: const Icon(Icons.add),
              label: const Text('Create Fundraiser'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Active Fundraisers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...posts.map(
              (post) => Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        post.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(label: Text(post.ticker)),
                          Text(
                            '${post.amountRaised.toStringAsFixed(2)} SOL',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 12,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _ticker = '';
  String _description = '';

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newPost = Post(
        title: _title,
        ticker: _ticker,
        description: _description,
      );
      Navigator.pop(context, newPost);
    }
  }

  Widget _buildCardField({
    required String label,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: TextFormField(
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
          ),
          onSaved: onSaved,
          validator: validator,
          maxLines: maxLines,
          keyboardType: keyboardType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Fundraiser')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildCardField(
                label: 'Title',
                onSaved: (val) => _title = val ?? '',
                validator:
                    (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              _buildCardField(
                label: 'Ticker (e.g. \$HELP)',
                onSaved: (val) => _ticker = val ?? '',
                validator:
                    (val) =>
                        val == null || !val.startsWith('\$')
                            ? 'Must start with \$'
                            : null,
              ),
              _buildCardField(
                label: 'Description',
                onSaved: (val) => _description = val ?? '',
                validator:
                    (val) => val == null || val.isEmpty ? 'Required' : null,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Submit Fundraiser'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

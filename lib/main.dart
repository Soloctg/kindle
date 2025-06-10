import 'package:flutter/material.dart';

void main() => runApp(const Kindle());

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
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Post> posts = [
    Post(
      title: 'Help build a school',
      ticker: '\$SCHOOL',
      description: 'We need funds to build a rural school.',
      amountRaised: 2.5,
    ),
    Post(
      title: 'Medical aid for John',
      ticker: '\$JOHN',
      description: 'John needs surgery funds.',
      amountRaised: 1.2,
    ),
  ];

  void _navigateToCreatePost() async {
    final result = await Navigator.pushNamed(context, '/create-post');
    if (result != null && result is Post) {
      setState(() {
        posts.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web3 GoFundMe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToCreatePost,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(post.title),
              subtitle: Text(post.ticker),
              trailing: Text('${post.amountRaised} SOL'),
            ),
          );
        },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Fundraiser')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                onSaved: (val) => _title = val ?? '',
                validator:
                    (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Ticker (e.g. \$HELP)',
                ),
                onSaved: (val) => _ticker = val ?? '',
                validator:
                    (val) =>
                        val == null || !val.startsWith('\$')
                            ? 'Must start with \$'
                            : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                onSaved: (val) => _description = val ?? '',
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _submit, child: const Text('Submit')),
            ],
          ),
        ),
      ),
    );
  }
}

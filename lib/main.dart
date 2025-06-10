import 'package:flutter/material.dart';

void main() => runApp(Kindle());

class Kindle extends StatelessWidget {
  const Kindle({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Web3 GoFundMe',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: HomeScreen(),
      routes: {'/create-post': (context) => CreatePostScreen()},
    );
  }
}

class HomeScreen extends StatelessWidget {
  //const HomeScreen({Key? key}) : super(key: key);

  // Sample data for demonstration purposes
  // In a real app, this would be fetched from a backend or blockchain
  final List<Map<String, dynamic>> samplePosts = [
    {'title': 'Help build a school', 'ticker': '\$SCHOOL', 'amountRaised': 2.5},
    {'title': 'Medical aid for John', 'ticker': '\$JOHN', 'amountRaised': 1.2},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Web3 GoFundMe'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/create-post'),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: samplePosts.length,
        itemBuilder: (context, index) {
          final post = samplePosts[index];
          return ListTile(
            title: Text(post['title']),
            subtitle: Text(post['ticker']),
            trailing: Text('${post['amountRaised']} SOL'),
          );
        },
      ),
    );
  }
}

class CreatePostScreen extends StatefulWidget {
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
      // Simulate API call or bot notification
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Post Created for \$_ticker!')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Fundraiser')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                onSaved: (val) => _title = val ?? '',
                validator:
                    (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Ticker (e.g. \$HELP)'),
                onSaved: (val) => _ticker = val ?? '',
                validator:
                    (val) =>
                        val == null || !val.startsWith('\$')
                            ? 'Must start with \$'
                            : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                onSaved: (val) => _description = val ?? '',
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _submit, child: Text('Submit')),
            ],
          ),
        ),
      ),
    );
  }
}

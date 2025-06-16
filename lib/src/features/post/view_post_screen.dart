import 'package:flutter/material.dart';
import 'package:kindle/main.dart';

class ViewPostScreen extends StatelessWidget {
  final Post post;

  const ViewPostScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(post.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.ticker,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(post.description),
            const SizedBox(height: 20),
            Text('Amount Raised: ${post.amountRaised} SOL'),
          ],
        ),
      ),
    );
  }
}

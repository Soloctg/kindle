import 'package:flutter/material.dart';

class Post {
  final String title;
  final String ticker;
  final String description;
  final double amountRaised;
  final int tokenAmount;
  final double fundraisingGoal;

  Post({
    required this.title,
    required this.ticker,
    required this.description,
    required this.amountRaised,
    required this.tokenAmount,
    required this.fundraisingGoal,
  });

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      title: map['title'] ?? '',
      ticker: map['ticker'] ?? '',
      description: map['description'] ?? '',
      amountRaised: (map['amount_raised'] ?? 0).toDouble(),
      tokenAmount: (map['token_amount'] ?? 0).toInt(),
      fundraisingGoal: (map['goal'] ?? 100).toDouble(),
    );
  }
}

class PostCard extends StatelessWidget {
  final Post post;
  final void Function(double amount)? onDonate;

  const PostCard({super.key, required this.post, this.onDonate});

  @override
  Widget build(BuildContext context) {
    final progress = (post.amountRaised / post.fundraisingGoal).clamp(0.0, 1.0);

    return Card(
      color: const Color(0xFF1A2D1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(0, 128, 0, 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    post.ticker.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Supply: ${post.tokenAmount} SOL',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              post.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${post.amountRaised.toStringAsFixed(2)} SOL raised',
                  style: const TextStyle(color: Colors.amber),
                ),
                Text(
                  'Goal: ${post.fundraisingGoal.toStringAsFixed(0)} SOL',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Colors.greenAccent,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.favorite),
                label: const Text('Donate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () => _showDonationDialog(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDonationDialog(BuildContext context) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: const Color(0xFF1F3D1F),
            title: const Text(
              'Enter Donation Amount',
              style: TextStyle(color: Colors.white),
            ),
            content: TextField(
              controller: amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Amount in SOL',
                hintStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.greenAccent),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
              TextButton(
                onPressed: () {
                  final value = double.tryParse(amountController.text);
                  if (value == null || value <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Enter a valid amount')),
                    );
                    return;
                  }
                  Navigator.pop(context);
                  onDonate?.call(value);
                },
                child: const Text(
                  'Donate',
                  style: TextStyle(color: Colors.greenAccent),
                ),
              ),
            ],
          ),
    );
  }
}

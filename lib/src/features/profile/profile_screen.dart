import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final String address;

  const ProfileScreen({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Wallet')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Your Solana Wallet Address:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            SelectableText(address, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

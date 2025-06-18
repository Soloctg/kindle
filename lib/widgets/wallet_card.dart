import 'package:flutter/material.dart';

class WalletCard extends StatelessWidget {
  final String walletAddress;
  final int? balance;

  const WalletCard({super.key, required this.walletAddress, this.balance});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const Icon(Icons.account_balance_wallet),
        title: Text('Wallet: $walletAddress'),
        subtitle: Text(
          balance != null ? '$balance SOL' : 'Fetching balance...',
        ),
      ),
    );
  }
}

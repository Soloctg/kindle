import 'package:flutter/material.dart';

class WalletCard extends StatelessWidget {
  final String walletAddress;

  const WalletCard({super.key, required this.walletAddress});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.indigo.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const Icon(Icons.account_balance_wallet, color: Colors.indigo),
        title: const Text('SOL Balance'),
        subtitle: FutureBuilder<int>(
          future: Future.value(0), // Replace with your actual future
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text('Loading...');
            }
            final sol = snapshot.data!;
            return Text('$sol SOL');
          },
        ),
        // trailing: IconButton(
        //   icon: const Icon(Icons.refresh),
        // onPressed: checkBalance,
        //  ),
        // ),
      ),
    );
  }
}

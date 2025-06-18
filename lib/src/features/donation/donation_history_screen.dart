import 'package:flutter/material.dart';
//import 'package:solana/solana.dart';
//import '../../../main.dart'; // adjust the import if Post is defined elsewhere

class DonationHistoryScreen extends StatelessWidget {
  //final Ed25519HDKeyPair keyPair;
  //final RpcClient rpcClient;
  //final Post post;

  const DonationHistoryScreen({
    super.key,
    //required this.keyPair,
    //required this.rpcClient,
    // required this.post,
  });

  //Future<List<String>> _fetchTransactions() async {
  //final signatures = await rpcClient.getSignaturesForAddress(keyPair.address);
  //return signatures.map((e) => e.signature).toList();
  //}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: Text('${post.title} - Donations')),
      body: FutureBuilder<List<String>>(
        future: Future.value(
          [],
        ), // Replace with _fetchTransactions() when implemented
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final transactions = snapshot.data ?? [];
          if (transactions.isEmpty) {
            return const Center(child: Text('No donations found.'));
          }

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final sig = transactions[index];
              return ListTile(
                leading: const Icon(Icons.monetization_on_outlined),
                title: Text('Transaction #${index + 1}'),
                subtitle: Text(sig),
                onTap: () {
                  final url =
                      'https://explorer.solana.com/tx/$sig?cluster=devnet';
                  showDialog(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: const Text('Transaction Link'),
                          content: Text(url),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

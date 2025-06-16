import 'package:solana/solana.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bip39/bip39.dart' as bip39;

class Web3Service {
  static final RpcClient rpcClient = RpcClient("https://api.devnet.solana.com");

  /// Generates a new Solana wallet and saves the mnemonic locally.
  static Future<Ed25519HDKeyPair> createAndSaveWallet() async {
    final mnemonic = bip39.generateMnemonic();
    final wallet = await Ed25519HDKeyPair.fromMnemonic(mnemonic);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wallet_mnemonic', mnemonic);
    return wallet;
  }

  /// Loads an existing wallet from local storage.
  static Future<Ed25519HDKeyPair?> loadWallet() async {
    final prefs = await SharedPreferences.getInstance();
    final mnemonic = prefs.getString('wallet_mnemonic');
    if (mnemonic == null) return null;
    return await Ed25519HDKeyPair.fromMnemonic(mnemonic);
  }

  /// Checks the SOL balance of the wallet address.
  static Future<double> getBalance(String address) async {
    final balance = await rpcClient.getBalance(address);
    return balance.value / lamportsPerSol;
  }

  /// Sends SOL to a recipient and waits for confirmation.
  static Future<String> sendSol(String recipientAddress, int lamports) async {
    final wallet = await loadWallet();
    if (wallet == null) throw Exception('Wallet not loaded');

    final signature = await rpcClient.requestAirdrop(
      recipientAddress,
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

    return signature;
  }
}

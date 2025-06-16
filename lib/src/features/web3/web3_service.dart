// features/web3/web3_service.dart

import 'dart:convert';
import 'package:bip39/bip39.dart';
import 'package:solana/solana.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Web3Service {
  static final Web3Service _instance = Web3Service._internal();
  factory Web3Service() => _instance;
  Web3Service._internal();

  Ed25519HDKeyPair? _wallet;
  late SolanaClient _client;

  final String _walletKey = 'solana_wallet';

  Future<void> init() async {
    _client = SolanaClient(
      rpcUrl: Uri.parse('https://api.devnet.solana.com'),
      websocketUrl: Uri.parse('wss://api.devnet.solana.com'),
    );

    await _loadWalletFromStorage();
  }

  Future<void> _loadWalletFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final mnemonic = prefs.getString(_walletKey);
    if (mnemonic != null) {
      _wallet = await Ed25519HDKeyPair.fromMnemonic(mnemonic);
    }
  }

  Future<void> loginWithNewWallet() async {
    final mnemonic = generateMnemonic();
    _wallet = await Ed25519HDKeyPair.fromMnemonic(mnemonic);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_walletKey, mnemonic);
  }

  Future<void> logoutWallet() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_walletKey);
    _wallet = null;
  }

  String? get walletAddress => _wallet?.address;

  bool get isLoggedIn => _wallet != null;

  Future<int> getBalance() async {
    if (_wallet == null) return 0;
    final balanceResult = await _client.rpcClient.getBalance(_wallet!.address);
    return balanceResult.value;
  }

  Future<String> mintFundraiserToken({
    required String name,
    required String symbol,
    required String description,
    required Uri uri,
  }) async {
    if (_wallet == null) throw Exception('Wallet not logged in');

    // Create a new mint (token)
    final mint = await _client.initializeMint(
      mintAuthority: _wallet!,
      decimals: 0,
    );

    // Get or create the associated token account for the wallet
    final ata = await _client.getAssociatedTokenAccount(
      owner: _wallet!.publicKey,
      mint: mint.address,
    );

    if (ata == null || ata.pubkey == null) {
      throw Exception('Associated token account not found or pubkey is null');
    }

    // Mint 1 token to the associated token account
    await _client.mintTo(
      mint: mint.address,
      destination: Ed25519HDPublicKey.fromBase58(ata.pubkey!),
      amount: 1,
      authority: _wallet!,
    );

    // Store token metadata (off-chain)
    final metadata = {
      'name': name,
      'symbol': symbol,
      'description': description,
      'image': uri.toString(),
      'mint': mint.address,
    };

    // TODO: Upload `metadata` to Supabase or Arweave

    return mint.address.toBase58();
  }

  Future<List<String>> getTransactionHistory() async {
    if (_wallet == null) return [];
    final history = await _client.rpcClient.getSignaturesForAddress(
      _wallet!.address,
    );
    return history.map((e) => e.signature).toList();
  }
}

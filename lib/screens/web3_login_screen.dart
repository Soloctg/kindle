//import 'dart:convert';
//import 'dart:typed_data';

//import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter/material.dart';
//import 'package:shared_preferences/shared_preferences.dart';
//import 'package:solana/solana.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Web3LoginScreen extends StatefulWidget {
  const Web3LoginScreen({super.key});

  @override
  State<Web3LoginScreen> createState() => _Web3LoginScreenState();
}

class _Web3LoginScreenState extends State<Web3LoginScreen> {
  bool _isLoading = false;
  String? _walletAddress;

  //Future<Ed25519HDKeyPair> _getOrCreateWallet() async {
  //  final prefs = await SharedPreferences.getInstance();
  //  final mnemonic = prefs.getString('wallet_mnemonic');

  //  if (mnemonic != null) {
  //    return Ed25519HDKeyPair.fromMnemonic(mnemonic);
  //  }

  //  final newMnemonic = bip39.generateMnemonic();
  //  final wallet = await Ed25519HDKeyPair.fromMnemonic(newMnemonic);
  //  await prefs.setString('wallet_mnemonic', newMnemonic);
  //  return wallet;
  // }

  //Future<String> _signMessage(Ed25519HDKeyPair wallet, String message) async {
  //  final messageBytes = Uint8List.fromList(utf8.encode(message));
  //  final signatureBytes = await wallet.sign(messageBytes);
  //  return base64Encode(signatureBytes.bytes);
  //}

  Future<void> _loginWithWallet() async {
    setState(() => _isLoading = true);
    try {
      //final wallet = await _getOrCreateWallet();
      final message =
          'Login to Web3 GoFundMe @ ${DateTime.now().toIso8601String()}';
      //final signature = await _signMessage(wallet, message);

      // Save wallet login in Supabase (you can use Edge Functions for verification too)
      await Supabase.instance.client.from('wallet_logins').insert({
        //  'address': wallet.address,
        'signed_message': message,
        //  'signature': signature,
      });

      //final prefs = await SharedPreferences.getInstance();
      //await prefs.setString('wallet_address', wallet.address);

      if (!mounted) return;
      //setState(() => _walletAddress = wallet.address);

      //ScaffoldMessenger.of(
      //  context,
      //).showSnackBar(SnackBar(content: Text('Logged in as ${wallet.address}')));

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Web3 Login')),
      body: Center(
        child:
            _isLoading
                ? const CircularProgressIndicator()
                : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _loginWithWallet,
                      icon: const Icon(Icons.account_balance_wallet),
                      label: const Text("Login with Solana Wallet"),
                    ),
                    if (_walletAddress != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Logged in as $_walletAddress',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                  ],
                ),
      ),
    );
  }
}

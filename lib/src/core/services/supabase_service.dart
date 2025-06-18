import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Get the Supabase client
  SupabaseClient get client => _client;

  // --------------------
  // AUTHENTICATION
  // --------------------

  Future<void> signUp(String email, String password) async {
    await _client.auth.signUp(email: email, password: password);
  }

  Future<void> signIn(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Session? getCurrentSession() {
    return _client.auth.currentSession;
  }

  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // --------------------
  // POSTS
  // --------------------

  Future<List<Map<String, dynamic>>> fetchPosts() async {
    return await _client.from('posts').select();
  }

  Future<void> createPost(Map<String, dynamic> postData) async {
    await _client.from('posts').insert(postData);
  }

  // --------------------
  // WALLET / RPC ACCESS (Optional)
  // --------------------

  // Example: Get wallet balance
  Future<int> getWalletBalance(String address) async {
    final result = await _client.rpc(
      'get_balance',
      params: {'address': address},
    );
    return result as int;
  }
}

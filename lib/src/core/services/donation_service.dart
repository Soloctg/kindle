import 'package:kindle/src/features/donation/donation_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
//import 'package:kindle/src/models/donation.dart';

class DonationService {
  final _supabase = Supabase.instance.client;

  /// Create a new donation entry
  Future<void> createDonation(Donation donation) async {
    await _supabase.from('donations').insert(donation.toMap());
  }

  /// Fetch all donations for a specific post ticker
  Future<List<Donation>> getDonationsForPost(String ticker) async {
    final response = await _supabase
        .from('donations')
        .select()
        .eq('post_ticker', ticker)
        .order('timestamp', ascending: false);

    return (response as List)
        .map((e) => Donation.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetch all donations from a specific donor
  Future<List<Donation>> getDonationsFromUser(String walletAddress) async {
    final response = await _supabase
        .from('donations')
        .select()
        .eq('donor_address', walletAddress)
        .order('timestamp', ascending: false);

    return (response as List)
        .map((e) => Donation.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}

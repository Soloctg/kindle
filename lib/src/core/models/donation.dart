class Donation {
  final String id;
  final String postTicker;
  final String donorAddress;
  final double amount;
  final DateTime timestamp;

  Donation({
    required this.id,
    required this.postTicker,
    required this.donorAddress,
    required this.amount,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'post_ticker': postTicker,
      'donor_address': donorAddress,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Donation.fromMap(Map<String, dynamic> map) {
    return Donation(
      id: map['id'],
      postTicker: map['post_ticker'],
      donorAddress: map['donor_address'],
      amount: (map['amount'] as num).toDouble(),
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}

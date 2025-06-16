class Donation {
  final String id;
  final String donorAddress;
  final String postTicker;
  final double amount;
  final DateTime timestamp;

  Donation({
    required this.id,
    required this.donorAddress,
    required this.postTicker,
    required this.amount,
    required this.timestamp,
  });

  factory Donation.fromMap(Map<String, dynamic> map) {
    return Donation(
      id: map['id'] as String,
      donorAddress: map['donor_address'] as String,
      postTicker: map['post_ticker'] as String,
      amount: (map['amount'] as num).toDouble(),
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'donor_address': donorAddress,
      'post_ticker': postTicker,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

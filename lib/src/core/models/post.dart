class Post {
  final String title;
  final String ticker;
  final String description;
  final double amountRaised;

  Post({
    required this.title,
    required this.ticker,
    required this.description,
    this.amountRaised = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'ticker': ticker,
      'description': description,
      'amount_raised': amountRaised,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      title: map['title'],
      ticker: map['ticker'],
      description: map['description'],
      amountRaised: (map['amount_raised'] ?? 0).toDouble(),
    );
  }
}

class Post {
  final String id;
  final String title;
  final String description;
  final double goalAmount;
  final double currentAmount;
  final String userId;

  Post({
    required this.id,
    required this.title,
    required this.description,
    required this.goalAmount,
    required this.currentAmount,
    required this.userId,
  });

  // Convert from JSON
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      goalAmount: json['goalAmount'],
      currentAmount: json['currentAmount'],
      userId: json['userId'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'goalAmount': goalAmount,
      'currentAmount': currentAmount,
      'userId': userId,
    };
  }
}

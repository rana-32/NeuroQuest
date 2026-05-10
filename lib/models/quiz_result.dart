class QuizResult {
  final String id;
  final String userId;
  final String categoryId;
  final int score;
  final int totalQuestions;
  final double percentage;
  final int xpEarned;
  final int completedAt;

  QuizResult({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    required this.xpEarned,
    required this.completedAt,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      id: json['id'] as String,
      userId: json['userId'] as String,
      categoryId: json['categoryId'] as String,
      score: json['score'] as int,
      totalQuestions: json['total'] as int,
      percentage: (json['percentage'] as num).toDouble(),
      xpEarned: json['xpEarned'] as int? ?? 0,
      completedAt: json['completedAt'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'categoryId': categoryId,
      'score': score,
      'total': totalQuestions,
      'percentage': percentage,
      'xpEarned': xpEarned,
      'completedAt': completedAt,
    };
  }
} 
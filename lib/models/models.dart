export 'question.dart';
export 'user_profile.dart';
export 'category.dart';
export 'quiz_result.dart';
export 'badge.dart';

class Quiz {
  final String id;
  final String title;
  final String description;
  final int questionCount;
  final int xpReward;
  final String categoryId;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.questionCount,
    required this.xpReward,
    required this.categoryId,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      questionCount: json['questionCount'],
      xpReward: json['xpReward'],
      categoryId: json['categoryId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'questionCount': questionCount,
      'xpReward': xpReward,
      'categoryId': categoryId,
    };
  }
} 
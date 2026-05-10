class Question {
  final String id;
  final String categoryId;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final int points;
  
  Question({
    required this.id,
    required this.categoryId,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.points,
  });
  
  
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      question: json['question'] as String,
      options: List<String>.from(json['options']),
      correctAnswer: json['correctAnswer'] as String,
      points: json['points'] as int,
    );
  }
  

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'points': points,
    };
  }
  
 
  int get correctAnswerIndex => options.indexOf(correctAnswer);
  
  // Override equality for proper comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Question && 
           other.id == id && 
           other.question == question;
  }
  

  @override
  int get hashCode => id.hashCode ^ question.hashCode;
} 
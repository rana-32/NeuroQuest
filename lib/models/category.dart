class Category {
  final String id;
  final String name;
  final String iconUrl;
  final String description;
  final int quizCount;
  final int requiredLevel;
  final String? color;

  Category({
    required this.id,
    required this.name,
    required this.iconUrl,
    required this.description,
    this.quizCount = 0,
    this.requiredLevel = 1,
    this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      iconUrl: json['iconUrl'] ?? '',
      description: json['description'] ?? '',
      quizCount: json['quizCount'] ?? 0,
      requiredLevel: json['requiredLevel'] ?? 1,
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconUrl': iconUrl,
      'description': description,
      'quizCount': quizCount,
      'requiredLevel': requiredLevel,
      'color': color,
    };
  }
} 
class Badge {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final String category;
  final int requiredScore;
  
  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.category,
    required this.requiredScore,
  });
  
  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconPath: json['iconPath'] as String,
      category: json['category'] as String,
      requiredScore: json['requiredScore'] as int,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconPath': iconPath,
      'category': category,
      'requiredScore': requiredScore,
    };
  }
} 
class UserProfile {
  final String uid;
  final String name;
  final int age;
  final int xp;
  final List<String> badges;
  final Map<String, Map<String, int>> progress;

  UserProfile({
    required this.uid,
    required this.name,
    required this.age,
    required this.xp,
    required this.badges,
    required this.progress,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final progressData = json['progress'] as Map<String, dynamic>? ?? {};
    final Map<String, Map<String, int>> progressMap = {};
    
    progressData.forEach((String category, dynamic value) {
      if (value is Map) {
        final innerMap = <String, int>{};
        (value).forEach((dynamic k, dynamic v) {
          if (k is String && v is int) {
            innerMap[k] = v;
          } else if (k is String) {
            // Try to convert to int if possible
            innerMap[k] = int.tryParse(v.toString()) ?? 0;
          }
        });
        progressMap[category] = innerMap;
      }
    });
    
    return UserProfile(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      xp: json['xp'] ?? 0,
      badges: List<String>.from(json['badges'] ?? []),
      progress: progressMap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'age': age,
      'xp': xp,
      'badges': badges,
      'progress': progress,
    };
  }

  UserProfile copyWith({
    String? uid,
    String? name,
    int? age,
    int? xp,
    List<String>? badges,
    Map<String, Map<String, int>>? progress,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      age: age ?? this.age,
      xp: xp ?? this.xp,
      badges: badges ?? this.badges,
      progress: progress ?? this.progress,
    );
  }
} 
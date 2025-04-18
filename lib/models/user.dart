class User {
  final String id;
  final String fullName;
  final bool isPremium;

  User({
    required this.id,
    required this.fullName,
    required this.isPremium,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['userId'],
      fullName: json['fullName'],
      isPremium: json['isPremium'] ?? false,
    );
  }
}
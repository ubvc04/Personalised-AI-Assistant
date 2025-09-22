class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final bool isVerified;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.isVerified,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    bool? isVerified,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'isVerified': isVerified,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      isVerified: json['isVerified'] ?? false,
    );
  }
}
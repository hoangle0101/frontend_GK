class User {
  final String id;
  final String username;
  final String email;
  final String password;
  final String image;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    this.image = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'image': image,
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? password,
    String? image,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      image: image ?? this.image,
    );
  }
}
class AppUser {
  final String id;
  final String name;
  final String email;
  final String career;       // Ej: Ingeniería de Sistemas, Derecho
  final String profilePic;   // URL de su foto de perfil

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.career,
    this.profilePic = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'career': career,
      'profilePic': profilePic,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      career: map['career'] ?? '',
      profilePic: map['profilePic'] ?? '',
    );
  }
}
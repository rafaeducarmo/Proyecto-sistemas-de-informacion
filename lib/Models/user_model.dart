class AppUser {
  final String id;
  final String name;
  final String email;
  final String career;
  final String profilePic;
  final String role; // <-- NUEVO: 'student' o 'admin'

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.career,
    this.profilePic = '',
    this.role = 'student', // Por defecto todos son estudiantes
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'career': career,
      'profilePic': profilePic,
      'role': role, // <-- Guardar el rol
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      career: map['career'] ?? '',
      profilePic: map['profilePic'] ?? '',
      role: map['role'] ?? 'student', // <-- Leer el rol (si no existe, es student)
    );
  }
}
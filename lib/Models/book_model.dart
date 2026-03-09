class Book {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final String category;
  final String condition;
  final String imageUrl;
  final String status;
  final DateTime createdAt;

  Book({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.category,
    required this.condition,
    required this.imageUrl,
    this.status = 'Disponible',
    required this.createdAt,
  });

  // 1. Empaqueta los datos para enviarlos a Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'category': category,
      'condition': condition,
      'imageUrl': imageUrl,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // 2. Desempaqueta los datos cuando vienen de Firebase
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] ?? '',
      ownerId: map['ownerId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      condition: map['condition'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      status: map['status'] ?? 'Disponible',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
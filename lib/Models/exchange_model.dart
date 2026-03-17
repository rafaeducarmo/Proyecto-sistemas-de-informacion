class Exchange {
  final String id;
  final String bookId;        // El ID del libro que se está pidiendo
  final String requesterId;   // El ID del estudiante que quiere el libro
  final String ownerId;       // El ID del dueño del libro
  final String status;        // Ej: Pendiente, Aceptado, Rechazado, Completado
  final DateTime requestDate;
  final DateTime? startDate;  // Fecha de inicio solicitada
  final DateTime? endDate;    // Fecha final solicitada

  Exchange({
    required this.id,
    required this.bookId,
    required this.requesterId,
    required this.ownerId,
    this.status = 'Pendiente', 
    required this.requestDate,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId,
      'requesterId': requesterId,
      'ownerId': ownerId,
      'status': status,
      'requestDate': requestDate.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }

  factory Exchange.fromMap(Map<String, dynamic> map) {
    return Exchange(
      id: map['id'] ?? '',
      bookId: map['bookId'] ?? '',
      requesterId: map['requesterId'] ?? '',
      ownerId: map['ownerId'] ?? '',
      status: map['status'] ?? 'Pendiente',
      requestDate: DateTime.parse(map['requestDate']),
      startDate: map['startDate'] != null ? DateTime.parse(map['startDate']) : null,
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
    );
  }
}
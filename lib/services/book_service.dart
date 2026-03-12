import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/book_model.dart';

class BookService {
  // Inicializamos la conexión con la base de datos
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. FUNCIÓN PARA SUBIR UN LIBRO NUEVO
  Future<void> createBook(Book book) async {
    try {
      // Va a la colección 'books', crea un documento con el ID del libro, y guarda el "paquete" (toMap)
      await _db.collection('books').doc(book.id).set(book.toMap());
    } catch (e) {
      // Si algo falla (ej. no hay internet), lanzamos un error para avisarle a la pantalla
      throw Exception('Error al guardar el material: $e');
    }
  }

  // 2. FUNCIÓN PARA DESCARGAR TODOS LOS LIBROS (Para el inicio de la app)
  // Usamos un Stream para que se actualice en tiempo real si alguien sube uno nuevo
  Stream<List<Book>> getBooksStream() {
    return _db.collection('books').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Book.fromMap(doc.data());
      }).toList();
    });
  }
}

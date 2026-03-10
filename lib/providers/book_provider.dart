import 'dart:io';
import 'package:flutter/material.dart';
// Rutas exactas basadas en tu árbol de carpetas
import '../Models/book_model.dart';
import '../services/book_service.dart';
import '../services/storage_service.dart';

class BookProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final StorageService _storageService = StorageService();
  final BookService _bookService = BookService();

  // Función conectada a tus modelos y servicios
  Future<bool> uploadBook({
    required String title,
    required String description, // Cambiado para coincidir con tu Book model
    required String category,
    required String condition,
    required File imageFile,
    required String ownerId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Generamos un nombre único para la foto usando la fecha y hora actual
      String fileName = 'book_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // 2. Subimos la imagen usando el método exacto de tu StorageService
      String imageUrl = await _storageService.uploadBookImage(
        imageFile,
        fileName,
      );

      // 3. Generamos un ID único para el documento en Firestore
      String bookId = DateTime.now().millisecondsSinceEpoch.toString();

      // 4. Creamos el objeto instanciando tu clase Book
      Book newBook = Book(
        id: bookId,
        ownerId: ownerId,
        title: title,
        description: description,
        category: category,
        condition: condition,
        imageUrl: imageUrl,
        status: 'Disponible',
        createdAt: DateTime.now(),
      );

      // 5. Guardamos en Firestore (Asegúrate de tener un método addBook en book_service.dart)
      // Descomenta la siguiente línea cuando tu BookService tenga la función lista
      await _bookService.createBook(newBook);

      _isLoading = false;
      notifyListeners();
      return true; // Todo fue un éxito
    } catch (e) {
      print("Error en provider: $e");
      _isLoading = false;
      notifyListeners();
      return false; // Hubo un fallo
    }
  }
}

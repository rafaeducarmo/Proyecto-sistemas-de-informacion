import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../Models/book_model.dart';
import '../services/book_service.dart';
import '../services/storage_service.dart';

class BookProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final StorageService _storageService = StorageService();
  final BookService _bookService = BookService();

  Future<bool> uploadBook({
    required String title,
    required String description, 
    required String category,
    required String condition,
    required Uint8List imageBytes, // <-- Cambiado de File a Uint8List
    required String ownerId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      String fileName = 'book_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Pasamos los bytes al Storage
      String imageUrl = await _storageService.uploadBookImage(
        imageBytes,
        fileName,
      );

      String bookId = DateTime.now().millisecondsSinceEpoch.toString();

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

      await _bookService.createBook(newBook);

      _isLoading = false;
      notifyListeners();
      return true; 
    } catch (e) {
      print("Error en provider: $e");
      _isLoading = false;
      notifyListeners();
      return false; 
    }
  }
}
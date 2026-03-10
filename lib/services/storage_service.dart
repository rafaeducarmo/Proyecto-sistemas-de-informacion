import 'dart:typed_data'; // <-- Importante para los bytes
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Ahora recibe Uint8List (bytes) en vez de File
  Future<String> uploadBookImage(Uint8List imageBytes, String fileName) async {
    try {
      Reference ref = _storage.ref().child('book_images').child(fileName);
      
      // Usamos putData para que funcione en Web y Móvil
      UploadTask uploadTask = ref.putData(imageBytes); 

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
      
    } catch (e) {
      throw Exception('Error al subir la imagen: $e');
    }
  }
}
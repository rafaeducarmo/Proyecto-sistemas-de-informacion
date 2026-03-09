import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  // Inicializamos la conexión con el almacén de Firebase
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Función para subir la foto y obtener el link de descarga
  Future<String> uploadBookImage(File imageFile, String fileName) async {
    try {
      // 1. Le decimos a Firebase dónde guardar la foto (en una carpeta llamada 'book_images')
      Reference ref = _storage.ref().child('book_images').child(fileName);

      // 2. Empezamos a subir el archivo físico
      UploadTask uploadTask = ref.putFile(imageFile);

      // 3. Esperamos pacientemente a que la barra de carga llegue al 100%
      TaskSnapshot snapshot = await uploadTask;

      // 4. Le pedimos a Firebase el link público de la foto que acabamos de subir
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Devolvemos el link para que el resto de la app lo use
      return downloadUrl;
      
    } catch (e) {
      throw Exception('Error al subir la imagen: $e');
    }
  }
}
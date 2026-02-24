import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Validación UNIMET: Solo permite correos institucionales 
  bool _esCorreoValido(String email) => email.toLowerCase().endsWith('@unimet.edu.ve');

  Future<String?> iniciarSesion(String email, String password) async {
    if (!_esCorreoValido(email)) return "Usa tu correo @unimet.edu.ve"; 
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Éxito
    } catch (e) {
      return "Error: Datos incorrectos o usuario no registrado";
    }
  }
}
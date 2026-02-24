import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Validación UNIFICADA
  bool _esCorreoValido(String email) {
    final emailLimpio = email.trim().toLowerCase();
    return emailLimpio.endsWith('@correo.unimet.edu.ve') || 
           emailLimpio.endsWith('@unimet.edu.ve');
  }

  Future<String?> iniciarSesion(String email, String password) async {
    if (!_esCorreoValido(email)) return "Usa tu correo @unimet.edu.ve"; 
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Error desconocido al iniciar sesión";
    }
  }

  Future<String?> registrarEstudiante(String email, String password) async {
    // 1. Validamos correo
    if (!_esCorreoValido(email)) {
      return "Acceso denegado: Solo correos @unimet.edu.ve";
    }
    
    // 2. Intentamos registro
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(), 
        password: password.trim()
      );
      return null; 
    } on FirebaseAuthException catch (e) {
      // Esto nos dirá si el servicio está apagado en la consola
      if (e.code == 'operation-not-allowed') {
        return "Error: Debes habilitar Email/Password en la consola de Firebase.";
      }
      return e.message ?? "Error de Firebase al registrar";
    } catch (e) {
      return "Error inesperado: $e";
    }
  }
}
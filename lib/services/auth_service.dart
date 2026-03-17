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
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return "Correo o contraseña incorrectos.";
      }
      return "Error al iniciar sesión.";
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
      } else if (e.code == 'email-already-in-use') {
        return "El correo ya está registrado.";
      } else if (e.code == 'weak-password') {
        return "La contraseña es demasiado débil.";
      } else if (e.code == 'invalid-email') {
        return "El formato del correo es inválido.";
      }
      return "Error de Firebase al registrar.";
    } catch (e) {
      return "Error inesperado: $e";
    }
  }

  // Método para cambiar la contraseña
  Future<String?> cambiarContrasena(String oldPassword, String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user != null && user.email != null) {
        // Re-autenticar al usuario
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: oldPassword,
        );

        await user.reauthenticateWithCredential(credential);

        // Actualizar la contraseña
        await user.updatePassword(newPassword);
        return null; // Éxito
      } else {
        return "No hay un usuario activo.";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
         return "La contraseña actual es incorrecta.";
      } else if (e.code == 'weak-password') {
         return "La nueva contraseña es demasiado débil.";
      }
      return "Error al cambiar la contraseña.";
    } catch (e) {
      return "Error inesperado: $e";
    }
  }
}
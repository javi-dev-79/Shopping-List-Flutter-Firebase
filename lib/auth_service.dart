import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:flutter_application_3/bottom_nav_bar.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static bool isLoggedIn = false;
  final Logger _logger = Logger();

  // Método para registrar un usuario con correo electrónico y contraseña
  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      _logger.i('Usuario $email creado correctamente');
      return user;
    } catch (e) {
      _logger.e('Error al registrar el usuario: $e');
      return null;
    }
  }

  // Future<bool> signInWithEmailAndPassword(String email, String password) async {
  //   try {
  //     UserCredential result = await _auth.signInWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //     User? user = result.user;
  //     return user != null;
  //   } catch (e) {
  //     _logger.e('Error al iniciar sesión: $e');
  //     return false;
  //   }
  // }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // Si el usuario no es null, la autenticación fue exitosa
        // Establecemos isLoggedIn en true y devolvemos true
        isLoggedIn = true;
        return true;
      } else {
        // Si el usuario es null, la autenticación falló
        return false;
      }
    } catch (e) {
      _logger.e('Error al iniciar sesión: $e');
      return false;
    }
  }

  // Método para cerrar sesión
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      _logger.e('Error al cerrar sesión: $e');
    }
  }

  // Método para restablecer la contraseña
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      _logger.e('Error al restablecer la contraseña: $e');
    }
  }

  // Otros métodos de autenticación según sea necesario para tu aplicación

  // Método para verificar el estado de autenticación
  static Future<bool> checkAuthStatus() async {
    try {
      User? user = _auth.currentUser;
      isLoggedIn = user != null;
      return isLoggedIn;
    } catch (e) {
      // Manejo de errores si ocurren al verificar el estado de autenticación
      print('Error al verificar el estado de autenticación: $e');
      return false;
    }
  }
}

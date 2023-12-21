import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
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

  // // Método para iniciar sesión con correo electrónico y contraseña
  // Future<User?> signInWithEmailAndPassword(
  //   String email,
  //   String password,
  // ) async {
  //   try {
  //     UserCredential result = await _auth.signInWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //     User? user = result.user;
  //     _logger.i('Se ha logueado el user: $email');
  //     return user;
  //   } catch (e) {
  //     _logger.e('Error al iniciar sesión: $e');
  //     return null;
  //   }
  // }

  void signInWithEmailAndPassword(String email, String password) {
    FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: email,
      password: password,
    )
        .then((UserCredential userCredential) {
      _logger.i('User signed in: ${userCredential.user!.email}');
    }).catchError((error) {
      if (error.code == 'user-not-found') {
        _logger.i('There is no user with that email.');
      }

      if (error.code == 'invalid-email') {
        _logger.i('That email address is invalid.');
      }
      _logger.e(error);
    });
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
}

import 'package:firebase_database/firebase_database.dart';

class User {
  late String key; // La clave única asignada por Firebase Realtime Database
  late String email;
  late String pass;

  User(this.email, this.pass);

  // Método para convertir un User a un mapa que se puede guardar en Firebase
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'pass': pass,
    };
  }

  // Método para convertir un mapa de Firebase en un User
  User.fromSnapshot(DataSnapshot snapshot) {
    key = snapshot.key ?? '';
    final value = snapshot.value as Map<dynamic, dynamic>?;

    if (value != null) {
      email = value['email'] as String? ?? '';
      pass = value['pass'] as String? ?? '';
    } else {
      email = '';
      pass = '';
    }
  }
}

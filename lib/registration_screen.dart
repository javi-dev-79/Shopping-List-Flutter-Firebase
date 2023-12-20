import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

// import 'constants.dart';
import 'list_users_screen.dart';

import 'package:firebase_database/firebase_database.dart';

class RegistrationScreen extends StatelessWidget {
  final TextEditingController _registrationTextEditingController =
      TextEditingController();

  final TextEditingController _registrationEmailEditingController =
      TextEditingController();

  final Color _registrationCursorColor = Colors.orange;

  final FocusNode _emailFocusNode = FocusNode();

  final Logger logger = Logger();

  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  RegistrationScreen({Key? key}) : super(key: key);

  // Future<http.Response> registerUser(String email, String pass) async {
  //   // final url = Uri.parse(
  //   //     'http://$host:3000/users'); // Reemplaza con la URL de tu servidor JSON
  //   final url =
  //       Uri.parse('http://$host:3000/users'); // Actualiza la URL a "db.json"

  //   final response = await http.post(url, body: {
  //     'email': email,
  //     'pass': pass,
  //   });

  //   return response;
  // }

  Future<void> registerUser(String email, String pass) async {
    try {
      await dbRef.child('users').push().set({
        'email': email,
        'password': pass,
      });
      // Registro exitoso
      logger.d('Usuario registrado exitosamente');
    } catch (e) {
      // Manejo de errores
      logger.e('Error al registrar el usuario: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _registrationTextEditingController,
              cursorColor: _registrationCursorColor,
              decoration: const InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.orange),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange),
                ),
              ),
              autofocus:
                  true, // Esta línea coloca el cursor por defecto en el campo "Usuario"
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _registrationEmailEditingController,
              cursorColor: _registrationCursorColor,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                labelStyle: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.orange),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final email = _registrationTextEditingController.text;
                final pass = _registrationEmailEditingController.text;

                await registerUser(email, pass);

                // if (response.statusCode == 201) {
                //   logger.d('Usuario registrado con éxito');
                //   // Navegar de nuevo a la pantalla de inicio de sesión después de un registro exitoso
                //   // Navigator.of(context).push(
                //   //   MaterialPageRoute(
                //   //     builder: (context) => LoginScreen(),
                //   //   ),
                //   // );
                // } else {
                //   logger.e(
                //       'Error al registrar el usuario. Código de estado: ${response.statusCode}');
                // }
                // Borra los campos TextField
                _registrationTextEditingController.clear();
                _registrationEmailEditingController.clear();

                // Enfoca nuevamente el campo 'Usuario'
                _emailFocusNode.requestFocus();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.orange),
              ),
              child: const Text('Registrarse'),
            ),
            const SizedBox(
                height:
                    10), // Espacio entre el botón "Registrarse" y el enlace "Eliminar"
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const UserListScreen(),
                  ),
                );
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

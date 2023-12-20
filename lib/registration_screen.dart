import 'package:flutter/material.dart';
import 'package:flutter_application_3/auth_service.dart';
import 'package:logger/logger.dart';
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

  AuthService authService = AuthService();

  RegistrationScreen({Key? key}) : super(key: key);

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

                await authService.registerWithEmailAndPassword(email, pass);

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

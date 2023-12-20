import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'constants.dart';
import 'registration_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _usuarioTextEditingController =
      TextEditingController();
  final TextEditingController _emailTextEditingController =
      TextEditingController();
  final Color _cursorColor = Colors.blueGrey;
  final FocusNode _usuarioFocusNode = FocusNode();

  LoginScreen({Key? key}) : super(key: key);

  Future<http.Response> fetchUsers() async {
    final url = Uri.parse('http://$host:3000/users'); // Reemplaza con tu URL
    final response = await http.get(url);
    return response;
  }

  Future<void> _performLogin(BuildContext context) async {
    final usuario = _usuarioTextEditingController.text;
    final email = _emailTextEditingController.text;

    final response = await fetchUsers();
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      bool credentialsMatch = false;

      for (var userData in jsonData) {
        final String name = userData['name'];
        final String userEmail = userData['email'];

        if (name == usuario && userEmail == email) {
          credentialsMatch = true;
          break;
        }
      }

      if (credentialsMatch) {
        // Navigator.pop(context, true);
        Navigator.of(context).pop(
            true); // Esto regresará a la pantalla anterior, que es la privada
      } else {
        _showErrorMessage(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al obtener usuarios')),
      );
    }
  }

  void _showErrorMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Usuario desconocido'),
          content: const Text('Las credenciales ingresadas no son válidas.'),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange, // Color del texto del botón
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio de Sesión'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usuarioTextEditingController,
              cursorColor: _cursorColor,
              decoration: const InputDecoration(
                labelText: 'Usuario',
                labelStyle: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange),
                ),
              ),
              // focusNode: _usuarioFocusNode,
              autofocus:
                  true, // Esta línea coloca el cursor por defecto en el campo "Usuario"
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailTextEditingController,
              cursorColor: _cursorColor,
              decoration: const InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _performLogin(context);
                _usuarioTextEditingController.clear(); // Borra el campo Usuario
                _emailTextEditingController.clear(); // Borra el campo Email

                // Enfoca nuevamente el campo 'Usuario'
                _usuarioFocusNode.requestFocus();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.orange),
              ),
              child: const Text('Iniciar Sesión'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => RegistrationScreen(),
                  ),
                );
              },
              child: const Text(
                'Registrarse',
                style: TextStyle(
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
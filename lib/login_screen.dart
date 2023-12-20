// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// import 'constants.dart';
// import 'registration_screen.dart';

// class LoginScreen extends StatelessWidget {
//   final TextEditingController _usuarioTextEditingController =
//       TextEditingController();
//   final TextEditingController _emailTextEditingController =
//       TextEditingController();
//   final Color _cursorColor = Colors.blueGrey;
//   final FocusNode _usuarioFocusNode = FocusNode();

//   LoginScreen({Key? key}) : super(key: key);

//   Future<http.Response> fetchUsers() async {
//     final url = Uri.parse('http://$host:3000/users'); // Reemplaza con tu URL
//     final response = await http.get(url);
//     return response;
//   }

//   Future<void> _performLogin(BuildContext context) async {
//     final usuario = _usuarioTextEditingController.text;
//     final pass = _emailTextEditingController.text;

//     final response = await fetchUsers();
//     if (response.statusCode == 200) {
//       final List<dynamic> jsonData = jsonDecode(response.body);
//       bool credentialsMatch = false;

//       for (var userData in jsonData) {
//         final String name = userData['name'];
//         final String userEmail = userData['email'];

//         if (name == usuario && userEmail == pass) {
//           credentialsMatch = true;
//           break;
//         }
//       }

//       if (credentialsMatch) {
//         // Navigator.pop(context, true);
//         Navigator.of(context).pop(
//             true); // Esto regresará a la pantalla anterior, que es la privada
//       } else {
//         _showErrorMessage(context);
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Error al obtener usuarios')),
//       );
//     }
//   }

//   void _showErrorMessage(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Usuario desconocido'),
//           content: const Text('Las credenciales ingresadas no son válidas.'),
//           actions: [
//             TextButton(
//               style: TextButton.styleFrom(
//                 foregroundColor: Colors.orange, // Color del texto del botón
//               ),
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: const Text('Aceptar'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Inicio de Sesión'),
//         backgroundColor: Colors.orange,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//               controller: _usuarioTextEditingController,
//               cursorColor: _cursorColor,
//               decoration: const InputDecoration(
//                 labelText: 'Usuario',
//                 labelStyle: TextStyle(
//                   color: Colors.orange,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 focusedBorder: UnderlineInputBorder(
//                   borderSide: BorderSide(color: Colors.orange),
//                 ),
//               ),
//               // focusNode: _usuarioFocusNode,
//               autofocus:
//                   true, // Esta línea coloca el cursor por defecto en el campo "Usuario"
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: _emailTextEditingController,
//               cursorColor: _cursorColor,
//               decoration: const InputDecoration(
//                 labelText: 'Email',
//                 labelStyle: TextStyle(
//                   color: Colors.orange,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 focusedBorder: UnderlineInputBorder(
//                   borderSide: BorderSide(color: Colors.orange),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 _performLogin(context);
//                 _usuarioTextEditingController.clear(); // Borra el campo Usuario
//                 _emailTextEditingController.clear(); // Borra el campo Email

//                 // Enfoca nuevamente el campo 'Usuario'
//                 _usuarioFocusNode.requestFocus();
//               },
//               style: ButtonStyle(
//                 backgroundColor: MaterialStateProperty.all(Colors.orange),
//               ),
//               child: const Text('Iniciar Sesión'),
//             ),
//             const SizedBox(height: 10),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (context) => RegistrationScreen(),
//                   ),
//                 );
//               },
//               child: const Text(
//                 'Registrarse',
//                 style: TextStyle(
//                   color: Colors.orange,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// ****************************************************************************************

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'registration_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Logger _logger = Logger();

  LoginScreen({Key? key}) : super(key: key);

  Future<void> _performLogin(String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        _logger.d(
            'Inicio de sesión exitoso para el usuario ${userCredential.user!.email}');
      } else {
        _logger.e('Credenciales incorrectas');
      }
    } on FirebaseAuthException catch (e) {
      _logger.e('Error al iniciar sesión: ${e.message}');
    }
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
              controller: _emailController,
              cursorColor: Colors.blueGrey,
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
              autofocus: true,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              cursorColor: Colors.blueGrey,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
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
                String email = _emailController.text;
                String password = _passwordController.text;
                _performLogin(email, password);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.orange),
              ),
              child: const Text('Iniciar Sesión'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                // Navigate to registration screen
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

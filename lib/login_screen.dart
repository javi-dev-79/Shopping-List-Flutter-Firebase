import 'package:flutter/material.dart';
import 'package:flutter_application_3/auth_service.dart';
import 'package:flutter_application_3/bottom_nav_bar.dart';
import 'package:flutter_application_3/registration_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService authService = AuthService();

  LoginScreen({super.key});

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
              onPressed: () async {
                String email = _emailController.text;
                String password = _passwordController.text;

                bool isLoggedIn = await authService.signInWithEmailAndPassword(
                    email, password);

                if (isLoggedIn) {
                  AuthService.isLoggedIn = true;
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) =>
                          const MyBottomNavigationBar(selectedIndex: 1),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Credenciales incorrectas. Por favor, inténtelo de nuevo.'),
                    ),
                  );
                }
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


import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'private_screen.dart';
import 'public_screen.dart';

class MyBottomNavigationBar extends StatefulWidget {
  const MyBottomNavigationBar({super.key});

  @override
  _MyBottomNavigationBarState createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  int _selectedIndex = 0; // Índice de la página seleccionada
  bool loggedIn = false; // Estado de inicio de sesión

  @override
  void initState() {
    super.initState();
    // Inicializa el estado de inicio de sesión como falso
    loggedIn = false;
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (_selectedIndex == 0) {
      body = const PublicScreen();
    } else {
      body = loggedIn ? const PrivateScreen() : const PublicScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Aplicación'),
        backgroundColor: Colors.orange,
        actions: <Widget>[
          if (!loggedIn)
            IconButton(
              icon: const Icon(Icons.login),
              onPressed: _handleLoginButton,
            ),
          if (loggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed:
                  _handleLogoutButton, // Agregamos el manejador de cierre de sesión
            ),
        ],
      ),
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: 'Pública',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lock),
            label: 'Privada',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      if (index == 1 && !loggedIn) {
        // El usuario selecciona "Privada" pero no está logueado
        Navigator.of(context)
            .push(
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        )
            .then((result) {
          if (result == true) {
            setState(() {
              loggedIn = true;
              _selectedIndex = 1; // Cambia a la pantalla "Privada"
            });
          }
        });
      } else {
        _selectedIndex = index;
      }
    });
  }

  void _handleLoginButton() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    )
        .then((result) {
      if (result == true) {
        setState(() {
          loggedIn = true;
          if (loggedIn) {
            _selectedIndex = 1; // Cambia a la pantalla "Privada"
          }
        });
      }
    });
  }

  void _handleLogoutButton() {
    // Realiza la lógica de cierre de sesión (cambia el estado de loggedIn, redirige, etc.)
    // Luego, muestra un SnackBar con el mensaje de confirmación.

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Has cerrado sesión, hasta luego...'),
      ),
    );

    // Después de cerrar sesión, establece loggedIn como false y el índice seleccionado según tu lógica.
    setState(() {
      loggedIn = false;
      _selectedIndex =
          0; // Cambia a la pantalla "Pública" u otra pantalla inicial
    });
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_application_3/auth_service.dart';
import 'login_screen.dart';
import 'private_screen.dart';
import 'public_screen.dart';

class MyBottomNavigationBar extends StatefulWidget {
  final int selectedIndex;

  const MyBottomNavigationBar({super.key, required this.selectedIndex});

  @override
  _MyBottomNavigationBarState createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  int _selectedIndex = 0; // Índice de la página seleccionada

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    // Inicializa el estado de inicio de sesión como falso
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Aplicación'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              // Aquí debes implementar la lógica para realizar el logout
              _performLogout();
            },
          ),
        ],
      ),
      body: _getBody(),
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

  Widget _getBody() {
    if (_selectedIndex == 1 && AuthService.isLoggedIn) {
      return const PrivateScreen();
    } else {
      return const PublicScreen();
    }
  }

  void _onItemTapped(int index) {
    // _logger.i('El estado en onItemTapped es: ${AuthService.isLoggedIn}');
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 1 && !AuthService.isLoggedIn) {
        Navigator.of(context)
            .push(
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        )
            .then((result) {
          if (result == true) {
            setState(() {
              AuthService.isLoggedIn = true;
            });
          }
        });
      }
    });
  }

  void _performLogout() {
    AuthService.logout(); // Ejemplo: cómo podrías llamar a un método logout
    // Navigator.of(context).push(MaterialPageRoute(
    //   builder: (context) => LoginScreen(),
    // ));
    // Navega a la pantalla de inicio o pantalla lógica después del logout
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AuthService.isLoggedIn ? const PrivateScreen() : const PublicScreen(),
      ),
    );
  }
}

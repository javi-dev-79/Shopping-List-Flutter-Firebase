import 'package:flutter/material.dart';
import 'package:flutter_application_3/firebase_options.dart';
import 'bottom_nav_bar.dart';
import 'package:firebase_core/firebase_core.dart'; // Importa el paquete de Firebase

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MaterialApp(
      theme: ThemeData(
        unselectedWidgetColor:
            Colors.orange, // Color del checkbox no seleccionado
        // Otros ajustes de estilo que desees aplicar a toda la aplicación
      ),
      home: const MyApp(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyBottomNavigationBar(
          selectedIndex: 0), // Establece el índice por defecto
      debugShowCheckedModeBanner: false,
    );
  }
}

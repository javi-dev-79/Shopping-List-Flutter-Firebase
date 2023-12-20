// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'bottom_nav_bar.dart';
// import 'package:firebase_core/firebase_core.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized(); // Asegúrate de que Flutter esté inicializado

//   await dotenv.load(
//       fileName: ".env"); // Carga las variables de entorno desde el archivo .env

//   await Firebase.initializeApp(); // Inicializa Firebase

//   runApp(
//     MaterialApp(
//       theme: ThemeData(
//         unselectedWidgetColor:
//             Colors.orange, // Color del checkbox no seleccionado
//         // Otros ajustes de estilo que desees aplicar a toda la aplicación
//       ),
//       home: const MyApp(),
//       debugShowCheckedModeBanner: false,
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: MyBottomNavigationBar(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// ****************************************************************************


import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'bottom_nav_bar.dart';
import 'package:firebase_core/firebase_core.dart'; // Importa el paquete de Firebase

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegúrate de que Flutter esté inicializado
  await dotenv.load(
    fileName: ".env",
  ); // Carga las variables de entorno desde el archivo .env
  await Firebase.initializeApp(); // Inicializa Firebase

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
      home: MyBottomNavigationBar(),
      debugShowCheckedModeBanner: false,
    );
  }
}



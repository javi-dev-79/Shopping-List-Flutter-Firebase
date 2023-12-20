// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:logger/logger.dart';

// import 'constants.dart';
// import 'user.dart';

// class UserListScreen extends StatefulWidget {
//   const UserListScreen({Key? key}) : super(key: key);

//   @override
//   _UserListScreenState createState() => _UserListScreenState();
// }

// class _UserListScreenState extends State<UserListScreen> {
//   List<User> users = [];
//   List<bool> selectedUsers = [];

//   final Logger logger = Logger();

//   @override
//   void initState() {
//     super.initState();
//     // Inicializa la lista de usuarios con datos de users.json
//     fetchUsers();
//   }

//   Future<void> fetchUsers() async {
//     final response = await http.get(Uri.parse(
//         'http://$host:3000/users')); // Reemplaza con la URL de tu servidor JSON

//     if (response.statusCode == 200) {
//       final List<dynamic> jsonData = jsonDecode(response.body);
//       setState(() {
//         users = jsonData.map((user) => User.fromJson(user)).toList();
//         selectedUsers = List.generate(users.length, (index) => false);
//       });
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Error al obtener usuarios')),
//       );
//     }
//   }

//   Future<void> eliminarUsuarioDelArchivo(int userId) async {
//     final file = File('users.json');
//     final content = await file.readAsString();
//     final usuarios = jsonDecode(content);

//     // Encuentra y elimina el usuario del archivo
//     usuarios.removeWhere((usuario) => usuario['id'] == userId);

//     // Escribe los usuarios actualizados en el archivo
//     await file.writeAsString(jsonEncode(usuarios));
//   }

//   Future<void> eliminarUsuariosEnServidor(List<int> usuariosAEliminar) async {
//     for (int userId in usuariosAEliminar) {
//       final url = Uri.parse(
//           'http://$host:3000/users/$userId'); // URL para eliminar el usuario por ID
//       final response = await http.delete(url);

//       if (response.statusCode == 204) {
//         logger.d('Usuario con ID $userId eliminado con éxito');
//       } else {
//         logger.e(
//             'Error al eliminar el usuario con ID $userId. Código de estado: ${response.statusCode}');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Lista de Usuarios'),
//         backgroundColor: Colors.orange,
//       ),
//       body: ListView.builder(
//         itemCount: users.length,
//         itemBuilder: (context, index) {
//           final user = users[index];
//           return ListTile(
//             leading: Checkbox(
//               activeColor: Colors.orange,
//               value: selectedUsers[index],
//               onChanged: (value) {
//                 setState(() {
//                   selectedUsers[index] = value!;
//                 });
//               },
//             ),
//             title: Text(
//                 'ID: ${user.id}, Usuario: ${user.name}, Email: ${user.email}'),
//           );
//         },
//       ),
//       bottomNavigationBar: BottomAppBar(
//         child: ElevatedButton(
//           onPressed: () {
//             List<int> usuariosAEliminar = [];

//             for (int i = 0; i < selectedUsers.length; i++) {
//               if (selectedUsers[i]) {
//                 usuariosAEliminar.add(users[i].id);
//               }
//             }

//             eliminarUsuariosEnServidor(usuariosAEliminar);

//             // Elimina usuarios seleccionados de la lista
//             for (int i = usuariosAEliminar.length - 1; i >= 0; i--) {
//               final userId = usuariosAEliminar[i];
//               users.removeWhere((user) => user.id == userId);
//               selectedUsers.removeAt(i);
//             }

//             // Establece todos los elementos en selectedUsers en false
//             selectedUsers = List.generate(users.length, (index) => false);

//             setState(() {});
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.orange,
//           ),
//           child: const Text(
//             'Eliminar',
//             style: TextStyle(
//               color: Colors.white,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// ************************************************************************

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'user.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<User> users = [];
  List<bool> selectedUsers = [];

  final Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    // Inicializa la lista de usuarios con datos de users.json
    fetchUsersFromFirebase();
  }

  Future<void> fetchUsersFromFirebase() async {
    final usersRef = FirebaseDatabase.instance.ref().child('users');
    usersRef.onValue.listen((event) {
      DataSnapshot snapshot = event.snapshot;
      dynamic data = snapshot.value;

      if (data != null && data is Map<dynamic, dynamic>) {
        List<User> fetchedUsers = [];
        data.forEach((key, value) {
          fetchedUsers.add(User.fromJson(value));
        });
        setState(() {
          users = fetchedUsers;
          selectedUsers = List.generate(users.length, (index) => false);
        });
      }
    }, onError: (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al obtener usuarios')),
      );
    });
  }

  Future<void> eliminarUsuariosEnFirebase(List<int> usuariosAEliminar) async {
    final usersRef = FirebaseDatabase.instance.ref().child('users');
    for (int userId in usuariosAEliminar) {
      usersRef.child(userId.toString()).remove().then((_) {
        logger.d('Usuario con ID $userId eliminado con éxito');
      }).catchError((error) {
        logger.e('Error al eliminar el usuario con ID $userId: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Usuarios'),
        backgroundColor: Colors.orange,
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            leading: Checkbox(
              activeColor: Colors.orange,
              value: selectedUsers[index],
              onChanged: (value) {
                setState(() {
                  selectedUsers[index] = value!;
                });
              },
            ),
            title: Text(
                'ID: ${user.id}, Usuario: ${user.email}, Email: ${user.pass}'),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: ElevatedButton(
          onPressed: () {
            List<int> usuariosAEliminar = [];

            for (int i = 0; i < selectedUsers.length; i++) {
              if (selectedUsers[i]) {
                usuariosAEliminar.add(users[i].id);
              }
            }

            eliminarUsuariosEnFirebase(usuariosAEliminar);

            // Elimina usuarios seleccionados de la lista
            for (int i = usuariosAEliminar.length - 1; i >= 0; i--) {
              final userId = usuariosAEliminar[i];
              users.removeWhere((user) => user.id == userId);
              selectedUsers.removeAt(i);
            }

            // Establece todos los elementos en selectedUsers en false
            selectedUsers = List.generate(users.length, (index) => false);

            setState(() {});
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
          ),
          child: const Text(
            'Eliminar',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

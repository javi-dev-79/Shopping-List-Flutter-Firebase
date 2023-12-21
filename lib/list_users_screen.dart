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
  List<Map<dynamic, dynamic>> userList = [];

  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    // Inicializa la lista de usuarios con datos de firebase
    // fetchUsersFromFirebase();
    fetchUsers();
  }

  void fetchUsers() {
    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users');

    usersRef.onValue.listen((event) {
      _logger.i('PASA AQUÍ');
      if (event.snapshot.value != null) {
        List<dynamic>? usersData = event.snapshot.value as List<dynamic>?;

        if (usersData != null) {
          setState(() {
            userList = usersData.cast<Map<dynamic, dynamic>>().toList();
          });

          _logger.i('Lista de usuarios: $userList');
        }
      }
    }, onError: (error) {
      _logger.e('Error al obtener usuarios: $error');
    });
  }

  // Future<void> fetchUsersFromFirebase() async {
  //   final usersRef = FirebaseDatabase.instance.ref().child('users');
  //   usersRef.onValue.listen((event) {
  //     DataSnapshot snapshot = event.snapshot;
  //     dynamic data = snapshot.value;

  //     if (data != null && data is Map<dynamic, dynamic>) {
  //       List<User> fetchedUsers = [];
  //       data.forEach((key, value) {
  //         fetchedUsers.add(User.fromSnapshot(value));
  //       });
  //       setState(() {
  //         users = fetchedUsers;
  //         selectedUsers = List.generate(users.length, (index) => false);
  //       });
  //     }
  //   }, onError: (error) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Error al obtener usuarios')),
  //     );
  //   });
  // }

  Future<void> eliminarUsuariosEnFirebase(List<int> usuariosAEliminar) async {
    final usersRef = FirebaseDatabase.instance.ref().child('users');
    for (int userId in usuariosAEliminar) {
      usersRef.child(userId.toString()).remove().then((_) {
        _logger.d('Usuario con ID $userId eliminado con éxito');
      }).catchError((error) {
        _logger.e('Error al eliminar el usuario con ID $userId: $error');
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
        itemCount: userList.length,
        itemBuilder: (context, index) {
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
            title: Text(userList[index]['email'] ?? 'Sin email'),
            subtitle: Text(userList[index]['pass'] ?? 'Sin password'),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: ElevatedButton(
          onPressed: () {
            List<int> usuariosAEliminar = [];

            for (int i = 0; i < selectedUsers.length; i++) {
              if (selectedUsers[i]) {
                usuariosAEliminar.add(int.parse(users[i].key));
              }
            }

            eliminarUsuariosEnFirebase(usuariosAEliminar);

            // Elimina usuarios seleccionados de la lista
            for (int i = usuariosAEliminar.length - 1; i >= 0; i--) {
              final userId = usuariosAEliminar[i];
              users.removeWhere((user) => user.key == userId.toString());
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

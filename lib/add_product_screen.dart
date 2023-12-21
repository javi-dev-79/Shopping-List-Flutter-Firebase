import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'product.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key, required this.actualizarListaProductos});

  final Function(Product) actualizarListaProductos;

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  final DatabaseReference _productRef =
      FirebaseDatabase.instance.ref().child('products');

  String? priceError;
  String? quantityError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Producto'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextFormField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Categoría'),
              ),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Precio'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un precio';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Cantidad'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una cantidad';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_validateFields()) {
                    _saveProduct();
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.orange),
                ),
                child: const Text('Guardar Producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _validateFields() {
    bool isValid = true;

    if (priceController.text.isEmpty) {
      setState(() {
        priceError = 'Por favor ingresa un precio';
      });
      isValid = false;
    } else {
      setState(() {
        priceError = null;
      });
    }

    if (quantityController.text.isEmpty) {
      setState(() {
        quantityError = 'Por favor ingresa una cantidad';
      });
      isValid = false;
    } else {
      setState(() {
        quantityError = null;
      });
    }

    return isValid;
  }

  void _saveProduct() {
    final String name = nameController.text;
    final String category = categoryController.text;
    final double price = double.parse(priceController.text);
    final int quantity = int.parse(quantityController.text);

    final newProductRef = _productRef.push();
    newProductRef.set({
      'name': name,
      'category': category,
      'price': price,
      'quantity': quantity,
      'selected': false,
    }).then((_) {
      Navigator.pop(context, true);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar el producto')),
      );
    });
  }

  Future<int> getNextProductId() async {
    final DatabaseEvent event =
        await _productRef.once(); // Referencia al nodo de productos en Firebase
    int lastId = 0;

    final dynamic snapshotValue =
        event.snapshot.value; // Obtén el valor del snapshot

    if (snapshotValue is Map<dynamic, dynamic>) {
      final Map<dynamic, dynamic> products =
          snapshotValue; // Asigna el valor a un mapa

      products.forEach((key, value) {
        final int productId =
            int.tryParse(key) ?? 0; // Intenta obtener el ID del producto
        if (productId > lastId) {
          lastId = productId;
        }
      });
    }

    return lastId + 1; // Retorna el siguiente ID
  }
}

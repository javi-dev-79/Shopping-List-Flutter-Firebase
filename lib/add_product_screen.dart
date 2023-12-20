
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'product.dart';
import 'utils.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key, required this.actualizarListaProductos});

  final Function(Product) actualizarListaProductos; // Agregamos esta función

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  // campos y controladores para el formulario
  final TextEditingController nameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

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
          // formulario con los campos Nombre, Categoría, Precio y Cantidad
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
                  final parsedValue = Utils.parseDouble(value);
                  if (parsedValue == null) {
                    return 'Dato incorrecto'; // Mensaje de error si no se puede analizar a double
                  }
                  return null; // No hay error
                },
              ),
              if (priceError != null)
                Text(
                  priceError!,
                  style: const TextStyle(color: Colors.red),
                ),
              TextFormField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Cantidad'),
                validator: (value) {
                  final parsedValue = Utils.parseInt(value);
                  if (parsedValue == null) {
                    return 'Dato incorrecto'; // Mensaje de error si no se puede analizar a int
                  }
                  return null; // No hay error
                },
              ),
              if (quantityError != null)
                Text(
                  quantityError!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final double? parsedPrice =
                      Utils.parseDouble(priceController.text);
                  final int? parsedQuantity =
                      Utils.parseInt(quantityController.text);

                  if (parsedPrice == null) {
                    setState(() {
                      priceError = 'Dato incorrecto';
                    });
                  } else {
                    setState(() {
                      priceError = null;
                    });
                  }

                  if (parsedQuantity == null) {
                    setState(() {
                      quantityError = 'Dato incorrecto';
                    });
                  } else {
                    setState(() {
                      quantityError = null;
                    });
                  }

                  if (parsedPrice != null && parsedQuantity != null) {
                    _saveProduct(); // Llama al método _saveProduct para guardar el producto.
                    Navigator.pop(context,
                        true); // Cierra la pantalla de agregar producto después de guardar.
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

  void _saveProduct() async {
    final String name = nameController.text;
    final String category = categoryController.text;
    final double price = Utils.parseDouble(priceController.text)!;
    final int quantity = Utils.parseInt(quantityController.text)!;

    final Map<String, dynamic> productData = {
      "name": name,
      "category": category,
      "price": price,
      "quantity": quantity,
      "selected": false, // Agregar "selected" con valor predeterminado false
    };

    final response = await http.post(
      Uri.parse('http://$host:3000/products'), // Reemplaza con la URL correcta
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(productData),
    );

    if (response.statusCode == 201) {
      // Producto guardado exitosamente
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar el producto')),
      );
    }

    final newProductId =
        await getNextProductId(); // Espera a que se resuelva la función asíncrona

    // Crear un objeto Product con los detalles proporcionados por el usuario
    final newProduct = Product(
      id: newProductId, // Debes implementar getNextProductId para generar un ID único
      name: name,
      category: category,
      price: price,
      quantity: quantity,
      selected:
          false, // Opcional: establece el valor predeterminado de selected
    );

    widget.actualizarListaProductos(newProduct);
  }

  Future<int> getNextProductId() async {
    final response = await http.get(Uri.parse('http://$host:3000/products'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      // Encontrar el último ID utilizado en la lista de productos
      int lastId = 0;
      for (final productData in jsonData) {
        final int productId = productData['id'] as int;
        if (productId > lastId) {
          lastId = productId;
        }
      }
      // El siguiente ID será el último ID + 1
      return lastId + 1;
    } else {
      // Si hay un error en la solicitud, puedes manejarlo de acuerdo a tus necesidades
      throw Exception('Error al obtener productos');
    }
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'add_product_screen.dart';
import 'constants.dart';
import 'edit_product_screen.dart';
import 'product.dart';

class PrivateScreen extends StatefulWidget {
  const PrivateScreen({Key? key}) : super(key: key);

  @override
  _PrivateScreenState createState() => _PrivateScreenState();
}

class _PrivateScreenState extends State<PrivateScreen> {
  List<Product> products = [];

  final Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final response = await http.get(Uri.parse('http://$host:3000/products'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);

      setState(() {
        products = jsonData.map((json) {
          final double price = json['price'] is int
              ? (json['price'] as int).toDouble()
              : json['price'] is String
                  ? double.tryParse(json['price']) ?? 0.0
                  : 0.0;

          final int quantity = json['quantity'] is int
              ? json['quantity'] as int
              : json['quantity'] is String
                  ? int.tryParse(json['quantity']) ?? 0
                  : 0;

          final bool selected = json['selected'] is bool
              ? json['selected'] as bool
              : json['selected'] is String
                  ? json['selected'].toLowerCase() == 'true'
                  : false;

          return Product(
            id: json['id'] as int,
            name: json['name'] as String,
            category: json['category'] as String,
            price: price,
            quantity: quantity,
            selected: selected,
          );
        }).toList();
      });

      // Registra los productos en el logger
      for (final product in products) {
        logger.d(
            'Producto: ${product.name}, Categoría: ${product.category}, Precio: ${product.price}, Cantidad: ${product.quantity}, Selected: ${product.selected}');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al obtener productos')),
      );
    }
  }

  void actualizarListaProductos(Product nuevoProducto) {
    setState(() {
      products.add(nuevoProducto);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ListTile(
                    leading: Checkbox(
                      activeColor: Colors.orange,
                      value: product
                          .selected, // Asigna el valor de 'selected' al Checkbox
                      onChanged: (value) async {
                        setState(() {
                          product.selected = value!;
                          _updateProduct(
                              product); // Aquí debes implementar la lógica para actualizar en el servidor
                        });

                        // Realiza una solicitud HTTP POST para actualizar el estado "selected" en el servidor
                        final url = Uri.parse(
                            'http://$host:3000/products/${product.id}');
                        final response = await http.post(
                          url,
                          headers: {"Content-Type": "application/json"},
                          body: jsonEncode({"selected": product.selected}),
                        );

                        if (response.statusCode != 200) {
                          // Ocurrió un error, puedes manejarlo aquí
                          setState(() {
                            // Revierte el cambio local en caso de error
                            product.selected = value!;
                          });
                        }
                      },
                    ),
                    title: Text(
                      'Nombre: ${product.name}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Categoría: ${product.category}'),
                        Text('Precio: ${product.price.toStringAsFixed(2)}€'),
                        Text('Cantidad: ${product.quantity.toString()}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Color.fromARGB(255, 24, 152, 211),
                          ),
                          onPressed: () {
                            _editProduct(product);
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Color.fromARGB(255, 226, 76, 66),
                          ),
                          onPressed: () {
                            _deleteProduct(product.id);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {
                    fetchProducts();
                  },
                  icon: const Icon(
                    IconData(0xe514, fontFamily: 'MaterialIcons'),
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {
                    _addProduct();
                  },
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateProduct(Product product) async {
    // Create a Map with the updated product data, setting 'selected' to the new value.
    final updatedProductData = {
      'id': product.id,
      'name': product.name,
      'category': product.category,
      'price': product.price,
      'quantity': product.quantity,
      'selected': product.selected, // Set the 'selected' value.
    };

    final url = Uri.parse('http://$host:3000/products/${product.id}');
    final response = await http.put(
      url,
      body: json.encode(updatedProductData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Product was updated successfully.
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating the product')),
      );
    }
  }

  Future<void> _addProduct() async {
    // Implementa la lógica para agregar un producto
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductScreen(
          actualizarListaProductos: actualizarListaProductos,
        ),
      ),
    ).then((value) {
      setState(() {});
    });
    // Guarda el producto y luego actualiza la lista
    await fetchProducts();
  }

  void _editProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(product: product),
      ),
    ).then((updatedProduct) {
      if (updatedProduct != null) {
        // Actualiza el producto en la lista o realiza cualquier acción necesaria
        // Puedes hacer esto en base a los datos de updatedProduct
        setState(() {
          // Busca el producto en la lista y actualiza sus datos
          final index = products.indexWhere((p) => p.id == updatedProduct.id);
          if (index != -1) {
            products[index] = updatedProduct;
          }
        });
      }
    });
  }

  void _deleteProduct(int productId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content:
              const Text('¿Estás seguro de que deseas eliminar este producto?'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _performDelete(productId);
                fetchProducts();
              },
              child: const Text('Eliminar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void callFetchProducts() async {
    fetchProducts();
  }

  Future<void> _performDelete(int productId) async {
    final url = Uri.parse('http://$host:3000/products/$productId');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      // El producto se eliminó con éxito, puedes realizar alguna acción adicional si es necesario
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar el producto')),
      );
    }
  }
}
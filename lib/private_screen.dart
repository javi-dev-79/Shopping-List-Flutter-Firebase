import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';
import 'product.dart';

import 'package:firebase_database/firebase_database.dart';

class PrivateScreen extends StatefulWidget {
  const PrivateScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PrivateScreenState createState() => _PrivateScreenState();
}

class _PrivateScreenState extends State<PrivateScreen> {
  late DatabaseReference _productRef;

  List<Product> products = [];

  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _productRef = FirebaseDatabase.instance.ref().child('products');
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final productsRef = FirebaseDatabase.instance.ref().child('products');

    productsRef.onValue.listen((event) {
      final snapshot = event.snapshot;

      if (snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final List<Product> fetchedProducts = [];

        data.forEach((key, value) {
          final double price = value['price'] is int
              ? (value['price'] as int).toDouble()
              : value['price'] is String
                  ? double.tryParse(value['price']) ?? 0.0
                  : 0.0;

          final int quantity = value['quantity'] is int
              ? value['quantity'] as int
              : value['quantity'] is String
                  ? int.tryParse(value['quantity']) ?? 0
                  : 0;

          final bool selected = value['selected'] is bool
              ? value['selected'] as bool
              : value['selected'] is String
                  ? value['selected'].toLowerCase() == 'true'
                  : false;

          fetchedProducts.add(
            Product(
              id: key,
              name: value['name'] as String,
              category: value['category'] as String,
              price: price,
              quantity: quantity,
              selected: selected,
            ),
          );
        });

        setState(() {
          products = fetchedProducts;
        });
      }
    }, onError: (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al obtener productos')),
      );
    });

    return Future.value();
  }

  void actualizarListaProductos(Product nuevoProducto) {
    setState(() {
      products.add(nuevoProducto);
    });

    _productRef.push().set({
      'name': nuevoProducto.name,
      'category': nuevoProducto.category,
      'price': nuevoProducto.price,
      'quantity': nuevoProducto.quantity,
      'selected': nuevoProducto.selected,
    }).then((_) {
      _logger.i('Producto agregado exitosamente a Firebase.');
    }).catchError((error) {
      _logger.e('Error al agregar el producto a Firebase: $error');
      // Maneja errores si la adición del producto falla
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
                      value: product.selected,
                      onChanged: (value) {
                        setState(() {
                          product.selected = value!;
                          _updateProduct(product);
                        });
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
                          onPressed: () async {
                            FirebaseDatabase.instance.ref().child('products');

                            final DatabaseReference productRef =
                                FirebaseDatabase.instance
                                    .ref()
                                    .child('products')
                                    .child(product.id);

                            _deleteProduct(productRef);

                            _logger.i('El producto es: $productRef');
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

  void _updateProduct(Product product) {
    _productRef.child(product.id.toString()).set({
      'name': product.name,
      'category': product.category,
      'price': product.price,
      'quantity': product.quantity,
      'selected': product.selected,
    });
  }

  void _addProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductScreen(
          // Pasa la función de actualización de lista al widget de agregar producto
          actualizarListaProductos: actualizarListaProductos,
        ),
      ),
    );
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
        actualizarListaProductos;
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

  void _deleteProduct(DatabaseReference productRef) {
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
                await productRef.remove().then((_) {
                  setState(() {
                    products.removeWhere(
                        (product) => product.id == productRef.key.toString());
                  });
                  _logger.i('Producto eliminado exitosamente de Firebase.');
                }).catchError((error) {
                  _logger
                      .e('Error al eliminar el producto de Firebase: $error');
                  // Manejar errores si la eliminación del producto falla
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Error al eliminar el producto')),
                  );
                });
                Navigator.pop(context);
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
}

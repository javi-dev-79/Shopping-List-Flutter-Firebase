import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'product.dart';

class PublicScreen extends StatefulWidget {
  const PublicScreen({super.key});

  @override
  _PublicScreenState createState() => _PublicScreenState();
}

class _PublicScreenState extends State<PublicScreen> {
  late DatabaseReference _productRef;
  List<Product> selectedProducts = [];

  @override
  void initState() {
    super.initState();
    _productRef = FirebaseDatabase.instance.ref().child('products');
    fetchSelectedProducts();
  }

  Future<void> fetchSelectedProducts() async {
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

        if (selected) {
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
        }
      });

      setState(() {
        selectedProducts = fetchedProducts;
      });
    }
  }, onError: (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error al obtener productos')),
    );
  });

  // Agrega un return al final para cumplir con la firma de Future<void>
  return Future.value();
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: selectedProducts.isEmpty
          ? const Center(child: Text('No hay productos seleccionados'))
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.builder(
                itemCount: selectedProducts.length,
                itemBuilder: (context, index) {
                  final product = selectedProducts[index];
                  return ListTile(
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
                        Text(
                          'Precio: ${product.price.toStringAsFixed(2)} €',
                        ),
                        Text('Cantidad: ${product.quantity.toString()}'),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}

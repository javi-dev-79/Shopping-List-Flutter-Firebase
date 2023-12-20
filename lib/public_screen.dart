import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'constants.dart';
import 'product.dart';

class PublicScreen extends StatefulWidget {
  const PublicScreen({Key? key}) : super(key: key);

  @override
  _PublicScreenState createState() => _PublicScreenState();
}

class _PublicScreenState extends State<PublicScreen> {
  List<Product> selectedProducts = [];

  @override
  void initState() {
    super.initState();
    fetchSelectedProducts();
  }

  Future<void> fetchSelectedProducts() async {
    final response = await http.get(Uri.parse('http://$host:3000/products'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      final products = jsonData.map((product) {
        // Verifica si el valor es String y luego intenta convertirlo a double
        final price = product['price'] is String
            ? double.tryParse(product['price']) ?? 0.0
            : (product['price'] is int
                ? product['price'].toDouble()
                : product['price'].toDouble());

        // Convierte quantity a double en lugar de int
        final quantity = product['quantity'] is String
            ? int.tryParse(product['quantity']) ?? 0
            : product['quantity'];

        // Convierte selected a bool
        final selected = product['selected'] is String
            ? product['selected'].toLowerCase() == 'true'
            : product['selected'];

        return Product(
          id: product['id'],
          name: product['name'],
          category: product['category'],
          price: price,
          quantity: quantity, // Ahora es de tipo double
          selected: selected,
        );
      }).toList();

      setState(() {
        selectedProducts =
            products.where((product) => product.selected).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al obtener productos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: selectedProducts.isEmpty
          ? const Center(child: Text('No hay productos seleccionados'))
          : Padding(
              padding: const EdgeInsets.all(
                  10.0), // Agregar un padding de 10 píxeles
              child: ListView.builder(
                itemCount: selectedProducts.length,
                itemBuilder: (context, index) {
                  final product = selectedProducts[index];
                  return ListTile(
                    title: Text(
                      'Nombre: ${product.name}',
                      style: const TextStyle(
                        fontWeight: FontWeight
                            .bold, // Mostrar el campo "nombre" en negrita
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Categoría: ${product.category}'),
                        Text(
                            'Precio: ${product.price.toStringAsFixed(2)} €'), // Agregar el símbolo €
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
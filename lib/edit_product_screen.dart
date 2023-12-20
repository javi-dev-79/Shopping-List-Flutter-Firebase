
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'constants.dart';
import 'product.dart';
import 'utils.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({Key? key, required this.product}) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  final Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    // Llena los controladores de texto con los datos del producto actual
    _nameController.text = widget.product.name;
    _categoryController.text = widget.product.category;
    _priceController.text = widget.product.price.toStringAsFixed(2);
    _quantityController.text = widget.product.quantity.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Producto'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Precio',
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final String name = _nameController.text;
                final String category = _categoryController.text;
                final String priceText = _priceController.text;
                final String quantityText = _quantityController.text;

                if (name.isEmpty || category.isEmpty) {
                  return;
                }

                final double? price = Utils.parseDouble(priceText);
                final int? quantity = Utils.parseInt(quantityText);

                if (price == null ||
                    price <= 0 ||
                    quantity == null ||
                    quantity <= 0) {
                  return;
                }

                final updatedProduct = Product(
                  id: widget.product.id,
                  name: name,
                  category: category,
                  price: price,
                  quantity: quantity,
                  selected: widget.product.selected,
                );

                updateProductInList(updatedProduct);

                Navigator.pop(context, updatedProduct);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.orange),
              ),
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }

  Future<http.Response> updateProductInList(Product product) async {
    final url = Uri.parse('http://$host:3000/products/${product.id}');

    logger.i('El id del producto es: ${product.id}');

    // Convierte el precio y la cantidad a números si son cadenas
    final double price = product.price is String
        ? double.parse(product.price as String)
        : product.price;
    final int quantity = product.quantity is String
        ? int.parse(product.quantity as String)
        : product.quantity;

    final response = await http.put(url, body: {
      'name': product.name,
      'category': product.category,
      'price': price.toString(),
      'quantity': quantity.toString(),
      'selected': product.selected.toString(),
    });

    return response;
  }
}
import 'package:firebase_database/firebase_database.dart';

class Product {
  final String id; // Cambio el tipo de id a String
  final String name;
  final String category;
  final double price;
  final int quantity;
  bool selected;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.quantity = 0,
    this.selected = false,
  });

factory Product.fromSnapshot(DataSnapshot snapshot) {
  Map<dynamic, dynamic>? json = snapshot.value as Map<dynamic, dynamic>?; // Conversión explícita
  json ??= {}; // Si el valor es nulo, se asigna un mapa vacío para evitar problemas

  return Product(
    id: snapshot.key ?? '', // Usamos snapshot.key para el ID
    name: json['name'] ?? '',
    category: json['category'] ?? '',
    price: (json['price'] ?? 0).toDouble(),
    quantity: json['quantity'] ?? 0,
    selected: json['selected'] ?? false,
  );
}

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'quantity': quantity,
      'selected': selected,
    };
  }

  void setSelected(bool value) {
    selected = value;
  }
}

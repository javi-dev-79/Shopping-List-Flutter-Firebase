class Product {
  final int id;
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

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
        id: json['id'],
        name: json['name'],
        category: json['category'],
        price: json['price'].toDouble(),
        quantity: json['quantity'],
        selected: json['selected']);
  }

  void setSelected(bool value) {
    selected = value;
  }
}
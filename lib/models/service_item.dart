class ServiceItem {
  String name;
  double price;
  int qty;

  ServiceItem({required this.name, required this.price, required this.qty});

  ServiceItem copyWith({String? name, double? price, int? qty}) {
    return ServiceItem(
      name: name ?? this.name,
      price: price ?? this.price,
      qty: qty ?? this.qty,
    );
  }
}

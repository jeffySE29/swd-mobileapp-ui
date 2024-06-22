class Dish {
  final String name;
  final String imageUrl;
  final int quantity;

  Dish({
    required this.name,
    required this.imageUrl,
    required this.quantity,
  });
}

class Order {
  final String area;
  final String tableNumber;
  final String note;
  final List<Dish> dishes;

  Order({
    required this.area,
    required this.tableNumber,
    required this.note,
    required this.dishes,
  });
}

Future<List<Order>> fetchOrders() async {
  // Giả lập API để fetch orders
  await Future.delayed(const Duration(seconds: 2));
  return sampleOrders;
}

List<Order> sampleOrders = [
  Order(
    area: 'A',
    tableNumber: '1',
    note: 'First Order',
    dishes: [
      Dish(
          name: 'Dish 1',
          imageUrl: 'https://via.placeholder.com/50',
          quantity: 2),
      Dish(
          name: 'Dish 2',
          imageUrl: 'https://via.placeholder.com/50',
          quantity: 1),
    ],
  ),
  Order(
    area: 'B',
    tableNumber: '2',
    note: 'Second Order',
    dishes: [],
  ),
];

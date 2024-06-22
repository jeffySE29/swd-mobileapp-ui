class FoodItem {
  final String name;
  final String category;
  final String imageUrl;
  final int price;

  FoodItem({
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.price,
  });
}

Future<List<FoodItem>> fetchFoodItems() async {
  // Đây là API giả, bạn sẽ cần thay thế bằng API thật của bạn
  await Future.delayed(Duration(seconds: 2));
  return sampleFoodItems;
}

List<FoodItem> sampleFoodItems = [
  FoodItem(
    name: 'Steamed Dumplings',
    category: 'Steam',
    imageUrl: 'https://via.placeholder.com/150',
    price: 10000,
  ),
  FoodItem(
    name: 'Grilled Chicken',
    category: 'Grill',
    imageUrl: 'https://via.placeholder.com/150',
    price: 20000,
  ),
  FoodItem(
    name: 'Beef Hotpot',
    category: 'Hotpot',
    imageUrl: 'https://via.placeholder.com/150',
    price: 15000,
  ),
  FoodItem(
    name: 'Caesar Salad',
    category: 'Salad',
    imageUrl: 'https://via.placeholder.com/150',
    price: 12000,
  ),
  FoodItem(
    name: 'Steamed Fish',
    category: 'Steam',
    imageUrl: 'https://via.placeholder.com/150',
    price: 18000,
  ),
  FoodItem(
    name: 'Grilled Pork',
    category: 'Grill',
    imageUrl: 'https://via.placeholder.com/150',
    price: 22000,
  ),
  FoodItem(
    name: 'Vegetable Hotpot',
    category: 'Hotpot',
    imageUrl: 'https://via.placeholder.com/150',
    price: 30000,
  ),
];

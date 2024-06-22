import 'package:flutter/material.dart';
import '../datas/menu_data.dart'; // Import lớp FoodItem và fetchFoodItems

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<FoodItem> _foodItems = [];
  List<FoodItem> _filteredFoodItems = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterFoodItems);
    _fetchFoodItems();
  }

  void _fetchFoodItems() async {
    try {
      List<FoodItem> foodItems = await fetchFoodItems();
      setState(() {
        _foodItems = foodItems;
        _filteredFoodItems = foodItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _foodItems = sampleFoodItems;
        _filteredFoodItems = sampleFoodItems;
        _isLoading = false;
      });
    }
  }

  void _filterFoodItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFoodItems = _foodItems.where((foodItem) {
        return foodItem.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _filterByCategory(String category) {
    setState(() {
      _filteredFoodItems = _foodItems.where((foodItem) {
        return foodItem.category == category;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue[100],
        title: const Center(
          child: Text(
            "Menu page",
            textAlign: TextAlign.center,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search food',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCategoryButton(Icons.air_outlined, 'Steam'),
                _buildCategoryButton(Icons.fireplace_sharp, 'Grill'),
                _buildCategoryButton(Icons.hot_tub, 'Hotpot'),
                _buildCategoryButton(Icons.add_business_sharp, 'Salad'),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredFoodItems.isEmpty
                      ? const Center(child: Text('No food items found'))
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: _filteredFoodItems.length,
                          itemBuilder: (context, index) {
                            final foodItem = _filteredFoodItems[index];
                            return _buildFoodItem(foodItem);
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context); // Back to HomePage
        },
        child: const Icon(Icons.home),
        backgroundColor: Colors.blue[100],
      ),
    );
  }

  Widget _buildCategoryButton(IconData icon, String category) {
    return IconButton(
      onPressed: () {
        _filterByCategory(category);
      },
      icon: Icon(icon),
      tooltip: category,
    );
  }

  Widget _buildFoodItem(FoodItem foodItem) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.network(
              foodItem.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            foodItem.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${foodItem.price} VND',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          ElevatedButton(
            onPressed: () {
              // Add food item to order logic
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.all(8.0),
              minimumSize: Size(double.infinity, 36),
            ),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

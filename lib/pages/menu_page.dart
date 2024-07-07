import 'package:flutter/material.dart';
import '../datas/menu_data.dart'; // Import lớp Category và fetchMenu từ menu_data.dart

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<Category> _categories = [];
  List<Product> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterProducts);
    _fetchMenu(); // Gọi hàm _fetchMenu() trong initState để fetch dữ liệu ban đầu
  }

  void _fetchMenu() async {
    try {
      Menu menu = Menu();
      List<Category> categories =
          await menu.fetchMenu(); // Gọi fetchMenu() từ menu_data.dart
      List<Product> products = [];

      // Lấy tất cả các sản phẩm từ các danh mục
      categories.forEach((category) {
        products.addAll(category.products);
      });

      setState(() {
        _categories = categories;
        _filteredProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching menu: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _categories
          .expand((category) => category.products)
          .where((product) => product.productName.toLowerCase().contains(query))
          .toList();
    });
  }

  void _filterByCategory(Category category) {
    setState(() {
      _filteredProducts = category.products;
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
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFaa4b6b),
                Color(0xFF6b6b83),
                Color(0xFF3b8d99),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Center(
          child: Text(
            "Menu",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
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
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _categories
                  .map((category) => _buildCategoryButton(category))
                  .toList(),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredProducts.isEmpty
                      ? const Center(child: Text('No food items found'))
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = _filteredProducts[index];
                            return _buildProductItem(product);
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: [
          Align(
            alignment: Alignment.bottomLeft,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pop(context); // Back to HomePage
              },
              backgroundColor: Colors.blue[100],
              child: const Icon(Icons.home),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton(
              onPressed: () {
                // Logic for save action
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Save success'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.blue[100], // Nền màu xanh nhạt
              ),
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(Category category) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 3 -
          16, // Adjust the width based on screen size
      child: ElevatedButton(
        onPressed: () {
          _filterByCategory(category);
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.amber[200], // Text color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Text(category.categoryName),
      ),
    );
  }

  Widget _buildProductItem(Product product) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.blue[50],
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
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      color: Colors
                          .white, // Đặt màu nền của ảnh trong border là trắng
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 110,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 1.0),
              ],
            ),
          ),
          const SizedBox(height: 1.0),
          Text(
            product.productName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text('Price: ',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  )),
              const SizedBox(width: 8),
              Text('${product.price} VND',
                  style: const TextStyle(color: Colors.black))
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Add food item to order logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[200], // Background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    minimumSize: const Size(double.infinity, 36),
                  ),
                  child: const Icon(Icons.add, color: Colors.black),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Add food item to order logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[200], // Background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    minimumSize: const Size(double.infinity, 36),
                  ),
                  child: const Icon(Icons.remove, color: Colors.black),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

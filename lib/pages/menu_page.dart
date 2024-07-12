import 'package:flutter/material.dart';
import 'package:swd_group_project/pages/order_detail_page.dart';
import '../datas/menu_data.dart'; // Import Category and fetchMenu from menu_data.dart
import 'package:another_flushbar/flushbar.dart';
import '../datas/user_data.dart';

class MenuPage extends StatefulWidget {
  final String areaName;
  final String tableId;
  final String tableName;
  final String orderId;
  final User user;

  MenuPage({
    super.key,
    required this.areaName,
    required this.tableId,
    required this.tableName,
    required this.orderId,
    required this.user,
  });

  @override
  // ignore: library_private_types_in_public_api
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<Category> _categories = [];
  List<Product> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  List<Product> _cartItems = []; // List to store items in the cart

  List<String> _productIds = [];
  List<int> _quantities = [];
  List<String> _notes = [];
  bool isChange = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterProducts);
    _fetchMenu(); // Call _fetchMenu() in initState to fetch initial data
  }

  void _fetchMenu() async {
    try {
      Menu menu = Menu();
      List<Category> categories = await menu.fetchMenu();
      List<Product> products = [];

      // Get all products from categories
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

  void _addToCart(Product product) {
    setState(() {
      if (!_cartItems.contains(product)) {
        _cartItems.add(product);
        _productIds.add(product.productId);
        _quantities.add(1); // Default quantity is 1
        _notes.add(""); // Default note is an empty string

        // Show Flushbar with added product message
        Flushbar(
          message: '${product.productName} Added to cart',
          backgroundColor: Colors.green,
          duration: const Duration(milliseconds: 800),
        ).show(context);
      }
    });
  }

  void _showCartDialog() {
    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text(
                  'Cart',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                content: _cartItems.isEmpty
                    ? Container(
                        height: 120,
                        alignment: Alignment.center,
                        child: const Text(
                          "You haven't ordered yet",
                          style: TextStyle(fontSize: 15),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: _cartItems.asMap().entries.map((entry) {
                            int index = entry.key;
                            Product product = entry.value;
                            int quantity = _quantities[index];

                            if (quantity <= 0) {
                              return Container(); // Không hiển thị item có quantity = 0
                            }

                            return Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          image: DecorationImage(
                                            image:
                                                NetworkImage(product.imageUrl),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        width:
                                            55, // Set độ rộng cố định cho productName
                                        child: Text(
                                          product.productName,
                                          style: const TextStyle(
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 11),
                                      Container(
                                        width: 35,
                                        child: TextField(
                                          onChanged: (text) {
                                            setState(() {
                                              _notes[index] = text;
                                            });
                                          },
                                          decoration: const InputDecoration(
                                            hintText: 'Note',
                                            hintStyle: TextStyle(
                                                overflow: TextOverflow.ellipsis,
                                                fontSize: 7),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                          color: Colors.black,
                                          size: 20.0,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            if (quantity > 1) {
                                              _quantities[index] -= 1;
                                            } else {
                                              _cartItems.removeAt(index);
                                              _productIds.removeAt(index);
                                              _quantities.removeAt(index);
                                              _notes.removeAt(index);
                                            }
                                          });
                                          _updateAddToCartAvailability(
                                              product, true);
                                        },
                                      ),
                                      const SizedBox(width: 1),
                                      Text(quantity.toString()),
                                      const SizedBox(width: 1),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                          color: Colors.black,
                                          size: 20.0,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _quantities[index] += 1;
                                          });
                                          _updateAddToCartAvailability(
                                              product, true);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  color: Colors.grey[400],
                                  height: 1,
                                  thickness: 1,
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                          context); // Đóng dialog thay vì mở một trang mới
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.grey[400],
                    ),
                    child: const Text('Close'),
                  ),
                  const SizedBox(
                    width: 2,
                    height: 5,
                  ),
                  ElevatedButton(
                    onPressed: _cartItems.isEmpty
                        ? null
                        : () async {
                            await _createOrderDetails();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderDetailPage(
                                  pageIndex: 3,
                                  user: widget.user,
                                  areaName: widget.areaName,
                                  tableId: widget.tableId,
                                  tableName: widget.tableName,
                                  orderId: widget.orderId,
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      foregroundColor:
                          _cartItems.isEmpty ? Colors.black : Colors.white,
                      backgroundColor: _cartItems.isEmpty
                          ? Colors.grey[400]
                          : Colors.green[800],
                    ),
                    child: const Text('Order'),
                  ),
                ],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                contentPadding: const EdgeInsets.all(16.0),
                actionsPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                buttonPadding: const EdgeInsets.symmetric(horizontal: 8.0),
              );
            },
          );
        },
      );
    } catch (e) {
      Flushbar(
        message: 'Error when creating order details at UI: $e',
        backgroundColor: Colors.red,
        duration: const Duration(milliseconds: 800),
      ).show(context);
    }
  }

  Future<void> _createOrderDetails() async {
    try {
      Menu menu = Menu();
      await menu.createOrderDetail(
        widget.orderId,
        widget.user.id,
        _productIds,
        _quantities,
        _notes,
      );
    } catch (e) {
      Flushbar(
        message: 'Error creating order: $e',
        backgroundColor: Colors.red,
        duration: const Duration(milliseconds: 1500),
      ).show(context);
    }
  }

  void _updateAddToCartAvailability(Product product, bool isRemoved) {
    setState(() {
      _filteredProducts = _filteredProducts.map((item) {
        if (item == product) {
          // item.isInCart = isRemoved ? false : true;
        }
        return item;
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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Colors.green[800],
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
            const SizedBox(height: 3),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 5.0),
                child: Text(
                  '${widget.areaName} - ${widget.tableName}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
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
                if (_cartItems.length != 0 && isChange == false) {
                  setState(() {
                    isChange = true;
                  });
                  Flushbar(
                    message:
                        'Order process havent finish yet. Check your cart before you leave',
                    backgroundColor: Colors.green,
                    duration: const Duration(milliseconds: 1500),
                  ).show(context);
                } else {
                  Navigator.pop(
                      context); // Go back to previous page (OrderListPage)
                }
              },
              backgroundColor: Colors.green[800],
              child: const Icon(
                Icons.home,
                color: Colors.white,
              ),
            ),
          ),
          Stack(
            children: [
              Positioned(
                right: 0,
                bottom: 0,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Stack(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Logic for shop action
                          _showCartDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.green[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.shopping_cart,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      if (_cartItems
                          .isNotEmpty) // Show count only if cart is not empty
                        Positioned(
                          right: 7,
                          top: -6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              _cartItems.length.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(Category category) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 3 - 16,
      child: ElevatedButton(
        onPressed: () {
          _filterByCategory(category);
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.amber[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Text(
          category.categoryName,
          style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }

  Widget _buildProductItem(Product product) {
    bool isInCart = _cartItems.contains(product);

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
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 0.1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        color: Colors.white,
                        child: Image.network(
                          product.imageUrl,
                          width: 110,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(
            product.productName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const SizedBox(width: 8),
          Text(
            '${product.formattedPrice} VND',
            style: const TextStyle(color: Colors.black),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: isInCart
                      ? null // Disable button if product is already in cart
                      : () {
                          _addToCart(product);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isInCart ? Colors.grey[300] : Colors.green[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    minimumSize: const Size(double.infinity, 36),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_checkout_outlined,
                        color: isInCart ? Colors.black : Colors.white,
                        size: 12.0,
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        "Add to cart",
                        style: TextStyle(
                          color: isInCart ? Colors.black : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

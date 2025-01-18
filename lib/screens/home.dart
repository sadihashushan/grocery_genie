import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_service.dart';
import 'cart_screen.dart';

final bottomNavProvider = StateProvider<int>((ref) => 0);
final ordersProvider = FutureProvider<List<dynamic>>((ref) async {
  final apiService = ApiService();
  return apiService.fetchOrdersForUser();
});
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class HomeScreen extends ConsumerWidget {
  final FlutterSecureStorage storage = FlutterSecureStorage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavProvider);
    final screens = [
      HomeTab(),
      OrdersTab(),
      SupermarketsTab(),
      ProfileTab(storage: storage),
    ];

    // Count of cart items
    final cartItemCount = ref.watch(cartProvider).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'GroceryGenie',
          style: TextStyle(
            fontFamily: 'San Francisco',
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFB04AE1), Color(0xFF883595)],
            ),
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.pushNamed(context, '/cart');
                },
              ),
              if (cartItemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$cartItemCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Container(
        color: Colors.white, // Set the body background to white
        child: screens[currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => ref.read(bottomNavProvider.notifier).state = index,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Supermarkets'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),
        ],
        selectedItemColor: Colors.purple[300],
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for products...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),

          // Welcome message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Welcome to GroceryGenie.\nYour magical shopping experience awaits...',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.purple[700],
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: 16),

          // Banners
          SizedBox(
            height: 200,
            child: PageView(
              controller: PageController(viewportFraction: 0.9),
              children: [
                _buildPromotionCard(
                  'images/promo1.png',
                  'Year End Sale\nUpto 30% Off',
                ),
                _buildPromotionCard(
                  'images/promo2.jpg',
                  'Free Delivery\nfor the First 3 Orders',
                ),
                _buildPromotionCard(
                  'images/promo3.jpeg',
                  'Another 15% off!\nFor HNB bank card holders',
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Review Button
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/review');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[200],
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Add a Review',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          SizedBox(height: 24),

          // Customer reviews section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'What Our Customers Say',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.purple[700],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                return _buildReviewCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionCard(String imagePath, String text) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.black.withOpacity(0.5),
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard(int index) {
    final reviews = [
      {"name": "Alice", "comment": "Amazing service! Highly recommend."},
      {"name": "Bob", "comment": "Great prices and quick delivery."},
      {"name": "Cathy", "comment": "Very convenient and reliable."},
      {"name": "Daniel", "comment": "Fantastic experience shopping here!"},
    ];

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                ClipOval(
                  child: Image.asset(
                    'images/person-review.jpg',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  reviews[index]["name"]!,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              reviews[index]["comment"]!,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Row(
              children: List.generate(
                5,
                    (star) => Icon(Icons.star, color: Colors.amber, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrdersTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsyncValue = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
        backgroundColor: Colors.purple,
      ),
      body: ordersAsyncValue.when(
        data: (orders) {
          if (orders.isEmpty) {
            return Center(child: Text('No orders found.'));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return OrderCard(order: order);
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;

  OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final supermarket = order['supermarket'];
    final items = order['order_items'] ?? 'No items';

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.store, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'Supermarket: ${supermarket != null ? (supermarket['name'] ?? 'N/A') : 'N/A'}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'Date: ${order['created_at'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.list, color: Colors.purple),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    // Handle both String and List cases
                    'Items: ${items is List ? items.join(', ') : items}',
                    style: TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  order['status'] == 'completed'
                      ? Icons.check_circle
                      : Icons.pending,
                  color: order['status'] == 'completed' ? Colors.green : Colors.orange,
                ),
                SizedBox(width: 8),
                Text(
                  'Status: ${order['status'] ?? 'Unknown'}',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  order['payment_status'] == 'paid'
                      ? Icons.payment
                      : Icons.error,
                  color: order['payment_status'] == 'paid'
                      ? Colors.green
                      : Colors.red,
                ),
                SizedBox(width: 8),
                Text(
                  'Payment: ${order['payment_status'] ?? 'Unknown'}',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class SupermarketsTab extends StatelessWidget {
  Future<List<dynamic>> fetchSupermarkets() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/supermarkets'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load supermarkets');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: fetchSupermarkets(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final supermarkets = snapshot.data!;
          return Scaffold(
            body: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 175,
                      child: Image.asset(
                        'images/supermarket.jpeg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 175,
                      color: Colors.black.withOpacity(0.3),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Supermarkets',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: supermarkets.length,
                    itemBuilder: (context, index) {
                      final supermarket = supermarkets[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SupermarketDetailPage(supermarket: supermarket),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 8.0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                          color: Colors.purple[100], // Solid light purple color
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  supermarket['name'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  supermarket['location'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SupermarketDetailPage(supermarket: supermarket),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple, // Button color
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child: const Text(
                                    'Visit Store',
                                    style: TextStyle(
                                      color: Colors.black
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class SupermarketDetailPage extends ConsumerWidget {
  final Map<String, dynamic> supermarket;

  SupermarketDetailPage({required this.supermarket});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groceryListController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(supermarket['name']),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.asset(
                  'images/market.png',
                  width: double.infinity,
                  height: 250.0,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              supermarket['name'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Location: ${supermarket['location']}',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            Text(
              'Add Grocery List:',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: groceryListController,
              maxLines: 5,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                hintText: 'Enter your grocery list here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final items = groceryListController.text
                    .split('\n')
                    .where((item) => item.trim().isNotEmpty)
                    .toList();
                if (items.isNotEmpty) {
                  ref.read(cartProvider.notifier).addToCart(
                    supermarket['id'], // Pass the supermarket ID
                    supermarket['name'],
                    supermarket['location'],
                    items,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Items added to cart!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter grocery items.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text('Add to Cart', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  final FlutterSecureStorage storage;

  ProfileTab({required this.storage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Profile Screen',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}

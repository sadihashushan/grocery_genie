import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home.dart';
import 'checkout_screen.dart';

// Cart Item Model
class CartItem {
  final int supermarketId;
  final String supermarketName;
  final String supermarketLocation;
  final List<String> groceryList;

  CartItem({
    required this.supermarketId,
    required this.supermarketName,
    required this.supermarketLocation,
    required this.groceryList,
  });
}

// Cart state
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addToCart(int supermarketId, String supermarketName, String supermarketLocation, List<String> groceryList) {
    // Add an item to cart
    state = [
      ...state,
      CartItem(
        supermarketId: supermarketId,
        supermarketName: supermarketName,
        supermarketLocation: supermarketLocation,
        groceryList: groceryList,
      ),
    ];
  }

  void removeFromCart(int index) {
    // Remove item
    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i]
    ];
  }
}

class CartScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Cart'),
        backgroundColor: Colors.purple[200],
      ),
      body: cartItems.isEmpty
          ? Center(child: Text('Your cart is empty!'))
          : ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final cartItem = cartItems[index];

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
                  Text(
                    'Supermarket: ${cartItem.supermarketName}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Location: ${cartItem.supermarketLocation}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Items:\n${cartItem.groceryList.join('\n')}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          ref.read(cartProvider.notifier).removeFromCart(index);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Item removed from cart.')));
                        },
                        child: Text('Remove', style: TextStyle(color: Colors.red)),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to checkout
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CheckoutScreen(
                                supermarketId: cartItem.supermarketId,
                                orderItems: cartItem.groceryList,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text('Checkout'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
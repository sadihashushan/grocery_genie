import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home.dart';

// Define a cart item model (optional but recommended for structure)
class CartItem {
  final String supermarketName;
  final String supermarketLocation;
  final List<String> groceryList;

  CartItem({
    required this.supermarketName,
    required this.supermarketLocation,
    required this.groceryList,
  });
}

// StateNotifier to manage cart state
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addToCart(String supermarketName, String supermarketLocation, List<String> groceryList) {
    // Add a new item to the cart
    state = [
      ...state,
      CartItem(
        supermarketName: supermarketName,
        supermarketLocation: supermarketLocation,
        groceryList: groceryList,
      ),
    ];
  }

  void removeFromCart(int index) {
    // Remove an item by index
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
                          // Implement checkout logic here
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

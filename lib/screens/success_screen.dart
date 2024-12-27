import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Success')),
        body: Center(child: Text('No order details available.')),
      );
    }

    final order = args['order'];
    final address = args['address'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Success'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(Icons.check_circle, color: Colors.green, size: 100),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Order placed successfully!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Invoice:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text('Order ID: ${order['id']}'),
            Text('Supermarket: ${order['supermarket_name']}'),
            Text('Items: ${order['items']}'),
            const SizedBox(height: 16),
            const Text(
              'Delivery Address:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text('Name: ${address['first_name']} ${address['last_name']}'),
            Text('Phone: ${address['phone']}'),
            Text('City: ${address['city']}'),
            Text('Street: ${address['street_address']}'),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                },
                child: const Text('Go to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_assignment/api_service.dart';

class CheckoutScreen extends StatelessWidget {
  final int supermarketId;
  final List<String> orderItems;

  CheckoutScreen({required this.supermarketId, required this.orderItems});

  final _formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final notesController = TextEditingController();
  String paymentMethod = 'cod'; // Default: Cash on Delivery

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        backgroundColor: Colors.purple[200],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Street Address'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: cityController,
                decoration: InputDecoration(labelText: 'City'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              DropdownButtonFormField<String>(
                value: paymentMethod,
                items: [
                  DropdownMenuItem(value: 'cod', child: Text('Cash on Delivery')),
                  DropdownMenuItem(value: 'card', child: Text('Card')),
                ],
                onChanged: (value) => paymentMethod = value!,
                decoration: InputDecoration(labelText: 'Payment Method'),
              ),
              TextFormField(
                controller: notesController,
                decoration: InputDecoration(labelText: 'Notes (Optional)'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final apiService = ApiService();
                    final error = await apiService.createOrder(
                      userId: 1, // Replace with actual user ID
                      supermarketId: supermarketId,
                      orderItems: orderItems,
                      paymentMethod: paymentMethod,
                      paymentStatus: 'pending',
                      firstName: firstNameController.text,
                      lastName: lastNameController.text,
                      phone: phoneController.text,
                      streetAddress: addressController.text,
                      city: cityController.text,
                      notes: notesController.text,
                    );

                    if (error == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Order created successfully!')),
                      );
                      Navigator.pop(context); // Go back to cart
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $error')),
                      );
                    }
                  }
                },
                child: Text('Place Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

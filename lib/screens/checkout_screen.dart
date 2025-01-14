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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Order Details',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[800],
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: firstNameController,
                        label: 'First Name',
                        icon: Icons.person,
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      SizedBox(height: 12),
                      _buildTextField(
                        controller: lastNameController,
                        label: 'Last Name',
                        icon: Icons.person_outline,
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      SizedBox(height: 12),
                      _buildTextField(
                        controller: phoneController,
                        label: 'Phone',
                        icon: Icons.phone,
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      SizedBox(height: 12),
                      _buildTextField(
                        controller: addressController,
                        label: 'Street Address',
                        icon: Icons.home,
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      SizedBox(height: 12),
                      _buildTextField(
                        controller: cityController,
                        label: 'City',
                        icon: Icons.location_city,
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: paymentMethod,
                        items: [
                          DropdownMenuItem(
                              value: 'cod', child: Text('Cash on Delivery')),
                          DropdownMenuItem(value: 'card', child: Text('Card')),
                        ],
                        onChanged: (value) => paymentMethod = value!,
                        decoration: InputDecoration(
                          labelText: 'Payment Method',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.payment),
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildTextField(
                        controller: notesController,
                        label: 'Notes (Optional)',
                        icon: Icons.notes,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final apiService = ApiService();
                            final error = await apiService.createOrder(
                              userId: 2,
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
                                SnackBar(
                                    content: Text('Order created successfully!')),
                              );
                              Navigator.pop(context); // Go back to cart
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $error')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                          backgroundColor: Colors.purple[400],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Place Order',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_assignment/api_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CheckoutScreen extends StatefulWidget {
  final int supermarketId;
  final List<String> orderItems;

  CheckoutScreen({required this.supermarketId, required this.orderItems});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final notesController = TextEditingController();
  final storage = FlutterSecureStorage();

  String paymentMethod = 'cod'; // Default
  bool _isLoading = false;

  Future<void> _pickContact() async {
    PermissionStatus permission = await Permission.contacts.request();
    if (permission.isGranted) {
      List<Contact> contacts = await FlutterContacts.getContacts(
          withProperties: true);
      if (contacts.isNotEmpty) {
        Contact? selectedContact = await showDialog<Contact>(
          context: context,
          builder: (context) =>
              AlertDialog(
                title: Text('Select a Contact'),
                content: SizedBox(
                  width: double.maxFinite,
                  height: 300,
                  child: ListView(
                    children: contacts.map((contact) {
                      return ListTile(
                        title: Text(contact.displayName ?? 'Unknown'),
                        subtitle: contact.phones.isNotEmpty
                            ? Text(contact.phones.first.number)
                            : Text('No phone number'),
                        onTap: () => Navigator.pop(context, contact),
                      );
                    }).toList(),
                  ),
                ),
              ),
        );

        if (selectedContact != null) {
          setState(() {
            firstNameController.text = selectedContact.name.first;
            phoneController.text = selectedContact.phones.isNotEmpty
                ? selectedContact.phones.first.number
                : '';
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No contacts found')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission denied')),
      );
    }
  }

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
                      ElevatedButton.icon(
                        onPressed: _pickContact,
                        icon: Icon(Icons.contacts, color: Colors.white),
                        label: Text('Book for a Friend'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[400],
                          textStyle: TextStyle(color: Colors.white),
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildTextField(controller: firstNameController,
                          label: 'First Name',
                          icon: Icons.person),
                      SizedBox(height: 12),
                      _buildTextField(controller: lastNameController,
                          label: 'Last Name',
                          icon: Icons.person_outline),
                      SizedBox(height: 12),
                      _buildTextField(controller: phoneController,
                          label: 'Phone',
                          icon: Icons.phone),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                                controller: addressController,
                                label: 'Street Address',
                                icon: Icons.home),
                          ),
                          IconButton(icon: Icon(
                              Icons.my_location, color: Colors.purple),
                              onPressed: _fetchLocation),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(controller: cityController,
                                label: 'City',
                                icon: Icons.location_city),
                          ),
                          IconButton(icon: Icon(
                              Icons.my_location, color: Colors.purple),
                              onPressed: _fetchLocation),
                        ],
                      ),
                      SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: paymentMethod,
                        items: [
                          DropdownMenuItem(value: 'cod',
                              child: Text('Cash on Delivery')),
                          DropdownMenuItem(value: 'card', child: Text('Card')),
                        ],
                        onChanged: (value) =>
                            setState(() => paymentMethod = value!),
                        decoration: InputDecoration(
                          labelText: 'Payment Method',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          prefixIcon: Icon(Icons.payment),
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildTextField(controller: notesController,
                          label: 'Notes (Optional)',
                          icon: Icons.notes),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _placeOrder,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: 14, horizontal: 12),
                          backgroundColor: Colors.purple[400],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading ? CircularProgressIndicator(
                            color: Colors.white) : Text(
                          'Place Order',
                          style: TextStyle(fontSize: 16, color: Colors.black),
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

  Widget _buildTextField(
      {required TextEditingController controller, required String label, required IconData icon}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: Icon(icon),
      ),
    );
  }

  Future<void> _fetchLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enable location services')));
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location permission denied')));
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, position.longitude);

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      setState(() {
        addressController.text = place.street ?? 'Unknown';
        cityController.text = place.locality ?? 'Unknown';
      });
    }
  }

  Future<void> _placeOrder() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final apiService = ApiService();
      String? userIdString = await storage.read(key: 'user_id');
      int? userId = userIdString != null ? int.tryParse(userIdString) : null;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User not logged in')));
        setState(() => _isLoading = false);
        return;
      }

      final error = await apiService.createOrder(
        userId: userId,
        supermarketId: widget.supermarketId,
        orderItems: widget.orderItems,
        paymentMethod: paymentMethod,
        paymentStatus: 'pending',
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        phone: phoneController.text,
        streetAddress: addressController.text,
        city: cityController.text,
        notes: notesController.text,
      );

      setState(() => _isLoading = false);

      if (error == null) {
        showDialog(
          context: context,
          builder: (_) =>
              AlertDialog(
                title: Text('Success'),
                content: Text('Your order has been placed successfully!'),
                actions: [
                  TextButton(onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/cart');
                  }, child: Text('OK'))
                ],
              ),
        );
      }
    }
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';

// Initialize the TextEditingControllers
final TextEditingController firstNameController = TextEditingController();
final TextEditingController lastNameController = TextEditingController();
final TextEditingController phoneController = TextEditingController();
final TextEditingController addressController = TextEditingController();
final TextEditingController cityController = TextEditingController();

// Text Editing Controller for grocery list
final TextEditingController groceryListController = TextEditingController();

class ApiService {
  final String baseUrl = 'http://10.0.2.2:8000/api';
  final storage = FlutterSecureStorage();

  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      body: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: 'token', value: data['token']);
      return null;
    } else {
      return jsonDecode(response.body)['message'];
    }
  }

  Future<String?> register(String name, String email, String password,
      String passwordConfirmation) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );

    if (response.statusCode == 201) {
      return null;
    } else {
      return jsonDecode(response.body)['message'];
    }
  }

  Future<String?> submitReview({
    required int userId,
    required String name,
    required String review,
    required int starCount,
  }) async {
    final token = await storage.read(key: 'token');

    final response = await http.post(
      Uri.parse('$baseUrl/reviews'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_id': userId,
        'name': name,
        'review': review,
        'star_count': starCount,
      }),
    );

    if (response.statusCode == 201) {
      return null;
    } else {
      return jsonDecode(response.body)['message'];
    }
  }

  Future<List<dynamic>> fetchSupermarkets() async {
    final response = await http.get(Uri.parse('$baseUrl/supermarkets'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load supermarkets');
    }
  }

  Future<Map<String, dynamic>> fetchSupermarketBySlug(String slug) async {
    final response = await http.get(
        Uri.parse('$baseUrl/supermarkets/slug/$slug'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load supermarket details');
    }
  }

  Future<List<dynamic>> fetchOrdersForUser() async {
    final token = await storage.read(key: 'token');

    final response = await http.get(
      Uri.parse('$baseUrl/orders'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch orders');
    }
  }

  Future<String?> createOrder({
    required int userId,
    required int supermarketId,
    required List<String> orderItems,
    required String paymentMethod,
    required String paymentStatus,
    required String firstName,
    required String lastName,
    required String phone,
    required String streetAddress,
    required String city,
    String? notes,
  }) async {
    final token = await storage.read(key: 'token');

    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_id': userId,
        'supermarket_id': supermarketId,
        'order_items': orderItems,
        'status': 'new',
        'payment_method': paymentMethod,
        'payment_status': paymentStatus,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'street_address': streetAddress,
        'city': city,
        'notes': notes,
      }),
    );

    if (response.statusCode == 201) {
      return null; // Success
    } else {
      return jsonDecode(response.body)['message']; // Error message
    }
  }

}

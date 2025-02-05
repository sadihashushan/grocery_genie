import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final TextEditingController firstNameController = TextEditingController();
final TextEditingController lastNameController = TextEditingController();
final TextEditingController phoneController = TextEditingController();
final TextEditingController addressController = TextEditingController();
final TextEditingController cityController = TextEditingController();

// Text Editing Controller for grocery list
final TextEditingController groceryListController = TextEditingController();

class ApiService {
  final String baseUrl = 'https://grocerygenie.xyz/api';
  final storage = FlutterSecureStorage();

  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: 'token', value: data['token']);
      await storage.write(key: 'user_id', value: data['user']['id'].toString());
      await storage.write(key: 'user_name', value: data['user']['name']);
      await storage.write(key: 'user_email', value: data['user']['email']);
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
      return null;
    } else {
      return jsonDecode(response.body)['message'];
    }
  }

  Future<String?> loginGenie(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/genie/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: 'token', value: data['token']);
      return null;
    } else {
      final errorData = jsonDecode(response.body);
      return errorData['message'];
    }
  }

  Future<List<dynamic>> fetchNewOrders() async {
    final token = await storage.read(key: 'token');

    final response = await http.get(
      Uri.parse('$baseUrl/genie/orders/new'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final orders = jsonDecode(response.body) as List;
      for (var order in orders) {
        final addressResponse = await http.get(
          Uri.parse('$baseUrl/addresses/${order['address_id']}'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );
        if (addressResponse.statusCode == 200) {
          order['address'] = jsonDecode(addressResponse.body);
        }
      }
      return orders;
    } else {
      throw Exception('Failed to fetch new orders');
    }
  }

  Future<List<dynamic>> fetchOngoingOrders() async {
    final token = await storage.read(key: 'token');

    final response = await http.get(
      Uri.parse('$baseUrl/genie/orders/ongoing'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final orders = jsonDecode(response.body) as List;
      for (var order in orders) {
        final addressResponse = await http.get(
          Uri.parse('$baseUrl/addresses/${order['address_id']}'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );
        if (addressResponse.statusCode == 200) {
          order['address'] = jsonDecode(addressResponse.body);
        }
      }
      return orders;
    } else {
      throw Exception('Failed to fetch ongoing orders');
    }
  }

  Future<List<dynamic>> fetchCompletedOrders() async {
    final token = await storage.read(key: 'token');

    final response = await http.get(
      Uri.parse('$baseUrl/genie/orders/completed'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final orders = jsonDecode(response.body) as List;
      for (var order in orders) {
        final addressResponse = await http.get(
          Uri.parse('$baseUrl/addresses/${order['address_id']}'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );
        if (addressResponse.statusCode == 200) {
          order['address'] = jsonDecode(addressResponse.body);
        }
      }
      return orders;
    } else {
      throw Exception('Failed to fetch completed orders');
    }
  }

  Future<String?> updateOrderStatus(int orderId, String action) async {
    final token = await storage.read(key: 'token');

    final response = await http.post(
      Uri.parse('$baseUrl/genie/orders/$orderId/$action'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return null;
    } else {
      return jsonDecode(response.body)['message'];
    }
  }

  Future<String?> logout() async {
    final token = await storage.read(key: 'token');
    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      await storage.delete(key: 'token');
      return null;
    } else {
      return jsonDecode(response.body)['message'];
    }
  }

  Future<void> logoutGenie() async {
    final token = await storage.read(key: 'token');
    if (token == null) return;

    final response = await http.post(
      Uri.parse('$baseUrl/genie/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      await storage.delete(key: 'token'); // Remove stored token
    }
  }
}
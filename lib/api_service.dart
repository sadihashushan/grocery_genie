import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  Future<String?> register(String name, String email, String password, String passwordConfirmation) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
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
    } else {
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

}

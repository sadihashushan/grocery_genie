import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ordersProvider = FutureProvider<List<dynamic>>((ref) async {
  const String jsonUrl = "https://drive.google.com/uc?export=download&id=1lSZkjG0EjiGmv2KpG7GWs1iKLihejysq";

  try {
    final response = await http.get(Uri.parse(jsonUrl));

    if (response.statusCode == 200) {
      final String responseBody = response.body.trim();
      if (responseBody.isEmpty) {
        throw Exception("Empty response from server");
      }
      final List<dynamic> orders = json.decode(responseBody);
      return orders;
    } else {
      throw Exception("Failed to load orders. Status code: ${response.statusCode}");
    }
  } catch (e) {
    throw Exception("Error fetching orders: $e");
  }
});

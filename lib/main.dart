import 'package:flutter/material.dart';
import 'package:flutter_assignment/cart_screen.dart';
import 'package:flutter_assignment/review_screen.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'home.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


// Main function with Riverpod provider
void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Assignment',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: LoginScreen(),
      routes: {
        '/login' : (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/review': (context) => ReviewScreen(),
        '/cart' : (context) => CartScreen()
      },
    );
  }
}
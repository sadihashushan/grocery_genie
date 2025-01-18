import 'package:flutter/material.dart';
import 'package:flutter_assignment/screens/cart_screen.dart';
import 'package:flutter_assignment/screens/review_screen.dart';
import 'package:flutter_assignment/screens/success_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home.dart';


// Main function with Riverpod provider
void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Assignment',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: LoginScreen(),
      routes: {
        '/login' : (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/review': (context) => ReviewScreen(),
        '/cart' : (context) => CartScreen(),
        '/success': (context) => SuccessScreen(),
      },
    );
  }
}
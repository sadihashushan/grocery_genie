import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_assignment/screens/home.dart';
import 'package:flutter_assignment/screens/login_screen.dart';
import 'package:flutter_assignment/screens/register_screen.dart';
import 'package:flutter_assignment/screens/review_screen.dart';
import 'package:flutter_assignment/screens/cart_screen.dart';
import 'package:flutter_assignment/theme/app_theme.dart';
import 'package:flutter_assignment/providers/theme_provider.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Assignment',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: LoginScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/review': (context) => ReviewScreen(),
        '/cart': (context) => CartScreen(),
      },
    );
  }
}

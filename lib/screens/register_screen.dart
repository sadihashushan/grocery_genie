import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api_service.dart';

// State provider for managing error message
final errorMessageProvider = StateProvider<String?>((ref) => null);

class RegisterScreen extends ConsumerWidget {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final ApiService _apiService = ApiService();

  void _register(BuildContext context, WidgetRef ref) async {
    final error = await _apiService.register(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
      _passwordConfirmController.text,
    );

    if (error == null) {
      Navigator.pop(context); // Return to Login Screen
    } else {
      ref.read(errorMessageProvider.notifier).state = error;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errorMessage = ref.watch(errorMessageProvider);

    return Scaffold(
      backgroundColor: Colors.purple[50], // Soft purple background
      body: Stack(
        children: [
          // Banner Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'images/home-banner.jpg',
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height * 0.4,
            ),
          ),
          // Curved Form
          Positioned.fill(
            top: MediaQuery.of(context).size.height * 0.35,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: Offset(0, -10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 20),
                    // Name Input
                    CustomTextField(
                      controller: _nameController,
                      label: 'Name',
                    ),
                    SizedBox(height: 16),
                    // Email Input
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email',
                    ),
                    SizedBox(height: 16),
                    // Password Input
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Password',
                      obscureText: true,
                    ),
                    SizedBox(height: 16),
                    // Confirm Password Input
                    CustomTextField(
                      controller: _passwordConfirmController,
                      label: 'Confirm Password',
                      obscureText: true,
                    ),
                    SizedBox(height: 16),
                    // Display Error Message
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          errorMessage,
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),
                    SizedBox(height: 16),
                    // Register Button
                    ElevatedButton(
                      onPressed: () => _register(context, ref),
                      child: Text(
                        'Register',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                        textStyle: TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Login Link
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Text(
                        "Already have an account? Login",
                        style: TextStyle(
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable Text Field Widget
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.purple[300],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.purple[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.purple[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      obscureText: obscureText,
    );
  }
}

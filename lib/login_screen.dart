import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'api_service.dart';

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
    );
  }
}

class LoginScreen extends ConsumerWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errorMessage = ref.watch(errorProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Top banner image
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
          // Curved login form
          Positioned.fill(
            top: MediaQuery.of(context).size.height * 0.30,
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
                    spreadRadius: 5,
                    blurRadius: 15,
                    offset: Offset(0, -10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[700],
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Please login to continue',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 30),
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
                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          errorMessage,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    SizedBox(height: 24),
                    // Login Button
                    ElevatedButton(
                      onPressed: () {
                        ref.read(authProvider.notifier).login(
                          context,
                          _emailController.text,
                          _passwordController.text,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Sign Up Button
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: Text(
                          "Don't have an account? Sign Up",
                          style: TextStyle(color: Colors.purple),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(thickness: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('OR'),
                        ),
                        Expanded(child: Divider(thickness: 1)),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Google Sign-In Button
                    OutlinedButton.icon(
                      onPressed: () async {
                        final googleSignIn = GoogleSignIn();
                        try {
                          await googleSignIn.signIn();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Google Sign-In failed: $e'),
                          ));
                        }
                      },
                      icon: Icon(Icons.g_mobiledata, color: Colors.purple),
                      label: Text(
                        'Sign Up with Google',
                        style: TextStyle(color: Colors.purple),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.purple),
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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

// Riverpod State Management
final errorProvider = StateProvider<String>((ref) => '');

final authProvider = StateNotifierProvider<AuthNotifier, String>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<String> {
  final Ref ref;

  AuthNotifier(this.ref) : super('');

  Future<void> login(BuildContext context, String email, String password) async {
    final apiService = ApiService();
    final error = await apiService.login(email, password);
    if (error == null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ref.read(errorProvider.notifier).state = error;
    }
  }
}

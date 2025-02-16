import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import '../genie_screens/genie_login_screen.dart';

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

class LoginScreen extends ConsumerStatefulWidget {
  LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _resetUserData();
  }

  Future<void> _resetUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('password');
    _emailController.clear();
    _passwordController.clear();
  }

  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _emailController.text = prefs.getString('email') ?? '';
    _passwordController.text = prefs.getString('password') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final errorMessage = ref.watch(errorProvider);

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.5,
              child: Image.asset(
                'images/home-banner.jpg',
                fit: BoxFit.cover,
              ),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.35),
                  Container(
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
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 25),
                        Text(
                          'Welcome Back!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[700],
                          ),
                        ),
                        SizedBox(height: 30),
                        Text(
                          'Please login to continue',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 30),
                        CustomTextField(controller: _emailController, label: 'Email'),
                        SizedBox(height: 30),
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
                        SizedBox(height: 25),
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
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('Login', style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            child: Text("Don't have an account? Sign Up", style: TextStyle(color: Colors.purple)),
                          ),
                        ),
                        SizedBox(height: 25),
                        ElevatedButton(
                          onPressed: () async {
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            String email = prefs.getString('email') ?? '';
                            String password = prefs.getString('password') ?? '';

                            // Fill the text fields with saved data
                            _emailController.text = email;
                            _passwordController.text = password;
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('Auto-Fill Credentials', style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                        SizedBox(height: 25),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => GenieLoginScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 27),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)
                                )
                            ),
                            child: Text('Login as a Genie', style: TextStyle(fontSize: 18, color: Colors.white))
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;

  const CustomTextField({super.key, required this.controller, required this.label, this.obscureText = false});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.purple[300]),
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
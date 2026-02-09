import 'package:flutter/material.dart';
import 'package:food_scanner_app/services/auth_service.dart';
import 'package:food_scanner_app/utils/validation_helper.dart';

class SignupCredentialsScreen extends StatefulWidget {
  const SignupCredentialsScreen({super.key});

  @override
  SignupCredentialsScreenState createState() => SignupCredentialsScreenState();
}

class SignupCredentialsScreenState extends State<SignupCredentialsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _next() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    final result = await _authService.signUpWithEmail(
      emailController.text.trim(),
      passwordController.text.trim(),
    );
    setState(() {
      _isLoading = false;
    });
    if (result == null) {
      // Proceed to the preferences page if signup succeeded.
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/signup_preferences');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(result)));
      }
    }
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[800],
      labelStyle: const TextStyle(color: Colors.white),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[600]!),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.yellow),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up - Credentials")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: emailController,
                decoration: _buildInputDecoration("Email"),
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                validator: ValidationHelper.validateEmail,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                decoration: _buildInputDecoration("Password"),
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                validator: ValidationHelper.validatePassword,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _next,
                      child: const Text("Next", style: TextStyle(fontSize: 18)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

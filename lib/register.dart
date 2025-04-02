import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  final String individualRegisterUrl; // URL for the register endpoint
  final String businessRegisterUrl; // URL for the register endpoint
  final String loginRoute; // Route or URL to the login page

  const RegisterPage({
    super.key,
    required this.individualRegisterUrl,
    required this.businessRegisterUrl,
    required this.loginRoute,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late String currentRegisterUrl; // Holds the currently selected register URL

  @override
  void initState() {
    super.initState();
    currentRegisterUrl = widget.individualRegisterUrl; // Default to individual register
  }

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _registerUser() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse(currentRegisterUrl); // Registration API
    final Map<String, dynamic> body = {
      'Username': _usernameController.text,
      'Email': _emailController.text,
      'Password': _passwordController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful')),
        );
        Navigator.pop(context); // Navigate back to login page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs: Individual and Corporate
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Register'),
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                // Switch API URL based on the selected tab
                currentRegisterUrl = index == 0
                    ? widget.individualRegisterUrl
                    : widget.businessRegisterUrl;
              });
            },
            tabs: const [
              Tab(text: 'Individual User'),
              Tab(text: 'Corporate User'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Same UI for both tabs, but backend URL changes dynamically
            _buildRegisterForm(),
            _buildRegisterForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    // Get the screen width and calculate percentage-based margin
    double screenWidth = MediaQuery.of(context).size.width;
    double horizontalMargin = screenWidth * 0.2; // 20% margin on each side

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16.0),
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: _isLoading ? null : _registerUser,
            child: _isLoading
                ? const SizedBox(
              height: 16.0,
              width: 16.0,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.0,
              ),
            )
                : const Text('Register'),
          ),
          const SizedBox(height: 16.0),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, widget.loginRoute);
            },
            child: const Text("Already have an account? Login"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}


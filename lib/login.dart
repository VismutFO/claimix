import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'idashboard.dart';
import 'bdashboard.dart';

class LoginPage extends StatefulWidget {
  final String individualLoginUrl; // Individual User Login
  final String businessLoginUrl; // Corporate User Login
  final String registerRoute; // Route or URL to the register page
  final String individualDashboardRoute; // Route or URL to the dashboard page
  final String businessDashboardRoute; // Route or URL to the dashboard page

  const LoginPage({
    super.key,
    required this.individualLoginUrl,
    required this.businessLoginUrl,
    required this.registerRoute,
    required this.individualDashboardRoute,
    required this.businessDashboardRoute,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late String currentLoginUrl; // Holds the currently selected login URL

  @override
  void initState() {
    super.initState();
    currentLoginUrl = widget.individualLoginUrl; // Default to individual login
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs: Individual and Corporate
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                // Switch API URL based on the selected tab
                currentLoginUrl =
                    index == 0
                        ? widget.individualLoginUrl
                        : widget.businessLoginUrl;
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
            _buildLoginForm(),
            _buildLoginForm(),
          ],
        ),
      ),
    );
  }

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _loginUser() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse(currentLoginUrl); // Login API
    final Map<String, dynamic> body = {
      'Username': _usernameController.text,
      'Password': _passwordController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);

        if (responseData["token"] != null) {
          final String token = responseData["token"];

          // Navigate to Dashboard and pass the token
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                if (currentLoginUrl == widget.individualLoginUrl) {
                  return IDashboardPage(
                    dashboardUrl: widget.individualDashboardRoute,
                    token: token,
                  );
                }
                return BDashboardPage(
                  dashboardUrl: widget.businessDashboardRoute,
                  token: token,
                );
              },
            ),
          );

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Login successful')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to retrieve token')),
          );
        }
      } else {
        // Handle invalid credentials
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid username or password')),
        );
      }
    } catch (e) {
      // Handle network error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildLoginForm() {
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
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: _isLoading ? null : _loginUser,
            child:
                _isLoading
                    ? const SizedBox(
                      height: 16.0,
                      width: 16.0,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.0,
                      ),
                    )
                    : const Text('Login'),
          ),
          const SizedBox(height: 16.0),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, widget.registerRoute);
            },
            child: const Text("Don't have an account? Register"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

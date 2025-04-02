import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart'; // Import the global config file
import 'dart:convert';
import 'b_services.dart';
import 'add_service_template.dart';

class BDashboardPage extends StatefulWidget {
  final String token;

  const BDashboardPage({
    super.key,
    required this.token,
  });

  @override
  State<BDashboardPage> createState() => _BDashboardPageState();
}

class _BDashboardPageState extends State<BDashboardPage> {
  String _dashboardMessage = "Loading dashboard...";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getBusinessDashboard}'); // Dashboard API

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}', // Set the token here
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);
        setState(() {
          _dashboardMessage = responseData["message"] ?? "Welcome to the dashboard!";
        });
      } else {
        setState(() {
          _dashboardMessage = "Failed to load dashboard. Status: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _dashboardMessage = "An error occurred while loading the dashboard: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Navigate to BServicesPage
  void _goToBServicesPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BServicesPage(
          authToken: widget.token, // Pass the auth token
        ),
      ),
    );
  }

  /// Navigate to AddServiceTemplatePage
  void _goToAddServiceTemplatePage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddServiceTemplatePage(
          token: widget.token, // Pass the auth token
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Center( // Center the column in the screen
        child: Column(
          mainAxisSize: MainAxisSize.min, // Center content vertically
          mainAxisAlignment: MainAxisAlignment.center, // Center content horizontally
          children: [
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _dashboardMessage,
                  style: const TextStyle(fontSize: 18.0),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _goToBServicesPage,
              child: const Text('Go to Services'),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _goToAddServiceTemplatePage,
              child: const Text('Go to Add Service Template'),
            ),
          ],
        ),
      ),
    );
  }
}
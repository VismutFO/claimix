import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'service_providers.dart'; // Import ServiceProvidersPage
import 'filled_requests.dart';

class IDashboardPage extends StatefulWidget {
  final String token;

  const IDashboardPage({Key? key, required this.token}) : super(key: key);

  @override
  State<IDashboardPage> createState() => _IDashboardPageState();
}

class _IDashboardPageState extends State<IDashboardPage> {
  String _dashboardMessage = "Loading dashboard...";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  /// Fetch dashboard data from the server
  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getIndividualDashboard}');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Parse the response from the server
        final responseData = json.decode(response.body);

        setState(() {
          // Extract the message or any other required data
          _dashboardMessage = responseData['message'] ?? 'Dashboard loaded successfully!';
        });
      } else {
        _showErrorDialog(
          title: 'Error',
          message: 'Failed to load dashboard data. Status code: ${response.statusCode}.',
        );
      }
    } catch (error) {
      _showErrorDialog(
        title: 'Error',
        message: 'An error occurred while loading dashboard data: $error',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Show an error dialog if API calls fail
  void _showErrorDialog({required String title, required String message}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Navigate to ServiceProvidersPage
  void _goToServiceProvidersPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ServiceProvidersPage(
          token: widget.token, // Pass the auth token
        ),
      ),
    );
  }

  /// Navigate to FilledRequestsPage
  void _goToFilledRequestsPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FilledRequestsPage(
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
              onPressed: _goToServiceProvidersPage,
              child: const Text('Go to Service Providers'),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _goToFilledRequestsPage,
              child: const Text('Go to Filled Requests'),
            ),
          ],
        ),
      ),
    );
  }
}
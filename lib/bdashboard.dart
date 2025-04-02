import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BDashboardPage extends StatefulWidget {
  final String token;
  final String dashboardUrl;

  const BDashboardPage({super.key, required this.token, required this.dashboardUrl});

  @override
  State<BDashboardPage> createState() => _BDashboardPageState();
}

class _BDashboardPageState extends State<BDashboardPage> {
  String message = "Loading dashboard...";

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final url = Uri.parse(widget.dashboardUrl); // Dashboard API

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
          message = responseData["message"] ?? "Welcome to the dashboard!";
        });
      } else {
        setState(() {
          message = "Failed to load dashboard. Status: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        message = "An error occurred while loading the dashboard: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18.0),
        ),
      ),
    );
  }
}
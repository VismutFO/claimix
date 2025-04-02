import 'dart:convert';
import 'config.dart'; // Import the global config file
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'idashboard.dart';

/// Page for filling and submitting a service template request.
///
/// The page fetches the service template details from the API using the provided
/// `serviceTemplateId` and dynamically creates input fields for each question
/// in the template.
class ServiceRequestPage extends StatefulWidget {
  final String serviceTemplateId;
  final String authToken;

  const ServiceRequestPage({
    Key? key,
    required this.serviceTemplateId,
    required this.authToken,
  }) : super(key: key);

  @override
  State<ServiceRequestPage> createState() => _ServiceRequestPageState();
}

class _ServiceRequestPageState extends State<ServiceRequestPage> {
  late Map<String, dynamic> _filledAnswers = {}; // Stores user inputs
  Map<String, dynamic>? _serviceTemplate; // Fetched template data
  bool _isLoading = false; // API loading state

  @override
  void initState() {
    super.initState();
    _fetchServiceTemplate();
  }

  /// Fetch the service template from the backend using the provided serviceTemplateId.
  Future<void> _fetchServiceTemplate() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getServiceTemplate}');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.authToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'service_template_id': widget.serviceTemplateId}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() {
          _serviceTemplate = json.decode(response.body);
        });

        // Initialize _filledAnswers for all questions
        if (_serviceTemplate != null &&
            _serviceTemplate!['FieldsFormat'] != null) {
          final questions = _serviceTemplate!['FieldsFormat'] as List<dynamic>;
          for (var question in questions) {
            _filledAnswers[question['ID']] =
                ''; // Default empty input for each question
          }
        }
      } else {
        _showErrorDialog(
          title: 'Error',
          message:
              'Failed to load service template. Status code: ${response.statusCode}.',
        );
      }
    } catch (error) {
      _showErrorDialog(
        title: 'Error',
        message: 'An error occurred while retrieving data: $error',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Submit the filled form data to the backend.
  Future<void> _submitFilledService() async {
    if (_serviceTemplate == null) {
      return;
    }

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.submitServiceRequest}');

    final filledServiceData = {
      'service_template_id': widget.serviceTemplateId,
      'service_data':
          _filledAnswers.entries.map((entry) {
            return {'question_id': entry.key, 'answer': entry.value};
          }).toList(),
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.authToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(filledServiceData),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _showSuccessDialog(
          title: 'Success',
          message: 'Service request submitted successfully!',
        );
      } else {
        _showErrorDialog(
          title: 'Submission Error',
          message:
              'Failed to submit service request. Status code: ${response.statusCode}.',
        );
      }
    } catch (error) {
      _showErrorDialog(
        title: 'Error',
        message:
            'An error occurred while submitting the service request: $error',
      );
    }
  }

  /// Displays an error dialog for any API-related issues.
  void _showErrorDialog({required String title, required String message}) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
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

  /// Show a success dialog and navigate to IDashboardPage when dialog is closed.
  void _showSuccessDialog({required String title, required String message}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              _navigateToDashboard(); // Navigate to the dashboard
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Navigate to the IDashboardPage
  void _navigateToDashboard() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => IDashboardPage(token: widget.authToken), // Pass auth token
      ),
          (route) => false, // Remove all previous routes from the stack
    );
  }

  /// Dynamically build the input field widget with the associated type.
  Widget _buildInputField(String type, String questionId) {
    switch (type.toLowerCase()) {
      case 'int':
        return TextField(
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {
              // _filledAnswers[questionId] = int.tryParse(value) ?? 0;
              _filledAnswers[questionId] = value;
            });
          },
          decoration: const InputDecoration(labelText: 'Enter number'),
        );
      case 'string':
      default:
        return TextField(
          onChanged: (value) {
            setState(() {
              _filledAnswers[questionId] = value;
            });
          },
          decoration: const InputDecoration(labelText: 'Enter text'),
        );
      // Add more input field types as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_serviceTemplate == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Failed to load service template.')),
      );
    }

    final questions = _serviceTemplate!['FieldsFormat'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(_serviceTemplate!['Name'] ?? 'Service Request'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _serviceTemplate!['Description'] ?? '',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question['Description'] ?? 'Question',
                          style: const TextStyle(fontSize: 14.0),
                        ),
                        _buildInputField(
                          question['Type'] ?? 'String',
                          question['ID'],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _submitFilledService,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

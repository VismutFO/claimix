import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart';

class BFilledServiceDetails extends StatefulWidget {
  final String filledServiceId; // UUID of the filled service
  final String token; // Authentication token for the API

  const BFilledServiceDetails({
    Key? key,
    required this.filledServiceId,
    required this.token,
  }) : super(key: key);

  @override
  State<BFilledServiceDetails> createState() => _BFilledServiceDetailsState();
}

class _BFilledServiceDetailsState extends State<BFilledServiceDetails> {
  bool _isLoading = false; // Loading state for the page
  BFilledServiceWithDetails? _serviceDetails; // Details fetched from the backend
  String? _errorMessage; // Error message for failed API calls

  @override
  void initState() {
    super.initState();
    _fetchServiceDetails(); // Fetch data when the widget is initialized
  }

  /// Fetches filled service details from the backend API.
  Future<void> _fetchServiceDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getBusinessFilledServiceWithDetails}');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "filled_service_id": widget.filledServiceId, // UUID key
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        setState(() {
          _serviceDetails = BFilledServiceWithDetails.fromJson(data);
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch service details: ${response.statusCode}';
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'An error occurred while fetching data: $error';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filled Service Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Loading spinner
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!)) // Error message
          : _buildServiceDetails(), // Details display
    );
  }

  /// Builds the details view when data is fetched successfully.
  Widget _buildServiceDetails() {
    if (_serviceDetails == null) {
      return const Center(child: Text('No service details available.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Template Name
          Text(
            _serviceDetails!.serviceTemplateName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Service Template Description
          Text(
            _serviceDetails!.serviceTemplateDescription,
            style: const TextStyle(fontSize: 16),
          ),
          const Divider(height: 32),

          // Questions and Answers
          const Text(
            'Questions & Answers:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Dynamically generate question-answer pairs
          ListView.separated(
            itemCount: _serviceDetails!.serviceData.length,
            physics: const NeverScrollableScrollPhysics(), // Disable inner scrolling
            shrinkWrap: true,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final questionAnswer = _serviceDetails!.serviceData[index];
              return ListTile(
                title: Text(
                  questionAnswer.question,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  questionAnswer.answer,
                  style: const TextStyle(fontSize: 16),
                ),
              );
            },
          ),

          // Service Created At
          const SizedBox(height: 16),
          Text(
            'Created At: ${_serviceDetails!.createdAt.toLocal()}',
            style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
          ),

          // Service Created By
          const SizedBox(height: 16),
          Text(
            'Created By: ${_serviceDetails!.user}',
            style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

/// Model for filled service details, including template data and questions/answers.
class BFilledServiceWithDetails {
  final String serviceTemplateName;
  final String serviceTemplateDescription;
  final List<QuestionAnsweredGridRecord> serviceData;
  final DateTime createdAt;
  final String user;

  BFilledServiceWithDetails({
    required this.serviceTemplateName,
    required this.serviceTemplateDescription,
    required this.serviceData,
    required this.createdAt,
    required this.user,
  });

  /// Factory for creating an instance of the model from a JSON object.
  factory BFilledServiceWithDetails.fromJson(Map<String, dynamic> json) {
    return BFilledServiceWithDetails(
      serviceTemplateName: json['ServiceTemplateName'] as String,
      serviceTemplateDescription: json['ServiceTemplateDescription'] as String,
      serviceData: List<QuestionAnsweredGridRecord>.from(
        (json['ServiceData'] as List).map((item) => QuestionAnsweredGridRecord.fromJson(item)),
      ),
      createdAt: DateTime.parse(json['CreatedAt'] as String),
      user: json['User'] as String,
    );
  }
}

/// Model for question and answer records.
class QuestionAnsweredGridRecord {
  final String question;
  final String answer;

  QuestionAnsweredGridRecord({
    required this.question,
    required this.answer,
  });

  /// Factory for creating an instance of the model from a JSON object.
  factory QuestionAnsweredGridRecord.fromJson(Map<String, dynamic> json) {
    return QuestionAnsweredGridRecord(
      question: json['Question'] as String,
      answer: json['Answer'] as String,
    );
  }
}
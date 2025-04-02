import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'filled_service_details.dart';

/// Page that retrieves and displays filled service requests with pagination.
class FilledRequestsPage extends StatefulWidget {
  final String token; // Authentication token to be passed to the API

  const FilledRequestsPage({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  State<FilledRequestsPage> createState() => _FilledRequestsPageState();
}

class _FilledRequestsPageState extends State<FilledRequestsPage> {
  static const int _defaultRowsPerPage = 10;

  int _currentPage = 0; // Tracks the current page index
  int _rowsPerPage = _defaultRowsPerPage; // Number of records per page
  int _totalRecords = 0; // Total number of records in backend
  bool _isLoading = false; // Loading indicator state
  List<FilledServiceGridRecord> _filledRequests = []; // Fetched requests list

  @override
  void initState() {
    super.initState();
    _fetchPage(0);
  }

  /// Fetch a page of filled service requests from the backend with pagination.
  Future<void> _fetchPage(int pageIndex) async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getFilledServices}');
    final int skip = pageIndex * _rowsPerPage;

    final requestBody = {
      "count": _rowsPerPage,
      "skip": skip,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);

        setState(() {
          // Parse the "data" array into the list of records
          _filledRequests = responseData["data"] != null
              ? List<FilledServiceGridRecord>.from(
            responseData["data"].map((item) => FilledServiceGridRecord.fromJson(item)),
          ) : [];

          // Parse the "total" field for the total number of records
          _totalRecords = responseData["total"];
          _currentPage = pageIndex;
        });
      } else {
        _showErrorDialog(
          title: 'Error',
          message: 'Failed to fetch filled service requests. Status code: ${response.statusCode}.',
        );
      }
    } catch (error) {
      _showErrorDialog(
        title: 'Error',
        message: 'An error occurred while fetching data: $error',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Handling row selection.
  void _onRowSelected(FilledServiceGridRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilledServiceDetails(
          filledServiceId: record.id, // Pass record.id as filledServiceId
          token: widget.token, // Pass the token for authentication
        ),
      ),
    );
  }

  /// Show a dialog for displaying errors.
  void _showErrorDialog({required String title, required String message}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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

  /// Build pagination controls for navigating pages.
  Widget _buildPaginationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _currentPage > 0
              ? () {
            setState(() {
              _currentPage--;
            });
            _fetchPage(_currentPage); // Fetch the previous page
          }
              : null, // Disable if already on the first page
        ),
        Text('Page ${_currentPage + 1} of ${( _totalRecords / _rowsPerPage).ceil()}'),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: (_currentPage + 1) * _rowsPerPage < _totalRecords
              ? () {
            setState(() {
              _currentPage++;
            });
            _fetchPage(_currentPage); // Fetch the next page
          }
              : null, // Disable if on the last page
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filled Service Requests'),
      ),
      body: Column(
        children: [
          if (_isLoading)
            const LinearProgressIndicator(), // Show a loading progress indicator
          Expanded(
            child: _filledRequests.isEmpty && !_isLoading
                ? const Center(
              child: Text('No filled service requests found.'),
            )
                : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                showCheckboxColumn: false, // Hides the "select-all" checkbox in the header
                columns: const [
                  DataColumn(label: Text('Service Name')),
                  DataColumn(label: Text('Description')),
                  DataColumn(label: Text('Created At')),
                ],
                rows: _filledRequests.map((record) {
                  return DataRow(
                    cells: [
                      DataCell(Text(record.serviceTemplateName)),
                      DataCell(Text(record.serviceTemplateDescription)),
                      DataCell(Text(record.createdAt.toLocal().toString())),
                    ],
                    onSelectChanged: (_) {
                      _onRowSelected(record);
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildPaginationControls(),
          ),
        ],
      ),
    );
  }
}

/// Model for each filled service request.
class FilledServiceGridRecord {
  final String id;
  final String serviceTemplateName;
  final String serviceTemplateDescription;
  final DateTime createdAt;

  FilledServiceGridRecord({
    required this.id,
    required this.serviceTemplateName,
    required this.serviceTemplateDescription,
    required this.createdAt,
  });

  /// Factory method to create an instance of the model from JSON.
  factory FilledServiceGridRecord.fromJson(Map<String, dynamic> json) {
    return FilledServiceGridRecord(
      id: json['ID'] as String,
      serviceTemplateName: json['ServiceTemplateName'] as String,
      serviceTemplateDescription: json['ServiceTemplateDescription'] as String,
      createdAt: DateTime.parse(json['CreatedAt'] as String),
    );
  }
}
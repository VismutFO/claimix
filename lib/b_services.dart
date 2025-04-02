import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart'; // Import the global config file
import 'b_filled_requests.dart';

/// Page that displays services templates for a specific service provider.
///
/// Requires a `serviceProviderUuid` that is passed via the constructor.
/// Communicates with the backend to fetch paginated data of services.
class BServicesPage extends StatefulWidget {
  final String authToken;

  const BServicesPage({
    Key? key,
    required this.authToken,
  }) : super(key: key);

  @override
  State<BServicesPage> createState() => _BServicesPageState();
}

class _BServicesPageState extends State<BServicesPage> {
  static const int _defaultRowsPerPage = 10;

  int _currentPage = 0; // Tracks the current page index
  int _rowsPerPage = _defaultRowsPerPage; // Number of records per page
  int _totalRecords = 0; // Total records (retrieved from backend)
  bool _isLoading = false; // Loading state for data fetching

  List<ServiceTemplateGridRecord> _services = []; // Fetched services list

  @override
  void initState() {
    super.initState();
    _fetchPage(0);
  }

  /// Fetch the desired page of services from the backend
  Future<void> _fetchPage(int pageIndex) async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getBusinessServiceTemplates}');

    // Calculate the "skip" value (offset)
    final int skip = pageIndex * _rowsPerPage;

    final requestBody = {
      "count": _rowsPerPage,
      "skip": skip,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.authToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);

        setState(() {
          _services = responseData["data"] != null
              ? List<ServiceTemplateGridRecord>.from(
            responseData["data"].map((item) => ServiceTemplateGridRecord.fromJson(item)),
          ) : [];

          _totalRecords = responseData["total"];
          _currentPage = pageIndex;
        });
      } else {
        _showErrorDialog(
          title: 'Error',
          message: 'Failed to fetch services. Status code: ${response.statusCode}.',
        );
      }
    } catch (error) {
      _showErrorDialog(
        title: 'Error',
        message: 'An error occurred while fetching services: $error',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Show an error dialog when backend communication fails.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
      ),
      body: Column(
        children: [
          if (_isLoading)
            const LinearProgressIndicator(),
          Expanded(
            child: _services.isEmpty && !_isLoading
                ? const Center(child: Text('No services found.'))
                : _buildDataTable(),
          ),
          _buildPaginationControls(),
        ],
      ),
    );
  }

  /// Build the paginated DataTable widget for displaying services.
  Widget _buildDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        showCheckboxColumn: false, // Hides the "select-all" checkbox in the header
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Description')),
        ],
        rows: _services.map((service) {
          return DataRow(cells: [
            DataCell(Text(service.name)),
            DataCell(Text(service.description)),
          ],
            onSelectChanged: (_) {
              _navigateToBFilledServicesPage(service.id);
            },
          );
        }).toList(),
      ),
    );
  }

  void _navigateToBFilledServicesPage(String serviceId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BFilledRequestsPage(
          serviceTemplateId: serviceId, // Pass the service template ID
          token: widget.authToken, // Pass the auth token
        ),
      ),
    );
  }

  /// Build the pagination control section.
  Widget _buildPaginationControls() {
    final totalPages = (_totalRecords / _rowsPerPage).ceil(); // Calculate total pages

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Rows per page dropdown
          Row(
            children: [
              const Text('Rows per page:'),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _rowsPerPage,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _rowsPerPage = value;
                      _fetchPage(0); // Reset to the first page
                    });
                  }
                },
                items: [10, 20, 50, 100].map<DropdownMenuItem<int>>((value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
              ),
            ],
          ),

          // Pagination buttons and page info
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.navigate_before),
                onPressed: _currentPage > 0
                    ? () => _fetchPage(_currentPage - 1)
                    : null, // Disable on the first page
              ),
              Text('Page ${_currentPage + 1} of $totalPages'),
              IconButton(
                icon: const Icon(Icons.navigate_next),
                onPressed: (_currentPage + 1) < totalPages
                    ? () => _fetchPage(_currentPage + 1)
                    : null, // Disable on the last page
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Representation of the service record as received from the backend.
class ServiceTemplateGridRecord {
  final String id;
  final String businessCustomerId;
  final String name;
  final String description;

  ServiceTemplateGridRecord({
    required this.id,
    required this.businessCustomerId,
    required this.name,
    required this.description,
  });

  factory ServiceTemplateGridRecord.fromJson(Map<String, dynamic> json) {
    return ServiceTemplateGridRecord(
      id: json['ID'],
      businessCustomerId: json['BusinessCustomerID'],
      name: json['Name'],
      description: json['Description'],
    );
  }
}
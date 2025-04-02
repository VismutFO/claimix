import 'dart:convert';
import 'config.dart'; // Import the global config file
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'services.dart'; // Import the ServicesPage file

/// Page that displays service providers in a grid format.
///
/// Allows selection of a provider to navigate to detailed services page for that provider.
class ServiceProvidersPage extends StatefulWidget {
  final String token;

  const ServiceProvidersPage({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  State<ServiceProvidersPage> createState() => _ServiceProvidersPageState();
}

class _ServiceProvidersPageState extends State<ServiceProvidersPage> {
  static const int _defaultRowsPerPage = 10;

  int _currentPage = 0; // Tracks the current page index
  int _rowsPerPage = _defaultRowsPerPage; // Number of records per page
  int _totalRecords = 0; // Total records (retrieved from backend)
  bool _isLoading = false; // Loading state for data fetching

  List<ServiceProviderRecord> _serviceProviders = []; // Fetched service providers list

  @override
  void initState() {
    super.initState();
    _fetchPage(0);
  }

  /// Fetch the desired page of service providers from the backend.
  Future<void> _fetchPage(int pageIndex) async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getBusinessUsers}');

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
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);

        setState(() {
          _serviceProviders = responseData["data"] != null
              ? List<ServiceProviderRecord>.from(
            responseData["data"].map((item) => ServiceProviderRecord.fromJson(item)),
          ) : [];

          _totalRecords = responseData["total"];
          _currentPage = pageIndex;
        });
      } else {
        _showErrorDialog(
          title: 'Error',
          message: 'Failed to fetch service providers. Status code: ${response.statusCode}.',
        );
      }
    } catch (error) {
      _showErrorDialog(
        title: 'Error',
        message: 'An error occurred while fetching service providers: $error',
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
        title: const Text('Service Providers'),
      ),
      body: Column(
        children: [
          if (_isLoading)
            const LinearProgressIndicator(),
          Expanded(
            child: _serviceProviders.isEmpty && !_isLoading
                ? const Center(child: Text('No service providers found.'))
                : _buildDataTable(),
          ),
          _buildPaginationControls(),
        ],
      ),
    );
  }

  /// Build the paginated DataTable for displaying service providers.
  Widget _buildDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        showCheckboxColumn: false, // Hides the "select-all" checkbox in the header
        columns: const [
          DataColumn(label: Text('Name')),
        ],
        rows: _serviceProviders.map((provider) {
          return DataRow(
            cells: [
              DataCell(Text(provider.name)),
            ],
            onSelectChanged: (_) {
              _navigateToServicesPage(provider.id);
            }, // Navigate to ServicesPage on row selection
          );
        }).toList(),
      ),
    );
  }

  /// Navigate to the ServicesPage for the selected service provider.
  void _navigateToServicesPage(String serviceProviderUuid) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ServicesPage(
          serviceProviderUuid: serviceProviderUuid,
          authToken: widget.token,
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

/// Representation of the service provider record received from the backend.
class ServiceProviderRecord {
  final String id;
  final String name;

  ServiceProviderRecord({
    required this.id,
    required this.name,
  });

  factory ServiceProviderRecord.fromJson(Map<String, dynamic> json) {
    return ServiceProviderRecord(
      id: json['ID'],
      name: json['Name'],
    );
  }
}
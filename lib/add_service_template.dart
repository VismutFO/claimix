import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'bdashboard.dart';

class AddServiceTemplatePage extends StatefulWidget {
  final String token; // Authentication token to be passed to the API

  const AddServiceTemplatePage({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  _AddServiceTemplatePageState createState() => _AddServiceTemplatePageState();
}

class _AddServiceTemplatePageState extends State<AddServiceTemplatePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<Map<String, dynamic>> _fieldFormats = [];

  void _addFieldFormat() {
    setState(() {
      _fieldFormats.add({
        'Number': _fieldFormats.length + 1, // Auto-incremented number
        'Type': 'int', // Default to "int"
        'Description': '',
      });
    });
  }

  void _removeFieldFormat(int index) {
    setState(() {
      _fieldFormats.removeAt(index);
      // Update numbers
      for (int i = 0; i < _fieldFormats.length; i++) {
        _fieldFormats[i]['Number'] = i + 1;
      }
    });
  }

  Future<void> _submitForm() async {
    final Map<String, dynamic> serviceTemplateRequest = {
      'Name': _nameController.text,
      'Description': _descriptionController.text,
      'FieldsFormat': _fieldFormats.map((field) {
        return {
          'Type': field['Type'],
          'Description': field['Description'],
          'Number': field['Number'],
        };
      }).toList(),
    };

    try {
      // Replace with your backend API endpoint
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.addServiceTemplate}'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(serviceTemplateRequest),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        // Show the popup and wait for it to be closed
        _showPopupDialog('Success', responseData['message']).then((_) {
          // Navigate to Dashboard and pass the token
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BDashboardPage(token: widget.token),
            ),
          );
        });
      } else {
        _showPopupDialog('Failure', 'Failed to submit the form.');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred: $error')),
      );
    }
  }

  Future<void> _showPopupDialog(String title, String message) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double horizontalMargin = screenWidth * 0.2; // 20% margin on each side

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Service Template'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
        child: ListView(
          children: [
            const SizedBox(height: 16.0),
            // Name Input
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Description Input
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Field Formats
            Text('Field Formats:', style: Theme.of(context).textTheme.labelSmall),
            ..._fieldFormats.asMap().entries.map((entry) {
              final index = entry.key;
              final field = entry.value;
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Field #${field['Number']}', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),

                      // Type Dropdown
                      DropdownButton<String>(
                        value: field['Type'],
                        items: ['int', 'float', 'string']
                            .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            field['Type'] = value!;
                          });
                        },
                      ),

                      // Description Input
                      TextField(
                        decoration: InputDecoration(labelText: 'Description'),
                        onChanged: (value) {
                          field['Description'] = value;
                        },
                      ),
                      SizedBox(height: 8),

                      // Remove Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => _removeFieldFormat(index),
                          child: Text('Remove', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

            // Add Field Format Button
            ElevatedButton(
              onPressed: _addFieldFormat,
              child: Text('+ Add Field Format'),
            ),
            SizedBox(height: 16),

            // Submit Button
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
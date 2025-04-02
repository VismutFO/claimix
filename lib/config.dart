import 'dart:convert';
import 'dart:html';
import 'dart:async';

class ApiConfig {
  static late final String hostname;
  static late final String port;

  static Future<void> loadConfig() async {
    final response = await HttpRequest.getString('config.json');
    final config = jsonDecode(response);
    hostname = config['API_HOSTNAME'] ?? 'localhost';
    port = config['API_PORT'] ?? '9998';
  }

  static String get baseUrl => 'http://$hostname:$port';

  // Example endpoints
  static const String getIndividualDashboard = '/dashboard';
  static const String getBusinessDashboard = '/business/dashboard';
  static const String getBusinessUsers = '/getBusinessUsers';
  static const String getServiceTemplates = '/getServiceTemplates';
  static const String getBusinessServiceTemplates = '/business/getServiceTemplates';
  static const String getServiceTemplate = '/getServiceTemplateWithQuestions';
  static const String submitServiceRequest = '/addFilledService';
  static const String getFilledServices = '/getFilledServices';
  static const String getBusinessFilledServices = '/business/getFilledServices';
  static const String getFilledServiceWithDetails =
      '/getFilledServiceWithDetails';
  static const String getBusinessFilledServiceWithDetails =
      '/business/getFilledServiceWithDetails';
  static const String addServiceTemplate = '/business/addServiceTemplate';

  static const String individualLogin = '/login';
  static const String businessLogin = '/business/login';
  static const String individualRegister = '/register';
  static const String businessRegister = '/business/register';
}

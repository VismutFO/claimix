import 'package:flutter/material.dart';
import 'login.dart';
import 'register.dart';
import 'config.dart';

void main() async {
  // Ensure the configuration is loaded before running the app
  WidgetsFlutterBinding.ensureInitialized();
  await ApiConfig.loadConfig(); // Load the configuration file

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Authentication',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(
            registerRoute: '/register',
        ),
        '/register': (context) => const RegisterPage(
            loginRoute: '/login'
        ),
/*        '/idashboard': (context) => const IDashboardPage(
            token: ''
        ), // Added dashboard route
        '/bdashboard': (context) => const BDashboardPage(
            token: ''
        ), // Added dashboard route
  */    },
    );
  }
}

import 'package:flutter/material.dart';
import 'login.dart';
import 'idashboard.dart';
import 'bdashboard.dart';
import 'register.dart';

void main() {
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
            individualLoginUrl: 'http://localhost:9998/login',
            businessLoginUrl: 'http://localhost:9998/business/login',
            registerRoute: '/register',
            individualDashboardRoute: 'http://localhost:9998/dashboard',
            businessDashboardRoute: 'http://localhost:9998/business/dashboard',
        ),
        '/register': (context) => const RegisterPage(
            individualRegisterUrl: 'http://localhost:9998/register',
            businessRegisterUrl: 'http://localhost:9998/business/register',
            loginRoute: '/login'
        ),
        '/idashboard': (context) => const IDashboardPage(
            dashboardUrl: 'http://localhost:9998/dashboard',
            token: ''
        ), // Added dashboard route
        '/bdashboard': (context) => const BDashboardPage(
            dashboardUrl: 'http://localhost:9998/business/dashboard',
            token: ''
        ), // Added dashboard route
      },
    );
  }
}

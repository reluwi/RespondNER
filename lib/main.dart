import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/summary_screen.dart';
import 'screens/about_screen.dart';
import 'screens/accounts_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: MaterialApp(
        title: 'Respond NER',
        theme: ThemeData(
          primaryColor: const Color(0xFF8B1F1F),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF8B1F1F),
          ),
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/summary': (context) => const SummaryScreen(),
          '/about': (context) => const AboutScreen(),
          '/accounts': (context) => const AccountsScreen(),
        },
      ),
    );
  }
}

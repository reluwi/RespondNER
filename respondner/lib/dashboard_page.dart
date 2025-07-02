import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart'; 

// Import your new, separated components
import 'screens/dashboard_view.dart';
import 'screens/accounts_view.dart';
import 'screens/summary_view.dart'; 
//import 'screens/about_us_view.dart';
import 'widgets/side_menu.dart';

class DashboardPage extends StatefulWidget {
  final String userEmail;
  const DashboardPage({super.key, required this.userEmail});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // The state that is SHARED across all pages
  String _username = 'Loading...'; 
  bool _isAdmin = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    final url = Uri.parse('https://respondner-api.onrender.com/get_user_details?email=${widget.userEmail}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _username = data['username'] ?? 'User';
          _isAdmin = data['is_admin'] ?? false;
        });
      }
    } catch (e) {
      setState(() { _username = 'Responder'; _isAdmin = false; });
    }
  }

  void _onSelectItem(int index) {
    if (index == 4) { // Sign Out
      _showSignOutDialog();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }
  
  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A4A7A), // Dark blue from the image
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: const Text(
            'Sign Out?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          content: const Text(
            'Do you want to end your session and sign out?',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            // "No" Button
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: const Text('No', style: TextStyle(color: Colors.white)),
              onPressed: () {
                // Close the dialog
                Navigator.of(dialogContext).pop();
              },
            ),
            const SizedBox(width: 10),
            // "Yes" Button
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: const Text('Yes', style: TextStyle(color: Colors.white)),
              onPressed: () {
                // This will clear all screens and push the LoginPage,
                // so the user cannot go "back" to the dashboard.
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  // This function now acts as a router to select the correct screen
  Widget _buildCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardView();
      
      case 1:
        // Return a placeholder widget for the Summary page
        return const SummaryView();

      case 2:
        // Return a placeholder widget for the About Us page
        return const Center(
          child: Text(
            'About Us Page - Coming Soon',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        );

      case 3:
        // This logic is correct: only show AccountsView if the user is an admin
        return _isAdmin ? const AccountsView() : const DashboardView();
      
      default:
        // Default to the main dashboard if the index is somehow invalid
        return const DashboardView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: Row(
        children: [
          // The reusable side menu widget
          SideMenu(
            username: _username,
            isAdmin: _isAdmin,
            selectedIndex: _selectedIndex,
            onItemSelected: _onSelectItem,
          ),
          // The main content area that changes
          Expanded(
            child: _buildCurrentScreen(),
          ),
        ],
      ),
    );
  }
}


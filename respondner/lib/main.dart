import 'package:flutter/material.dart';
import 'dashboard_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RespondNER Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Using a sans-serif font family that is common on most systems
        fontFamily: 'sans-serif',
        // Set a global background color for the app
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // A list of dummy agency names for the dropdown
  final List<String> _agencies = [
    'National Disaster Response Force',
    'State Disaster Response Force',
    'Local Fire Department',
    'Regional Medical Services',
  ];
  String? _selectedAgency;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The 'Log In' text at the top-left corner
      appBar: AppBar(
        title: const Text('Log In', style: TextStyle(color: Colors.black54)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            // The main card container for the form
            child: Card(
              elevation: 4,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      _buildLogo(),
                      const SizedBox(height: 16),

                      // Subtitle
                      Text(
                        'Log in to track and respond to emergencies',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Form Fields
                      _buildFormField(
                        label: 'Agency Login Name:',
                        child: _buildAgencyDropdown(),
                      ),
                      const SizedBox(height: 20),

                      _buildFormField(
                        label: 'Email:',
                        child: _buildTextField(hintText: 'Write your email'),
                      ),
                      const SizedBox(height: 20),

                      _buildFormField(
                        label: 'Password:',
                        child: _buildTextField(
                          hintText: 'Write your password',
                          obscureText: true,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Action Buttons
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // A helper method to build the logo
  Widget _buildLogo() {
    return Row(
      children: [
        // A simplified representation of the logo icon. For an exact match, an SVG image would be best.
        const Icon(Icons.emergency, color: Color(0xFFE53935), size: 48),
        const SizedBox(width: 8),
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              fontFamily: 'sans-serif',
            ),
            children: [
              TextSpan(
                text: 'Respond',
                style: TextStyle(color: Color(0xFF0B2B4B)), // Dark Blue
              ),
              TextSpan(
                text: 'NER',
                style: TextStyle(color: Color(0xFFE53935)), // Red
              ),
            ],
          ),
        ),
      ],
    );
  }

  // A helper method to create a consistent layout for form fields (label + input)
  Widget _buildFormField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
  
  // A helper method for the agency dropdown
  Widget _buildAgencyDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedAgency,
      hint: const Text('Select agency name', style: TextStyle(color: Colors.black54)),
      decoration: _inputDecoration(),
      items: _agencies.map((String agency) {
        return DropdownMenuItem<String>(
          value: agency,
          child: Text(agency),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedAgency = newValue;
        });
      },
    );
  }

  // A helper method to build styled text fields
  Widget _buildTextField({required String hintText, bool obscureText = false}) {
    return TextFormField(
      obscureText: obscureText,
      decoration: _inputDecoration(hintText: hintText),
    );
  }

  // Reusable input decoration for form fields
  InputDecoration _inputDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.black45),
      filled: true,
      fillColor: Colors.grey[200],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(
          color: Colors.blue, // Highlight color on focus
          width: 2.0,
        ),
      ),
    );
  }

  // A helper method for the login and help buttons
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // --- NAVIGATION LOGIC ADDED HERE ---
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const DashboardPage()),
              );
              // --- END OF NAVIGATION LOGIC ---
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F), // Red button
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text('Log In', style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Handle "Can't Sign in?" logic
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F), // Red button
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text('Can\'t Sign in?', style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dashboard_page.dart';
import 'learn_more.dart'; // Make sure this file exists in your lib folder

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // --- STATE AND CONTROLLERS FROM OUR EXISTING LOGIC ---
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- OUR EXISTING, FUNCTIONAL LOGIN LOGIC ---
  Future<void> _login() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    const String loginUrl = 'https://respondner-api.onrender.com/login';
    
    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final String userEmail = _emailController.text;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardPage(userEmail: userEmail),
            ),
          );
        } else {
          showCantSignInDialog(context); // Use the new dialog function
        }
      } else {
        showCantSignInDialog(context);
      }
    } catch (e) {
      if (mounted) showCantSignInDialog(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- THE NEW BUILD METHOD FOR THE UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Row(
          children: [
            // --- WHITE PANEL (FORM) ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500), // Max width for the form
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/respondnerlogo.png', // Corrected path
                            width: 300,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Log in to track and respond to emergencies',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 40),
                          
                          // Agency Dropdown is REMOVED as requested

                          const Text('Email:', style: TextStyle(fontSize: 18)),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: 'Write your Email',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text('Password:', style: TextStyle(fontSize: 18)),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: 'Write Your Password',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          Row(
                            children: [
                              _buildGlowingButton('Log In', _isLoading ? null : _login),
                              const SizedBox(width: 24),
                              _buildGlowingButton('Can’t Sign in?', () {
                                showCantSignInDialog(context);
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // --- RED PANEL (INFO) ---
            // Hide this panel on smaller screens for better mobile/portrait view
            if (MediaQuery.of(context).size.width > 1000)
              Container(
                width: MediaQuery.of(context).size.width * 0.45,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE62629), Color(0xFF9B2C3A)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'From Taglish posts to\ntargeted rescue—\nRespondNER delivers',
                        style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold, height: 1.2),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'An AI-powered system that analyzes\nTaglish disaster-related social media\nposts to identify key people, places, and\nurgent needs.',
                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 24, height: 1.4),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LearnMorePage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: const BorderSide(color: Colors.white, width: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          elevation: 0, // Base elevation
                        ).copyWith(
                          side: MaterialStateProperty.resolveWith<BorderSide>((states) {
                            if (states.contains(MaterialState.hovered)) {
                              return const BorderSide(color: Colors.white, width: 3);
                            }
                            return const BorderSide(color: Colors.white, width: 2); // Default
                          }),
                          backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                            if (states.contains(MaterialState.pressed)) {
                              return Colors.white.withOpacity(0.1);
                            }
                            return Colors.transparent; // Default
                          }),
                          elevation: MaterialStateProperty.resolveWith<double>((states) {
                            if (states.contains(MaterialState.hovered)) {
                              return 12;
                            }
                            return 0; // Default
                          }),
                          shadowColor: MaterialStateProperty.resolveWith<Color>((states) {
                            if (states.contains(MaterialState.hovered)) {
                              return Colors.white.withOpacity(0.4);
                            }
                            return Colors.transparent; // Default
                          }),
                        ),
                        child: const Text('Learn more', style: TextStyle(color: Colors.white, fontSize: 24)),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper method for the glowing button styling
  Widget _buildGlowingButton(String text, VoidCallback? onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      // --- THIS IS THE UPDATED STYLE ---
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(180, 56),
        padding: const EdgeInsets.symmetric(horizontal: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        // Define default properties here
        backgroundColor: const Color(0xFFa61c1c),
        foregroundColor: Colors.white,
        elevation: 4,
        // Define properties for different states using .copyWith and MaterialStateProperty
      ).copyWith(
        backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) return Colors.grey.shade400;
          if (states.contains(MaterialState.pressed)) return const Color(0xFF9B2C3A);
          if (states.contains(MaterialState.hovered)) return const Color(0xFFE62629);
          return const Color(0xFFa61c1c); // Default
        }),
        elevation: MaterialStateProperty.resolveWith<double>((states) {
          if (states.contains(MaterialState.hovered)) return 12;
          return 4; // Default
        }),
        shadowColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.hovered)) {
            return Colors.redAccent.withOpacity(0.6);
          }
          return Colors.transparent; // Default
        }),
      ),
      // ------------------------------------
      child: text == 'Log In' && _isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
            )
          : Text(
              text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
    );
  }
}

// The new "Can't Sign In" dialog function from your design
void showCantSignInDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.3),
    builder: (context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: AlertDialog(
          backgroundColor: const Color(0xFF005A9C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          title: const Text("Can’t Sign in?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
          content: const Text(
            "Please make sure your login credentials are correct.\n\n"
            "For account assistance, contact your system administrator.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24)),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Okay", style: TextStyle(color: Color(0xFF005A9C), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    },
  );
}
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/account.dart';

class UpdateAccountPopup extends StatefulWidget {
  // It now requires the account to be updated and a success callback
  final Account accountToUpdate;
  final VoidCallback onAccountUpdated;
  
  const UpdateAccountPopup({
    super.key, 
    required this.accountToUpdate,
    required this.onAccountUpdated,
  });

  @override
  State<UpdateAccountPopup> createState() => _UpdateAccountPopupState();
}

class _UpdateAccountPopupState extends State<UpdateAccountPopup> {
  // Your existing controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedAgency;
  bool _isLoading = false;

  final List<String> _agencies = [
    'National Disaster Response Force', 'State Disaster Response Force',
    'Local Fire Department', 'Regional Medical Services', 'N/A',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill the form fields with the existing account data
    _nameController.text = widget.accountToUpdate.name;
    _emailController.text = widget.accountToUpdate.email;
    _passwordController.text = widget.accountToUpdate.password;
    
    // Ensure the agency exists in the list before setting it
    if (_agencies.contains(widget.accountToUpdate.agencyName)) {
      _selectedAgency = widget.accountToUpdate.agencyName;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // The function to call the update API
  Future<void> _updateAccount() async {
    final currentContext = context;
    if (!mounted) return;

    setState(() => _isLoading = true);
    
    // Construct the URL with the user's ID
    final String updateUrl = 'https://respondner-api.onrender.com/update_user/${widget.accountToUpdate.id}';
    final url = Uri.parse(updateUrl);

    try {
      final response = await http.put( // Using http.put
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': _nameController.text,
          'email': _emailController.text,
          'agency_name': _selectedAgency,
        }),
      );

      if (!mounted) return;
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        Navigator.of(currentContext).pop(); // Close the popup
        _showSuccessDialog(currentContext, data['message']);
        widget.onAccountUpdated(); // Refresh the list on the parent page
      } else {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Failed to update account.'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(currentContext).showSnackBar(const SnackBar(content: Text('An error occurred.'), backgroundColor: Colors.red));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Update'),
          content: const Text('Are you sure you want to save these changes?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('No')),
            ElevatedButton(onPressed: () { 
              Navigator.of(dialogContext).pop();
              _updateAccount(); 
            }, child: const Text('Yes')),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext parentContext, String message) {
    showDialog(
      context: parentContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF14426A), Color(0xFF2782D0)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message, // Use the dynamic message from the API
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () => Navigator.of(dialogContext).pop(), // Close this success dialog
                      child: const Text('Okay', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 800,
        height: 550,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Column - Form
            Expanded(
              flex: 3,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF14426A),
                      Color(0xFF2782D0),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(24),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Update Account Information',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Form Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                  // Name Field
                  const Text(
                    'Name:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: TextField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Write name',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Agency Name Field
                  const Text(
                    'Agency Name:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedAgency,
                      style: const TextStyle(color: Colors.white),
                      dropdownColor: const Color(0xFF2E5B9A),
                      decoration: const InputDecoration(
                        hintText: 'Choose agency',
                        hintStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                      ),
                      items: _agencies.map((String agency) {
                        return DropdownMenuItem<String>(
                          value: agency,
                          child: Text(
                            agency,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedAgency = newValue;
                        });
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Email Field
                  const Text(
                    'Email:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: TextField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'Write email',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Password Field
                  const Text(
                    'Update Password:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      style: const TextStyle(color: Colors.white),
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Write password',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                            const Spacer(),
                            
                            // Update Account Button
                            Align(
                              alignment: Alignment.centerRight,
                              child: OutlinedButton(
                                // Use the confirmation dialog here
                                onPressed: _isLoading ? null : _showConfirmationDialog,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white, width: 2),
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                ),
                                // Use the _isLoading flag to show the spinner
                                child: _isLoading
                                  ? const SizedBox(
                                      width: 24, height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Text(
                                      'Update account!',
                                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                                    ),
                              ),
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Right Column - Title and Logo
            Expanded(
              flex: 2,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Stack(
                  children: [
                    // Close button
                    Positioned(
                      top: 16,
                      right: 16,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    
                    // Content - 2x2 Grid Layout
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          // First Column - Logo (spans both rows)
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: Container(
                                width: 300,
                                height: 90,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.zero,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.zero,
                                  child: Image.asset(
                                    '../../assets/respondnerlogo.png', // Replace with your image path
                                    fit: BoxFit.cover,
                                    alignment: Alignment.center,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
}
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DeleteAccountPopup extends StatefulWidget {
  final Set<int> selectedAccountIds;
  final VoidCallback? onDeleteSuccess;

  const DeleteAccountPopup({
    super.key,
    required this.selectedAccountIds,
    this.onDeleteSuccess,
  });

  @override
  State<DeleteAccountPopup> createState() => _DeleteAccountPopupState();
}

class _DeleteAccountPopupState extends State<DeleteAccountPopup> {
  bool _isDeleting = false;

  Future<void> _deleteAccounts() async {
    // Store context and check if mounted *before* the async call
    final currentContext = context;
    if (!mounted) return;

    setState(() => _isDeleting = true);

    const String deleteUrl = 'https://respondner-api.onrender.com/delete_users';
    final url = Uri.parse(deleteUrl);

    try {
      final response = await http.delete( // Using the correct http.delete verb
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'ids': widget.selectedAccountIds.toList(),
        }),
      );

      // Check if the widget is still mounted *after* the async call
      if (!mounted) return;

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        Navigator.of(currentContext).pop(); // Close the confirmation popup
        _showSuccessDialog(currentContext, data['message']);
        widget.onDeleteSuccess?.call(); // Call the callback to refresh the list
      } else {
        _showErrorMessage(currentContext, data['message'] ?? "Failed to delete accounts.");
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage(currentContext, "An error occurred. Please try again.");
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  void _showSuccessDialog(BuildContext parentContext, String message) {
    showDialog(
      context: parentContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF14426A), Color(0xFF2782D0)])),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Okay', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.white), borderRadius: BorderRadius.circular(4)),
                      ),
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

  void _showErrorMessage(BuildContext parentContext, String message) {
    ScaffoldMessenger.of(parentContext).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int accountCount = widget.selectedAccountIds.length;
    final String accountText = accountCount == 1 ? 'account' : 'accounts';

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        width: 400,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF14426A), Color(0xFF2782D0)]),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to delete $accountCount $accountText?',
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text('This action cannot be undone.', style: TextStyle(color: Colors.white), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            if (_isDeleting)
              const CircularProgressIndicator(color: Colors.white)
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _deleteAccounts,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: const RoundedRectangleBorder()),
                    child: const Text('Yes', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white), shape: const RoundedRectangleBorder()),
                    child: const Text('No', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DeleteAccountPopup extends StatefulWidget {
  final Set<int> selectedAccountIds;
  final VoidCallback? onDeleteSuccess;

  const DeleteAccountPopup({
    Key? key,
    required this.selectedAccountIds,
    this.onDeleteSuccess,
  }) : super(key: key);

  @override
  State<DeleteAccountPopup> createState() => _DeleteAccountPopupState();
}

class _DeleteAccountPopupState extends State<DeleteAccountPopup> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final int accountCount = widget.selectedAccountIds.length;
    final String accountText = accountCount == 1 ? 'account' : 'accounts';

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        width: 400,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF14426A),
              Color(0xFF2782D0),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to delete ${accountCount} ${accountText}?',
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (_isDeleting)
              const CircularProgressIndicator(color: Colors.white)
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _deleteAccounts,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: const Text('Yes', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: const Text('No', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAccounts() async {
    setState(() => _isDeleting = true);

    const String deleteUrl = 'https://respondner-api.onrender.com/delete_users';
    final url = Uri.parse(deleteUrl);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'ids': widget.selectedAccountIds.toList(),
        }),
      );

      if (response.statusCode == 200) {
        // Success - close popup and show success message
        Navigator.of(context).pop();
        _showSuccessDialog();
        // Call the callback to refresh the accounts list
        if (widget.onDeleteSuccess != null) {
          widget.onDeleteSuccess!();
        }
      } else {
        // Handle server errors
        setState(() => _isDeleting = false);
        _showErrorMessage("Failed to delete accounts. Server error.");
      }
    } catch (e) {
      // Handle network errors
      setState(() => _isDeleting = false);
      _showErrorMessage("An error occurred while deleting accounts.");
    }
  }

  void _showSuccessDialog() {
    final int accountCount = widget.selectedAccountIds.length;
    final String accountText = accountCount == 1 ? 'account has' : 'accounts have';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Container(
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
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'The ${accountCount} ${accountText} been removed successfully',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Okay'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
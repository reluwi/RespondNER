import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/account.dart';
import '../popup/create_account_popup.dart';
import '../popup/update_account_popup.dart';
import '../popup/delete_account_popup.dart';

class AccountsView extends StatefulWidget {
  const AccountsView({super.key});

  @override
  State<AccountsView> createState() => _AccountsViewState();
}

class _AccountsViewState extends State<AccountsView> {
  // State specific to the Accounts page
  final _searchController = TextEditingController();
  String _selectedAgency = 'All';
  List<Account> _allAccounts = [];
  List<Account> _filteredAccounts = [];
  final Set<int> _selectedAccountIds = {};
  bool _isSelectAll = false;
  bool _isAccountsLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAccounts();
    _searchController.addListener(_filterAccounts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAccounts() async {
  setState(() => _isAccountsLoading = true);

  const String accountsUrl = 'https://respondner-api.onrender.com/get_all_users';
  final url = Uri.parse(accountsUrl);

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _allAccounts = data.map((json) => Account.fromJson(json)).toList();
        _filteredAccounts = _allAccounts; // Initialize filtered list
        _isAccountsLoading = false;
      });
    } else {
      // Handle server errors
      setState(() => _isAccountsLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch accounts."), backgroundColor: Colors.red)
      );
    }
  } catch (e) {
    // Handle network errors
    setState(() => _isAccountsLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("An error occurred."), backgroundColor: Colors.red)
    );
  }
}

  void _filterAccounts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredAccounts = _allAccounts.where((account) {
        final agencyMatches = _selectedAgency == 'All' || account.agencyName == _selectedAgency;
        final searchMatches = query.isEmpty || account.name.toLowerCase().contains(query) || account.email.toLowerCase().contains(query);
        return agencyMatches && searchMatches;
      }).toList();
    });
  }

  void _deleteSelectedItems() {
    if (_selectedAccountIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No accounts selected for deletion."), 
          backgroundColor: Colors.orange
        )
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteAccountPopup(
          selectedAccountIds: _selectedAccountIds,
          onDeleteSuccess: () {
            // Clear selections and refresh the accounts list
            setState(() {
              _selectedAccountIds.clear();
              _isSelectAll = false;
            });
            _fetchAccounts(); // Refresh the accounts list
          },
        );
      },
    );
  }

  void _addNewItem() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const CreateAccountPopup(); // This returns your popup widget
      },
    );
  }

  void _updateItem() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const UpdateAccountPopup(); // This returns your popup widget
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAccountsTitleBar(),
        _buildAccountsActionBar(),
        Expanded(child: _buildAccountsTable()),
      ],
    );
  }

  Widget _buildAccountsTitleBar() {
    return Container(
      padding: const EdgeInsets.all(6),
      width: double.infinity,
      color: const Color(0xFFa61c1c), // Using your app's red
      child: const Center(
        child: Text(
          'Account Records',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAccountsActionBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Search and Filter Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search by name or email',
                      border: InputBorder.none,
                      icon: Icon(Icons.search),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedAgency,
                    items: ['All', 'Agency 1', 'Agency 2'].map((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() => _selectedAgency = newValue);
                        _filterAccounts();
                      }
                    },
                    hint: const Text('Filter by Agency'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Action Buttons Row
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _addNewItem, // Connected to your existing function
                icon: const Icon(Icons.add), label: const Text('Add new'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _deleteSelectedItems, // Connected to new delete logic
                icon: const Icon(Icons.delete), label: const Text('Delete'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFa61c1c), foregroundColor: Colors.white),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _updateItem, // Connected to your existing function
                icon: const Icon(Icons.update), label: const Text('Update'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountsTable() {
    if (_isAccountsLoading) {
    return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300)
          ),
          child: Table(
            border: TableBorder.all(color: Colors.grey[300]!, width: 1),
            columnWidths: const {
              0: FixedColumnWidth(50), 1: FlexColumnWidth(1.5), 2: FlexColumnWidth(1.5),
              3: FlexColumnWidth(2.5), 4: FlexColumnWidth(2), 5: FlexColumnWidth(2),
            },
            children: [
              _buildAccountsTableHeader(), // Header Row
              // Dynamic Data Rows from our state
              ..._filteredAccounts.map((account) => _buildAccountTableRow(account)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildAccountsTableHeader() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey[200]),
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Checkbox(
              value: _isSelectAll,
              onChanged: (bool? value) {
                setState(() {
                  _isSelectAll = value ?? false;
                  if (_isSelectAll) {
                    _selectedAccountIds.addAll(_filteredAccounts.map((a) => a.id));
                  } else {
                    _selectedAccountIds.clear();
                  }
                });
              },
            ),
          ),
        ),
        // Helper to create header cells
        _buildHeaderCell('Account'), _buildHeaderCell('Agency Name'),
        _buildHeaderCell('Email Address'), _buildHeaderCell('Name'),
        _buildHeaderCell('Password'),
      ],
    );
  }

  TableCell _buildHeaderCell(String text) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  TableRow _buildAccountTableRow(Account account) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Checkbox(
              value: _selectedAccountIds.contains(account.id),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedAccountIds.add(account.id);
                  } else {
                    _selectedAccountIds.remove(account.id);
                  }
                });
              },
            ),
          ),
        ),
        _buildTableCell(account.accountType), _buildTableCell(account.agencyName),
        _buildTableCell(account.email), _buildTableCell(account.name),
        _buildTableCell(account.password),
      ],
    );
  }

  TableCell _buildTableCell(String text) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(text),
      ),
    );
  }
}
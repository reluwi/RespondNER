import 'package:flutter/material.dart';
import '../widgets/side_menu.dart';
import '../widgets/data_table_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedFilter = 'Location';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const SideMenu(),
          Expanded(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset(
                      'assets/respondnerlogo.png',
                      height: 80,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search by keyword',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      DropdownButton<String>(
                        hint: const Text('Date Range'),
                        items: const [
                          DropdownMenuItem(value: 'today', child: Text('Today')),
                          DropdownMenuItem(value: 'week', child: Text('This Week')),
                          DropdownMenuItem(value: 'month', child: Text('This Month')),
                        ],
                        onChanged: (value) {},
                      ),
                      const SizedBox(width: 16),
                      DropdownButton<String>(
                        hint: const Text('Filter by Location'),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All Locations')),
                          DropdownMenuItem(value: 'north', child: Text('North Region')),
                          DropdownMenuItem(value: 'south', child: Text('South Region')),
                        ],
                        onChanged: (value) {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _buildFilterButton('Location'),
                      const SizedBox(width: 8),
                      _buildFilterButton('People'),
                      const SizedBox(width: 8),
                      _buildFilterButton('Organization'),
                      const SizedBox(width: 8),
                      _buildFilterButton('Emergency'),
                      const SizedBox(width: 8),
                      _buildFilterButton('Needs'),
                    ],
                  ),
                ),
                const Expanded(
                  child: DataTableWidget(),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Last Update: 1:00pm'),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label) {
    final isSelected = _selectedFilter == label;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFilter = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            border: Border.all(color: isSelected ? Colors.red : Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.red : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
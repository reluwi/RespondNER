import 'package:flutter/material.dart';
import 'main.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class EmergencyPost {
  final String timestamp;
  final String extractedPost;
  final String namedEntities;

  EmergencyPost({
    required this.timestamp,
    required this.extractedPost,
    required this.namedEntities,
  });
}

class _DashboardPageState extends State<DashboardPage> {
  // State to track the active navigation item
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Define the primary red color from the design
    const Color primaryRed = Color(0xFFa61c1c);

    return Scaffold(
      backgroundColor: Colors.grey[300], // The outer gray background
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          decoration: BoxDecoration(
            color: primaryRed,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              // Left Side Navigation
              _buildSideNav(primaryRed),
              // Right Main Content
              _buildMainContent(),
            ],
          ),
        ),
      ),
    );
  }

  final List<EmergencyPost> _samplePosts = [
    EmergencyPost(
      timestamp: '2025-05-09 13:21',
      extractedPost: 'Baha na dito sa Marikina, walang tulong!',
      namedEntities: '[Location: Marikina], [Emergency: baha]',
    ),
    EmergencyPost(
      timestamp: '2025-05-09 12:21',
      extractedPost: 'Need rescue sa Barangay Bagong Silangan!',
      namedEntities: '[Location: Bagong Silangan], [Emergency: rescue]',
    ),
    EmergencyPost(
      timestamp: '2025-05-09 12:20',
      extractedPost: 'Si Lola Fe naiwan sa rooftop ng bahay!',
      namedEntities: '[Person: Lola Fe], [Emergency: stranded]',
    ),
    EmergencyPost(
      timestamp: '2025-05-09 11:55',
      extractedPost: 'DSWD and NDRRMC coordinating relief efforts in Cainta.',
      namedEntities: '[Organization: DSWD], [Organization: NDRRMC], [Location: Cainta], [Emergency: relief efforts]',
    ),
    EmergencyPost(
      timestamp: '2025-05-09 11:30',
      extractedPost: 'Urgent help needed in Makati. Flash flood reported.',
      namedEntities: '[Location: Makati], [Emergency: flash flood]',
    ),
  ];

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Use a different context for the dialog
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

  // Widget for the left navigation panel
  Widget _buildSideNav(Color primaryRed) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Profile Section
          _buildUserProfile(),
          const SizedBox(height: 40),
          // Navigation Items
          _buildNavItem(0, 'Dashboard', primaryRed),
          _buildNavItem(1, 'Summary', primaryRed),
          _buildNavItem(2, 'About us', primaryRed),
          const Spacer(), // Pushes Sign Out to the bottom
          _buildNavItem(3, 'Sign Out', primaryRed),
        ],
      ),
    );
  }

  // Widget for the user profile display
  Widget _buildUserProfile() {
    return const Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.white,
          child: Icon(Icons.person, size: 30, color: Color(0xFFa61c1c)),
        ),
        SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Responder',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            Text(
              'Clyde Lopez',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Widget for a single navigation item
  Widget _buildNavItem(int index, String title, Color primaryColor) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        // Check if the tapped item is 'Sign Out'
        if (title == 'Sign Out') {
          _showSignOutDialog(); // Call the dialog function
        } else {
          // Otherwise, just update the selected index
          setState(() {
            _selectedIndex = index;
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: primaryColor.withOpacity(0.5), width: 2)
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? primaryColor : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // Widget for the main content area on the right
  Widget _buildMainContent() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildEntityFilters(),
            const SizedBox(height: 20),
            _buildDataTable(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // Widget for the header containing logo and search filters
  Widget _buildHeader() {
    return Row(
      children: [
        // Logo
        RichText(
          text: const TextSpan(
            style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'sans-serif'),
            children: [
              TextSpan(text: 'Respond', style: TextStyle(color: Color(0xFF0B2B4B))),
              TextSpan(text: 'NER', style: TextStyle(color: Color(0xFFE53935))),
            ],
          ),
        ),
        const Spacer(),
        // Search & Filter controls
        _buildSearchField(),
        const SizedBox(width: 15),
        _buildDropdown("Date Range"),
        const SizedBox(width: 15),
        _buildDropdown("Filter by Location"),
      ],
    );
  }

  // Widget for the search input field
  Widget _buildSearchField() {
    return SizedBox(
      width: 200,
      height: 40,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by keyword',
          suffixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        ),
      ),
    );
  }

  // Reusable widget for dropdown buttons
  Widget _buildDropdown(String hint) {
    return Container(
      width: 180,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(hint),
          items: const [], // Add your dropdown items here
          onChanged: (value) {},
        ),
      ),
    );
  }

  // Widget for the entity filter chips
  Widget _buildEntityFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filter Entities by:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: ['Location', 'People', 'Organization', 'Emergency', 'Needs']
              .map((label) => OutlinedButton(
                    onPressed: () {},
                    child: Text(label),
                  ))
              .toList(),
        ),
      ],
    );
  }

  // Widget for the data table section
  Widget _buildDataTable() {
    const headerStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
      color: Color(0xFF333333),
    );
    const cellStyle = TextStyle(
      fontSize: 14,
      color: Color(0xFF333333),
    );

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            // Table Header
            Container(
              color: Colors.grey.shade200, // Lighter header color
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: const Row(
                children: [
                  Expanded(child: Text('TIMESTAMP', style: headerStyle)),
                  Expanded(
                      flex: 2, child: Text('EXTRACTED POST', style: headerStyle)),
                  Expanded(
                      flex: 2, child: Text('NAMED ENTITIES', style: headerStyle)),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1),

            // Table Body - built from the sample data
            Expanded(
              child: ListView.builder(
                itemCount: _samplePosts.length,
                itemBuilder: (context, index) {
                  final post = _samplePosts[index];
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(post.timestamp, style: cellStyle),
                            ),
                            Expanded(
                              flex: 2,
                              child:
                                  Text(post.extractedPost, style: cellStyle),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(post.namedEntities, style: cellStyle),
                            ),
                          ],
                        ),
                      ),
                      if (index < _samplePosts.length - 1)
                        const Divider(height: 1, thickness: 1),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for the footer with refresh button
  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Row(
        children: [
          const Text('Last Update: 1:00pm', style: TextStyle(color: Colors.grey)),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text('Refresh', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
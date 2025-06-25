import 'package:flutter/material.dart';
import 'main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  final String userEmail;
  
  const DashboardPage({super.key, required this.userEmail});

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

  factory EmergencyPost.fromJson(Map<String, dynamic> json) {
    return EmergencyPost(
      timestamp: json['timestamp'] ?? 'N/A',
      extractedPost: json['extractedPost'] ?? 'No content',
      namedEntities: json['namedEntities'] ?? 'N/A',
    );
  }
}

class _DashboardPageState extends State<DashboardPage> {
  String _username = 'Loading...'; 
  bool _isAdmin = false;
  
  // State to track the active navigation item
  int _selectedIndex = 0;
  bool _isLoading = true; // Start in loading state
  String? _errorMessage;
  
  // State for search functionality
  final _searchController = TextEditingController();
  List<EmergencyPost> _posts = []; // This will live data
  List<EmergencyPost> _filteredPosts = []; // This list will be displayed

  // State variables for the date range filter
  DateTime? _startDate;
  DateTime? _endDate;

  // State variables for the location filter
  String? _selectedLocation;
  List<String> _uniqueLocations = [];

  // This function runs once when the widget is first created
  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _fetchPosts(); // Call the function to get data from the server
    _searchController.addListener(_filterPosts); // Add a listener to the search controller to filter posts in real-time
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Function to fetch user details from the new endpoint
  Future<void> _fetchUserDetails() async {
  final url = Uri.parse('https://respondner-api.onrender.com/get_user_details?email=${widget.userEmail}');
  
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _username = data['username'] ?? 'User';
        _isAdmin = data['is_admin'] ?? false; // Get the admin status
      });
    } else {
      setState(() { _username = 'Responder'; _isAdmin = false; });
    }
  } catch (e) {
    setState(() { _username = 'Responder'; _isAdmin = false; });
  }
}

  void _filterPosts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      // Start with the full master list of posts
      List<EmergencyPost> tempFilteredList = _posts;

      // 1. Filter by the search keyword (if any)
      if (query.isEmpty) {
        // If the search bar is empty, show all posts
        _filteredPosts = _posts;
      } else {
        // Otherwise, filter the master list
        _filteredPosts = _posts.where((post) {
          final postText = post.extractedPost.toLowerCase();
          return postText.contains(query);
        }).toList();
      }

      // 2. Filter by the date range (if any)
      if (_startDate != null && _endDate != null) {
        tempFilteredList = tempFilteredList.where((post) {
          // We need to parse the post's timestamp string into a DateTime object
          try {
            final postDate = DateTime.parse(post.timestamp);
            return postDate.isAfter(_startDate!) && postDate.isBefore(_endDate!);
          } catch (e) {
            // If the timestamp format is invalid, exclude it from the results
            return false;
          }
        }).toList();
      }

      // 3. NEW: Filter by selected location
      if (_selectedLocation != null) {
        tempFilteredList = tempFilteredList.where((post) =>
          post.namedEntities.contains('[Location: $_selectedLocation]')
        ).toList();
      }

      // Update the final list that is displayed on screen
      _filteredPosts = tempFilteredList;

    });
  }

  // Function to show the date range picker dialog
  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020), // The earliest possible date
      lastDate: DateTime.now(),   // The latest possible date
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null, // Pre-select the current range if it exists
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        // The end date from the picker is the start of the day, so we add a day
        // to make the range inclusive of the selected end day.
        _endDate = picked.end.add(const Duration(days: 1));
      });
      // After selecting a new date range, re-apply the filters.
      _filterPosts();
    }
  }

  // The function that calls your Python API
  Future<void> _fetchPosts() async {
    // URL for deployed API
    const String postsUrl = 'https://respondner-api.onrender.com/get_mock_posts';
    final url = Uri.parse(postsUrl);

    // Reset state before fetching
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _startDate = null;
      _endDate = null;
    });

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<EmergencyPost> fetchedPosts = data.map((json) => EmergencyPost.fromJson(json)).toList();

        // Logic to extract unique, non-empty locations
        final Set<String> locations = {};
        for (var post in fetchedPosts) {
          // A bit of regex to find location entities like [Location: Marikina]
          final RegExp regex = RegExp(r'\[Location: (.*?)\]');
          final matches = regex.allMatches(post.namedEntities);
          for (final match in matches) {
            final locationName = match.group(1);
            if (locationName != null && locationName.isNotEmpty) {
              locations.add(locationName.trim());
            }
          }
        }

        setState(() {
          // Convert the list of json maps to a list of EmergencyPost objects
          _posts = fetchedPosts;
          _filteredPosts = _posts; // Initialize filtered posts with all posts

          // Set the state for the new location data
          _uniqueLocations = locations.toList()..sort(); // Convert Set to a sorted List
          _selectedLocation = null; // Reset selected location on new fetch

          _startDate = null;
          _endDate = null;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load posts (Status code: ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please check your connection.';
        _isLoading = false;
      });
    }
  }

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
          if (_isAdmin)
            _buildNavItem(3, 'Accounts', primaryRed),
          const Spacer(), // Pushes Sign Out to the bottom
          _buildNavItem(4, 'Sign Out', primaryRed),
        ],
      ),
    );
  }

  // Widget for the user profile display
  Widget _buildUserProfile() {
    return Row(
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
              _isAdmin ? 'Admin' : 'Responder',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            Text(
              _username,
              style: const TextStyle(
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
         _buildDateRangeButton(),
        const SizedBox(width: 15),
        _buildLocationDropdown(),
      ],
    );
  }

   // You can rename this function for clarity if you like
  Widget _buildLocationDropdown() {
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
          // Show a hint text if no location is selected
          hint: const Text("Filter by Location", style: TextStyle(color: Colors.black54, fontSize: 14)),
          // The currently selected value
          value: _selectedLocation,
          // The list of items is built from our dynamic _uniqueLocations list
          items: _uniqueLocations.map((String location) {
            return DropdownMenuItem<String>(
              value: location,
              child: Text(location, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          // This is called when the user selects a new item
          onChanged: (String? newValue) {
            setState(() {
              // We can add a "Clear Filter" option if we want
              // For now, selecting a new value updates the state.
              _selectedLocation = newValue;
            });
            // After updating the state, re-apply all filters
            _filterPosts();
          },
        ),
      ),
    );
  }

  // NEW: This widget creates the date range button
  Widget _buildDateRangeButton() {
    // Format the date for display, e.g., "Jun 25, 2024"
    final formatter = DateFormat('MMM d, yyyy');
    
    // Determine the text to show on the button
    String buttonText = "Date Range";
    if (_startDate != null && _endDate != null) {
      // Subtract one day from _endDate for display because we added it for logic
      final displayEndDate = _endDate!.subtract(const Duration(days: 1));
      buttonText = '${formatter.format(_startDate!)} - ${formatter.format(displayEndDate)}';
    }

    return InkWell(
      onTap: _selectDateRange, // Call our function on tap
      child: Container(
        width: 180,
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                buttonText,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  // Widget for the search input field
  Widget _buildSearchField() {
    return SizedBox(
      width: 200,
      height: 40,
      child: TextField(
        controller: _searchController, // Connect the controller
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
    const headerStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF333333));
    const cellStyle = TextStyle(fontSize: 14, color: Color(0xFF333333));

    Widget buildBody() {
      if (_isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_errorMessage != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
      if (_posts.isEmpty) {
        return const Center(child: Text('No posts found.'));
      }
      
      // Use the live '_posts' list from the API instead of '_samplePosts'
      return ListView.builder(
        itemCount: _filteredPosts.length,
        itemBuilder: (context, index) {
          final post = _filteredPosts[index];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(post.timestamp, style: cellStyle)),
                    Expanded(flex: 2, child: Text(post.extractedPost, style: cellStyle)),
                    Expanded(flex: 2, child: Text(post.namedEntities, style: cellStyle)),
                  ],
                ),
              ),
              if (index < _posts.length - 1) const Divider(height: 1, thickness: 1),
            ],
          );
        },
      );
    }

    return Expanded(
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
        child: Column(
          children: [
            Container( // The header remains the same
              color: Colors.grey.shade200,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: const Row(
                children: [
                  Expanded(child: Text('TIMESTAMP', style: headerStyle)),
                  Expanded(flex: 2, child: Text('EXTRACTED POST', style: headerStyle)),
                  Expanded(flex: 2, child: Text('NAMED ENTITIES', style: headerStyle)),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1),
            Expanded(child: buildBody()), // The body is now dynamic
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
          // We can update this timestamp later if needed
          const Text('Last Update: Just now', style: TextStyle(color: Colors.grey)),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _fetchPosts, // Calls the API function again
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text('Refresh', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
          ),
        ],
      ),
    );
  }
}
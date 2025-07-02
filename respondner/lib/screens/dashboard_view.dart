import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/emergency_post.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  // All state related to the Dashboard page
  bool _isLoading = true;
  String? _errorMessage;
  final _searchController = TextEditingController();
  List<EmergencyPost> _posts = [];
  List<EmergencyPost> _filteredPosts = [];
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedLocation = 'All Locations';
  List<String> _uniqueLocations = ['All Locations'];
  String? _selectedEntity;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _searchController.addListener(_filterPosts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          // --- NEW: Add "All Locations" to the very beginning of the list ---
          _uniqueLocations.insert(0, 'All Locations');
          _selectedLocation = 'All Locations'; // Reset selected location on new fetch

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

  void _filterPosts() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      // Start with the full master list of posts
      List<EmergencyPost> tempFilteredList = _posts;

      // 1. Filter by the search keyword (if any)
      if (query.isNotEmpty) {
        tempFilteredList = tempFilteredList.where((post) => 
          post.extractedPost.toLowerCase().contains(query)
        ).toList();
      }

      // 2. Filter by the date range (if any)
      if (_startDate != null && _endDate != null) {
        tempFilteredList = tempFilteredList.where((post) {
          try {
            final postDate = DateTime.parse(post.timestamp);
            return postDate.isAfter(_startDate!) && postDate.isBefore(_endDate!);
          } catch (e) {
            return false;
          }
        }).toList();
      }

      // 3. Filter by selected location
      if (_selectedLocation != null && _selectedLocation != 'All Locations') {
        tempFilteredList = tempFilteredList.where((post) =>
          post.namedEntities.contains('[Location: $_selectedLocation]')
        ).toList();
      }

      // 4. Filter by selected entity type
      if (_selectedEntity != null) {
        final entityQuery = '[${_selectedEntity!.toLowerCase()}:';
        tempFilteredList = tempFilteredList.where((post) => 
          post.namedEntities.toLowerCase().contains(entityQuery)
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTopHeader(),
        _buildEntityButtons(),
        Expanded(child: _buildDataTable()),
        _buildFooter(),
      ],
    );
  }

  // widget for the top bar with the logo
  Widget _buildTopHeader() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Logo Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Image.asset('assets/respondnerlogo.png', height: 60),
            ),
          ),
          // Filter Bar (Search, Date, Location)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by keyword',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _buildDateRangeButton(),
                const SizedBox(width: 16),
                _buildLocationDropdown(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // widget for the entity filter buttons, connected to our logic
  Widget _buildEntityButtons() {
    final List<String> entities = ['Location', 'People', 'Organization', 'Emergency', 'Needs'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          Text("Filter Entities by: ", style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          ...entities.map((entity) {
            final isSelected = _selectedEntity == entity;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: OutlinedButton(
                onPressed: () { setState(() { _selectedEntity = isSelected ? null : entity; }); _filterPosts(); },
                style: OutlinedButton.styleFrom(
                  backgroundColor: isSelected ? const Color(0xFFa61c1c).withOpacity(0.1) : Colors.transparent,
                  side: BorderSide(color: isSelected ? const Color(0xFFa61c1c) : Colors.grey),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: Text(entity, style: TextStyle(color: isSelected ? const Color(0xFFa61c1c) : Colors.grey[700], fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // Data table widget now with padding and fitting into the new layout
  Widget _buildDataTable() {
    const headerStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF333333));
    const cellStyle = TextStyle(fontSize: 14, color: Color(0xFF333333));
    
    Widget buildBody() {
      if (_isLoading) return const Center(child: CircularProgressIndicator());
      if (_errorMessage != null) return Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)));
      if (_filteredPosts.isEmpty) return const Center(child: Text('No matching posts found.'));
      
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
              if (index < _filteredPosts.length - 1) const Divider(height: 1, thickness: 1),
            ],
          );
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Column(
            children: [
              Container(
                color: const Color(0xFFE3F2FD),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                child: const Row(
                  children: [
                    Expanded(child: Text('TIMESTAMP', style: headerStyle)),
                    Expanded(flex: 2, child: Text('EXTRACTED POST', style: headerStyle)),
                    Expanded(flex: 2, child: Text('NAMED ENTITIES', style: headerStyle)),
                  ],
                ),
              ),
              Expanded(child: buildBody()),
            ],
          ),
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
              if (newValue == 'All Locations') {
                // If "All Locations" is selected, set the filter to null
                _selectedLocation = null;
              } else {
                // Otherwise, set it to the selected location
                _selectedLocation = newValue;
              }
            });
            // After updating the state, re-apply all filters
            _filterPosts();
          },
        ),
      ),
    );
  }

  // Footer widget with padding to fit the new layout
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Last Update: Just now'),
          ElevatedButton.icon(
            onPressed: _fetchPosts,
            icon: const Icon(Icons.refresh), label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFa61c1c), foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }
}

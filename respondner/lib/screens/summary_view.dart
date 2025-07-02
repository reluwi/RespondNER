import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/emergency_post.dart';

class SummaryView extends StatefulWidget {
  const SummaryView({super.key});

  @override
  State<SummaryView> createState() => _SummaryViewState();
}

class _SummaryViewState extends State<SummaryView> {
  // All state related to the Summary page
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

  // Build hierarchical table with categories and top 5 sub-entities
  List<Widget> _buildHierarchicalTable(Map<String, int> entityFrequencies, Map<String, Map<String, int>> detailedBreakdown) {
    const cellStyle = TextStyle(fontSize: 14, color: Color(0xFF333333));
    List<Widget> widgets = [];

    for (var category in entityFrequencies.keys) {
      final isHighlighted = _selectedEntity == category;
      final totalCount = entityFrequencies[category] ?? 0;
      final subEntities = detailedBreakdown[category] ?? {};

      // Category row
      widgets.add(
        Container(
          color: isHighlighted ? const Color(0xFFa61c1c).withOpacity(0.1) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category,
                  style: cellStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isHighlighted ? const Color(0xFFa61c1c) : const Color(0xFF333333),
                  ),
                ),
                Text(
                  '$totalCount',
                  style: cellStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isHighlighted ? const Color(0xFFa61c1c) : const Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Sub-entity rows (indented)
      for (var subEntity in subEntities.entries) {
        widgets.add(
          Container(
            color: isHighlighted ? const Color(0xFFa61c1c).withOpacity(0.05) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      subEntity.key,
                      style: cellStyle.copyWith(
                        fontSize: 13,
                        color: isHighlighted ? const Color(0xFFa61c1c).withOpacity(0.8) : Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${subEntity.value}',
                    style: cellStyle.copyWith(
                      fontSize: 13,
                      color: isHighlighted ? const Color(0xFFa61c1c).withOpacity(0.8) : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      // Add divider between categories (except for the last one)
      if (category != entityFrequencies.keys.last) {
        widgets.add(const Divider(height: 1, thickness: 1));
      }
    }

    return widgets;
  }

  // Build dynamic chart based on selection
  Widget _buildDynamicChart(Map<String, int> entityFrequencies, Map<String, Map<String, int>> fullBreakdown) {
    const cellStyle = TextStyle(fontSize: 14, color: Color(0xFF333333));

    if (_selectedEntity != null) {
      // Show detailed breakdown for selected entity (ALL data, not just top 5)
      final selectedData = fullBreakdown[_selectedEntity] ?? {};
      
      if (selectedData.isEmpty) {
        return const Center(child: Text('No data available for this entity type.'));
      }

      final maxValue = selectedData.values.reduce((a, b) => a > b ? a : b);

      return SingleChildScrollView(
        child: Column(
          children: selectedData.entries.map((entry) {
            final barWidth = maxValue > 0 ? (entry.value / maxValue) * 0.8 : 0.0;
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      entry.key,
                      style: cellStyle.copyWith(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        Container(
                          height: 20,
                          width: MediaQuery.of(context).size.width * 0.25 * barWidth,
                          decoration: BoxDecoration(
                            color: const Color(0xFFa61c1c),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 30,
                    child: Text(
                      '${entry.value}',
                      style: cellStyle.copyWith(fontSize: 13),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      );
    } else {
      // Show overall entity distribution
      final maxFrequency = entityFrequencies.values.isNotEmpty 
          ? entityFrequencies.values.reduce((a, b) => a > b ? a : b) 
          : 0;

      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: entityFrequencies.entries.map((entry) {
          final barWidth = maxFrequency > 0 ? (entry.value / maxFrequency) * 0.8 : 0.0;
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    entry.key,
                    style: cellStyle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      Container(
                        height: 24,
                        width: MediaQuery.of(context).size.width * 0.3 * barWidth,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A90E2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 30,
                  child: Text(
                    '${entry.value}',
                    style: cellStyle,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }
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

  // Helper method to calculate entity frequencies
  Map<String, int> _calculateEntityFrequencies() {
    final Map<String, int> frequencies = {
      'Location': 0,
      'People': 0,
      'Organization': 0,
      'Emergency': 0,
      'Needs': 0,
    };

    for (var post in _filteredPosts) {
      final namedEntities = post.namedEntities.toLowerCase();
      
      if (namedEntities.contains('[location:')) frequencies['Location'] = frequencies['Location']! + 1;
      if (namedEntities.contains('[people:')) frequencies['People'] = frequencies['People']! + 1;
      if (namedEntities.contains('[organization:')) frequencies['Organization'] = frequencies['Organization']! + 1;
      if (namedEntities.contains('[emergency:')) frequencies['Emergency'] = frequencies['Emergency']! + 1;
      if (namedEntities.contains('[needs:')) frequencies['Needs'] = frequencies['Needs']! + 1;
    }

    return frequencies;
  }

  // Helper method to extract detailed entities for each category
  Map<String, Map<String, int>> _getDetailedEntityBreakdown() {
    final Map<String, Map<String, int>> breakdown = {
      'Location': {},
      'People': {},
      'Organization': {},
      'Emergency': {},
      'Needs': {},
    };

    for (var post in _filteredPosts) {
      final namedEntities = post.namedEntities;
      
      // Extract entities using regex for each category
      _extractEntitiesFromPost(namedEntities, 'Location', breakdown['Location']!);
      _extractEntitiesFromPost(namedEntities, 'People', breakdown['People']!);
      _extractEntitiesFromPost(namedEntities, 'Organization', breakdown['Organization']!);
      _extractEntitiesFromPost(namedEntities, 'Emergency', breakdown['Emergency']!);
      _extractEntitiesFromPost(namedEntities, 'Needs', breakdown['Needs']!);
    }

    // Sort all entries by frequency (no limit for full data)
    for (var category in breakdown.keys) {
      final sortedEntries = breakdown[category]!.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      breakdown[category] = Map.fromEntries(sortedEntries);
    }

    return breakdown;
  }

  // Helper method to get top 5 entities for table display only
  Map<String, Map<String, int>> _getTop5EntityBreakdown(Map<String, Map<String, int>> fullBreakdown) {
    final Map<String, Map<String, int>> top5Breakdown = {};

    for (var category in fullBreakdown.keys) {
      final sortedEntries = fullBreakdown[category]!.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      top5Breakdown[category] = Map.fromEntries(sortedEntries.take(5));
    }

    return top5Breakdown;
  }

  void _extractEntitiesFromPost(String namedEntities, String category, Map<String, int> categoryMap) {
    final regex = RegExp('\\[${category.toLowerCase()}: (.*?)\\]', caseSensitive: false);
    final matches = regex.allMatches(namedEntities);
    
    for (final match in matches) {
      final entityName = match.group(1);
      if (entityName != null && entityName.trim().isNotEmpty) {
        final cleanName = entityName.trim();
        categoryMap[cleanName] = (categoryMap[cleanName] ?? 0) + 1;
      }
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
          Text("See Charts by: ", style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold)),
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

  // Modified Data table widget with two-column layout
  Widget _buildDataTable() {
    const headerStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF333333));
    const cellStyle = TextStyle(fontSize: 14, color: Color(0xFF333333));
    
    Widget buildBody() {
      if (_isLoading) return const Center(child: CircularProgressIndicator());
      if (_errorMessage != null) return Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)));
      if (_filteredPosts.isEmpty) return const Center(child: Text('No matching posts found.'));
      
      final entityFrequencies = _calculateEntityFrequencies();
      final fullBreakdown = _getDetailedEntityBreakdown();
      final top5Breakdown = _getTop5EntityBreakdown(fullBreakdown);
      
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First Column - Hierarchical Entity Table (Top 5 only)
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFE3F2FD),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    child: const Text('Entity Frequency Table', style: headerStyle, textAlign: TextAlign.center),
                  ),
                  // Table Content
                  Expanded(
                    child: ListView(
                      children: _buildHierarchicalTable(entityFrequencies, top5Breakdown),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Second Column - Dynamic Bar Chart (All data)
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Chart Header
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFE3F2FD),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    child: Text(
                      _selectedEntity != null ? '$_selectedEntity Distribution' : 'Entity Distribution Chart',
                      style: headerStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Chart Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildDynamicChart(entityFrequencies, fullBreakdown),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: buildBody(),
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
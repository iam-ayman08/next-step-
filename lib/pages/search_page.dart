import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchResults = [];
  final List<String> _allItems = [
    "Software Engineer Internship",
    "Marketing Manager Position",
    "Data Analyst Job",
    "UX Designer Role",
    "Product Manager Opportunity",
    "John Doe - Alumni",
    "Jane Smith - Student",
    "Tech Conference 2024",
    "Career Development Workshop",
    "Networking Event",
  ];

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    final results = _allItems
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();

    setState(() => _searchResults = results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          style: GoogleFonts.inter(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: "Search opportunities, people, events...",
            hintStyle: GoogleFonts.inter(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[400]
                  : Colors.grey[600],
            ),
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.search,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          onChanged: _performSearch,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.clear,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            onPressed: () {
              _searchController.clear();
              setState(() => _searchResults = []);
            },
          ),
        ],
      ),
      body: _searchController.text.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    size: 80,
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Search for opportunities,\npeople, and events",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : _searchResults.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 80,
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "No results found",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final result = _searchResults[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(
                      result.contains("Alumni") || result.contains("Student")
                          ? Icons.person
                          : result.contains("Event") ||
                                result.contains("Conference")
                          ? Icons.event
                          : Icons.business,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    title: Text(
                      result,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    onTap: () {
                      // Handle item tap
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Selected: $result"),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.secondary,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

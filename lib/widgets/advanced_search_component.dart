import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Advanced search component with filters and sorting
class AdvancedSearchComponent extends StatefulWidget {
  final String hintText;
  final List<String> filterOptions;
  final List<String> sortOptions;
  final Function(String query, List<String> activeFilters, String sortBy)
  onSearch;
  final bool showVoiceSearch;
  final bool showFilters;
  final bool showSorting;

  const AdvancedSearchComponent({
    super.key,
    this.hintText = 'Search...',
    this.filterOptions = const [],
    this.sortOptions = const ['Relevance', 'Date', 'Name', 'Rating'],
    required this.onSearch,
    this.showVoiceSearch = true,
    this.showFilters = true,
    this.showSorting = true,
  });

  @override
  State<AdvancedSearchComponent> createState() =>
      _AdvancedSearchComponentState();
}

class _AdvancedSearchComponentState extends State<AdvancedSearchComponent>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSearching = false;
  bool _showFilters = false;
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  late Animation<double> _opacityAnimation;

  final List<String> _activeFilters = [];
  String _sortBy = 'Relevance';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _heightAnimation = Tween<double>(begin: 0.0, end: 200.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _isSearching = _searchController.text.isNotEmpty;
    });
    _performSearch();
  }

  void _performSearch() {
    widget.onSearch(_searchController.text, _activeFilters, _sortBy);
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
      if (_showFilters) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _toggleFilter(String filter) {
    setState(() {
      if (_activeFilters.contains(filter)) {
        _activeFilters.remove(filter);
      } else {
        _activeFilters.add(filter);
      }
      _performSearch();
    });
  }

  void _setSortBy(String sortBy) {
    setState(() {
      _sortBy = sortBy;
      _performSearch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main search bar
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    border: InputBorder.none,
                    hintStyle: GoogleFonts.inter(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                  ),
                  style: GoogleFonts.inter(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
              if (_isSearching) ...[
                IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _activeFilters.clear();
                    _performSearch();
                  },
                ),
              ],
              if (widget.showVoiceSearch) ...[
                IconButton(
                  icon: Icon(
                    Icons.mic,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () {
                    // Voice search functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Voice search coming soon!'),
                      ),
                    );
                  },
                ),
              ],
              if (widget.showFilters || widget.showSorting) ...[
                IconButton(
                  icon: Icon(
                    _showFilters ? Icons.filter_list_off : Icons.filter_list,
                    color: _activeFilters.isNotEmpty
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: _toggleFilters,
                ),
              ],
              const SizedBox(width: 8),
            ],
          ),
        ),

        // Active filters display
        if (_activeFilters.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _activeFilters.map((filter) {
                return Chip(
                  label: Text(filter, style: GoogleFonts.inter(fontSize: 12)),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => _toggleFilter(filter),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.1),
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                );
              }).toList(),
            ),
          ),

        // Filters and sorting panel
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return SizedBox(
              height: _heightAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.showSorting) ...[
                        Text(
                          'Sort by',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.sortOptions.map((option) {
                            final isSelected = _sortBy == option;
                            return ChoiceChip(
                              label: Text(
                                option,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: isSelected
                                      ? Colors.white
                                      : Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.color,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) _setSortBy(option);
                              },
                              backgroundColor:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[700]
                                  : Colors.grey[200],
                              selectedColor: Theme.of(
                                context,
                              ).colorScheme.secondary,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (widget.showFilters &&
                          widget.filterOptions.isNotEmpty) ...[
                        Text(
                          'Filters',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.filterOptions.map((filter) {
                            final isActive = _activeFilters.contains(filter);
                            return FilterChip(
                              label: Text(
                                filter,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: isActive
                                      ? Colors.white
                                      : Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.color,
                                ),
                              ),
                              selected: isActive,
                              onSelected: (selected) => _toggleFilter(filter),
                              backgroundColor:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[700]
                                  : Colors.grey[200],
                              selectedColor: Theme.of(
                                context,
                              ).colorScheme.secondary,
                              checkmarkColor: Colors.white,
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Search result item widget
class SearchResultItem extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final List<String> tags;
  final VoidCallback? onTap;
  final Widget? trailing;

  const SearchResultItem({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    this.tags = const [],
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                  ),
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tag,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 16), trailing!],
          ],
        ),
      ),
    );
  }
}

/// Search suggestions widget
class SearchSuggestions extends StatelessWidget {
  final List<String> suggestions;
  final Function(String) onSuggestionSelected;
  final String query;

  const SearchSuggestions({
    super.key,
    required this.suggestions,
    required this.onSuggestionSelected,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return InkWell(
            onTap: () => onSuggestionSelected(suggestion),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    size: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      suggestion,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Advanced search page
class AdvancedSearchPage extends StatefulWidget {
  final String title;
  final List<String> searchCategories;
  final Function(String, Map<String, dynamic>) onSearch;

  const AdvancedSearchPage({
    super.key,
    required this.title,
    required this.searchCategories,
    required this.onSearch,
  });

  @override
  State<AdvancedSearchPage> createState() => _AdvancedSearchPageState();
}

class _AdvancedSearchPageState extends State<AdvancedSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = '';
  final Map<String, dynamic> _searchFilters = {};

  @override
  void initState() {
    super.initState();
    if (widget.searchCategories.isNotEmpty) {
      _selectedCategory = widget.searchCategories.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: _performSearch,
            child: Text(
              'Search',
              style: GoogleFonts.inter(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search input
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter search terms...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Category selection
            Text(
              'Search in',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.searchCategories.map((category) {
                final isSelected = _selectedCategory == category;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedCategory = category);
                    }
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Advanced filters based on category
            Text(
              'Filters',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildCategoryFilters(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    switch (_selectedCategory) {
      case 'People':
        return _buildPeopleFilters();
      case 'Companies':
        return _buildCompanyFilters();
      case 'Jobs':
        return _buildJobFilters();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPeopleFilters() {
    return Column(
      children: [
        _buildFilterDropdown('Industry', [
          'Technology',
          'Finance',
          'Healthcare',
          'Education',
        ]),
        _buildFilterDropdown('Experience Level', [
          'Entry Level',
          'Mid Level',
          'Senior Level',
          'Executive',
        ]),
        _buildFilterDropdown('Location', ['Remote', 'On-site', 'Hybrid']),
      ],
    );
  }

  Widget _buildCompanyFilters() {
    return Column(
      children: [
        _buildFilterDropdown('Industry', [
          'Technology',
          'Finance',
          'Healthcare',
          'Education',
        ]),
        _buildFilterDropdown('Company Size', [
          'Startup',
          'Small',
          'Medium',
          'Large',
          'Enterprise',
        ]),
        _buildFilterDropdown('Location', [
          'Local',
          'National',
          'International',
        ]),
      ],
    );
  }

  Widget _buildJobFilters() {
    return Column(
      children: [
        _buildFilterDropdown('Job Type', [
          'Full-time',
          'Part-time',
          'Contract',
          'Internship',
        ]),
        _buildFilterDropdown('Experience Level', [
          'Entry Level',
          'Mid Level',
          'Senior Level',
        ]),
        _buildFilterDropdown('Salary Range', [
          '0-50k',
          '50k-100k',
          '100k-150k',
          '150k+',
        ]),
      ],
    );
  }

  Widget _buildFilterDropdown(String label, List<String> options) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: options.map((option) {
          return DropdownMenuItem(value: option, child: Text(option));
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            _searchFilters[label.toLowerCase().replaceAll(' ', '_')] = value;
          }
        },
      ),
    );
  }

  void _performSearch() {
    if (_searchController.text.isNotEmpty) {
      widget.onSearch(_searchController.text, {
        'category': _selectedCategory,
        ..._searchFilters,
      });
      Navigator.of(context).pop();
    }
  }
}

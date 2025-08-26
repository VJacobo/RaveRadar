import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../models/event_model.dart';

class EventSearchBar extends StatefulWidget {
  final Function(String query, EventSearchFilters filters) onSearch;
  final VoidCallback onShowFilters;
  
  const EventSearchBar({
    super.key,
    required this.onSearch,
    required this.onShowFilters,
  });

  @override
  State<EventSearchBar> createState() => _EventSearchBarState();
}

class _EventSearchBarState extends State<EventSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSearching = false;
  EventSearchFilters _filters = EventSearchFilters();

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });
    widget.onSearch(query, _filters);
  }

  void _clearSearch() {
    _searchController.clear();
    _handleSearch('');
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundPrimary,
        border: Border(
          bottom: BorderSide(
            color: AppColors.backgroundTertiary,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Label
          Text(
            '🔍 Search Events Worldwide',
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Search Input
          Container(
            height: 55,
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: Colors.purple.withAlpha(77),
                width: 2,
              ),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              onChanged: _handleSearch,
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textPrimary,
              ),
              cursorColor: Colors.purple,
              decoration: InputDecoration(
                hintText: 'Type city, venue, artist, or event name...',
                hintStyle: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.purple,
                  size: 24,
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isSearching)
                      IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: _clearSearch,
                      ),
                    IconButton(
                      icon: Stack(
                        children: [
                          Icon(
                            Icons.tune,
                            color: _filters.hasActiveFilters 
                                ? Theme.of(context).primaryColor 
                                : AppColors.textSecondary,
                          ),
                          if (_filters.hasActiveFilters)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      onPressed: () => _showAdvancedFilters(context),
                    ),
                  ],
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ),
          // Example searches
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Text(
                  'Quick search: ',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                ...['Berlin', 'Miami', 'London', 'Techno events', 'Tonight'].map((suggestion) {
                  return GestureDetector(
                    onTap: () {
                      _searchController.text = suggestion;
                      _handleSearch(suggestion);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: AppSpacing.sm),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple.withAlpha(26),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                          color: Colors.purple.withAlpha(77),
                        ),
                      ),
                      child: Text(
                        suggestion,
                        style: TextStyle(
                          color: Colors.purple,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          if (_filters.hasActiveFilters) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildActiveFilters(),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveFilters() {
    return Container(
      width: double.infinity,
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          if (_filters.location != null)
            _buildFilterChip(
              label: _filters.location!,
              icon: Icons.location_on,
              onRemove: () {
                setState(() {
                  _filters.location = null;
                });
                _handleSearch(_searchController.text);
              },
            ),
          if (_filters.dateRange != null)
            _buildFilterChip(
              label: _filters.dateRange!.label,
              icon: Icons.calendar_today,
              onRemove: () {
                setState(() {
                  _filters.dateRange = null;
                });
                _handleSearch(_searchController.text);
              },
            ),
          if (_filters.priceRange != null)
            _buildFilterChip(
              label: _filters.priceRange!.label,
              icon: Icons.attach_money,
              onRemove: () {
                setState(() {
                  _filters.priceRange = null;
                });
                _handleSearch(_searchController.text);
              },
            ),
          if (_filters.genres.isNotEmpty)
            ..._filters.genres.map((genre) => _buildFilterChip(
              label: genre,
              icon: Icons.music_note,
              onRemove: () {
                setState(() {
                  _filters.genres.remove(genre);
                });
                _handleSearch(_searchController.text);
              },
            )),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: Theme.of(context).primaryColor.withAlpha(77),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).primaryColor),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 14,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showAdvancedFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (context) => _AdvancedFiltersSheet(
        filters: _filters,
        onApply: (filters) {
          setState(() {
            _filters = filters;
          });
          _handleSearch(_searchController.text);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _AdvancedFiltersSheet extends StatefulWidget {
  final EventSearchFilters filters;
  final Function(EventSearchFilters) onApply;

  const _AdvancedFiltersSheet({
    required this.filters,
    required this.onApply,
  });

  @override
  State<_AdvancedFiltersSheet> createState() => _AdvancedFiltersSheetState();
}

class _AdvancedFiltersSheetState extends State<_AdvancedFiltersSheet> {
  late EventSearchFilters _tempFilters;
  final TextEditingController _locationController = TextEditingController();

  // Popular worldwide locations
  final List<String> _popularLocations = [
    'New York, USA',
    'Los Angeles, USA',
    'Miami, USA',
    'Las Vegas, USA',
    'London, UK',
    'Berlin, Germany',
    'Amsterdam, Netherlands',
    'Paris, France',
    'Barcelona, Spain',
    'Ibiza, Spain',
    'Tokyo, Japan',
    'Bangkok, Thailand',
    'Dubai, UAE',
    'Sydney, Australia',
    'Toronto, Canada',
    'Mexico City, Mexico',
    'São Paulo, Brazil',
    'Buenos Aires, Argentina',
    'Tel Aviv, Israel',
    'Mumbai, India',
  ];

  final List<String> _genres = [
    'House',
    'Techno',
    'Trance',
    'Drum & Bass',
    'Dubstep',
    'Progressive',
    'Deep House',
    'Tech House',
    'Psytrance',
    'Hardstyle',
    'EDM',
    'Experimental',
    'Ambient',
    'Breakbeat',
    'Garage',
  ];

  @override
  void initState() {
    super.initState();
    _tempFilters = widget.filters.copyWith();
    _locationController.text = _tempFilters.location ?? '';
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Advanced Filters',
                      style: AppTextStyles.headline2,
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _tempFilters = EventSearchFilters();
                          _locationController.clear();
                        });
                      },
                      child: Text(
                        'Clear All',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Filters
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              children: [
                // Location Search
                Text(
                  'Location',
                  style: AppTextStyles.subtitle1,
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    hintText: 'Enter city, country, or venue',
                    prefixIcon: Icon(Icons.location_on),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.my_location),
                      onPressed: () {
                        setState(() {
                          _locationController.text = 'Current Location';
                          _tempFilters.location = 'Current Location';
                        });
                      },
                    ),
                    filled: true,
                    fillColor: AppColors.backgroundTertiary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _tempFilters.location = value.isEmpty ? null : value;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                // Popular Locations
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: _popularLocations.map((location) {
                    final isSelected = _tempFilters.location == location;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _locationController.text = location;
                          _tempFilters.location = location;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).primaryColor.withAlpha(26)
                              : AppColors.backgroundTertiary,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          location,
                          style: TextStyle(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.xxl),
                
                // Date Range
                Text(
                  'Date Range',
                  style: AppTextStyles.subtitle1,
                ),
                const SizedBox(height: AppSpacing.md),
                ...DateRangeOption.values.map((option) {
                  final isSelected = _tempFilters.dateRange == option;
                  return RadioListTile<DateRangeOption>(
                    title: Text(option.label),
                    value: option,
                    groupValue: _tempFilters.dateRange,
                    onChanged: (value) {
                      setState(() {
                        _tempFilters.dateRange = value;
                      });
                    },
                    activeColor: Theme.of(context).primaryColor,
                    contentPadding: EdgeInsets.zero,
                  );
                }),
                const SizedBox(height: AppSpacing.xxl),
                
                // Price Range
                Text(
                  'Price Range',
                  style: AppTextStyles.subtitle1,
                ),
                const SizedBox(height: AppSpacing.md),
                ...PriceRangeOption.values.map((option) {
                  final isSelected = _tempFilters.priceRange == option;
                  return RadioListTile<PriceRangeOption>(
                    title: Text(option.label),
                    value: option,
                    groupValue: _tempFilters.priceRange,
                    onChanged: (value) {
                      setState(() {
                        _tempFilters.priceRange = value;
                      });
                    },
                    activeColor: Theme.of(context).primaryColor,
                    contentPadding: EdgeInsets.zero,
                  );
                }),
                const SizedBox(height: AppSpacing.xxl),
                
                // Genres
                Text(
                  'Music Genres',
                  style: AppTextStyles.subtitle1,
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: _genres.map((genre) {
                    final isSelected = _tempFilters.genres.contains(genre);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _tempFilters.genres.remove(genre);
                          } else {
                            _tempFilters.genres.add(genre);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).primaryColor.withAlpha(26)
                              : AppColors.backgroundTertiary,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          genre,
                          style: TextStyle(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
          // Apply Button
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ElevatedButton(
              onPressed: () => widget.onApply(_tempFilters),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Filter Models
class EventSearchFilters {
  String? location;
  DateRangeOption? dateRange;
  PriceRangeOption? priceRange;
  List<String> genres;

  EventSearchFilters({
    this.location,
    this.dateRange,
    this.priceRange,
    List<String>? genres,
  }) : genres = genres ?? [];

  bool get hasActiveFilters =>
      location != null ||
      dateRange != null ||
      priceRange != null ||
      genres.isNotEmpty;

  EventSearchFilters copyWith({
    String? location,
    DateRangeOption? dateRange,
    PriceRangeOption? priceRange,
    List<String>? genres,
  }) {
    return EventSearchFilters(
      location: location ?? this.location,
      dateRange: dateRange ?? this.dateRange,
      priceRange: priceRange ?? this.priceRange,
      genres: genres ?? List.from(this.genres),
    );
  }
}

enum DateRangeOption {
  today('Today'),
  tomorrow('Tomorrow'),
  thisWeek('This Week'),
  thisWeekend('This Weekend'),
  nextWeek('Next Week'),
  thisMonth('This Month'),
  nextMonth('Next Month'),
  custom('Custom Range');

  final String label;
  const DateRangeOption(this.label);
}

enum PriceRangeOption {
  free('Free'),
  under25('Under \$25'),
  under50('\$25 - \$50'),
  under100('\$50 - \$100'),
  over100('Over \$100');

  final String label;
  const PriceRangeOption(this.label);
}
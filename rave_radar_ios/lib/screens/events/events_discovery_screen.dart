import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../utils/constants.dart';
import '../../widgets/events/event_card.dart';
import '../../widgets/events/event_search_bar.dart';
import '../../utils/error_handler.dart';

class EventsDiscoveryScreen extends StatefulWidget {
  const EventsDiscoveryScreen({super.key});

  @override
  State<EventsDiscoveryScreen> createState() => _EventsDiscoveryScreenState();
}

class _EventsDiscoveryScreenState extends State<EventsDiscoveryScreen> {
  final EventService _eventService = EventService();
  EventType? _selectedType;
  String _searchQuery = '';
  EventSearchFilters _searchFilters = EventSearchFilters();

  @override
  void initState() {
    super.initState();
    _eventService.initializeRealWorldEvents();
  }

  List<EventModel> get _filteredEvents {
    // Start with all events or filtered by type
    var events = _eventService.getUpcomingEvents(type: _selectedType);
    
    // Apply search query
    if (_searchQuery.isNotEmpty) {
      final searchLower = _searchQuery.toLowerCase();
      events = events.where((event) {
        return event.name.toLowerCase().contains(searchLower) ||
               event.venue.toLowerCase().contains(searchLower) ||
               event.artists.any((artist) => artist.toLowerCase().contains(searchLower)) ||
               event.location.toLowerCase().contains(searchLower);
      }).toList();
    }
    
    // Apply location filter
    if (_searchFilters.location != null && _searchFilters.location!.isNotEmpty) {
      final location = _searchFilters.location!.toLowerCase();
      events = events.where((event) {
        return event.location.toLowerCase().contains(location) ||
               event.venue.toLowerCase().contains(location) ||
               event.name.toLowerCase().contains(location);
      }).toList();
    }
    
    // Apply date range filter
    if (_searchFilters.dateRange != null) {
      final now = DateTime.now();
      events = events.where((event) {
        switch (_searchFilters.dateRange!) {
          case DateRangeOption.today:
            return event.startTime.day == now.day && 
                   event.startTime.month == now.month && 
                   event.startTime.year == now.year;
          case DateRangeOption.tomorrow:
            final tomorrow = now.add(const Duration(days: 1));
            return event.startTime.day == tomorrow.day && 
                   event.startTime.month == tomorrow.month && 
                   event.startTime.year == tomorrow.year;
          case DateRangeOption.thisWeek:
            final endOfWeek = now.add(Duration(days: 7 - now.weekday));
            return event.startTime.isBefore(endOfWeek) && event.startTime.isAfter(now.subtract(const Duration(days: 1)));
          case DateRangeOption.thisWeekend:
            final saturday = now.add(Duration(days: DateTime.saturday - now.weekday));
            final sunday = saturday.add(const Duration(days: 1));
            return (event.startTime.day == saturday.day || event.startTime.day == sunday.day);
          case DateRangeOption.thisMonth:
            return event.startTime.month == now.month && event.startTime.year == now.year;
          case DateRangeOption.nextWeek:
            final nextWeekStart = now.add(Duration(days: 7 - now.weekday + 1));
            final nextWeekEnd = nextWeekStart.add(const Duration(days: 6));
            return event.startTime.isAfter(nextWeekStart.subtract(const Duration(days: 1))) && 
                   event.startTime.isBefore(nextWeekEnd.add(const Duration(days: 1)));
          case DateRangeOption.nextMonth:
            final nextMonth = DateTime(now.year, now.month + 1);
            return event.startTime.month == nextMonth.month && event.startTime.year == nextMonth.year;
          case DateRangeOption.custom:
            return true; // Would need date picker implementation
        }
      }).toList();
    }
    
    // Apply price filter
    if (_searchFilters.priceRange != null) {
      events = events.where((event) {
        final price = event.price ?? 0;
        switch (_searchFilters.priceRange!) {
          case PriceRangeOption.free:
            return price == 0;
          case PriceRangeOption.under25:
            return price > 0 && price < 25;
          case PriceRangeOption.under50:
            return price >= 25 && price < 50;
          case PriceRangeOption.under100:
            return price >= 50 && price < 100;
          case PriceRangeOption.over100:
            return price >= 100;
        }
      }).toList();
    }
    
    // Apply genre filter
    if (_searchFilters.genres.isNotEmpty) {
      events = events.where((event) {
        // Check if any event genre/artist/description matches selected genres
        return _searchFilters.genres.any((genre) {
          final genreLower = genre.toLowerCase();
          return event.name.toLowerCase().contains(genreLower) ||
                 event.description?.toLowerCase().contains(genreLower) == true ||
                 event.artists.any((artist) => artist.toLowerCase().contains(genreLower)) ||
                 event.genres.any((g) => g.toLowerCase().contains(genreLower));
        });
      }).toList();
    }
    
    return events;
  }

  void _handleSearch(String query, EventSearchFilters filters) {
    setState(() {
      _searchQuery = query;
      _searchFilters = filters;
    });
  }

  void _handleEventTap(EventModel event) {
    if (event.ticketUrl != null) {
      ErrorHandler.showSuccess(
        context,
        'Opening ${event.source.displayName} for tickets...',
      );
    } else {
      _showEventDetails(event);
    }
  }

  void _showEventDetails(EventModel event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _buildEventDetailsSheet(event, scrollController),
      ),
    );
  }

  Widget _buildEventDetailsSheet(EventModel event, ScrollController scrollController) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: ListView(
        controller: scrollController,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            event.name,
            style: AppTextStyles.headline2,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '${event.venue} • ${event.location}',
            style: AppTextStyles.body1,
          ),
          const SizedBox(height: AppSpacing.xl),
          if (event.description != null) ...[
            Text(
              'About',
              style: AppTextStyles.subtitle1,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              event.description!,
              style: AppTextStyles.body2,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
          Text(
            'Artists',
            style: AppTextStyles.subtitle1,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: event.artists.map((artist) {
              return Chip(
                label: Text(artist),
                backgroundColor: event.typeColor.withAlpha(26),
                side: BorderSide(
                  color: event.typeColor.withAlpha(77),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Icon(Icons.calendar_today, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.md),
              Text(
                '${event.formattedDate} at ${event.formattedTime}',
                style: AppTextStyles.body1,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(Icons.location_on, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  '${event.venue}, ${event.location}',
                  style: AppTextStyles.body1,
                ),
              ),
            ],
          ),
          if (event.price != null) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(Icons.confirmation_number, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.md),
                Text(
                  event.price == 0 ? 'Free Event' : 'Starting at \$${event.price!.toStringAsFixed(2)}',
                  style: AppTextStyles.body1.copyWith(
                    color: event.price == 0 ? Colors.green : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Source: ${event.source.displayName}',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.xxl),
          if (event.ticketUrl != null && !event.isSoldOut)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ErrorHandler.showSuccess(
                  context,
                  'Opening ${event.source.displayName} for tickets...',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: event.typeColor,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              child: const Text(
                'Get Tickets',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (event.isSoldOut)
            Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(26),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: Colors.red.withAlpha(77)),
              ),
              child: const Center(
                child: Text(
                  'SOLD OUT',
                  style: TextStyle(
                    color: Colors.red,
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

  @override
  Widget build(BuildContext context) {
    final events = _filteredEvents;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary,
        title: const Text(
          'Discover Events',
          style: AppTextStyles.headline2,
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.map_outlined, color: AppColors.textPrimary),
            onPressed: () {
              ErrorHandler.showSuccess(context, 'Map view coming soon!');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          EventSearchBar(
            onSearch: _handleSearch,
            onShowFilters: () {},
          ),
          // Show active location filter if set
          if (_searchFilters.location != null && _searchFilters.location!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Theme.of(context).primaryColor),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Showing events in: ${_searchFilters.location}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _searchFilters.location = null;
                      });
                      _handleSearch(_searchQuery, _searchFilters);
                    },
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          // Event Type Filter (kept for quick access)
          Container(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                children: [
                  _buildTypeChip(null, 'All Events'),
                  ...EventType.values.map((type) => _buildTypeChip(type, type.name)),
                ],
              ),
            ),
          ),
          // Events List
          Expanded(
            child: events.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'No events found',
                          style: AppTextStyles.subtitle1,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Try adjusting your filters',
                          style: AppTextStyles.body2,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return EventCard(
                        event: event,
                        onTap: () => _handleEventTap(event),
                        onInterested: () {
                          ErrorHandler.showSuccess(
                            context,
                            'Marked as interested in ${event.name}',
                          );
                        },
                        onShare: () {
                          ErrorHandler.showSuccess(
                            context,
                            'Sharing ${event.name}...',
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(EventType? type, String label) {
    final isSelected = _selectedType == type;
    final color = type?.name == 'festival' ? Colors.purple
        : type?.name == 'clubNight' ? Colors.blue
        : type?.name == 'concert' ? Colors.orange
        : type?.name == 'rave' ? Colors.pink
        : type?.name == 'underground' ? Colors.deepPurple
        : type?.name == 'warehouse' ? Colors.indigo
        : Colors.grey;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withAlpha(51)
              : AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(AppRadius.rounded),
          border: Border.all(
            color: isSelected
                ? color.withAlpha(128)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? color
                : AppColors.textSecondary,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
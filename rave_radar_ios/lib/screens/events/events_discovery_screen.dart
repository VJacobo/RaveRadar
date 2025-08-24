import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../utils/constants.dart';
import '../../widgets/events/event_card.dart';
import '../../utils/error_handler.dart';

class EventsDiscoveryScreen extends StatefulWidget {
  const EventsDiscoveryScreen({super.key});

  @override
  State<EventsDiscoveryScreen> createState() => _EventsDiscoveryScreenState();
}

class _EventsDiscoveryScreenState extends State<EventsDiscoveryScreen> {
  final EventService _eventService = EventService();
  EventType? _selectedType;
  String _selectedLocation = 'All Locations';
  final List<String> _locations = [
    'All Locations',
    'Miami, FL',
    'New York, NY',
    'Los Angeles, CA',
    'Chicago, IL',
    'Las Vegas, NV',
    'San Francisco, CA',
    'Brooklyn, NY',
    'Detroit, MI',
    'Austin, TX',
    'Seattle, WA',
  ];

  @override
  void initState() {
    super.initState();
    _eventService.initializeRealWorldEvents();
  }

  List<EventModel> get _filteredEvents {
    return _eventService.getUpcomingEvents(
      type: _selectedType,
      location: _selectedLocation == 'All Locations' ? null : _selectedLocation.split(',')[0],
    );
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
            icon: Icon(Icons.search, color: AppColors.textPrimary),
            onPressed: () {
              ErrorHandler.showSuccess(context, 'Search coming soon!');
            },
          ),
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
          // Filters
          Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Column(
              children: [
                // Event Type Filter
                SizedBox(
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
                const SizedBox(height: AppSpacing.md),
                // Location Filter
                Container(
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(AppRadius.rounded),
                    border: Border.all(
                      color: AppColors.backgroundTertiary,
                    ),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedLocation,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    dropdownColor: AppColors.backgroundSecondary,
                    icon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                    style: AppTextStyles.body2.copyWith(color: AppColors.textPrimary),
                    onChanged: (value) {
                      setState(() {
                        _selectedLocation = value!;
                      });
                    },
                    items: _locations.map((location) {
                      return DropdownMenuItem(
                        value: location,
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(location),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
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
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../utils/constants.dart';
import '../../models/rank_model.dart';

class EnhancedEventsTab extends StatefulWidget {
  final UserProfile userProfile;
  final Function(bool) onScrollDirectionChanged;
  
  const EnhancedEventsTab({
    super.key,
    required this.userProfile,
    required this.onScrollDirectionChanged,
  });

  @override
  State<EnhancedEventsTab> createState() => _EnhancedEventsTabState();
}

class _EnhancedEventsTabState extends State<EnhancedEventsTab> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrollingDown = false;
  String _selectedCity = 'All Cities';
  final Set<String> _interestedEvents = {};
  final Set<String> _goingEvents = {};
  
  // Trusted techno event sources
  final List<TechnoEvent> _events = [
    TechnoEvent(
      id: '1',
      title: 'Circoloco Miami',
      venue: 'Club Space',
      city: 'Miami',
      date: DateTime.now().add(const Duration(days: 7)),
      imageUrl: 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30',
      artists: ['Martinez Brothers', 'Seth Troxler', 'Jamie Jones'],
      source: 'Resident Advisor',
      ticketUrl: 'https://ra.co',
    ),
    TechnoEvent(
      id: '2',
      title: 'Time Warp NYC',
      venue: 'Brooklyn Navy Yard',
      city: 'New York',
      date: DateTime.now().add(const Duration(days: 14)),
      imageUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745',
      artists: ['Richie Hawtin', 'Nina Kraviz', 'Ben Klock'],
      source: 'Resident Advisor',
      ticketUrl: 'https://ra.co',
    ),
    TechnoEvent(
      id: '3',
      title: 'Movement Festival',
      venue: 'Hart Plaza',
      city: 'Detroit',
      date: DateTime.now().add(const Duration(days: 30)),
      imageUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f',
      artists: ['Carl Craig', 'Jeff Mills', 'Derrick May'],
      source: 'Bandsintown',
      ticketUrl: 'https://bandsintown.com',
    ),
    TechnoEvent(
      id: '4',
      title: 'Warehouse Project',
      venue: 'Depot Mayfield',
      city: 'Los Angeles',
      date: DateTime.now().add(const Duration(days: 21)),
      imageUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819',
      artists: ['Four Tet', 'Floating Points', 'Avalon Emerson'],
      source: 'Dice',
      ticketUrl: 'https://dice.fm',
    ),
    TechnoEvent(
      id: '5',
      title: 'Boiler Room Miami',
      venue: 'Factory Town',
      city: 'Miami',
      date: DateTime.now().add(const Duration(days: 10)),
      imageUrl: 'https://images.unsplash.com/photo-1571266028243-d220c6a8d7e7',
      artists: ['Mall Grab', 'DJ Boring', 'Ross From Friends'],
      source: 'Boiler Room',
      ticketUrl: 'https://boilerroom.tv',
    ),
    TechnoEvent(
      id: '6',
      title: 'Dekmantel Festival',
      venue: 'Exchange LA',
      city: 'Los Angeles',
      date: DateTime.now().add(const Duration(days: 45)),
      imageUrl: 'https://images.unsplash.com/photo-1506157786151-b8491531f063',
      artists: ['DJ Harvey', 'Palms Trax', 'Helena Hauff'],
      source: 'Resident Advisor',
      ticketUrl: 'https://ra.co',
    ),
  ];
  
  final List<String> _cities = [
    'All Cities',
    'Miami',
    'New York',
    'Los Angeles',
    'Detroit',
    'Chicago',
    'Berlin',
    'London',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (!_isScrollingDown) {
        _isScrollingDown = true;
        widget.onScrollDirectionChanged(true); // Hide tabs
      }
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (_isScrollingDown) {
        _isScrollingDown = false;
        widget.onScrollDirectionChanged(false); // Show tabs
      }
    }
  }

  List<TechnoEvent> get _filteredEvents {
    if (_selectedCity == 'All Cities') {
      return _events;
    }
    return _events.where((event) => event.city == _selectedCity).toList();
  }

  void _toggleInterested(String eventId) {
    setState(() {
      if (_goingEvents.contains(eventId)) {
        _goingEvents.remove(eventId);
      }
      if (_interestedEvents.contains(eventId)) {
        _interestedEvents.remove(eventId);
      } else {
        _interestedEvents.add(eventId);
      }
    });
  }

  void _toggleGoing(String eventId) {
    setState(() {
      if (_interestedEvents.contains(eventId)) {
        _interestedEvents.remove(eventId);
      }
      if (_goingEvents.contains(eventId)) {
        _goingEvents.remove(eventId);
      } else {
        _goingEvents.add(eventId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildCityFilter(),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: _filteredEvents.length,
            itemBuilder: (context, index) {
              final event = _filteredEvents[index];
              return _buildEventCard(event);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Techno Events',
            style: AppTextStyles.headline1,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Discover events from trusted sources',
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCityFilter() {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: _cities.length,
        itemBuilder: (context, index) {
          final city = _cities[index];
          final isSelected = city == _selectedCity;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Text(city),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCity = city;
                });
              },
              backgroundColor: AppColors.backgroundSecondary,
              selectedColor: widget.userProfile.rank.primaryColor.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? widget.userProfile.rank.primaryColor : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? widget.userProfile.rank.primaryColor : AppColors.backgroundTertiary,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventCard(TechnoEvent event) {
    final isInterested = _interestedEvents.contains(event.id);
    final isGoing = _goingEvents.contains(event.id);
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    widget.userProfile.rank.primaryColor.withOpacity(0.8),
                    widget.userProfile.rank.primaryColor.withOpacity(0.3),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      event.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.backgroundTertiary,
                          child: const Icon(Icons.music_note, size: 50, color: Colors.white),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: AppSpacing.md,
                    right: AppSpacing.md,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        event.source,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Event Details
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: AppTextStyles.headline3,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${event.venue} • ${event.city}',
                      style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      _formatDate(event.date),
                      style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                
                // Artists
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: event.artists.map((artist) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundTertiary,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      artist,
                      style: AppTextStyles.caption,
                    ),
                  )).toList(),
                ),
                const SizedBox(height: AppSpacing.xl),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        label: 'Interested',
                        icon: Icons.star_outline,
                        selectedIcon: Icons.star,
                        isSelected: isInterested,
                        onTap: () => _toggleInterested(event.id),
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _buildActionButton(
                        label: "I'm Going!",
                        icon: Icons.check_circle_outline,
                        selectedIcon: Icons.check_circle,
                        isSelected: isGoing,
                        onTap: () => _toggleGoing(event.id),
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required IconData selectedIcon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: isSelected ? color.withOpacity(0.1) : AppColors.backgroundTertiary,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? color : AppColors.backgroundTertiary,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected ? color : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }
}

class TechnoEvent {
  final String id;
  final String title;
  final String venue;
  final String city;
  final DateTime date;
  final String imageUrl;
  final List<String> artists;
  final String source;
  final String ticketUrl;

  TechnoEvent({
    required this.id,
    required this.title,
    required this.venue,
    required this.city,
    required this.date,
    required this.imageUrl,
    required this.artists,
    required this.source,
    required this.ticketUrl,
  });
}
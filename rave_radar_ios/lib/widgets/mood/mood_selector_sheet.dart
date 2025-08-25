import 'package:flutter/material.dart';
import '../../models/mood_model.dart';
import '../../utils/constants.dart';
import '../common/success_notification.dart';

class MoodSelectorSheet extends StatefulWidget {
  final Function(MoodType, LocationTag?, EventTag?) onMoodSelected;
  
  const MoodSelectorSheet({
    super.key,
    required this.onMoodSelected,
  });

  @override
  State<MoodSelectorSheet> createState() => _MoodSelectorSheetState();
}

class _MoodSelectorSheetState extends State<MoodSelectorSheet> {
  MoodType? _selectedMood;
  LocationTag? _selectedLocation;
  EventTag? _selectedEvent;
  bool _showLocationOptions = false;
  List<String> _taggedUsers = [];
  Map<String, int> _moodCountsByLocation = {};
  Map<String, int> _moodCountsByEvent = {};
  
  late final List<EventTag> _events;
  
  @override
  void initState() {
    super.initState();
    _initializeEvents();
  }
  
  void _initializeEvents() {
    _events = [
      EventTag(
        id: 'e1',
        name: 'Bass Temple',
        venue: 'Club Space, Miami',
        startTime: DateTime.now().add(const Duration(days: 2)),
        hasRSVP: true,
      ),
      EventTag(
        id: 'e2',
        name: 'Techno Tuesday',
        venue: 'Output, Brooklyn',
        startTime: DateTime.now().add(const Duration(hours: 6)),
      ),
      EventTag(
        id: 'e3',
        name: 'Underground Sessions',
        venue: 'Warehouse 215',
        startTime: DateTime.now().add(const Duration(days: 1)),
      ),
      EventTag(
        id: 'e4',
        name: 'Sunset Rave',
        venue: 'Rooftop Miami',
        startTime: DateTime.now().add(const Duration(days: 3)),
        hasRSVP: true,
      ),
    ];
    
    // Sort: RSVP'd events first, then by start time
    _events.sort((a, b) {
      if (a.hasRSVP && !b.hasRSVP) return -1;
      if (!a.hasRSVP && b.hasRSVP) return 1;
      return a.startTime.compareTo(b.startTime);
    });
  }
  
  final List<LocationTag> _mockLocations = [
    LocationTag(id: 'l1', name: 'Miami Beach', type: 'city'),
    LocationTag(id: 'l2', name: 'Brooklyn Navy Yard', type: 'venue'),
    LocationTag(id: 'l3', name: 'Space Miami', type: 'club'),
    LocationTag(id: 'l4', name: 'Electric Pickle', type: 'club'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _selectedMood == null
                ? _buildMoodGrid()
                : _buildOptionsPanel(),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.backgroundTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            "What's Your Mood?",
            style: AppTextStyles.headline2,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Express yourself for the next 24 hours',
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
          ),
          if (_selectedMood != null) ...[
            const SizedBox(height: AppSpacing.md),
            _buildSelectedMoodChip(),
          ],
        ],
      ),
    );
  }

  Widget _buildMoodGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.xl),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.85,
      ),
      itemCount: MoodType.values.length,
      itemBuilder: (context, index) {
        final mood = MoodType.values[index];
        final isSelected = _selectedMood == mood;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedMood = mood;
              // Load mood counts for this mood type
              _loadMoodCounts(mood);
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected 
                  ? mood.color.withValues(alpha: 0.2)
                  : AppColors.backgroundTertiary,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: isSelected ? mood.color : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  mood.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  mood.label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected ? mood.color : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMoodPreview(MoodType mood) {
    // Don't show preview anymore, just select the mood
    // User can immediately post or add optional location/event
  }
  
  void _loadMoodCounts(MoodType mood) {
    // Simulate loading mood counts from service
    // In production, this would fetch from the MoodService
    setState(() {
      _moodCountsByLocation = {
        'l1': 12,  // 12 others in same mood at Miami Beach
        'l2': 5,
        'l3': 23,  // 23 others at Space Miami
        'l4': 8,
      };
      _moodCountsByEvent = {
        'e1': 45,  // 45 others in same mood at Bass Temple
        'e2': 15,
        'e3': 7,
        'e4': 28,
      };
    });
  }
  
  Widget _buildOptionsPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Optional Actions
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.backgroundTertiary,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              children: [
                Text(
                  'Add details (optional)',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildOptionButton(
                      icon: Icons.event,
                      label: 'Event',
                      color: Colors.orange,
                      isSelected: _selectedEvent != null,
                      onTap: () => setState(() => _showLocationOptions = true),
                    ),
                    _buildOptionButton(
                      icon: Icons.location_on,
                      label: 'Location',
                      color: Colors.blue,
                      isSelected: _selectedLocation != null,
                      onTap: () => setState(() => _showLocationOptions = true),
                    ),
                    _buildOptionButton(
                      icon: Icons.people,
                      label: 'Tag People',
                      color: Colors.purple,
                      isSelected: _taggedUsers.isNotEmpty,
                      onTap: _showPeopleTagging,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          if (_showLocationOptions) ...[
            const SizedBox(height: AppSpacing.xl),
            _buildLocationOptions(),
          ],
          
          // Show selected details
          if (_selectedEvent != null || _selectedLocation != null) ...[
            const SizedBox(height: AppSpacing.xl),
            _buildSelectedDetails(),
          ],
        ],
      ),
    );
  }
  
  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isSelected 
                  ? color.withValues(alpha: 0.2)
                  : AppColors.backgroundSecondary,
              shape: BoxShape.circle,
              border: isSelected 
                  ? Border.all(color: color, width: 2)
                  : null,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? color : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSelectedDetails() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _selectedMood!.color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: _selectedMood!.color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedEvent != null) ...[
            Row(
              children: [
                Icon(Icons.event, size: 16, color: Colors.orange),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    _selectedEvent!.name,
                    style: AppTextStyles.body2,
                  ),
                ),
                if (_moodCountsByEvent[_selectedEvent!.id] != null && 
                    _moodCountsByEvent[_selectedEvent!.id]! > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedMood!.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      '${_moodCountsByEvent[_selectedEvent!.id]} others ${_selectedMood!.emoji}',
                      style: TextStyle(
                        fontSize: 11,
                        color: _selectedMood!.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
          if (_selectedLocation != null) ...[
            if (_selectedEvent != null) const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.blue),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    _selectedLocation!.name,
                    style: AppTextStyles.body2,
                  ),
                ),
                if (_moodCountsByLocation[_selectedLocation!.id] != null && 
                    _moodCountsByLocation[_selectedLocation!.id]! > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedMood!.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      '${_moodCountsByLocation[_selectedLocation!.id]} others ${_selectedMood!.emoji}',
                      style: TextStyle(
                        fontSize: 11,
                        color: _selectedMood!.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
          if (_taggedUsers.isNotEmpty) ...[
            if (_selectedEvent != null || _selectedLocation != null) 
              const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(Icons.people, size: 16, color: Colors.purple),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'Tagged: ${_taggedUsers.join(", ")}',
                    style: AppTextStyles.body2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
  
  void _showPeopleTagging() {
    // TODO: Implement people tagging
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tag People'),
        content: const Text('People tagging coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationOptions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedMood != null) _buildSelectedMoodChip(),
          const SizedBox(height: AppSpacing.xl),
          
          // Events Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🎫 Events',
                style: AppTextStyles.headline3,
              ),
              TextButton.icon(
                onPressed: _showEventSearch,
                icon: const Icon(Icons.search, size: 16),
                label: const Text('Add Event'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ..._events.map((event) => _buildEventTile(event)),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Locations Section
          Text(
            '📍 Popular Spots',
            style: AppTextStyles.headline3,
          ),
          const SizedBox(height: AppSpacing.md),
          ..._mockLocations.map((location) => _buildLocationTile(location)),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Custom Location
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_location, color: Colors.blue),
            ),
            title: const Text('Add Custom Location'),
            subtitle: Text(
              'Search for a place',
              style: AppTextStyles.caption,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showLocationSearch,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedMoodChip() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: _selectedMood!.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: _selectedMood!.color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_selectedMood!.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: AppSpacing.xs),
          Text(
            _selectedMood!.label,
            style: TextStyle(
              color: _selectedMood!.color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTile(EventTag event) {
    final isSelected = _selectedEvent == event;
    final moodCount = _moodCountsByEvent[event.id] ?? 0;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedEvent = event;
          _selectedLocation = null;
          _showLocationOptions = false;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.orange.withValues(alpha: 0.1)
              : AppColors.backgroundTertiary,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: isSelected 
              ? Border.all(color: Colors.orange, width: 2)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.event, color: Colors.orange),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(child: Text(event.name, style: AppTextStyles.body1)),
                              if (moodCount > 0) ...[
                                const SizedBox(width: AppSpacing.sm),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xs,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _selectedMood?.color.withValues(alpha: 0.2) ?? Colors.grey.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                  ),
                                  child: Text(
                                    '$moodCount ${_selectedMood?.emoji ?? ""}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: _selectedMood?.color ?? Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (event.hasRSVP)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.check_circle, size: 12, color: Colors.green),
                                SizedBox(width: 4),
                                Text(
                                  'RSVP\'d',
                                  style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(event.venue, style: AppTextStyles.caption),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.orange : AppColors.textTertiary,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationTile(LocationTag location) {
    final isSelected = _selectedLocation == location;
    final moodCount = _moodCountsByLocation[location.id] ?? 0;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLocation = location;
          _selectedEvent = null;
          _showLocationOptions = false;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.blue.withValues(alpha: 0.1)
              : AppColors.backgroundTertiary,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: isSelected 
              ? Border.all(color: Colors.blue, width: 2)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  location.type == 'club' ? Icons.nightlife
                      : location.type == 'venue' ? Icons.stadium
                      : Icons.location_city,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(child: Text(location.name, style: AppTextStyles.body1)),
                        if (moodCount > 0) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _selectedMood?.color.withValues(alpha: 0.2) ?? Colors.grey.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              '$moodCount ${_selectedMood?.emoji ?? ""}',
                              style: TextStyle(
                                fontSize: 11,
                                color: _selectedMood?.color ?? Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      location.type.toUpperCase(),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.blue : AppColors.textTertiary,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final canPost = _selectedMood != null;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.backgroundPrimary,
        border: Border(
          top: BorderSide(color: AppColors.backgroundTertiary),
        ),
      ),
      child: Row(
        children: [
          if (_selectedMood != null)
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedMood = null;
                  _selectedLocation = null;
                  _selectedEvent = null;
                  _taggedUsers.clear();
                  _showLocationOptions = false;
                });
              },
              child: const Text('Change Mood'),
            ),
          const Spacer(),
          ElevatedButton(
            onPressed: canPost
                ? () {
                    // Show success notification
                    SuccessNotification.show(
                      context: context,
                      title: 'Mood Posted! ${_selectedMood!.emoji}',
                      subtitle: 'Active for 24 hours',
                      backgroundColor: _selectedMood!.color,
                      emoji: _selectedMood!.emoji,
                      duration: const Duration(seconds: 2),
                    );
                    
                    // Call callback
                    widget.onMoodSelected(
                      _selectedMood!,
                      _selectedLocation,
                      _selectedEvent,
                    );
                    
                    // Delay navigation to allow notification to show
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    });
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedMood?.color ?? Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxl,
                vertical: AppSpacing.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selectedMood != null) ...[
                  Text(
                    _selectedMood!.emoji,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Text(
                  canPost ? 'Post Mood' : 'Select a Mood',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _showEventSearch() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Events'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for an event...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              onChanged: (value) {
                // TODO: Implement event search
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Search results will appear here',
              style: AppTextStyles.caption,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
  
  void _showLocationSearch() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for a place...',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              onChanged: (value) {
                // TODO: Implement location search
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Popular locations will appear here',
              style: AppTextStyles.caption,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
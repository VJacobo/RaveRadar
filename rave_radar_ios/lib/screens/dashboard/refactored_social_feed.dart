import 'package:flutter/material.dart';
import '../../models/rank_model.dart' as rank_model;
import '../../models/post_model.dart';
import '../../models/mood_model.dart' as mood_model;
import '../../models/event_model.dart';
import '../../services/post_service.dart';
import '../../services/event_service.dart';
import '../../utils/constants.dart';
import '../../widgets/feed/post_card.dart';
import '../../widgets/feed/mood_filter_bar.dart';
import '../../widgets/feed/create_post_menu.dart';
import '../events/events_discovery_screen.dart';

class RefactoredSocialFeed extends StatefulWidget {
  final rank_model.UserProfile userProfile;
  
  const RefactoredSocialFeed({
    super.key,
    required this.userProfile,
  });

  @override
  State<RefactoredSocialFeed> createState() => _RefactoredSocialFeedState();
}

class _RefactoredSocialFeedState extends State<RefactoredSocialFeed> 
    with TickerProviderStateMixin {
  final PostService _postService = PostService();
  
  int _selectedIndex = 0;
  MoodType? _filterMood;
  late AnimationController _floatingButtonController;
  late Animation<double> _floatingButtonAnimation;
  bool _isCreateMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _postService.initializeMockData();
  }

  void _initializeAnimations() {
    _floatingButtonController = AnimationController(
      duration: AppDurations.normal,
      vsync: this,
    );
    _floatingButtonAnimation = CurvedAnimation(
      parent: _floatingButtonController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _floatingButtonController.dispose();
    super.dispose();
  }

  void _toggleCreateMenu() {
    setState(() {
      _isCreateMenuOpen = !_isCreateMenuOpen;
      if (_isCreateMenuOpen) {
        _floatingButtonController.forward();
      } else {
        _floatingButtonController.reverse();
      }
    });
  }

  void _handlePostTypeSelected(PostType type) {
    _toggleCreateMenu();
    
    switch (type) {
      case PostType.mood:
        _showMoodPostDialog();
        break;
      case PostType.location:
        _showLocationPostDialog();
        break;
      case PostType.event:
        _showEventPostDialog();
        break;
      case PostType.text:
      case PostType.photo:
      case PostType.track:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Creating ${type.name} post...'),
            backgroundColor: AppColors.backgroundTertiary,
          ),
        );
        break;
    }
  }

  void _showMoodPostDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundSecondary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (context) => _MoodPostCreator(),
    );
  }

  void _showLocationPostDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundSecondary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (context) => _LocationPostCreator(),
    );
  }

  void _showEventPostDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundSecondary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (context) => _EventPostCreator(),
    );
  }

  void _handleReaction(String postId, ReactionType reaction) {
    setState(() {
      _postService.addReaction(postId, reaction);
    });
  }

  void _handleSavePost(String postId) {
    setState(() {
      _postService.toggleSavePost(postId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _buildFeedContent(),
                ),
              ],
            ),
            _buildFloatingActionButton(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RaveRadar',
                style: AppTextStyles.headline2.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Stack(
                      children: [
                        Icon(
                          Icons.notifications_outlined,
                          color: AppColors.textPrimary,
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.pink,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.search,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedContent() {
    final posts = _postService.getFilteredPosts(mood: _filterMood);
    
    return RefreshIndicator(
      color: Colors.purple,
      backgroundColor: AppColors.backgroundSecondary,
      onRefresh: () async {
        await Future.delayed(AppDurations.slow);
      },
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverToBoxAdapter(
              child: MoodFilterBar(
                selectedMood: _filterMood,
                onMoodSelected: (mood) {
                  setState(() {
                    _filterMood = mood;
                  });
                },
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final post = posts[index];
                  return PostCard(
                    post: post,
                    onReaction: (reaction) => _handleReaction(post.id, reaction),
                    onSave: () => _handleSavePost(post.id),
                    onShare: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Sharing ${post.userName}\'s post...'),
                          backgroundColor: AppColors.backgroundTertiary,
                        ),
                      );
                    },
                    onComment: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Opening comments...'),
                          backgroundColor: AppColors.backgroundTertiary,
                        ),
                      );
                    },
                  );
                },
                childCount: posts.length,
              ),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.only(bottom: 80),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Positioned(
      bottom: 90,
      right: AppSpacing.lg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isCreateMenuOpen)
            CreatePostMenu(
              animation: _floatingButtonAnimation,
              onPostTypeSelected: _handlePostTypeSelected,
            ),
          FloatingActionButton(
            heroTag: 'main_fab',
            backgroundColor: Colors.purple,
            onPressed: _toggleCreateMenu,
            child: AnimatedRotation(
              turns: _isCreateMenuOpen ? 0.125 : 0,
              duration: AppDurations.fast,
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        border: Border(
          top: BorderSide(
            color: AppColors.backgroundTertiary,
            width: 0.5,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 1) {
            // Navigate to Events screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EventsDiscoveryScreen(),
              ),
            );
          } else {
            setState(() => _selectedIndex = index);
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        selectedItemColor: Colors.purple,
        unselectedItemColor: AppColors.textSecondary,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: AppStrings.discover,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            activeIcon: Icon(Icons.event),
            label: AppStrings.progress,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: AppStrings.community,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: AppStrings.profile,
          ),
        ],
      ),
    );
  }
}

class _MoodPostCreator extends StatefulWidget {
  @override
  State<_MoodPostCreator> createState() => _MoodPostCreatorState();
}

class _MoodPostCreatorState extends State<_MoodPostCreator> {
  MoodType? _selectedMood;

  String _getMoodEmoji(MoodType mood) {
    switch (mood) {
      case MoodType.floating:
        return '💫';
      case MoodType.hyped:
        return '🔥';
      case MoodType.vibing:
        return '🌈';
      case MoodType.euphoric:
        return '✨';
      case MoodType.chill:
        return '😌';
      case MoodType.energized:
        return '⚡';
      case MoodType.nostalgic:
        return '💭';
      case MoodType.underground:
        return '🌙';
    }
  }

  String _getMoodLabel(MoodType mood) {
    return mood.label.replaceAll(RegExp(r'[^a-zA-Z\s]'), '').trim();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Share Your Mood',
                style: AppTextStyles.headline2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Select a mood',
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: MoodType.values.length,
                  itemBuilder: (context, index) {
                    final mood = MoodType.values[index];
                    final isSelected = _selectedMood == mood;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMood = mood),
                      child: Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: isSelected ? mood.color.withOpacity(0.2) : AppColors.backgroundTertiary,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(
                            color: isSelected ? mood.color : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _getMoodEmoji(mood),
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              _getMoodLabel(mood),
                              style: AppTextStyles.caption,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Spacer(),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedMood != null ? () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Mood posted: ${_getMoodLabel(_selectedMood!)}'),
                        backgroundColor: _selectedMood!.color,
                      ),
                    );
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: const Text(
                    'Share Mood',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LocationPostCreator extends StatefulWidget {
  @override
  State<_LocationPostCreator> createState() => _LocationPostCreatorState();
}

class _LocationPostCreatorState extends State<_LocationPostCreator> {
  mood_model.LocationTag? _selectedLocation;
  final TextEditingController _searchController = TextEditingController();
  List<mood_model.LocationTag> _filteredLocations = [];
  
  final List<mood_model.LocationTag> _locations = [
    mood_model.LocationTag(id: '1', name: 'Berghain', type: 'club'),
    mood_model.LocationTag(id: '2', name: 'Fabric London', type: 'club'),
    mood_model.LocationTag(id: '3', name: 'Output Brooklyn', type: 'club'),
    mood_model.LocationTag(id: '4', name: 'Space Miami', type: 'club'),
    mood_model.LocationTag(id: '5', name: 'Printworks London', type: 'venue'),
    mood_model.LocationTag(id: '6', name: 'Brooklyn Mirage', type: 'venue'),
    mood_model.LocationTag(id: '7', name: 'Red Rocks', type: 'venue'),
    mood_model.LocationTag(id: '8', name: 'The Warehouse Project', type: 'venue'),
    mood_model.LocationTag(id: '9', name: 'Miami', type: 'city'),
    mood_model.LocationTag(id: '10', name: 'New York', type: 'city'),
    mood_model.LocationTag(id: '11', name: 'Los Angeles', type: 'city'),
    mood_model.LocationTag(id: '12', name: 'Chicago', type: 'city'),
  ];

  @override
  void initState() {
    super.initState();
    _filteredLocations = _locations;
    _searchController.addListener(_filterLocations);
  }

  void _filterLocations() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredLocations = _locations
          .where((location) => location.name.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Check In to Location',
                style: AppTextStyles.headline2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search locations...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.backgroundTertiary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _filteredLocations.length,
                  itemBuilder: (context, index) {
                    final location = _filteredLocations[index];
                    final isSelected = _selectedLocation == location;
                    return Card(
                      color: isSelected ? Colors.purple.withOpacity(0.1) : AppColors.backgroundTertiary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        side: BorderSide(
                          color: isSelected ? Colors.purple : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        onTap: () => setState(() => 
                          _selectedLocation = isSelected ? null : location
                        ),
                        leading: Icon(
                          location.type == 'club' ? Icons.nightlife :
                          location.type == 'venue' ? Icons.stadium :
                          Icons.location_city,
                          color: isSelected ? Colors.purple : AppColors.textSecondary,
                        ),
                        title: Text(
                          location.name,
                          style: TextStyle(
                            color: isSelected ? Colors.purple : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          location.type.toUpperCase(),
                          style: AppTextStyles.caption,
                        ),
                        trailing: isSelected ? 
                          const Icon(Icons.check_circle, color: Colors.purple) : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedLocation != null ? () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Checked in at ${_selectedLocation!.name}'),
                        backgroundColor: Colors.purple,
                      ),
                    );
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: const Text(
                    'Check In',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EventPostCreator extends StatefulWidget {
  @override
  State<_EventPostCreator> createState() => _EventPostCreatorState();
}

class _EventPostCreatorState extends State<_EventPostCreator> {
  EventModel? _selectedEvent;
  final TextEditingController _searchController = TextEditingController();
  List<EventModel> _filteredEvents = [];
  final EventService _eventService = EventService();

  @override
  void initState() {
    super.initState();
    _eventService.initializeRealWorldEvents();
    _filteredEvents = _eventService.getUpcomingEvents();
    _searchController.addListener(_filterEvents);
  }

  void _filterEvents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEvents = _eventService.getUpcomingEvents().where((event) {
        return event.name.toLowerCase().contains(query) ||
               event.venue.toLowerCase().contains(query) ||
               event.location.toLowerCase().contains(query) ||
               event.artists.any((artist) => artist.toLowerCase().contains(query));
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Share an Event',
                style: AppTextStyles.headline2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search events, venues, or artists...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.backgroundTertiary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _filteredEvents.length,
                  itemBuilder: (context, index) {
                    final event = _filteredEvents[index];
                    final isSelected = _selectedEvent == event;
                    return Card(
                      color: isSelected ? event.typeColor.withOpacity(0.1) : AppColors.backgroundTertiary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        side: BorderSide(
                          color: isSelected ? event.typeColor : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        onTap: () => setState(() => 
                          _selectedEvent = isSelected ? null : event
                        ),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: event.typeColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Icon(
                            event.typeIcon,
                            color: event.typeColor,
                          ),
                        ),
                        title: Text(
                          event.name,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${event.venue} • ${event.location}',
                              style: AppTextStyles.caption,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${event.formattedDate} • ${event.daysUntil}',
                              style: AppTextStyles.caption.copyWith(
                                color: event.typeColor,
                              ),
                            ),
                          ],
                        ),
                        trailing: isSelected ? 
                          Icon(Icons.check_circle, color: event.typeColor) : null,
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedEvent != null ? () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Shared event: ${_selectedEvent!.name}'),
                        backgroundColor: _selectedEvent!.typeColor,
                      ),
                    );
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: const Text(
                    'Share Event',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
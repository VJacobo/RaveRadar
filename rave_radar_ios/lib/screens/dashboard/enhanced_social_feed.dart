import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import 'dart:async';
import '../../blocs/feed/feed_bloc.dart';
import '../../blocs/feed/feed_event.dart';
import '../../blocs/feed/feed_state.dart';
import '../../models/rank_model.dart' as rank_model;
import '../../models/post_model.dart';
import '../../models/event_model.dart';
import '../../models/location_model.dart';
import '../../utils/constants.dart';
import '../events/enhanced_events_tab.dart';
import '../profile/enhanced_profile_tab.dart';
import '../../widgets/mood/mood_selector_sheet.dart';
import '../../models/mood_model.dart' as mood_model;
import '../../services/mood_service.dart';
import '../create/create_event_screen.dart';
import '../create/create_location_screen.dart';
import '../search/search_screen.dart';
import '../../widgets/common/toast_notification.dart';

class EnhancedSocialFeed extends StatefulWidget {
  final rank_model.UserProfile userProfile;
  
  const EnhancedSocialFeed({super.key, required this.userProfile});

  @override
  State<EnhancedSocialFeed> createState() => _EnhancedSocialFeedState();
}

class _EnhancedSocialFeedState extends State<EnhancedSocialFeed> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _floatingButtonController;
  late Animation<double> _floatingButtonAnimation;
  bool _isCreateMenuOpen = false;
  late FeedBloc _feedBloc;
  late AnimationController _tabBarAnimationController;
  late Animation<double> _tabBarAnimation;
  bool _isTabBarVisible = true;
  final ScrollController _feedScrollController = ScrollController();
  Timer? _scrollEndTimer;
  final MoodService _moodService = MoodService();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  
  @override
  void initState() {
    super.initState();
    _floatingButtonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _floatingButtonAnimation = CurvedAnimation(
      parent: _floatingButtonController,
      curve: Curves.easeOut,
    );
    
    _tabBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _tabBarAnimation = CurvedAnimation(
      parent: _tabBarAnimationController,
      curve: Curves.easeInOut,
    );
    _tabBarAnimationController.forward();
    
    _feedScrollController.addListener(_handleFeedScroll);
    
    _feedBloc = FeedBloc();
    _feedBloc.add(LoadFeed());
    _moodService.initializeDemoData();
  }
  
  @override
  void dispose() {
    _scrollEndTimer?.cancel();
    _floatingButtonController.dispose();
    _tabBarAnimationController.dispose();
    _feedScrollController.removeListener(_handleFeedScroll);
    _feedScrollController.dispose();
    _feedBloc.close();
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
  
  void _handleScrollDirection(bool isScrollingDown) {
    // This method is kept for compatibility with events tab
    if (isScrollingDown && _isTabBarVisible) {
      setState(() {
        _isTabBarVisible = false;
        _tabBarAnimationController.reverse();
      });
    } else if (!isScrollingDown && !_isTabBarVisible) {
      setState(() {
        _isTabBarVisible = true;
        _tabBarAnimationController.forward();
      });
    }
  }
  
  void _handleFeedScroll() {
    if (_selectedIndex != 0) return; // Only handle scroll for feed tab
    
    // Hide tabs when scrolling up (reverse direction)
    if (_feedScrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_isTabBarVisible) {
        setState(() {
          _isTabBarVisible = false;
          _tabBarAnimationController.reverse();
        });
      }
      
      // Reset the timer for auto-show when scrolling stops
      _scrollEndTimer?.cancel();
      _scrollEndTimer = Timer(const Duration(milliseconds: 500), () {
        // Show tabs when scrolling has stopped
        if (!_isTabBarVisible) {
          setState(() {
            _isTabBarVisible = true;
            _tabBarAnimationController.forward();
          });
        }
      });
    } else if (_feedScrollController.position.userScrollDirection == ScrollDirection.forward) {
      // Show tabs immediately when scrolling down
      _scrollEndTimer?.cancel();
      if (!_isTabBarVisible) {
        setState(() {
          _isTabBarVisible = true;
          _tabBarAnimationController.forward();
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _feedBloc,
      child: ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: Scaffold(
          backgroundColor: AppColors.backgroundPrimary,
          body: SafeArea(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _buildFeedTab(),
                _buildEventsTab(),
                _buildConnectTab(),
                _buildProfileTab(),
              ],
            ),
          ),
          floatingActionButton: _selectedIndex == 0 ? _buildFloatingActionButton() : null,
          bottomNavigationBar: AnimatedBuilder(
            animation: _tabBarAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 100 * (1 - _tabBarAnimation.value)),
                child: _buildBottomNavBar(),
              );
            },
          ),
        ),
      ),
    );
  }
  
  Widget _buildFloatingActionButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isCreateMenuOpen) ..._buildCreateOptions(),
        FloatingActionButton(
          onPressed: _toggleCreateMenu,
          backgroundColor: widget.userProfile.rank.primaryColor,
          child: AnimatedBuilder(
            animation: _floatingButtonAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _floatingButtonAnimation.value * math.pi / 4,
                child: Icon(
                  _isCreateMenuOpen ? Icons.close : Icons.add,
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  List<Widget> _buildCreateOptions() {
    final options = [
      ('Mood', Icons.mood, Colors.purple),
      ('Text', Icons.edit, Colors.blue),
      ('Photo', Icons.camera_alt, Colors.purple),
      ('Track', Icons.music_note, Colors.green),
      ('Event', Icons.event, Colors.orange),
      ('Location', Icons.place, Colors.teal),
    ];
    
    return options.map((option) {
      return ScaleTransition(
        scale: _floatingButtonAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  option.$1,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              FloatingActionButton.small(
                onPressed: () {
                  _toggleCreateMenu();
                  _handleCreateOption(option.$1);
                },
                backgroundColor: option.$3,
                child: Icon(option.$2, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
  
  void _handleCreateOption(String type) {
    switch (type) {
      case 'Mood':
        _showMoodSelector();
        break;
      case 'Text':
        // TODO: Show text post creator
        ToastNotification.show(
          context: context,
          title: 'Text Post Coming Soon!',
          subtitle: 'Share your thoughts',
          backgroundColor: Colors.blue,
          icon: Icons.edit,
          duration: const Duration(seconds: 2),
        );
        break;
      case 'Photo':
        // TODO: Show photo picker
        ToastNotification.show(
          context: context,
          title: 'Photo Post Coming Soon!',
          subtitle: 'Share your memories',
          backgroundColor: Colors.purple,
          icon: Icons.camera_alt,
          duration: const Duration(seconds: 2),
        );
        break;
      case 'Track':
        // TODO: Show track selector
        ToastNotification.show(
          context: context,
          title: 'Track Share Coming Soon!',
          subtitle: 'Share your tracks',
          backgroundColor: Colors.green,
          icon: Icons.music_note,
          duration: const Duration(seconds: 2),
        );
        break;
      case 'Event':
        _showEventCreator();
        break;
      case 'Location':
        _showLocationCreator();
        break;
    }
  }
  
  void _showMoodSelector() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MoodSelectorSheet(
        onMoodSelected: (mood, location, event) {
          // Pass the data back to the parent
          Navigator.pop(context, {
            'mood': mood,
            'location': location,
            'event': event,
          });
        },
      ),
    );
    
    // Handle the result after modal is closed
    if (result != null && mounted) {
      final mood = result['mood'] as mood_model.MoodType;
      final location = result['location'] as mood_model.LocationTag?;
      final event = result['event'] as mood_model.EventTag?;
      
      _moodService.postMood(
        userId: widget.userProfile.id,
        userName: widget.userProfile.djName,
        userAvatar: widget.userProfile.avatarUrl ?? '',
        mood: mood,
        location: location,
        event: event,
      );
      
      // Show notification in the main context after modal is closed
      if (mounted) {
        ToastNotification.show(
          context: context,
          title: 'Mood Posted Successfully!',
          subtitle: '${mood.label} - Active for 24 hours',
          backgroundColor: mood.color,
          emoji: mood.emoji,
        );
      }
      
      // Refresh feed
      _feedBloc.add(RefreshFeed());
    }
  }

  void _showEventCreator() async {
    final event = await Navigator.push<EventModel>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEventScreen(
          onEventCreated: (event) {
            // Just pass the event back
          },
        ),
      ),
    );
    
    // Handle the result after screen is closed
    if (event != null && mounted) {
      _feedBloc.add(RefreshFeed());
      
      // Show notification in the main context
      ToastNotification.show(
        context: context,
        title: 'Event Posted Successfully! 🎉',
        subtitle: '${event.name} at ${event.venue}',
        backgroundColor: event.typeColor,
        icon: event.typeIcon,
      );
    }
  }

  void _showLocationCreator() async {
    final location = await Navigator.push<LocationModel>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateLocationScreen(
          onLocationCreated: (location) {
            // Just pass the location back
          },
        ),
      ),
    );
    
    // Handle the result after screen is closed
    if (location != null && mounted) {
      _feedBloc.add(RefreshFeed());
      
      // Show notification in the main context
      ToastNotification.show(
        context: context,
        title: 'Location Added Successfully! 📍',
        subtitle: '${location.name} in ${location.city}',
        backgroundColor: location.typeColor,
        icon: location.typeIcon,
      );
    }
  }
  
  Widget _buildFeedTab() {
    return BlocBuilder<FeedBloc, FeedState>(
      builder: (context, state) {
        if (state is FeedLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.purple),
          );
        }
        
        if (state is FeedError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${state.message}', style: AppTextStyles.body1),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  onPressed: () => _feedBloc.add(LoadFeed()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        if (state is FeedLoaded) {
          return RefreshIndicator(
            color: Colors.purple,
            backgroundColor: AppColors.backgroundSecondary,
            onRefresh: () async {
              _feedBloc.add(RefreshFeed());
              await Future.delayed(const Duration(seconds: 1));
            },
            child: CustomScrollView(
              controller: _feedScrollController,
              slivers: [
                SliverAppBar(
                  floating: true,
                  backgroundColor: AppColors.backgroundPrimary,
                  title: Row(
                    children: [
                      Text('RaveRadar', style: AppTextStyles.headline2),
                      const SizedBox(width: AppSpacing.sm),
                      if (state.filterMood != null)
                        Chip(
                          label: Text(
                            state.filterMood!.label,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          backgroundColor: state.filterMood!.color.withAlpha(128),
                          deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white),
                          onDeleted: () => _feedBloc.add(const FilterByMood(null)),
                        ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.filter_alt, color: AppColors.textPrimary),
                      onPressed: () => _showMoodFilter(state.filterMood),
                    ),
                    IconButton(
                      icon: Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
                      onPressed: () {},
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: _buildMoodBar(state.filterMood),
                ),
                if (state.posts.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Text('No posts yet', style: AppTextStyles.body1),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildPostCard(state.posts[index]),
                      childCount: state.posts.length,
                    ),
                  ),
              ],
            ),
          );
        }
        
        return Center(
          child: Text('Loading feed...', style: AppTextStyles.body1),
        );
      },
    );
  }
  
  Widget _buildMoodBar(MoodType? selectedMood) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: MoodType.values.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              margin: const EdgeInsets.only(right: AppSpacing.sm),
              child: ActionChip(
                label: const Text('All Vibes'),
                onPressed: () => _feedBloc.add(const FilterByMood(null)),
                backgroundColor: selectedMood == null 
                  ? widget.userProfile.rank.primaryColor 
                  : AppColors.backgroundSecondary,
                labelStyle: TextStyle(
                  color: selectedMood == null ? Colors.white : AppColors.textPrimary,
                ),
              ),
            );
          }
          
          final mood = MoodType.values[index - 1];
          final isSelected = selectedMood == mood;
          
          return Container(
            margin: const EdgeInsets.only(right: AppSpacing.sm),
            child: ActionChip(
              label: Text(mood.label),
              onPressed: () => _feedBloc.add(FilterByMood(mood)),
              backgroundColor: isSelected ? mood.color : AppColors.backgroundSecondary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildPostCard(Post post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      color: AppColors.backgroundPrimary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostHeader(post),
          if (post.mood != null) _buildMoodIndicator(post.mood!),
          if (post.content != null) _buildPostContent(post),
          _buildPostMedia(post),
          _buildPostActions(post),
          Divider(height: 1, color: AppColors.backgroundTertiary),
        ],
      ),
    );
  }
  
  Widget _buildPostHeader(Post post) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: _getColorForUser(post.userId),
            child: Text(
              post.userName[0],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(post.userName, style: AppTextStyles.subtitle2),
                    const SizedBox(width: AppSpacing.xs),
                    Text(post.userHandle, style: AppTextStyles.caption),
                  ],
                ),
                Text(post.timeAgo, style: AppTextStyles.caption),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.more_horiz, color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
  
  Widget _buildMoodIndicator(MoodType mood) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [mood.color.withAlpha(51), mood.color.withAlpha(26)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            mood.label,
            style: TextStyle(
              color: mood.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPostContent(Post post) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Text(
        post.content!,
        style: AppTextStyles.body1.copyWith(fontSize: 15),
      ),
    );
  }
  
  Widget _buildPostMedia(Post post) {
    switch (post.type) {
      case PostType.photo:
        return _buildPhotoMedia();
      case PostType.track:
        return _buildTrackMedia(post);
      case PostType.event:
        return _buildEventMedia(post);
      default:
        return const SizedBox.shrink();
    }
  }
  
  Widget _buildPhotoMedia() {
    return Container(
      height: 300,
      width: double.infinity,
      color: AppColors.backgroundSecondary,
      child: Center(
        child: Icon(
          Icons.image,
          size: 60,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
  
  Widget _buildTrackMedia(Post post) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.withAlpha(51), Colors.green.withAlpha(26)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Colors.green.withAlpha(77)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(51),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(Icons.music_note, color: Colors.green, size: 30),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.trackTitle ?? 'Unknown Track',
                  style: AppTextStyles.subtitle2,
                ),
                Text(
                  post.trackArtist ?? 'Unknown Artist',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    const Icon(Icons.play_circle_outline, size: 16, color: Colors.green),
                    const SizedBox(width: AppSpacing.xs),
                    Text('Play on Spotify', style: AppTextStyles.caption.copyWith(color: Colors.green)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEventMedia(Post post) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.withAlpha(51), Colors.orange.withAlpha(26)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Colors.orange.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event, color: Colors.orange, size: 24),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  post.eventName ?? 'Event',
                  style: AppTextStyles.subtitle1.copyWith(color: Colors.orange),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.xs),
              Text(post.eventLocation ?? 'TBA', style: AppTextStyles.caption),
            ],
          ),
          if (post.eventTime != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${post.eventTime!.day}/${post.eventTime!.month} at ${post.eventTime!.hour}:00',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.orange),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: const Text('Interested', style: TextStyle(color: Colors.orange)),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: const Text('Going', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPostActions(Post post) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildReactionButton(post),
              const SizedBox(width: AppSpacing.xl),
              _buildActionButton(
                Icons.chat_bubble_outline,
                post.commentCount.toString(),
                () {},
              ),
              const SizedBox(width: AppSpacing.xl),
              _buildActionButton(
                Icons.send,
                post.shareCount > 0 ? post.shareCount.toString() : '',
                () {},
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  post.isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: post.isSaved ? widget.userProfile.rank.primaryColor : AppColors.textPrimary,
                ),
                onPressed: () => _feedBloc.add(ToggleSavePost(post.id)),
              ),
            ],
          ),
          if (post.totalReactions > 0) _buildReactionSummary(post),
        ],
      ),
    );
  }
  
  Widget _buildReactionButton(Post post) {
    return GestureDetector(
      onLongPress: () => _showReactionPicker(post),
      onTap: () {
        _feedBloc.add(AddReaction(postId: post.id, reaction: ReactionType.love));
      },
      child: Row(
        children: [
          Icon(
            Icons.favorite_border,
            color: AppColors.textPrimary,
            size: 24,
          ),
          if (post.totalReactions > 0) ...[
            const SizedBox(width: AppSpacing.xs),
            Text(
              post.totalReactions.toString(),
              style: AppTextStyles.body2,
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildActionButton(IconData icon, String count, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppColors.textPrimary, size: 24),
          if (count.isNotEmpty) ...[
            const SizedBox(width: AppSpacing.xs),
            Text(count, style: AppTextStyles.body2),
          ],
        ],
      ),
    );
  }
  
  Widget _buildReactionSummary(Post post) {
    final topReactions = post.reactions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        children: [
          ...topReactions.take(3).map((entry) => Container(
            margin: const EdgeInsets.only(right: AppSpacing.xs),
            child: Text(
              '${entry.key.emoji} ${entry.value}',
              style: AppTextStyles.caption,
            ),
          )),
        ],
      ),
    );
  }
  
  void _showReactionPicker(Post post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.backgroundTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text('React', style: AppTextStyles.headline3),
            const SizedBox(height: AppSpacing.xl),
            Wrap(
              spacing: AppSpacing.xl,
              runSpacing: AppSpacing.xl,
              children: ReactionType.values.map((reaction) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _feedBloc.add(AddReaction(postId: post.id, reaction: reaction));
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundTertiary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          reaction.emoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(reaction.label, style: AppTextStyles.caption),
                ],
              )).toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
  
  void _showMoodFilter(MoodType? currentMood) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.backgroundTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text('Filter by Mood', style: AppTextStyles.headline3),
            const SizedBox(height: AppSpacing.xl),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: MoodType.values.map((mood) => ActionChip(
                label: Text(mood.label),
                onPressed: () {
                  _feedBloc.add(FilterByMood(mood));
                  Navigator.pop(context);
                },
                backgroundColor: currentMood == mood ? mood.color : AppColors.backgroundTertiary,
                labelStyle: TextStyle(
                  color: currentMood == mood ? Colors.white : AppColors.textPrimary,
                ),
              )).toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
  
  Color _getColorForUser(String userId) {
    final colors = [Colors.purple, Colors.pink, Colors.cyan, Colors.orange, Colors.green];
    final hash = userId.hashCode;
    return colors[hash.abs() % colors.length];
  }
  
  Widget _buildEventsTab() {
    return EnhancedEventsTab(
      userProfile: widget.userProfile,
      onScrollDirectionChanged: _handleScrollDirection,
    );
  }
  
  Widget _buildConnectTab() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Connect', style: AppTextStyles.headline2),
          const SizedBox(height: AppSpacing.xl),
          
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
            icon: const Icon(Icons.search, color: Colors.white),
            label: const Text('Search Events & Locations', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.userProfile.rank.primaryColor,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
            icon: const Icon(Icons.people, color: AppColors.textPrimary),
            label: const Text('Find Friends', style: TextStyle(color: AppColors.textPrimary)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProfileTab() {
    return EnhancedProfileTab(
      userProfile: widget.userProfile,
      isOwnProfile: true,
    );
  }
  
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.backgroundTertiary, width: 0.5),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: AppColors.backgroundPrimary,
        selectedItemColor: widget.userProfile.rank.primaryColor,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            activeIcon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Connect',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
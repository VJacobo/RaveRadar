import 'package:flutter/material.dart';
import '../../models/rank_model.dart' as rank_model;
import '../../models/post_model.dart';
import '../../services/post_service.dart';
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Creating ${type.name} post...'),
        backgroundColor: AppColors.backgroundTertiary,
      ),
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
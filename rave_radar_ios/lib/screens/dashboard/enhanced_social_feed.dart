import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/rank_model.dart' as rank_model;
import '../../models/post_model.dart';
import '../../utils/constants.dart';
import '../../widgets/common/rave_button.dart';

class EnhancedSocialFeed extends StatefulWidget {
  final rank_model.UserProfile userProfile;
  
  const EnhancedSocialFeed({super.key, required this.userProfile});

  @override
  State<EnhancedSocialFeed> createState() => _EnhancedSocialFeedState();
}

class _EnhancedSocialFeedState extends State<EnhancedSocialFeed> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  MoodType? _filterMood;
  late AnimationController _floatingButtonController;
  late Animation<double> _floatingButtonAnimation;
  bool _isCreateMenuOpen = false;
  
  final List<Post> _mockPosts = [];
  
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
    _generateMockPosts();
  }
  
  @override
  void dispose() {
    _floatingButtonController.dispose();
    super.dispose();
  }
  
  void _generateMockPosts() {
    final random = math.Random();
    final moods = MoodType.values;
    final names = ['BassHead', 'RaveQueen', 'DropMaster', 'NeonVibes', 'TechnoSoul'];
    
    for (int i = 0; i < 20; i++) {
      final postTypes = PostType.values;
      final type = postTypes[random.nextInt(postTypes.length)];
      
      _mockPosts.add(Post(
        id: 'post_$i',
        userId: 'user_$i',
        userName: '${names[i % names.length]}${i ~/ names.length > 0 ? i ~/ names.length : ''}',
        userHandle: '@${names[i % names.length].toLowerCase()}${i}',
        type: type,
        timestamp: DateTime.now().subtract(Duration(
          hours: random.nextInt(24),
          minutes: random.nextInt(60),
        )),
        content: _getContentForType(type, i),
        mood: type == PostType.mood ? moods[random.nextInt(moods.length)] : null,
        trackTitle: type == PostType.track ? 'Underground Mix ${i + 1}' : null,
        trackArtist: type == PostType.track ? 'DJ ${names[i % names.length]}' : null,
        eventName: type == PostType.event ? 'Warehouse Sessions ${i + 1}' : null,
        eventLocation: type == PostType.event ? 'Secret Location' : null,
        eventTime: type == PostType.event 
          ? DateTime.now().add(Duration(days: random.nextInt(7)))
          : null,
        reactions: _generateRandomReactions(),
        commentCount: random.nextInt(50),
        shareCount: random.nextInt(20),
      ));
    }
    
    _mockPosts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
  
  String _getContentForType(PostType type, int index) {
    switch (type) {
      case PostType.mood:
        final vibes = [
          'The bass is hitting different tonight ✨',
          'Lost in the rhythm 🌊',
          'This set is taking me places 🚀',
          'Pure euphoria on the dancefloor',
          'When the drop hits just right 🔥',
        ];
        return vibes[index % vibes.length];
      case PostType.text:
        final thoughts = [
          'Remember when we thought 3am was late? Now that\'s when the real magic starts 🌙',
          'Shoutout to everyone who made last night unforgettable! You know who you are 💜',
          'That moment when the DJ reads the crowd perfectly... pure magic',
          'New underground spot discovered. If you know, you know 👁️',
          'The scene isn\'t dead, it\'s just gone deeper underground',
        ];
        return thoughts[index % thoughts.length];
      case PostType.photo:
        return 'Last night\'s energy captured in one frame 📸';
      case PostType.track:
        return 'This track has been on repeat all day 🎵';
      case PostType.event:
        return 'Who\'s pulling up? Let\'s rage together! 🎉';
    }
  }
  
  Map<ReactionType, int> _generateRandomReactions() {
    final random = math.Random();
    final reactions = <ReactionType, int>{};
    
    for (final reaction in ReactionType.values.take(3 + random.nextInt(3))) {
      if (random.nextBool()) {
        reactions[reaction] = random.nextInt(100) + 1;
      }
    }
    
    return reactions;
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
  
  @override
  Widget build(BuildContext context) {
    final filteredPosts = _filterMood != null
      ? _mockPosts.where((post) => post.mood == _filterMood).toList()
      : _mockPosts;
    
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildFeedTab(filteredPosts),
            _buildEventsTab(),
            _buildConnectTab(),
            _buildProfileTab(),
          ],
        ),
      ),
      floatingActionButton: _selectedIndex == 0 ? _buildFloatingActionButton() : null,
      bottomNavigationBar: _buildBottomNavBar(),
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
      ('Mood', Icons.mood, MoodType.vibing.color),
      ('Text', Icons.edit, Colors.blue),
      ('Photo', Icons.camera_alt, Colors.purple),
      ('Track', Icons.music_note, Colors.green),
      ('Event', Icons.event, Colors.orange),
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
                  // Handle create action
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
  
  Widget _buildFeedTab(List<Post> posts) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: AppColors.backgroundPrimary,
          title: Row(
            children: [
              Text('RaveRadar', style: AppTextStyles.headline2),
              const SizedBox(width: AppSpacing.sm),
              if (_filterMood != null)
                Chip(
                  label: Text(
                    _filterMood!.label,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: _filterMood!.color.withAlpha(128),
                  deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white),
                  onDeleted: () => setState(() => _filterMood = null),
                ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.filter_alt, color: AppColors.textPrimary),
              onPressed: () => _showMoodFilter(),
            ),
            IconButton(
              icon: Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
              onPressed: () {},
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: _buildMoodBar(),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildPostCard(posts[index]),
            childCount: posts.length,
          ),
        ),
      ],
    );
  }
  
  Widget _buildMoodBar() {
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
                onPressed: () => setState(() => _filterMood = null),
                backgroundColor: _filterMood == null 
                  ? widget.userProfile.rank.primaryColor 
                  : AppColors.backgroundSecondary,
                labelStyle: TextStyle(
                  color: _filterMood == null ? Colors.white : AppColors.textPrimary,
                ),
              ),
            );
          }
          
          final mood = MoodType.values[index - 1];
          final isSelected = _filterMood == mood;
          
          return Container(
            margin: const EdgeInsets.only(right: AppSpacing.sm),
            child: ActionChip(
              label: Text(mood.label),
              onPressed: () => setState(() => _filterMood = mood),
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
                    Icon(Icons.play_circle_outline, size: 16, color: Colors.green),
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
              Icon(Icons.event, color: Colors.orange, size: 24),
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
                    side: BorderSide(color: Colors.orange),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: Text('Interested', style: TextStyle(color: Colors.orange)),
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
                onPressed: () {},
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
        // Quick react with default reaction
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
                      // Handle reaction
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
  
  void _showMoodFilter() {
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
                  setState(() => _filterMood = mood);
                  Navigator.pop(context);
                },
                backgroundColor: _filterMood == mood ? mood.color : AppColors.backgroundTertiary,
                labelStyle: TextStyle(
                  color: _filterMood == mood ? Colors.white : AppColors.textPrimary,
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
    return const Center(
      child: Text('Events', style: AppTextStyles.headline2),
    );
  }
  
  Widget _buildConnectTab() {
    return const Center(
      child: Text('Connect', style: AppTextStyles.headline2),
    );
  }
  
  Widget _buildProfileTab() {
    return const Center(
      child: Text('Profile', style: AppTextStyles.headline2),
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
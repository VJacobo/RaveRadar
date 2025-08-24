import 'package:flutter/material.dart';
import '../../models/rank_model.dart';
import '../../utils/constants.dart';
import '../../widgets/common/rave_button.dart';

class SocialFeedScreen extends StatefulWidget {
  final UserProfile userProfile;
  
  const SocialFeedScreen({super.key, required this.userProfile});

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> {
  int _selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      bottomNavigationBar: Container(
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
      ),
    );
  }
  
  Widget _buildFeedTab() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: AppColors.backgroundPrimary,
          title: Text(
            'RaveRadar',
            style: AppTextStyles.headline2,
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search, color: AppColors.textPrimary),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
              onPressed: () {},
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: _buildStories(),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildPost(index),
            childCount: 10,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStories() {
    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: 10,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildAddStory();
          }
          return _buildStoryItem(index);
        },
      ),
    );
  }
  
  Widget _buildAddStory() {
    return Container(
      width: 75,
      margin: const EdgeInsets.only(right: AppSpacing.md),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.backgroundSecondary,
                  border: Border.all(
                    color: widget.userProfile.rank.primaryColor,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.add,
                  color: widget.userProfile.rank.primaryColor,
                  size: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Your Story',
            style: AppTextStyles.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  Widget _buildStoryItem(int index) {
    final colors = [
      Colors.purple, Colors.pink, Colors.cyan, 
      Colors.orange, Colors.green, Colors.blue
    ];
    final color = colors[index % colors.length];
    
    return Container(
      width: 75,
      margin: const EdgeInsets.only(right: AppSpacing.md),
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [color, color.withAlpha(128)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.backgroundSecondary,
                border: Border.all(
                  color: AppColors.backgroundPrimary,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  'DJ',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'DJ ${index}',
            style: AppTextStyles.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  Widget _buildPost(int index) {
    final isVideo = index % 3 == 0;
    final hasMultipleImages = index % 4 == 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      color: AppColors.backgroundPrimary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.purple.withAlpha(77),
                  child: Text(
                    'D${index + 1}',
                    style: TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DJ User ${index + 1}',
                        style: AppTextStyles.subtitle2,
                      ),
                      Text(
                        index == 0 ? 'Just now' : '${index}h ago • Warehouse District',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_horiz, color: AppColors.textSecondary),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          
          // Post Content
          if (index % 2 == 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                index == 0 
                  ? 'Tonight\'s set was unreal! Thanks to everyone who came out 🔥'
                  : 'New mix dropping tomorrow. Get ready for some serious bass 🎵',
                style: AppTextStyles.body1,
              ),
            ),
          
          if (index % 2 == 0) const SizedBox(height: AppSpacing.md),
          
          // Post Media
          Stack(
            children: [
              Container(
                height: 400,
                width: double.infinity,
                color: AppColors.backgroundSecondary,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isVideo ? Icons.play_circle_outline : Icons.music_note,
                        size: 60,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        isVideo ? 'Live Set Preview' : 'Mix Cover',
                        style: AppTextStyles.body2,
                      ),
                    ],
                  ),
                ),
              ),
              if (hasMultipleImages)
                Positioned(
                  top: AppSpacing.md,
                  right: AppSpacing.md,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      '1/4',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          // Post Actions
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                _buildActionButton(
                  index % 3 == 0 ? Icons.favorite : Icons.favorite_border,
                  index % 3 == 0 ? Colors.red : AppColors.textPrimary,
                  '${234 + index * 17}',
                ),
                const SizedBox(width: AppSpacing.xl),
                _buildActionButton(
                  Icons.chat_bubble_outline,
                  AppColors.textPrimary,
                  '${12 + index * 3}',
                ),
                const SizedBox(width: AppSpacing.xl),
                _buildActionButton(
                  Icons.send,
                  AppColors.textPrimary,
                  '',
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.bookmark_border, color: AppColors.textPrimary),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton(IconData icon, Color color, String count) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        if (count.isNotEmpty) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(count, style: AppTextStyles.body2),
        ],
      ],
    );
  }
  
  Widget _buildEventsTab() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: AppColors.backgroundPrimary,
          title: Text('Upcoming Events', style: AppTextStyles.headline3),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildEventCard(index),
              childCount: 5,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildEventCard(int index) {
    final colors = [Colors.purple, Colors.pink, Colors.cyan, Colors.orange];
    final color = colors[index % colors.length];
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withAlpha(77), color.withAlpha(38)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.lg),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.event,
                size: 50,
                color: color,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  index == 0 ? 'Underground Sessions' : 'Warehouse Party ${index + 1}',
                  style: AppTextStyles.subtitle1,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: AppColors.textTertiary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      index == 0 ? 'Tonight' : 'Next ${['Friday', 'Saturday', 'Sunday'][index % 3]}',
                      style: AppTextStyles.body2,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: AppColors.textTertiary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Secret Location',
                      style: AppTextStyles.body2,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${234 + index * 47} going',
                        style: AppTextStyles.caption,
                      ),
                    ),
                    RaveButton(
                      text: 'Interested',
                      onPressed: () {},
                      backgroundColor: color,
                      height: 36,
                      width: 100,
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
  
  Widget _buildConnectTab() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: AppColors.backgroundPrimary,
          title: Text('Connect', style: AppTextStyles.headline3),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == 0) {
                  return _buildSuggestedSection();
                }
                return _buildUserCard(index);
              },
              childCount: 10,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSuggestedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suggested for you',
          style: AppTextStyles.subtitle1,
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
  
  Widget _buildUserCard(int index) {
    final colors = [Colors.purple, Colors.pink, Colors.cyan, Colors.orange, Colors.green];
    final color = colors[index % colors.length];
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color.withAlpha(77),
            child: Text(
              'U$index',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User ${index}',
                  style: AppTextStyles.subtitle2,
                ),
                Text(
                  '@user${index}',
                  style: AppTextStyles.caption,
                ),
                Text(
                  '${100 + index * 23} mutual friends',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          RaveButton(
            text: 'Connect',
            onPressed: () {},
            backgroundColor: color,
            height: 36,
            width: 90,
          ),
        ],
      ),
    );
  }
  
  Widget _buildProfileTab() {
    final rank = widget.userProfile.rank;
    
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: AppColors.backgroundPrimary,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [rank.primaryColor.withAlpha(77), AppColors.backgroundPrimary],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: rank.primaryColor,
                      child: Text(
                        widget.userProfile.djName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      widget.userProfile.djName,
                      style: AppTextStyles.headline3,
                    ),
                    Text(
                      widget.userProfile.username,
                      style: AppTextStyles.body2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.settings, color: AppColors.textPrimary),
              onPressed: () {},
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              [
                _buildProfileStats(),
                const SizedBox(height: AppSpacing.xl),
                _buildProfileSection('About', widget.userProfile.preferredGenres.join(' • ')),
                const SizedBox(height: AppSpacing.xl),
                _buildProfileSection('Member Since', 'Today'),
                const SizedBox(height: AppSpacing.xl),
                RaveButton(
                  text: 'Edit Profile',
                  onPressed: () {},
                  backgroundColor: rank.primaryColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildProfileStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem('Posts', '0'),
        _buildStatItem('Followers', '0'),
        _buildStatItem('Following', '0'),
      ],
    );
  }
  
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.headline3),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
  
  Widget _buildProfileSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.subtitle2),
        const SizedBox(height: AppSpacing.sm),
        Text(content, style: AppTextStyles.body1),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import '../../models/rank_model.dart';
import '../../models/profile_song_model.dart';
import '../../models/post_model.dart' as post_model;
import '../../models/mood_model.dart' as mood_model;
import '../../services/music_service.dart';
import '../../services/post_service.dart';
import '../../services/mood_service.dart';
import '../../widgets/mood/mood_visual_effects.dart';
import '../../utils/constants.dart';
import '../../widgets/profile/audio_visualizer.dart';
import '../../widgets/profile/profile_song_selector.dart';

class EnhancedProfileTab extends StatefulWidget {
  final UserProfile userProfile;
  final bool isOwnProfile;
  
  const EnhancedProfileTab({
    super.key,
    required this.userProfile,
    this.isOwnProfile = true,
  });

  @override
  State<EnhancedProfileTab> createState() => _EnhancedProfileTabState();
}

class _EnhancedProfileTabState extends State<EnhancedProfileTab> with SingleTickerProviderStateMixin {
  final MusicService _musicService = MusicService();
  final PostService _postService = PostService();
  final MoodService _moodService = MoodService();
  ProfileSong? _profileSong;
  bool _isPlaying = false;
  bool _isMuted = false;
  SongReaction? _userReaction;
  PlaybackSettings _playbackSettings = PlaybackSettings();
  late TabController _tabController;
  List<post_model.Post> _userPosts = [];
  mood_model.MoodPost? _currentMood;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfileSong();
    _loadPlaybackSettings();
    _loadUserPosts();
    _loadCurrentMood();
  }

  Future<void> _loadProfileSong() async {
    final song = _musicService.getProfileSong(widget.userProfile.id);
    if (song != null) {
      setState(() {
        _profileSong = song;
        // Auto-play if visiting someone else's profile and not in silent mode
        if (!widget.isOwnProfile && _playbackSettings.autoPlayOnVisit && !_playbackSettings.silentMode) {
          _isPlaying = true;
        }
      });
    }
  }

  Future<void> _loadPlaybackSettings() async {
    final settings = _musicService.getPlaybackSettings();
    setState(() {
      _playbackSettings = settings;
      _isMuted = settings.silentMode;
    });
  }
  
  Future<void> _loadUserPosts() async {
    setState(() {
      _userPosts = _postService.getPostsByUserId(widget.userProfile.id);
    });
  }
  
  void _loadCurrentMood() {
    setState(() {
      _currentMood = _moodService.getUserMood(widget.userProfile.id);
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _toggleMute() async {
    await _musicService.toggleSilentMode();
    setState(() {
      _isMuted = !_isMuted;
      if (_isMuted) {
        _isPlaying = false;
      }
    });
  }

  void _showSongSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProfileSongSelector(
        currentSong: _profileSong,
        onSongSelected: (song) async {
          await _musicService.setProfileSong(widget.userProfile.id, song);
          setState(() {
            _profileSong = song;
          });
        },
      ),
    );
  }

  void _reactToSong(SongReaction reaction) async {
    if (_profileSong == null) return;
    
    setState(() {
      _userReaction = _userReaction == reaction ? null : reaction;
    });
    
    if (_userReaction != null) {
      await _musicService.addReaction(_profileSong!.id, reaction, widget.userProfile.id);
    }
  }

  void _saveSong() async {
    if (_profileSong == null) return;
    
    await _musicService.saveSong(_profileSong!, widget.userProfile.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved "${_profileSong!.title}" to your library'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildProfileHeader(),
        if (_profileSong != null) _buildMusicPlayer(),
        _buildStats(),
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPostsSection(),
              _buildMusicSection(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (_profileSong != null && _isPlaying)
                CircularVisualizer(
                  isPlaying: _isPlaying,
                  color: widget.userProfile.rank.primaryColor,
                  size: 140,
                ),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.userProfile.rank.primaryColor,
                    width: 3,
                  ),
                  image: widget.userProfile.avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(widget.userProfile.avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: widget.userProfile.avatarUrl == null
                    ? Icon(
                        Icons.person,
                        size: 50,
                        color: widget.userProfile.rank.primaryColor,
                      )
                    : null,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            widget.userProfile.djName,
            style: AppTextStyles.headline1,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.userProfile.username,
                style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
              ),
              if (_currentMood != null && !_currentMood!.isExpired) ...[
                Text(
                  ' · ',
                  style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                ),
                _buildMoodBadgeInline(),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: widget.userProfile.rank.primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              widget.userProfile.rank.name,
              style: TextStyle(
                color: widget.userProfile.rank.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMusicPlayer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: widget.userProfile.rank.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Container(
                  width: 50,
                  height: 50,
                  color: AppColors.backgroundTertiary,
                  child: _profileSong!.albumArt != null
                      ? Image.network(
                          _profileSong!.albumArt!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.music_note,
                            color: Colors.white54,
                          ),
                        )
                      : const Icon(
                          Icons.music_note,
                          color: Colors.white54,
                        ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _profileSong!.title,
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _profileSong!.artist,
                      style: AppTextStyles.caption,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _profileSong!.source.color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _profileSong!.source.displayName,
                            style: TextStyle(
                              fontSize: 10,
                              color: _profileSong!.source.color,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          _playbackSettings.loopSnippet ? '🔁' : '▶️',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause_circle : Icons.play_circle,
                  size: 40,
                  color: widget.userProfile.rank.primaryColor,
                ),
                onPressed: _togglePlayback,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AudioVisualizer(
            isPlaying: _isPlaying,
            color: widget.userProfile.rank.primaryColor,
            height: 30,
            barCount: 25,
          ),
          const SizedBox(height: AppSpacing.md),
          if (!widget.isOwnProfile) _buildReactionButtons(),
        ],
      ),
    );
  }

  Widget _buildReactionButtons() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: SongReaction.values.map((reaction) {
            final isSelected = _userReaction == reaction;
            return GestureDetector(
              onTap: () => _reactToSong(reaction),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? widget.userProfile.rank.primaryColor.withValues(alpha: 0.2)
                      : AppColors.backgroundTertiary,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: isSelected
                      ? Border.all(color: widget.userProfile.rank.primaryColor)
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(reaction.emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      reaction.label,
                      style: TextStyle(
                        color: isSelected
                            ? widget.userProfile.rank.primaryColor
                            : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _saveSong,
            icon: const Icon(Icons.bookmark_add),
            label: const Text('Save This Song'),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.userProfile.rank.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Points', widget.userProfile.totalPoints.toString()),
          _buildStatItem('Genres', widget.userProfile.preferredGenres.length.toString()),
          _buildStatItem('Badges', widget.userProfile.unlockedBadges.length.toString()),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headline2.copyWith(
            color: widget.userProfile.rank.primaryColor,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  Widget _buildSettings() {
    if (!widget.isOwnProfile) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Music Settings',
            style: AppTextStyles.headline3,
          ),
          const SizedBox(height: AppSpacing.md),
          ListTile(
            leading: Icon(
              Icons.music_note,
              color: widget.userProfile.rank.primaryColor,
            ),
            title: Text(
              _profileSong != null ? 'Change Profile Song' : 'Choose Profile Song',
            ),
            subtitle: Text(
              _profileSong != null
                  ? '"${_profileSong!.title}" by ${_profileSong!.artist}'
                  : 'Select a track to play on your profile',
              style: AppTextStyles.caption,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showSongSelector,
          ),
          SwitchListTile(
            title: const Text('Silent Mode'),
            subtitle: Text(
              'Disable auto-play when browsing',
              style: AppTextStyles.caption,
            ),
            value: _isMuted,
            onChanged: (value) => _toggleMute(),
            activeColor: widget.userProfile.rank.primaryColor,
          ),
          SwitchListTile(
            title: const Text('Loop Preview'),
            subtitle: Text(
              'Repeat the preview clip',
              style: AppTextStyles.caption,
            ),
            value: _playbackSettings.loopSnippet,
            onChanged: (value) async {
              final newSettings = _playbackSettings.copyWith(loopSnippet: value);
              await _musicService.updatePlaybackSettings(newSettings);
              setState(() {
                _playbackSettings = newSettings;
              });
            },
            activeColor: widget.userProfile.rank.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingSection() {
    return FutureBuilder<List<TrendingSong>>(
      future: _musicService.getTrendingSongs(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        
        final trendingSongs = snapshot.data!.take(5).toList();
        
        return Container(
          margin: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🔥 Top Profile Songs This Week',
                style: AppTextStyles.headline3,
              ),
              const SizedBox(height: AppSpacing.md),
              ...trendingSongs.map((trending) => Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: trending.rank <= 3
                            ? Colors.amber
                            : AppColors.backgroundTertiary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '#${trending.rank}',
                          style: TextStyle(
                            color: trending.rank <= 3
                                ? Colors.black
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trending.song.title,
                            style: AppTextStyles.body2.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            trending.song.artist,
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${trending.profileCount} profiles',
                          style: AppTextStyles.caption,
                        ),
                        Text(
                          '${trending.weeklyPlays} plays',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.backgroundTertiary, width: 0.5),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: widget.userProfile.rank.primaryColor,
        labelColor: widget.userProfile.rank.primaryColor,
        unselectedLabelColor: AppColors.textSecondary,
        tabs: [
          Tab(
            icon: const Icon(Icons.grid_on),
            text: 'Posts',
          ),
          Tab(
            icon: const Icon(Icons.music_note),
            text: 'Music',
          ),
        ],
      ),
    );
  }

  Widget _buildPostsSection() {
    if (_userPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.post_add,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              widget.isOwnProfile ? 'No posts yet' : 'No posts to show',
              style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
            ),
            if (widget.isOwnProfile) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Start sharing your rave journey!',
                style: AppTextStyles.caption,
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _userPosts.length,
      itemBuilder: (context, index) {
        final post = _userPosts[index];
        return _buildPostCard(post);
      },
    );
  }

  Widget _buildPostCard(post_model.Post post) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.userProfile.rank.primaryColor.withValues(alpha: 0.2),
                ),
                child: Center(
                  child: Text(
                    widget.userProfile.djName[0].toUpperCase(),
                    style: TextStyle(
                      color: widget.userProfile.rank.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.userProfile.djName,
                      style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _formatTimestamp(post.timestamp),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              _buildPostTypeIcon(post.type),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          
          // Post Content
          if (post.content != null) ...[
            Text(post.content!, style: AppTextStyles.body1),
            const SizedBox(height: AppSpacing.md),
          ],
          
          // Type-specific content
          if (post.type == post_model.PostType.mood && post.mood != null)
            _buildMoodBadge(post.mood!),
          
          if (post.type == post_model.PostType.track)
            _buildTrackInfo(post),
          
          if (post.type == post_model.PostType.event)
            _buildEventInfo(post),
          
          if (post.type == post_model.PostType.photo && post.mediaUrls != null)
            _buildPhotoGrid(post.mediaUrls!),
          
          const SizedBox(height: AppSpacing.md),
          
          // Reactions Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.favorite_border, size: 20, color: AppColors.textSecondary),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${post.reactions.values.fold(0, (sum, count) => sum + count)}',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  Icon(Icons.comment_outlined, size: 20, color: AppColors.textSecondary),
                  const SizedBox(width: AppSpacing.xs),
                  Text('${post.commentCount}', style: AppTextStyles.caption),
                  const SizedBox(width: AppSpacing.xl),
                  Icon(Icons.share_outlined, size: 20, color: AppColors.textSecondary),
                  const SizedBox(width: AppSpacing.xs),
                  Text('${post.shareCount}', style: AppTextStyles.caption),
                ],
              ),
              Icon(
                post.isSaved ? Icons.bookmark : Icons.bookmark_border,
                size: 20,
                color: post.isSaved ? widget.userProfile.rank.primaryColor : AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostTypeIcon(post_model.PostType type) {
    IconData icon;
    Color color;
    
    switch (type) {
      case post_model.PostType.mood:
        icon = Icons.mood;
        color = Colors.amber;
        break;
      case post_model.PostType.text:
        icon = Icons.edit;
        color = Colors.blue;
        break;
      case post_model.PostType.photo:
        icon = Icons.camera_alt;
        color = Colors.purple;
        break;
      case post_model.PostType.track:
        icon = Icons.music_note;
        color = Colors.green;
        break;
      case post_model.PostType.event:
        icon = Icons.event;
        color = Colors.orange;
        break;
      case post_model.PostType.location:
        icon = Icons.location_on;
        color = Colors.red;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }

  Widget _buildMoodBadge(post_model.MoodType mood) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: mood.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(mood.label.split(' ')[0], style: const TextStyle(fontSize: 20)),
          const SizedBox(width: AppSpacing.xs),
          Text(
            mood.label,
            style: TextStyle(
              color: mood.color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackInfo(post_model.Post post) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundTertiary,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(Icons.music_note, color: Colors.green),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.trackTitle ?? 'Unknown Track',
                  style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  post.trackArtist ?? 'Unknown Artist',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Icon(Icons.play_circle_outline, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildEventInfo(post_model.Post post) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.1),
            Colors.pink.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.eventName ?? 'Event',
            style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                post.eventLocation ?? 'TBA',
                style: AppTextStyles.caption,
              ),
            ],
          ),
          if (post.eventTime != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  _formatEventTime(post.eventTime!),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhotoGrid(List<String> mediaUrls) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: AspectRatio(
        aspectRatio: 1,
        child: Image.network(
          mediaUrls.first,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: AppColors.backgroundTertiary,
            child: const Center(
              child: Icon(Icons.image, size: 50, color: Colors.white54),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMusicSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSettings(),
          if (widget.isOwnProfile) _buildTrendingSection(),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 7) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _formatEventTime(DateTime eventTime) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[eventTime.month - 1]} ${eventTime.day}, ${eventTime.hour.toString().padLeft(2, '0')}:${eventTime.minute.toString().padLeft(2, '0')}';
  }
  
  Widget _buildMoodBadgeInline() {
    if (_currentMood == null) return const SizedBox.shrink();
    
    return GestureDetector(
      onTap: () {
        // Show mood details
        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Stack(
              alignment: Alignment.center,
              children: [
                MoodVisualEffect(
                  effect: _currentMood!.mood.effect,
                  color: _currentMood!.mood.color,
                  isActive: true,
                  size: 200,
                ),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentMood!.mood.emoji,
                        style: const TextStyle(fontSize: 48),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        _currentMood!.mood.label,
                        style: AppTextStyles.headline3.copyWith(
                          color: _currentMood!.mood.color,
                        ),
                      ),
                      if (_currentMood!.locationText.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _currentMood!.event != null ? Icons.event : Icons.location_on,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              _currentMood!.locationText,
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: _currentMood!.mood.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          _currentMood!.timeRemainingText,
                          style: TextStyle(
                            color: _currentMood!.mood.color,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _currentMood!.mood.emoji,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 4),
          Text(
            _currentMood!.mood.label,
            style: TextStyle(
              color: _currentMood!.mood.color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_currentMood!.locationText.isNotEmpty) ...[
            Text(
              ' at ',
              style: AppTextStyles.caption.copyWith(fontSize: 12),
            ),
            Text(
              _currentMood!.locationText,
              style: TextStyle(
                color: _currentMood!.mood.color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
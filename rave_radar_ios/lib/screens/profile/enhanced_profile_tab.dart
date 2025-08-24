import 'package:flutter/material.dart';
import '../../models/rank_model.dart';
import '../../models/profile_song_model.dart';
import '../../services/music_service.dart';
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

class _EnhancedProfileTabState extends State<EnhancedProfileTab> {
  final MusicService _musicService = MusicService();
  ProfileSong? _profileSong;
  bool _isPlaying = false;
  bool _isMuted = false;
  SongReaction? _userReaction;
  PlaybackSettings _playbackSettings = PlaybackSettings();

  @override
  void initState() {
    super.initState();
    _loadProfileSong();
    _loadPlaybackSettings();
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
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProfileHeader(),
          if (_profileSong != null) _buildMusicPlayer(),
          _buildStats(),
          _buildSettings(),
          if (widget.isOwnProfile) _buildTrendingSection(),
        ],
      ),
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
          Text(
            widget.userProfile.username,
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
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
}
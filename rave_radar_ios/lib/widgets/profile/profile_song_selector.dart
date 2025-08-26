import 'package:flutter/material.dart';
import '../../models/profile_song_model.dart';
import '../../services/music_service.dart';
import '../../utils/constants.dart';

class ProfileSongSelector extends StatefulWidget {
  final Function(ProfileSong) onSongSelected;
  final ProfileSong? currentSong;
  
  const ProfileSongSelector({
    super.key,
    required this.onSongSelected,
    this.currentSong,
  });

  @override
  State<ProfileSongSelector> createState() => _ProfileSongSelectorState();
}

class _ProfileSongSelectorState extends State<ProfileSongSelector> {
  final MusicService _musicService = MusicService();
  final TextEditingController _searchController = TextEditingController();
  MusicSource? _selectedSource;
  List<ProfileSong> _songs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSongs() async {
    setState(() => _isLoading = true);
    final songs = await _musicService.getAvailableTracks(source: _selectedSource);
    setState(() {
      _songs = songs;
      _isLoading = false;
    });
  }

  Future<void> _searchSongs(String query) async {
    if (query.isEmpty) {
      _loadSongs();
      return;
    }
    
    setState(() => _isLoading = true);
    final songs = await _musicService.searchTracks(query);
    setState(() {
      _songs = songs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildSourceFilter(),
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildSongList(),
          ),
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
            'Choose Your Profile Song',
            style: AppTextStyles.headline2,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'This will play when others visit your profile',
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceFilter() {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        children: [
          _buildSourceChip(null, 'All Sources'),
          ...MusicSource.values.map((source) => 
            _buildSourceChip(source, source.displayName),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceChip(MusicSource? source, String label) {
    final isSelected = _selectedSource == source;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (source != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: source.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedSource = selected ? source : null;
          });
          _loadSongs();
        },
        backgroundColor: AppColors.backgroundTertiary,
        selectedColor: source?.color.withValues(alpha: 0.2) ?? Colors.purple.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: isSelected 
              ? (source?.color ?? Colors.purple)
              : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: TextField(
            controller: _searchController,
            onChanged: _searchSongs,
            decoration: InputDecoration(
              hintText: 'Search Spotify for tracks...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Icon(
                Icons.music_note,
                color: Colors.green,
                size: 20,
              ),
              filled: true,
              fillColor: AppColors.backgroundTertiary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Searches real Spotify tracks with 30-second previews',
          style: AppTextStyles.caption.copyWith(
            color: Colors.green,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildSongList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _songs.length,
      itemBuilder: (context, index) {
        final song = _songs[index];
        final isSelected = widget.currentSong?.id == song.id;
        
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected 
                ? Colors.purple.withValues(alpha: 0.1)
                : AppColors.backgroundTertiary,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: isSelected
                ? Border.all(color: Colors.purple, width: 2)
                : null,
          ),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Container(
                width: 50,
                height: 50,
                color: AppColors.backgroundSecondary,
                child: song.albumArt != null
                    ? Image.network(
                        song.albumArt!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildMusicIcon(),
                      )
                    : _buildMusicIcon(),
              ),
            ),
            title: Text(
              song.title,
              style: AppTextStyles.body1.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(song.artist, style: AppTextStyles.caption),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: song.source.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        song.source.displayName,
                        style: TextStyle(
                          fontSize: 10,
                          color: song.source.color,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    if (song.previewUrl != null) ...[
                      Icon(
                        Icons.play_circle_filled,
                        size: 12,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '30s preview',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green,
                        ),
                      ),
                    ] else ...[
                      Icon(
                        Icons.music_off,
                        size: 12,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'No preview',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                isSelected ? Icons.check_circle : Icons.play_circle_outline,
                color: isSelected ? Colors.purple : AppColors.textSecondary,
              ),
              onPressed: () {
                widget.onSongSelected(song);
                Navigator.pop(context);
              },
            ),
            onTap: () {
              widget.onSongSelected(song);
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  Widget _buildMusicIcon() {
    return const Center(
      child: Icon(
        Icons.music_note,
        color: Colors.white54,
      ),
    );
  }
}
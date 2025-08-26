import '../models/profile_song_model.dart';
import 'spotify_service.dart';
import 'audio_player_service.dart';

class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  
  final SpotifyService _spotifyService = SpotifyService();
  final AudioPlayerService _audioPlayerService = AudioPlayerService();

  // Mock techno tracks for demo - using free sample audio URLs for testing
  final List<ProfileSong> _availableTracks = [
    ProfileSong(
      id: '1',
      title: 'Transcendence',
      artist: 'Charlotte de Witte',
      albumArt: 'https://images.unsplash.com/photo-1571266028243-d220c6a8d7e7',
      source: MusicSource.spotify,
      sourceUrl: 'spotify:track:1234567890',
      previewUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3', // Free sample for testing
      previewDuration: const Duration(seconds: 30),
      hasFullTrack: true,
      addedAt: DateTime.now(),
    ),
    ProfileSong(
      id: '2',
      title: 'Your Mind',
      artist: 'Adam Beyer & Bart Skils',
      albumArt: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f',
      source: MusicSource.soundcloud,
      sourceUrl: 'soundcloud:track:987654321',
      previewDuration: const Duration(seconds: 45),
      hasFullTrack: true,
      addedAt: DateTime.now(),
    ),
    ProfileSong(
      id: '3',
      title: 'Acid Thunder',
      artist: 'Amelie Lens',
      albumArt: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819',
      source: MusicSource.spotify,
      sourceUrl: 'spotify:track:2345678901',
      previewDuration: const Duration(seconds: 30),
      hasFullTrack: false,
      addedAt: DateTime.now(),
    ),
    ProfileSong(
      id: '4',
      title: 'Rave Cave',
      artist: 'ANNA',
      albumArt: 'https://images.unsplash.com/photo-1506157786151-b8491531f063',
      source: MusicSource.soundcloud,
      sourceUrl: 'soundcloud:track:456789012',
      previewDuration: const Duration(seconds: 60),
      hasFullTrack: true,
      addedAt: DateTime.now(),
    ),
    ProfileSong(
      id: '5',
      title: 'Afterlife',
      artist: 'Tale of Us',
      albumArt: 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30',
      source: MusicSource.spotify,
      sourceUrl: 'spotify:track:3456789012',
      previewDuration: const Duration(seconds: 30),
      hasFullTrack: false,
      addedAt: DateTime.now(),
    ),
    ProfileSong(
      id: '6',
      title: 'Space Date',
      artist: 'Boris Brejcha',
      albumArt: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745',
      source: MusicSource.inApp,
      sourceUrl: 'local:track:567890123',
      previewDuration: const Duration(seconds: 40),
      hasFullTrack: true,
      addedAt: DateTime.now(),
    ),
    ProfileSong(
      id: '7',
      title: 'Exhale',
      artist: 'Amelie Lens',
      albumArt: 'https://images.unsplash.com/photo-1571266028243-d220c6a8d7e7',
      source: MusicSource.spotify,
      sourceUrl: 'spotify:track:4567890123',
      previewDuration: const Duration(seconds: 30),
      hasFullTrack: false,
      addedAt: DateTime.now(),
    ),
    ProfileSong(
      id: '8',
      title: 'Koma',
      artist: 'UMEK',
      albumArt: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f',
      source: MusicSource.soundcloud,
      sourceUrl: 'soundcloud:track:678901234',
      previewDuration: const Duration(seconds: 50),
      hasFullTrack: true,
      addedAt: DateTime.now(),
    ),
  ];

  final List<ProfileSong> _userSavedTracks = [];
  ProfileSong? _currentProfileSong;
  final Map<String, ProfileSong> _profileSongs = {};
  PlaybackSettings _playbackSettings = PlaybackSettings();
  
  MusicService._internal() {
    // Set a default profile song for demo purposes
    _currentProfileSong = _availableTracks.first;
    _profileSongs['guest_user'] = _availableTracks.first;
  }

  // Get available tracks for selection
  Future<List<ProfileSong>> getAvailableTracks({MusicSource? source}) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (source != null) {
      return _availableTracks.where((track) => track.source == source).toList();
    }
    return _availableTracks;
  }

  // Search tracks using Spotify API
  Future<List<ProfileSong>> searchTracks(String query) async {
    try {
      // Search Spotify for tracks
      final spotifyTracks = await _spotifyService.searchTracks(query);
      
      // Convert Spotify tracks to ProfileSongs
      return spotifyTracks.map((track) => ProfileSong(
        id: track.id,
        title: track.name,
        artist: track.artist,
        albumArt: track.albumArt,
        source: MusicSource.spotify,
        sourceUrl: track.spotifyUrl ?? '',
        previewUrl: track.previewUrl,
        previewDuration: const Duration(seconds: 30),
        hasFullTrack: track.previewUrl != null,
        addedAt: DateTime.now(),
      )).toList();
    } catch (e) {
      print('Error searching Spotify: $e');
      // Fallback to local search
      await Future.delayed(const Duration(milliseconds: 300));
      
      final lowercaseQuery = query.toLowerCase();
      return _availableTracks.where((track) =>
        track.title.toLowerCase().contains(lowercaseQuery) ||
        track.artist.toLowerCase().contains(lowercaseQuery)
      ).toList();
    }
  }
  
  // Play a track preview
  Future<bool> playTrackPreview(ProfileSong song) async {
    if (song.previewUrl == null) {
      print('No preview URL available');
      return false;
    }
    
    // Convert ProfileSong to SpotifyTrack for audio player
    final spotifyTrack = SpotifyTrack(
      id: song.id,
      name: song.title,
      artist: song.artist,
      albumArt: song.albumArt,
      previewUrl: song.previewUrl,
      durationMs: song.previewDuration.inMilliseconds,
    );
    
    return await _audioPlayerService.playTrack(spotifyTrack);
  }
  
  // Control playback
  Future<void> pausePlayback() async {
    await _audioPlayerService.pause();
  }
  
  Future<void> resumePlayback() async {
    await _audioPlayerService.play();
  }
  
  Future<void> togglePlayback() async {
    await _audioPlayerService.togglePlayPause();
  }
  
  Future<void> stopPlayback() async {
    await _audioPlayerService.stop();
  }
  
  // Get playback state
  bool get isPlaying => _audioPlayerService.isPlaying;
  Stream<bool> get playingStream => _audioPlayerService.playingStream;
  Stream<Duration> get positionStream => _audioPlayerService.positionStream;
  Stream<Duration?> get durationStream => _audioPlayerService.durationStream;

  // Set profile song for user
  Future<void> setProfileSong(String userId, ProfileSong song) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _profileSongs[userId] = song;
    if (userId == 'current_user') {
      _currentProfileSong = song;
    }
  }

  // Get profile song for user
  ProfileSong? getProfileSong(String userId) {
    // For demo, return a default song if none is set
    return _profileSongs[userId] ?? _availableTracks.first;
  }

  // Get current user's profile song
  ProfileSong? getCurrentProfileSong() {
    return _currentProfileSong;
  }

  // Add reaction to song
  Future<void> addReaction(String songId, SongReaction reaction, String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final song = _availableTracks.firstWhere((s) => s.id == songId);
    final updatedReactions = Map<SongReaction, int>.from(song.reactions);
    updatedReactions[reaction] = (updatedReactions[reaction] ?? 0) + 1;
    
    final index = _availableTracks.indexWhere((s) => s.id == songId);
    _availableTracks[index] = song.copyWith(reactions: updatedReactions);
  }

  // Save song to user's library
  Future<void> saveSong(ProfileSong song, String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (!_userSavedTracks.any((s) => s.id == song.id)) {
      _userSavedTracks.add(song);
      
      final updatedSavedBy = List<String>.from(song.savedByUsers)..add(userId);
      final index = _availableTracks.indexWhere((s) => s.id == song.id);
      if (index != -1) {
        _availableTracks[index] = song.copyWith(savedByUsers: updatedSavedBy);
      }
    }
  }

  // Get trending songs
  Future<List<TrendingSong>> getTrendingSongs() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Sort by total reactions and create trending list
    final sortedSongs = List<ProfileSong>.from(_availableTracks)
      ..sort((a, b) => b.totalReactions.compareTo(a.totalReactions));
    
    return sortedSongs.take(10).toList().asMap().entries.map((entry) {
      return TrendingSong(
        song: entry.value,
        profileCount: 150 - (entry.key * 10), // Mock profile count
        weeklyPlays: 1000 - (entry.key * 50), // Mock play count
        rank: entry.key + 1,
      );
    }).toList();
  }

  // Get playback settings
  PlaybackSettings getPlaybackSettings() {
    return _playbackSettings;
  }

  // Update playback settings
  Future<void> updatePlaybackSettings(PlaybackSettings settings) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _playbackSettings = settings;
  }

  // Toggle silent mode
  Future<void> toggleSilentMode() async {
    _playbackSettings = _playbackSettings.copyWith(
      silentMode: !_playbackSettings.silentMode,
    );
  }
}
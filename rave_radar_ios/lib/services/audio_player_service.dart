import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'spotify_service.dart';

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  SpotifyTrack? _currentTrack;
  bool _isInitialized = false;
  
  // Singleton pattern
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  // Getters
  AudioPlayer get player => _audioPlayer;
  SpotifyTrack? get currentTrack => _currentTrack;
  Stream<bool> get playingStream => _audioPlayer.playingStream;
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  bool get isPlaying => _audioPlayer.playing;

  // Initialize audio session
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    
    // Handle interruptions
    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        pause();
      }
    });

    _isInitialized = true;
  }

  // Play a Spotify track preview
  Future<bool> playTrack(SpotifyTrack track) async {
    try {
      await initialize();
      
      if (track.previewUrl == null) {
        print('No preview available for this track');
        return false;
      }

      // Stop current playback if any
      await stop();
      
      // Set the new track
      _currentTrack = track;
      
      // Load and play the preview
      await _audioPlayer.setUrl(track.previewUrl!);
      await _audioPlayer.play();
      
      // Set to loop the 30-second preview
      await _audioPlayer.setLoopMode(LoopMode.one);
      
      return true;
    } catch (e) {
      print('Error playing track: $e');
      return false;
    }
  }

  // Play/Resume
  Future<void> play() async {
    if (_currentTrack != null) {
      await _audioPlayer.play();
    }
  }

  // Pause
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  // Stop
  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentTrack = null;
  }

  // Toggle play/pause
  Future<void> togglePlayPause() async {
    if (_audioPlayer.playing) {
      await pause();
    } else {
      await play();
    }
  }

  // Seek to position
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
  }

  // Set loop mode
  Future<void> setLoopMode(bool loop) async {
    await _audioPlayer.setLoopMode(loop ? LoopMode.one : LoopMode.off);
  }

  // Dispose
  void dispose() {
    _audioPlayer.dispose();
  }

  // Helper to format duration
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';
import '../config/spotify_config.dart';

class SpotifyService {
  // Get credentials from config
  static String get clientId => SpotifyConfig.clientId;
  static String get clientSecret => SpotifyConfig.clientSecret;
  static String get redirectUri => SpotifyConfig.redirectUri;
  
  String? _accessToken;
  DateTime? _tokenExpiry;
  
  // Singleton pattern
  static final SpotifyService _instance = SpotifyService._internal();
  factory SpotifyService() => _instance;
  SpotifyService._internal();

  // Generate code verifier for PKCE flow
  String _generateCodeVerifier() {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = Random.secure();
    return List.generate(128, (i) => characters[random.nextInt(characters.length)]).join();
  }

  // Generate code challenge from verifier
  String _generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  // Client Credentials Flow for app-only authentication
  Future<void> _authenticateApp() async {
    // Check if credentials are configured
    if (!SpotifyConfig.isConfigured) {
      throw Exception('Spotify credentials not configured. Please update spotify_config.dart');
    }
    
    if (_accessToken != null && _tokenExpiry != null && DateTime.now().isBefore(_tokenExpiry!)) {
      return; // Token is still valid
    }

    final credentials = base64.encode(utf8.encode('$clientId:$clientSecret'));
    
    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'grant_type=client_credentials',
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _accessToken = data['access_token'];
      final expiresIn = data['expires_in'] as int;
      _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));
    } else {
      throw Exception('Failed to authenticate with Spotify');
    }
  }

  // Search for tracks
  Future<List<SpotifyTrack>> searchTracks(String query) async {
    await _authenticateApp();
    
    final uri = Uri.https('api.spotify.com', '/v1/search', {
      'q': query,
      'type': 'track',
      'limit': '20',
    });

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final tracks = data['tracks']['items'] as List;
      
      return tracks.map((track) => SpotifyTrack.fromJson(track)).toList();
    } else {
      throw Exception('Failed to search tracks');
    }
  }

  // Get track by ID
  Future<SpotifyTrack?> getTrack(String trackId) async {
    await _authenticateApp();
    
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/tracks/$trackId'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return SpotifyTrack.fromJson(data);
    } else {
      return null;
    }
  }

  // Get recommendations based on seed tracks
  Future<List<SpotifyTrack>> getRecommendations({
    List<String>? seedTracks,
    List<String>? seedArtists,
    List<String>? seedGenres,
  }) async {
    await _authenticateApp();
    
    final params = <String, String>{};
    
    if (seedTracks != null && seedTracks.isNotEmpty) {
      params['seed_tracks'] = seedTracks.take(5).join(',');
    }
    if (seedArtists != null && seedArtists.isNotEmpty) {
      params['seed_artists'] = seedArtists.take(5).join(',');
    }
    if (seedGenres != null && seedGenres.isNotEmpty) {
      params['seed_genres'] = seedGenres.take(5).join(',');
    }
    
    params['limit'] = '20';
    
    final uri = Uri.https('api.spotify.com', '/v1/recommendations', params);
    
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final tracks = data['tracks'] as List;
      
      return tracks.map((track) => SpotifyTrack.fromJson(track)).toList();
    } else {
      throw Exception('Failed to get recommendations');
    }
  }

  // Get available genre seeds for recommendations
  Future<List<String>> getAvailableGenres() async {
    await _authenticateApp();
    
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/recommendations/available-genre-seeds'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<String>.from(data['genres']);
    } else {
      throw Exception('Failed to get genres');
    }
  }

  // Get top tracks (requires user authentication)
  Future<List<SpotifyTrack>> getTopTracks() async {
    // This would require user authentication flow
    // For now, we'll return popular tracks from search
    return searchTracks('electronic dance music');
  }
}

class SpotifyTrack {
  final String id;
  final String name;
  final String artist;
  final String? album;
  final String? albumArt;
  final String? previewUrl; // 30-second preview URL
  final int durationMs;
  final String? spotifyUrl;
  final double? popularity;

  SpotifyTrack({
    required this.id,
    required this.name,
    required this.artist,
    this.album,
    this.albumArt,
    this.previewUrl,
    required this.durationMs,
    this.spotifyUrl,
    this.popularity,
  });

  factory SpotifyTrack.fromJson(Map<String, dynamic> json) {
    // Extract artist names
    final artists = json['artists'] as List;
    final artistNames = artists.map((a) => a['name']).join(', ');
    
    // Extract album art
    String? albumArt;
    if (json['album'] != null && json['album']['images'] != null) {
      final images = json['album']['images'] as List;
      if (images.isNotEmpty) {
        albumArt = images[0]['url'];
      }
    }

    return SpotifyTrack(
      id: json['id'],
      name: json['name'],
      artist: artistNames,
      album: json['album']?['name'],
      albumArt: albumArt,
      previewUrl: json['preview_url'],
      durationMs: json['duration_ms'] ?? 0,
      spotifyUrl: json['external_urls']?['spotify'],
      popularity: json['popularity']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'artist': artist,
      'album': album,
      'albumArt': albumArt,
      'previewUrl': previewUrl,
      'durationMs': durationMs,
      'spotifyUrl': spotifyUrl,
      'popularity': popularity,
    };
  }
}
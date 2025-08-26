import 'package:flutter/material.dart';

enum MusicSource {
  spotify('Spotify', Colors.green),
  soundcloud('SoundCloud', Colors.orange),
  inApp('Library', Colors.purple);

  final String displayName;
  final Color color;
  
  const MusicSource(this.displayName, this.color);
}

enum SongReaction {
  hype('🔥', 'Hype'),
  vibe('🎶', 'Vibe'),
  drop('⚡', 'Drop');

  final String emoji;
  final String label;
  
  const SongReaction(this.emoji, this.label);
}

class ProfileSong {
  final String id;
  final String title;
  final String artist;
  final String? albumArt;
  final MusicSource source;
  final String sourceUrl;
  final String? previewUrl; // Spotify preview URL
  final Duration previewDuration;
  final bool hasFullTrack;
  final DateTime addedAt;
  final Map<SongReaction, int> reactions;
  final List<String> savedByUsers;

  ProfileSong({
    required this.id,
    required this.title,
    required this.artist,
    this.albumArt,
    required this.source,
    required this.sourceUrl,
    this.previewUrl,
    this.previewDuration = const Duration(seconds: 30),
    this.hasFullTrack = false,
    required this.addedAt,
    Map<SongReaction, int>? reactions,
    List<String>? savedByUsers,
  }) : reactions = reactions ?? {
          SongReaction.hype: 0,
          SongReaction.vibe: 0,
          SongReaction.drop: 0,
        },
        savedByUsers = savedByUsers ?? [];

  int get totalReactions => reactions.values.fold(0, (sum, count) => sum + count);
  
  ProfileSong copyWith({
    String? id,
    String? title,
    String? artist,
    String? albumArt,
    MusicSource? source,
    String? sourceUrl,
    String? previewUrl,
    Duration? previewDuration,
    bool? hasFullTrack,
    DateTime? addedAt,
    Map<SongReaction, int>? reactions,
    List<String>? savedByUsers,
  }) {
    return ProfileSong(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      albumArt: albumArt ?? this.albumArt,
      source: source ?? this.source,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      previewUrl: previewUrl ?? this.previewUrl,
      previewDuration: previewDuration ?? this.previewDuration,
      hasFullTrack: hasFullTrack ?? this.hasFullTrack,
      addedAt: addedAt ?? this.addedAt,
      reactions: reactions ?? this.reactions,
      savedByUsers: savedByUsers ?? this.savedByUsers,
    );
  }
}

class TrendingSong {
  final ProfileSong song;
  final int profileCount;
  final int weeklyPlays;
  final int rank;

  TrendingSong({
    required this.song,
    required this.profileCount,
    required this.weeklyPlays,
    required this.rank,
  });
}

class PlaybackSettings {
  final bool silentMode;
  final bool loopSnippet;
  final bool autoPlayOnVisit;
  final double volume;

  PlaybackSettings({
    this.silentMode = false,
    this.loopSnippet = true,
    this.autoPlayOnVisit = true,
    this.volume = 0.7,
  });

  PlaybackSettings copyWith({
    bool? silentMode,
    bool? loopSnippet,
    bool? autoPlayOnVisit,
    double? volume,
  }) {
    return PlaybackSettings(
      silentMode: silentMode ?? this.silentMode,
      loopSnippet: loopSnippet ?? this.loopSnippet,
      autoPlayOnVisit: autoPlayOnVisit ?? this.autoPlayOnVisit,
      volume: volume ?? this.volume,
    );
  }
}
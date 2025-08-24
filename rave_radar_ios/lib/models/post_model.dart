import 'package:flutter/material.dart';

enum PostType {
  mood,       // Mood/vibe update
  text,       // Text drops, stories, thoughts
  photo,      // Photo uploads
  track,      // Music/track share
  event,      // Event shoutout
}

enum MoodType {
  floating('💫 Floating', Colors.purple),
  hyped('🔥 Hyped', Colors.orange),
  vibing('🌈 Vibing', Colors.cyan),
  euphoric('✨ Euphoric', Colors.pink),
  chill('😌 Chill', Colors.blue),
  energized('⚡ Energized', Colors.yellow),
  nostalgic('💭 Nostalgic', Colors.indigo),
  underground('🌙 Underground', Colors.deepPurple);

  final String label;
  final Color color;
  const MoodType(this.label, this.color);
}

enum ReactionType {
  glow('✨', 'Glow'),
  hype('🔥', 'Hype'),
  drop('🎛️', 'Drop'),
  vibe('🌈', 'Vibe'),
  bass('🔊', 'Bass'),
  love('💜', 'Love');

  final String emoji;
  final String label;
  const ReactionType(this.emoji, this.label);
}

class Post {
  final String id;
  final String userId;
  final String userName;
  final String userHandle;
  final String? userAvatar;
  final PostType type;
  final DateTime timestamp;
  final String? content;
  final List<String>? mediaUrls;
  final MoodType? mood;
  final String? trackTitle;
  final String? trackArtist;
  final String? trackUrl;
  final String? eventName;
  final String? eventLocation;
  final DateTime? eventTime;
  final Map<ReactionType, int> reactions;
  final int commentCount;
  final int shareCount;
  final List<String> taggedUsers;
  final bool isSaved;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userHandle,
    this.userAvatar,
    required this.type,
    required this.timestamp,
    this.content,
    this.mediaUrls,
    this.mood,
    this.trackTitle,
    this.trackArtist,
    this.trackUrl,
    this.eventName,
    this.eventLocation,
    this.eventTime,
    Map<ReactionType, int>? reactions,
    this.commentCount = 0,
    this.shareCount = 0,
    List<String>? taggedUsers,
    this.isSaved = false,
  }) : reactions = reactions ?? {},
       taggedUsers = taggedUsers ?? [];

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return '${difference.inDays ~/ 7}w';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  int get totalReactions => reactions.values.fold(0, (sum, count) => sum + count);
}

class UserProfile {
  final String id;
  final String displayName;
  final String username;
  final String? avatarUrl;
  final String? bio;
  final MoodType? currentMood;
  final String? pinnedSongTitle;
  final String? pinnedSongArtist;
  final String? pinnedSongUrl;
  final Map<String, dynamic> profileTheme;
  final List<String> following;
  final List<String> followers;
  final int postCount;

  UserProfile({
    required this.id,
    required this.displayName,
    required this.username,
    this.avatarUrl,
    this.bio,
    this.currentMood,
    this.pinnedSongTitle,
    this.pinnedSongArtist,
    this.pinnedSongUrl,
    Map<String, dynamic>? profileTheme,
    List<String>? following,
    List<String>? followers,
    this.postCount = 0,
  }) : profileTheme = profileTheme ?? {},
       following = following ?? [],
       followers = followers ?? [];
}
import 'package:flutter/material.dart';

enum RankType {
  raveInitiate,
  raveRegular,
  raveVeteran,
}

class RankModel {
  final RankType type;
  final String name;
  final String description;
  final Color primaryColor;
  final Color secondaryColor;
  final int level;
  final int minPoints;
  final int maxPoints;
  final List<String> unlockedFeatures;
  final List<String> badges;
  final String iconPath;

  const RankModel({
    required this.type,
    required this.name,
    required this.description,
    required this.primaryColor,
    required this.secondaryColor,
    required this.level,
    required this.minPoints,
    required this.maxPoints,
    required this.unlockedFeatures,
    required this.badges,
    required this.iconPath,
  });

  static RankModel getRankByType(RankType type) {
    return ranks.firstWhere((rank) => rank.type == type);
  }

  static const List<RankModel> ranks = [
    RankModel(
      type: RankType.raveInitiate,
      name: 'New to the Scene',
      description: 'Just discovering the community. Welcome!',
      primaryColor: Color(0xFF00E5FF),
      secondaryColor: Color(0xFF00ACC1),
      level: 1,
      minPoints: 0,
      maxPoints: 500,
      unlockedFeatures: [
        'Basic profile themes',
        'Access to beginner tracks',
        'Join public communities',
        'Follow other DJs',
      ],
      badges: ['First Drop', 'Beat Matcher'],
      iconPath: 'assets/ranks/initiate.png',
    ),
    RankModel(
      type: RankType.raveRegular,
      name: 'Scene Regular',
      description: 'Part of the community. Making connections.',
      primaryColor: Color(0xFF9C27B0),
      secondaryColor: Color(0xFF7B1FA2),
      level: 2,
      minPoints: 501,
      maxPoints: 2000,
      unlockedFeatures: [
        'Advanced profile customization',
        'Exclusive sound packs',
        'Create custom playlists',
        'Join VIP communities',
        'DJ name customization',
      ],
      badges: ['Crowd Pleaser', 'Mix Master', 'Night Owl'],
      iconPath: 'assets/ranks/regular.png',
    ),
    RankModel(
      type: RankType.raveVeteran,
      name: 'Community Veteran',
      description: 'Experienced member. Helping others connect.',
      primaryColor: Color(0xFFE91E63),
      secondaryColor: Color(0xFFC2185B),
      level: 3,
      minPoints: 2001,
      maxPoints: 5000,
      unlockedFeatures: [
        'All profile themes unlocked',
        'VIP room access',
        'Mentor new DJs',
        'Custom visual themes',
        'Priority in communities',
        'Exclusive badges',
      ],
      badges: ['Headliner', 'Mentor', 'Bass Prophet', 'Rave Warrior'],
      iconPath: 'assets/ranks/veteran.png',
    ),
  ];
}

class UserProfile {
  final String id;
  final String djName;
  final String username;
  final String? avatarUrl;
  final RankType currentRank;
  final int totalPoints;
  final List<String> preferredGenres;
  final Map<String, dynamic> profileTheme;
  final List<String> unlockedBadges;
  final DateTime joinedDate;

  UserProfile({
    required this.id,
    required this.djName,
    required this.username,
    this.avatarUrl,
    required this.currentRank,
    required this.totalPoints,
    required this.preferredGenres,
    required this.profileTheme,
    required this.unlockedBadges,
    required this.joinedDate,
  });

  RankModel get rank => RankModel.getRankByType(currentRank);
  
  double get currentRankProgress {
    final rank = this.rank;
    final pointsInCurrentRank = totalPoints - rank.minPoints;
    final totalRankPoints = rank.maxPoints - rank.minPoints;
    return (pointsInCurrentRank / totalRankPoints).clamp(0.0, 1.0);
  }

  int get pointsToNextRank {
    final rank = this.rank;
    return rank.maxPoints - totalPoints;
  }
}
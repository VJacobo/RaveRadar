import 'package:flutter/material.dart';

enum MoodType {
  hyped('🔥', 'Hyped', Colors.orange, MoodEffect.pulsingFlames),
  floating('💫', 'Floating', Colors.purple, MoodEffect.shimmeringParticles),
  trippy('🌌', 'Trippy', Colors.deepPurple, MoodEffect.rippleGlitch),
  vibing('🌈', 'Vibing', Colors.cyan, MoodEffect.rainbowWave),
  chargedUp('⚡', 'Charged Up', Colors.yellow, MoodEffect.electricSparks),
  flowing('🌊', 'Flowing', Colors.blue, MoodEffect.waveMotion),
  afterglow('🌙', 'Afterglow', Colors.indigo, MoodEffect.softGlow),
  lostInBeat('🌀', 'Lost in the Beat', Colors.teal, MoodEffect.spiralPulse),
  onFire('🔥🔥', 'On Fire', Colors.red, MoodEffect.intenseFire),
  underground('🖤', 'Underground', Colors.black87, MoodEffect.strobeFlash),
  euphoric('✨', 'Euphoric', Colors.pink, MoodEffect.sparkleRain),
  blasting('💥', 'Blasting', Colors.deepOrange, MoodEffect.explosion),
  maskedUp('🎭', 'Masked Up', Colors.purple, MoodEffect.mysteryFade),
  spunOut('🌪️', 'Spun Out', Colors.grey, MoodEffect.tornado),
  cosmic('☄️', 'Cosmic', Colors.blueAccent, MoodEffect.starField),
  chillin('🕶️', "Chillin'", Colors.blueGrey, MoodEffect.smoothWave),
  icy('💎', 'Icy', Colors.lightBlue, MoodEffect.crystalShine),
  melting('🫠', 'Melting', Colors.amber, MoodEffect.meltDrip),
  rabbitHole('🐇', 'Down the Rabbit Hole', Colors.deepPurple, MoodEffect.tunnelZoom),
  mystic('🔮', 'Mystic', Colors.purple, MoodEffect.orbFloat),
  mechanical('🦾', 'Mechanical', Colors.grey, MoodEffect.roboticPulse),
  grooving('🕺', 'Grooving', Colors.green, MoodEffect.danceWave),
  inTheMix('🎶', 'In the Mix', Colors.teal, MoodEffect.soundWave),
  shroomed('🍄', 'Shroomed', Colors.brown, MoodEffect.mushroomGrow),
  bassHeavy('🔊', 'Bass-Heavy', Colors.deepOrange, MoodEffect.bassThump),
  starlit('🌟', 'Starlit', Colors.yellow, MoodEffect.twinkle),
  alienated('🛸', 'Alienated', Colors.green, MoodEffect.alienBeam),
  ringing('🔔', 'Ringing', Colors.amber, MoodEffect.bellVibrate),
  crashedOut('💤', 'Crashed Out', Colors.blueGrey, MoodEffect.fadeOut),
  mindBlown('🤯', 'Mind-Blown', Colors.red, MoodEffect.headExplode);

  final String emoji;
  final String label;
  final Color color;
  final MoodEffect effect;

  const MoodType(this.emoji, this.label, this.color, this.effect);

  String get displayName => '$emoji $label';
}

enum MoodEffect {
  pulsingFlames,
  shimmeringParticles,
  rippleGlitch,
  rainbowWave,
  electricSparks,
  waveMotion,
  softGlow,
  spiralPulse,
  intenseFire,
  strobeFlash,
  sparkleRain,
  explosion,
  mysteryFade,
  tornado,
  starField,
  smoothWave,
  crystalShine,
  meltDrip,
  tunnelZoom,
  orbFloat,
  roboticPulse,
  danceWave,
  soundWave,
  mushroomGrow,
  bassThump,
  twinkle,
  alienBeam,
  bellVibrate,
  fadeOut,
  headExplode,
}

class MoodPost {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final MoodType mood;
  final DateTime postedAt;
  final DateTime expiresAt;
  final LocationTag? location;
  final EventTag? event;
  final List<MoodReaction> reactions;
  final bool isActive;

  MoodPost({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.mood,
    required this.postedAt,
    DateTime? expiresAt,
    this.location,
    this.event,
    List<MoodReaction>? reactions,
  })  : expiresAt = expiresAt ?? postedAt.add(const Duration(hours: 24)),
        reactions = reactions ?? [],
        isActive = DateTime.now().isBefore(
            expiresAt ?? postedAt.add(const Duration(hours: 24)));

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  
  Duration get timeRemaining => expiresAt.difference(DateTime.now());
  
  String get timeRemainingText {
    if (isExpired) return 'Expired';
    
    final hours = timeRemaining.inHours;
    final minutes = timeRemaining.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m left';
    } else {
      return '${minutes}m left';
    }
  }

  String get locationText {
    if (event != null) {
      return event!.name;
    } else if (location != null) {
      return location!.name;
    }
    return '';
  }

  MoodPost copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    MoodType? mood,
    DateTime? postedAt,
    DateTime? expiresAt,
    LocationTag? location,
    EventTag? event,
    List<MoodReaction>? reactions,
  }) {
    return MoodPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      mood: mood ?? this.mood,
      postedAt: postedAt ?? this.postedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      location: location ?? this.location,
      event: event ?? this.event,
      reactions: reactions ?? this.reactions,
    );
  }
}

class LocationTag {
  final String id;
  final String name;
  final String type; // club, venue, city, custom
  final double? latitude;
  final double? longitude;
  final String? address;

  LocationTag({
    required this.id,
    required this.name,
    required this.type,
    this.latitude,
    this.longitude,
    this.address,
  });
}

class EventTag {
  final String id;
  final String name;
  final String venue;
  final DateTime startTime;
  final bool hasRSVP;

  EventTag({
    required this.id,
    required this.name,
    required this.venue,
    required this.startTime,
    this.hasRSVP = false,
  });
}

class MoodReaction {
  final String userId;
  final String emoji;
  final DateTime timestamp;

  MoodReaction({
    required this.userId,
    required this.emoji,
    required this.timestamp,
  });
}

class MoodCluster {
  final MoodType mood;
  final List<MoodPost> posts;
  final LocationTag? location;
  final EventTag? event;

  MoodCluster({
    required this.mood,
    required this.posts,
    this.location,
    this.event,
  });

  int get count => posts.length;
  
  String get clusterText {
    if (location != null) {
      return '$count ravers are ${mood.displayName} at ${location!.name}';
    } else if (event != null) {
      return '$count ravers are ${mood.displayName} at ${event!.name}';
    } else {
      return '$count ravers are ${mood.displayName} right now';
    }
  }
}
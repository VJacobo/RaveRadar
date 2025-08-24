import 'package:flutter/material.dart';

enum EventType {
  festival,
  clubNight,
  concert,
  rave,
  underground,
  warehouse,
}

enum EventSource {
  residentAdvisor('Resident Advisor', 'https://ra.co'),
  edmTrain('EDM Train', 'https://edmtrain.com'),
  ticketmaster('Ticketmaster', 'https://ticketmaster.com'),
  dice('DICE', 'https://dice.fm'),
  eventbrite('Eventbrite', 'https://eventbrite.com'),
  bandsintown('Bandsintown', 'https://bandsintown.com');

  final String displayName;
  final String baseUrl;
  const EventSource(this.displayName, this.baseUrl);
}

class EventModel {
  final String id;
  final String name;
  final String venue;
  final String location;
  final DateTime startTime;
  final DateTime? endTime;
  final EventType type;
  final List<String> artists;
  final String? imageUrl;
  final String? description;
  final double? price;
  final String? ticketUrl;
  final EventSource source;
  final List<String> genres;
  final int? capacity;
  final bool isSoldOut;
  final double? latitude;
  final double? longitude;
  final int interestedCount;
  final int attendingCount;

  EventModel({
    required this.id,
    required this.name,
    required this.venue,
    required this.location,
    required this.startTime,
    this.endTime,
    required this.type,
    required this.artists,
    this.imageUrl,
    this.description,
    this.price,
    this.ticketUrl,
    required this.source,
    required this.genres,
    this.capacity,
    this.isSoldOut = false,
    this.latitude,
    this.longitude,
    this.interestedCount = 0,
    this.attendingCount = 0,
  });

  String get formattedDate {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[startTime.month - 1]} ${startTime.day}';
  }

  String get formattedTime {
    final hour = startTime.hour > 12 ? startTime.hour - 12 : startTime.hour;
    final amPm = startTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${startTime.minute.toString().padLeft(2, '0')} $amPm';
  }

  String get daysUntil {
    final now = DateTime.now();
    final difference = startTime.difference(now).inDays;
    
    if (difference == 0) return 'Tonight';
    if (difference == 1) return 'Tomorrow';
    if (difference < 7) return 'In $difference days';
    if (difference < 30) return 'In ${difference ~/ 7} weeks';
    return 'In ${difference ~/ 30} months';
  }

  Color get typeColor {
    switch (type) {
      case EventType.festival:
        return Colors.purple;
      case EventType.clubNight:
        return Colors.blue;
      case EventType.concert:
        return Colors.orange;
      case EventType.rave:
        return Colors.pink;
      case EventType.underground:
        return Colors.deepPurple;
      case EventType.warehouse:
        return Colors.indigo;
    }
  }

  IconData get typeIcon {
    switch (type) {
      case EventType.festival:
        return Icons.festival;
      case EventType.clubNight:
        return Icons.nightlife;
      case EventType.concert:
        return Icons.music_note;
      case EventType.rave:
        return Icons.flash_on;
      case EventType.underground:
        return Icons.vpn_key;
      case EventType.warehouse:
        return Icons.warehouse;
    }
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      name: json['name'] as String,
      venue: json['venue'] as String,
      location: json['location'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null 
        ? DateTime.parse(json['endTime'] as String) 
        : null,
      type: EventType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => EventType.clubNight,
      ),
      artists: List<String>.from(json['artists'] ?? []),
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      ticketUrl: json['ticketUrl'] as String?,
      source: EventSource.values.firstWhere(
        (s) => s.name == json['source'],
        orElse: () => EventSource.eventbrite,
      ),
      genres: List<String>.from(json['genres'] ?? []),
      capacity: json['capacity'] as int?,
      isSoldOut: json['isSoldOut'] as bool? ?? false,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      interestedCount: json['interestedCount'] as int? ?? 0,
      attendingCount: json['attendingCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'venue': venue,
      'location': location,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'type': type.name,
      'artists': artists,
      'imageUrl': imageUrl,
      'description': description,
      'price': price,
      'ticketUrl': ticketUrl,
      'source': source.name,
      'genres': genres,
      'capacity': capacity,
      'isSoldOut': isSoldOut,
      'latitude': latitude,
      'longitude': longitude,
      'interestedCount': interestedCount,
      'attendingCount': attendingCount,
    };
  }
}
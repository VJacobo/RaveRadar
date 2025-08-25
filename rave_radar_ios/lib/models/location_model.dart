import 'package:flutter/material.dart';

enum LocationType {
  club,
  bar,
  venue,
  festival,
  warehouse,
  underground,
  outdoor,
  rooftop,
}

class LocationModel {
  final String id;
  final String name;
  final String address;
  final String city;
  final String state;
  final String country;
  final double? latitude;
  final double? longitude;
  final LocationType type;
  final String? description;
  final List<String> images;
  final double? rating;
  final int reviewCount;
  final String? phoneNumber;
  final String? website;
  final List<String> amenities;
  final Map<String, String> hours;
  final bool isVerified;
  final DateTime createdAt;
  final String createdBy;
  final List<String> taggedUsers;

  LocationModel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    this.latitude,
    this.longitude,
    required this.type,
    this.description,
    List<String>? images,
    this.rating,
    this.reviewCount = 0,
    this.phoneNumber,
    this.website,
    List<String>? amenities,
    Map<String, String>? hours,
    this.isVerified = false,
    required this.createdAt,
    required this.createdBy,
    List<String>? taggedUsers,
  }) : images = images ?? [],
       amenities = amenities ?? [],
       hours = hours ?? {},
       taggedUsers = taggedUsers ?? [];

  String get fullAddress => '$address, $city, $state';

  Color get typeColor {
    switch (type) {
      case LocationType.club:
        return Colors.purple;
      case LocationType.bar:
        return Colors.amber;
      case LocationType.venue:
        return Colors.blue;
      case LocationType.festival:
        return Colors.green;
      case LocationType.warehouse:
        return Colors.grey;
      case LocationType.underground:
        return Colors.deepPurple;
      case LocationType.outdoor:
        return Colors.lightGreen;
      case LocationType.rooftop:
        return Colors.orange;
    }
  }

  IconData get typeIcon {
    switch (type) {
      case LocationType.club:
        return Icons.nightlife;
      case LocationType.bar:
        return Icons.local_bar;
      case LocationType.venue:
        return Icons.place;
      case LocationType.festival:
        return Icons.festival;
      case LocationType.warehouse:
        return Icons.warehouse;
      case LocationType.underground:
        return Icons.vpn_key;
      case LocationType.outdoor:
        return Icons.nature;
      case LocationType.rooftop:
        return Icons.terrain;
    }
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      country: json['country'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      type: LocationType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => LocationType.venue,
      ),
      description: json['description'] as String?,
      images: List<String>.from(json['images'] ?? []),
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: json['reviewCount'] as int? ?? 0,
      phoneNumber: json['phoneNumber'] as String?,
      website: json['website'] as String?,
      amenities: List<String>.from(json['amenities'] ?? []),
      hours: Map<String, String>.from(json['hours'] ?? {}),
      isVerified: json['isVerified'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
      taggedUsers: List<String>.from(json['taggedUsers'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'type': type.name,
      'description': description,
      'images': images,
      'rating': rating,
      'reviewCount': reviewCount,
      'phoneNumber': phoneNumber,
      'website': website,
      'amenities': amenities,
      'hours': hours,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'taggedUsers': taggedUsers,
    };
  }
}
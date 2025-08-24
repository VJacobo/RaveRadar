import 'dart:math' as math;
import '../models/event_model.dart';

class EventService {
  static final EventService _instance = EventService._internal();
  factory EventService() => _instance;
  EventService._internal();

  final List<EventModel> _events = [];
  final _random = math.Random();

  List<EventModel> get allEvents => List.unmodifiable(_events);

  List<EventModel> getUpcomingEvents({
    String? location,
    EventType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    var filtered = _events.where((event) {
      if (type != null && event.type != type) return false;
      if (startDate != null && event.startTime.isBefore(startDate)) return false;
      if (endDate != null && event.startTime.isAfter(endDate)) return false;
      if (location != null && !event.location.toLowerCase().contains(location.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    filtered.sort((a, b) => a.startTime.compareTo(b.startTime));
    return filtered;
  }

  void initializeRealWorldEvents() {
    if (_events.isNotEmpty) return;

    final now = DateTime.now();
    
    // Real venues and events based on popular EDM destinations
    _events.addAll([
      // Miami Events
      EventModel(
        id: 'ultra2024',
        name: 'Ultra Music Festival 2024',
        venue: 'Bayfront Park',
        location: 'Miami, FL',
        startTime: DateTime(now.year, 3, 22, 15, 0),
        endTime: DateTime(now.year, 3, 24, 23, 0),
        type: EventType.festival,
        artists: ['Swedish House Mafia', 'Martin Garrix', 'David Guetta', 'Tiësto', 'Hardwell'],
        imageUrl: 'https://ultramusicfestival.com',
        description: 'The world\'s premier electronic music festival returns to Miami',
        price: 399.99,
        ticketUrl: 'https://ultramusicfestival.com/tickets',
        source: EventSource.ticketmaster,
        genres: ['House', 'Techno', 'Trance', 'Dubstep'],
        capacity: 55000,
        isSoldOut: false,
        latitude: 25.7751,
        longitude: -80.1860,
        interestedCount: 45000,
        attendingCount: 35000,
      ),
      
      EventModel(
        id: 'space_miami_1',
        name: 'Tale Of Us All Night Long',
        venue: 'Space Miami',
        location: 'Miami, FL',
        startTime: now.add(Duration(days: 3)).copyWith(hour: 23, minute: 0),
        endTime: now.add(Duration(days: 4)).copyWith(hour: 11, minute: 0),
        type: EventType.clubNight,
        artists: ['Tale Of Us'],
        description: 'Extended journey through melodic techno',
        price: 80.00,
        ticketUrl: 'https://ra.co/events',
        source: EventSource.residentAdvisor,
        genres: ['Melodic Techno', 'Techno'],
        capacity: 1500,
        latitude: 25.7995,
        longitude: -80.1982,
        interestedCount: 1200,
        attendingCount: 800,
      ),

      // Los Angeles Events
      EventModel(
        id: 'edc_vegas',
        name: 'Electric Daisy Carnival Las Vegas',
        venue: 'Las Vegas Motor Speedway',
        location: 'Las Vegas, NV',
        startTime: DateTime(now.year, 5, 17, 19, 0),
        endTime: DateTime(now.year, 5, 19, 5, 30),
        type: EventType.festival,
        artists: ['Kaskade', 'Zedd', 'Alesso', 'Above & Beyond', 'Eric Prydz'],
        description: 'Under the Electric Sky - The biggest EDM festival in North America',
        price: 389.00,
        ticketUrl: 'https://lasvegas.electricdaisycarnival.com',
        source: EventSource.ticketmaster,
        genres: ['EDM', 'House', 'Trance', 'Drum & Bass'],
        capacity: 150000,
        isSoldOut: false,
        latitude: 36.2724,
        longitude: -115.0099,
        interestedCount: 120000,
        attendingCount: 100000,
      ),

      EventModel(
        id: 'sound_la_1',
        name: 'Amelie Lens',
        venue: 'Sound Nightclub',
        location: 'Los Angeles, CA',
        startTime: now.add(Duration(days: 7)).copyWith(hour: 22, minute: 0),
        endTime: now.add(Duration(days: 8)).copyWith(hour: 4, minute: 0),
        type: EventType.clubNight,
        artists: ['Amelie Lens', 'Farrago'],
        description: 'Belgian techno powerhouse',
        price: 45.00,
        ticketUrl: 'https://dice.fm',
        source: EventSource.dice,
        genres: ['Techno'],
        capacity: 500,
        latitude: 34.0452,
        longitude: -118.2388,
        interestedCount: 450,
        attendingCount: 300,
      ),

      // New York Events
      EventModel(
        id: 'brooklyn_mirage_1',
        name: 'Boris Brejcha',
        venue: 'Brooklyn Mirage',
        location: 'Brooklyn, NY',
        startTime: now.add(Duration(days: 14)).copyWith(hour: 21, minute: 0),
        endTime: now.add(Duration(days: 15)).copyWith(hour: 6, minute: 0),
        type: EventType.clubNight,
        artists: ['Boris Brejcha', 'Ann Clue'],
        description: 'High-tech minimal master at NYC\'s premier venue',
        price: 70.00,
        ticketUrl: 'https://ra.co',
        source: EventSource.residentAdvisor,
        genres: ['Minimal Techno', 'Tech House'],
        capacity: 6000,
        latitude: 40.7117,
        longitude: -73.9369,
        interestedCount: 5000,
        attendingCount: 4000,
      ),

      EventModel(
        id: 'ezoo_ny',
        name: 'Electric Zoo Festival',
        venue: 'Randall\'s Island Park',
        location: 'New York, NY',
        startTime: DateTime(now.year, 9, 1, 13, 0),
        endTime: DateTime(now.year, 9, 3, 23, 0),
        type: EventType.festival,
        artists: ['Deadmau5', 'Rezz', 'Illenium', 'Seven Lions', 'Marshmello'],
        description: 'New York\'s electronic music festival',
        price: 299.00,
        ticketUrl: 'https://electriczoo.com',
        source: EventSource.ticketmaster,
        genres: ['EDM', 'House', 'Dubstep', 'Future Bass'],
        capacity: 50000,
        latitude: 40.7931,
        longitude: -73.9217,
        interestedCount: 40000,
        attendingCount: 30000,
      ),

      // Chicago Events
      EventModel(
        id: 'arc_chicago',
        name: 'ARC Music Festival',
        venue: 'Union Park',
        location: 'Chicago, IL',
        startTime: DateTime(now.year, 9, 2, 12, 0),
        endTime: DateTime(now.year, 9, 4, 22, 0),
        type: EventType.festival,
        artists: ['Adam Beyer', 'Charlotte de Witte', 'Carl Cox', 'Nina Kraviz'],
        description: 'House and techno paradise in Chicago',
        price: 279.00,
        ticketUrl: 'https://arcmusicfestival.com',
        source: EventSource.eventbrite,
        genres: ['House', 'Techno'],
        capacity: 30000,
        latitude: 41.8858,
        longitude: -87.6476,
        interestedCount: 25000,
        attendingCount: 20000,
      ),

      EventModel(
        id: 'smartbar_chi',
        name: 'Honey Dijon',
        venue: 'Smartbar',
        location: 'Chicago, IL',
        startTime: now.add(Duration(days: 10)).copyWith(hour: 22, minute: 0),
        endTime: now.add(Duration(days: 11)).copyWith(hour: 5, minute: 0),
        type: EventType.clubNight,
        artists: ['Honey Dijon'],
        description: 'Chicago house legend returns home',
        price: 30.00,
        ticketUrl: 'https://ra.co',
        source: EventSource.residentAdvisor,
        genres: ['House', 'Disco'],
        capacity: 400,
        latitude: 41.9397,
        longitude: -87.6547,
        interestedCount: 380,
        attendingCount: 350,
      ),

      // San Francisco Events
      EventModel(
        id: 'portola_sf',
        name: 'Portola Music Festival',
        venue: 'Pier 80',
        location: 'San Francisco, CA',
        startTime: DateTime(now.year, 9, 28, 12, 0),
        endTime: DateTime(now.year, 9, 29, 23, 0),
        type: EventType.festival,
        artists: ['Jamie xx', 'Four Tet', 'Floating Points', 'Bicep', 'The Chemical Brothers'],
        description: 'Electronic music meets the Bay',
        price: 195.00,
        ticketUrl: 'https://portolamusicfestival.com',
        source: EventSource.ticketmaster,
        genres: ['Electronic', 'House', 'Techno', 'Experimental'],
        capacity: 25000,
        latitude: 37.7484,
        longitude: -122.3850,
        interestedCount: 20000,
        attendingCount: 15000,
      ),

      // Detroit Events
      EventModel(
        id: 'movement_det',
        name: 'Movement Electronic Music Festival',
        venue: 'Hart Plaza',
        location: 'Detroit, MI',
        startTime: DateTime(now.year, 5, 25, 12, 0),
        endTime: DateTime(now.year, 5, 27, 23, 0),
        type: EventType.festival,
        artists: ['Jeff Mills', 'Richie Hawtin', 'Carl Craig', 'Seth Troxler'],
        description: 'Techno returns to its birthplace',
        price: 225.00,
        ticketUrl: 'https://movement.us',
        source: EventSource.ticketmaster,
        genres: ['Techno', 'House', 'Electronic'],
        capacity: 40000,
        latitude: 42.3273,
        longitude: -83.0448,
        interestedCount: 35000,
        attendingCount: 30000,
      ),

      // Underground/Warehouse Events
      EventModel(
        id: 'warehouse_bk_1',
        name: '999999999 Live',
        venue: 'Secret Brooklyn Warehouse',
        location: 'Brooklyn, NY',
        startTime: now.add(Duration(days: 5)).copyWith(hour: 23, minute: 30),
        endTime: now.add(Duration(days: 6)).copyWith(hour: 8, minute: 0),
        type: EventType.warehouse,
        artists: ['999999999', 'I Hate Models', 'Dax J'],
        description: 'Location revealed 24h before. Hard techno all night.',
        price: 40.00,
        ticketUrl: 'https://ra.co',
        source: EventSource.residentAdvisor,
        genres: ['Hard Techno', 'Industrial'],
        capacity: 800,
        latitude: 40.6782,
        longitude: -73.9442,
        interestedCount: 750,
        attendingCount: 600,
      ),

      EventModel(
        id: 'underground_la_1',
        name: 'Incognito presents: DVS1',
        venue: 'Downtown LA Warehouse',
        location: 'Los Angeles, CA',
        startTime: now.add(Duration(days: 8)).copyWith(hour: 22, minute: 0),
        endTime: now.add(Duration(days: 9)).copyWith(hour: 7, minute: 0),
        type: EventType.underground,
        artists: ['DVS1', 'Truncate', 'Drumcell'],
        description: 'Proper techno. No phones. Just dancing.',
        price: 35.00,
        ticketUrl: 'https://dice.fm',
        source: EventSource.dice,
        genres: ['Techno'],
        capacity: 500,
        isSoldOut: true,
        latitude: 34.0407,
        longitude: -118.2468,
        interestedCount: 600,
        attendingCount: 500,
      ),

      // Smaller Club Events
      EventModel(
        id: 'output_bk',
        name: 'Ben Klock 6 Hour Set',
        venue: 'Nowadays',
        location: 'Queens, NY',
        startTime: now.add(Duration(days: 2)).copyWith(hour: 23, minute: 0),
        endTime: now.add(Duration(days: 3)).copyWith(hour: 5, minute: 0),
        type: EventType.clubNight,
        artists: ['Ben Klock'],
        description: 'Berghain resident extended set',
        price: 40.00,
        ticketUrl: 'https://ra.co',
        source: EventSource.residentAdvisor,
        genres: ['Techno'],
        capacity: 350,
        latitude: 40.7282,
        longitude: -73.9506,
        interestedCount: 340,
        attendingCount: 300,
      ),

      EventModel(
        id: 'flash_dc',
        name: 'Adriatique',
        venue: 'Flash',
        location: 'Washington, DC',
        startTime: now.add(Duration(days: 12)).copyWith(hour: 22, minute: 30),
        endTime: now.add(Duration(days: 13)).copyWith(hour: 4, minute: 0),
        type: EventType.clubNight,
        artists: ['Adriatique'],
        description: 'Melodic journey',
        price: 35.00,
        ticketUrl: 'https://dice.fm',
        source: EventSource.dice,
        genres: ['Melodic House', 'Progressive'],
        capacity: 600,
        latitude: 38.9072,
        longitude: -77.0369,
        interestedCount: 500,
        attendingCount: 400,
      ),
    ]);

    // Add some random future events
    for (int i = 0; i < 10; i++) {
      final daysAhead = _random.nextInt(60) + 1;
      final hour = 20 + _random.nextInt(4);
      
      _events.add(EventModel(
        id: 'random_$i',
        name: _generateRandomEventName(),
        venue: _generateRandomVenue(),
        location: _generateRandomLocation(),
        startTime: now.add(Duration(days: daysAhead)).copyWith(hour: hour, minute: 0),
        endTime: now.add(Duration(days: daysAhead + (_random.nextBool() ? 0 : 1)))
            .copyWith(hour: (hour + 4 + _random.nextInt(4)) % 24, minute: 0),
        type: EventType.values[_random.nextInt(EventType.values.length)],
        artists: _generateRandomArtists(),
        description: 'Electronic music event',
        price: 20.0 + _random.nextInt(80).toDouble(),
        source: EventSource.values[_random.nextInt(EventSource.values.length)],
        genres: _generateRandomGenres(),
        capacity: (5 + _random.nextInt(50)) * 100,
        interestedCount: _random.nextInt(1000),
        attendingCount: _random.nextInt(500),
      ));
    }

    _events.sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  String _generateRandomEventName() {
    final names = [
      'Techno Tuesday', 'House Music Wednesdays', 'Deep & Dark',
      'Warehouse Sessions', 'Underground Movement', 'Rhythm & Sound',
      'After Hours', 'Sunset Sessions', 'Rooftop Vibes', 'Basement Beats'
    ];
    return names[_random.nextInt(names.length)];
  }

  String _generateRandomVenue() {
    final venues = [
      'The Warehouse', 'Underground Club', 'Rooftop Lounge',
      'The Basement', 'Electric Room', 'Sound Factory',
      'The Bunker', 'Rhythm Hall', 'Beat Laboratory', 'The Cave'
    ];
    return venues[_random.nextInt(venues.length)];
  }

  String _generateRandomLocation() {
    final locations = [
      'Austin, TX', 'Seattle, WA', 'Portland, OR', 'Denver, CO',
      'Atlanta, GA', 'Boston, MA', 'Philadelphia, PA', 'Phoenix, AZ',
      'San Diego, CA', 'Nashville, TN'
    ];
    return locations[_random.nextInt(locations.length)];
  }

  List<String> _generateRandomArtists() {
    final artists = [
      'Nina Kraviz', 'Maceo Plex', 'Dixon', 'Solomun', 'Black Coffee',
      'Peggy Gou', 'Mall Grab', 'Denis Sulta', 'Jayda G', 'Palms Trax',
      'DJ Seinfeld', 'Ross From Friends', 'DJ Boring', 'Motor City Drum Ensemble'
    ];
    final count = 1 + _random.nextInt(3);
    final selected = <String>[];
    for (int i = 0; i < count; i++) {
      final artist = artists[_random.nextInt(artists.length)];
      if (!selected.contains(artist)) selected.add(artist);
    }
    return selected;
  }

  List<String> _generateRandomGenres() {
    final genres = [
      'House', 'Techno', 'Deep House', 'Tech House', 'Minimal',
      'Progressive', 'Acid', 'Electro', 'Breaks', 'Disco'
    ];
    final count = 1 + _random.nextInt(3);
    final selected = <String>[];
    for (int i = 0; i < count; i++) {
      final genre = genres[_random.nextInt(genres.length)];
      if (!selected.contains(genre)) selected.add(genre);
    }
    return selected;
  }
}
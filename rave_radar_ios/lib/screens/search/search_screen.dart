import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../models/location_model.dart';
import '../../models/post_model.dart';
import '../../utils/constants.dart';
import '../../widgets/common/rave_text_field.dart';
import '../../widgets/events/event_card.dart';

enum SearchType { all, events, locations, users }

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  SearchType _selectedType = SearchType.all;
  late TabController _tabController;

  final List<EventModel> _events = [];
  final List<LocationModel> _locations = [];
  final List<UserProfile> _users = [];
  
  List<EventModel> _filteredEvents = [];
  List<LocationModel> _filteredLocations = [];
  List<UserProfile> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchController.addListener(_onSearchChanged);
    _loadDemoData();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadDemoData() {
    final now = DateTime.now();
    
    _events.addAll([
      EventModel(
        id: '1',
        name: 'Underground Techno Night',
        venue: 'Warehouse 23',
        location: 'Brooklyn, NY',
        startTime: now.add(const Duration(days: 2)),
        type: EventType.underground,
        artists: ['Charlotte de Witte', 'Amelie Lens'],
        source: EventSource.residentAdvisor,
        genres: ['Techno'],
        price: 25.0,
      ),
      EventModel(
        id: '2',
        name: 'Summer Festival 2024',
        venue: 'Central Park',
        location: 'New York, NY',
        startTime: now.add(const Duration(days: 30)),
        type: EventType.festival,
        artists: ['Calvin Harris', 'The Chainsmokers', 'Zedd'],
        source: EventSource.ticketmaster,
        genres: ['EDM', 'Pop'],
        price: 150.0,
      ),
    ]);

    _locations.addAll([
      LocationModel(
        id: '1',
        name: 'Warehouse 23',
        address: '123 Industrial Blvd',
        city: 'Brooklyn',
        state: 'NY',
        country: 'USA',
        type: LocationType.warehouse,
        description: 'Raw industrial space perfect for underground events',
        amenities: ['Sound System', 'Bar', 'Parking'],
        createdAt: DateTime.now(),
        createdBy: 'admin',
      ),
      LocationModel(
        id: '2',
        name: 'Rooftop Lounge',
        address: '456 Skyline Ave',
        city: 'Miami',
        state: 'FL',
        country: 'USA',
        type: LocationType.rooftop,
        description: 'Amazing city views with premium sound',
        amenities: ['Outdoor Space', 'VIP Area', 'Food'],
        createdAt: DateTime.now(),
        createdBy: 'admin',
      ),
    ]);

    _users.addAll([
      UserProfile(
        id: '1',
        displayName: 'DJ Sarah',
        username: 'djsarah',
        bio: 'House & Techno enthusiast',
      ),
      UserProfile(
        id: '2',
        displayName: 'Mike Beats',
        username: 'mikebeats',
        bio: 'Festival lover and producer',
      ),
    ]);

    _filteredEvents = _events;
    _filteredLocations = _locations;
    _filteredUsers = _users;
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEvents = _events.where((event) =>
          event.name.toLowerCase().contains(query) ||
          event.venue.toLowerCase().contains(query) ||
          event.location.toLowerCase().contains(query) ||
          event.artists.any((artist) => artist.toLowerCase().contains(query))
      ).toList();

      _filteredLocations = _locations.where((location) =>
          location.name.toLowerCase().contains(query) ||
          location.address.toLowerCase().contains(query) ||
          location.city.toLowerCase().contains(query) ||
          location.amenities.any((amenity) => amenity.toLowerCase().contains(query))
      ).toList();

      _filteredUsers = _users.where((user) =>
          user.displayName.toLowerCase().contains(query) ||
          user.username.toLowerCase().contains(query) ||
          (user.bio?.toLowerCase().contains(query) ?? false)
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: AppColors.backgroundSecondary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search events, locations, or users...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Events'),
                  Tab(text: 'Locations'),
                  Tab(text: 'Users'),
                ],
              ),
            ],
          ),
        ),
      ),
      backgroundColor: AppColors.backgroundPrimary,
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllTab(),
          _buildEventsTab(),
          _buildLocationsTab(),
          _buildUsersTab(),
        ],
      ),
    );
  }

  Widget _buildAllTab() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        if (_filteredEvents.isNotEmpty) ...[
          const Text(
            'Events',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ..._filteredEvents.take(3).map((event) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: EventCard(
              event: event,
              onTap: () {},
              onInterested: () {},
              onShare: () {},
            ),
          )),
          if (_filteredEvents.length > 3)
            TextButton(
              onPressed: () => _tabController.animateTo(1),
              child: Text('See all ${_filteredEvents.length} events'),
            ),
          const SizedBox(height: AppSpacing.lg),
        ],

        if (_filteredLocations.isNotEmpty) ...[
          const Text(
            'Locations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ..._filteredLocations.take(3).map((location) => _buildLocationCard(location)),
          if (_filteredLocations.length > 3)
            TextButton(
              onPressed: () => _tabController.animateTo(2),
              child: Text('See all ${_filteredLocations.length} locations'),
            ),
          const SizedBox(height: AppSpacing.lg),
        ],

        if (_filteredUsers.isNotEmpty) ...[
          const Text(
            'Users',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ..._filteredUsers.take(3).map((user) => _buildUserCard(user)),
          if (_filteredUsers.length > 3)
            TextButton(
              onPressed: () => _tabController.animateTo(3),
              child: Text('See all ${_filteredUsers.length} users'),
            ),
        ],

        if (_filteredEvents.isEmpty && _filteredLocations.isEmpty && _filteredUsers.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Text(
                'No results found',
                style: TextStyle(color: Color(0xFF666666)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEventsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _filteredEvents.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: EventCard(
          event: _filteredEvents[index],
          onTap: () {},
          onInterested: () {},
          onShare: () {},
        ),
      ),
    );
  }

  Widget _buildLocationsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _filteredLocations.length,
      itemBuilder: (context, index) => _buildLocationCard(_filteredLocations[index]),
    );
  }

  Widget _buildUsersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) => _buildUserCard(_filteredUsers[index]),
    );
  }

  Widget _buildLocationCard(LocationModel location) {
    return Card(
      color: AppColors.backgroundSecondary,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: location.typeColor,
          child: Icon(location.typeIcon, color: Colors.white, size: 20),
        ),
        title: Text(
          location.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              location.fullAddress,
              style: const TextStyle(color: Color(0xFF666666)),
            ),
            if (location.amenities.isNotEmpty)
              Text(
                location.amenities.take(3).join(', '),
                style: const TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: Icon(
          location.isVerified ? Icons.verified : Icons.place,
          color: location.isVerified ? Colors.blue : const Color(0xFF666666),
        ),
        onTap: () {
          // TODO: Navigate to location details
        },
      ),
    );
  }

  Widget _buildUserCard(UserProfile user) {
    return Card(
      color: AppColors.backgroundSecondary,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user.avatarUrl != null 
              ? NetworkImage(user.avatarUrl!)
              : null,
          backgroundColor: Colors.purple,
          child: user.avatarUrl == null
              ? Text(
                  user.displayName[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                )
              : null,
        ),
        title: Text(
          user.displayName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '@${user.username}',
              style: const TextStyle(color: Color(0xFF666666)),
            ),
            if (user.bio != null)
              Text(
                user.bio!,
                style: const TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: const Icon(Icons.person, color: Color(0xFF666666)),
        onTap: () {
          // TODO: Navigate to user profile
        },
      ),
    );
  }
}
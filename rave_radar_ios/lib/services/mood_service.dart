import '../models/mood_model.dart';

class MoodService {
  static final MoodService _instance = MoodService._internal();
  factory MoodService() => _instance;
  MoodService._internal();

  final Map<String, MoodPost> _userMoods = {};
  final List<MoodPost> _allMoodPosts = [];
  
  // Post a new mood
  Future<void> postMood({
    required String userId,
    required String userName,
    required String userAvatar,
    required MoodType mood,
    LocationTag? location,
    EventTag? event,
  }) async {
    final moodPost = MoodPost(
      id: 'mood_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      mood: mood,
      postedAt: DateTime.now(),
      location: location,
      event: event,
    );
    
    _userMoods[userId] = moodPost;
    _allMoodPosts.add(moodPost);
    
    // Remove expired moods
    _cleanupExpiredMoods();
  }
  
  // Get current mood for a user
  MoodPost? getUserMood(String userId) {
    final mood = _userMoods[userId];
    if (mood != null && !mood.isExpired) {
      return mood;
    }
    return null;
  }
  
  // Get all active moods
  List<MoodPost> getActiveMoods() {
    _cleanupExpiredMoods();
    return _allMoodPosts.where((mood) => !mood.isExpired).toList();
  }
  
  // Get mood clusters (users with same mood at same location/event)
  List<MoodCluster> getMoodClusters() {
    final activeMoods = getActiveMoods();
    final Map<String, List<MoodPost>> clusters = {};
    
    for (final mood in activeMoods) {
      // Create cluster key based on mood type and location/event
      String key = mood.mood.name;
      if (mood.event != null) {
        key += '_event_${mood.event!.id}';
      } else if (mood.location != null) {
        key += '_location_${mood.location!.id}';
      }
      
      clusters.putIfAbsent(key, () => []).add(mood);
    }
    
    // Convert to MoodCluster objects and filter for clusters with 2+ users
    return clusters.entries
        .where((entry) => entry.value.length >= 2)
        .map((entry) {
          final posts = entry.value;
          return MoodCluster(
            mood: posts.first.mood,
            posts: posts,
            location: posts.first.location,
            event: posts.first.event,
          );
        })
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));
  }
  
  // Get moods at a specific event
  List<MoodPost> getMoodsAtEvent(String eventId) {
    return getActiveMoods()
        .where((mood) => mood.event?.id == eventId)
        .toList();
  }
  
  // Get moods at a specific location
  List<MoodPost> getMoodsAtLocation(String locationId) {
    return getActiveMoods()
        .where((mood) => mood.location?.id == locationId)
        .toList();
  }
  
  // Add reaction to a mood
  void addReaction(String moodId, String userId, String emoji) {
    final moodIndex = _allMoodPosts.indexWhere((m) => m.id == moodId);
    if (moodIndex != -1) {
      final mood = _allMoodPosts[moodIndex];
      final reaction = MoodReaction(
        userId: userId,
        emoji: emoji,
        timestamp: DateTime.now(),
      );
      
      final updatedReactions = List<MoodReaction>.from(mood.reactions)..add(reaction);
      _allMoodPosts[moodIndex] = mood.copyWith(reactions: updatedReactions);
    }
  }
  
  // Clean up expired moods
  void _cleanupExpiredMoods() {
    _allMoodPosts.removeWhere((mood) => mood.isExpired);
    _userMoods.removeWhere((userId, mood) => mood.isExpired);
  }
  
  // Initialize with demo data
  void initializeDemoData() {
    final demoMoods = [
      MoodPost(
        id: 'demo_1',
        userId: 'user_1',
        userName: 'BassHead',
        userAvatar: '',
        mood: MoodType.hyped,
        postedAt: DateTime.now().subtract(const Duration(hours: 2)),
        event: EventTag(
          id: 'e1',
          name: 'Bass Temple',
          venue: 'Club Space',
          startTime: DateTime.now().add(const Duration(hours: 4)),
        ),
      ),
      MoodPost(
        id: 'demo_2',
        userId: 'user_2',
        userName: 'RaveQueen',
        userAvatar: '',
        mood: MoodType.floating,
        postedAt: DateTime.now().subtract(const Duration(hours: 1)),
        location: LocationTag(
          id: 'l1',
          name: 'Miami Beach',
          type: 'city',
        ),
      ),
      MoodPost(
        id: 'demo_3',
        userId: 'user_3',
        userName: 'TechnoSoul',
        userAvatar: '',
        mood: MoodType.hyped,
        postedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        event: EventTag(
          id: 'e1',
          name: 'Bass Temple',
          venue: 'Club Space',
          startTime: DateTime.now().add(const Duration(hours: 4)),
        ),
      ),
      MoodPost(
        id: 'demo_4',
        userId: 'user_4',
        userName: 'DropMaster',
        userAvatar: '',
        mood: MoodType.trippy,
        postedAt: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
      MoodPost(
        id: 'demo_5',
        userId: 'user_5',
        userName: 'NeonVibes',
        userAvatar: '',
        mood: MoodType.vibing,
        postedAt: DateTime.now().subtract(const Duration(hours: 3)),
        location: LocationTag(
          id: 'l2',
          name: 'Electric Pickle',
          type: 'club',
        ),
      ),
    ];
    
    _allMoodPosts.addAll(demoMoods);
    for (final mood in demoMoods) {
      _userMoods[mood.userId] = mood;
    }
  }
}
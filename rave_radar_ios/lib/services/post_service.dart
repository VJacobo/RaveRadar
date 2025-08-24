import 'dart:math' as math;
import '../models/post_model.dart';

class PostService {
  static final PostService _instance = PostService._internal();
  factory PostService() => _instance;
  PostService._internal();

  final List<Post> _posts = [];
  final _random = math.Random();

  List<Post> get allPosts => List.unmodifiable(_posts);

  List<Post> getFilteredPosts({MoodType? mood, PostType? type}) {
    return _posts.where((post) {
      if (mood != null && post.mood != mood) return false;
      if (type != null && post.type != type) return false;
      return true;
    }).toList();
  }

  List<Post> getPostsByUserId(String userId) {
    // For demo, create some posts for the current user if none exist
    if (_posts.where((p) => p.userId == userId).isEmpty && userId == 'guest_user') {
      _createUserPosts(userId);
    }
    
    return _posts
        .where((post) => post.userId == userId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  void _createUserPosts(String userId) {
    // Create sample posts for the user
    final postTypes = [PostType.mood, PostType.text, PostType.track, PostType.photo, PostType.event];
    final moods = MoodType.values;
    
    for (int i = 0; i < 5; i++) {
      final type = postTypes[i % postTypes.length];
      _posts.add(Post(
        id: 'user_post_$i',
        userId: userId,
        userName: 'Guest User',
        userHandle: '@guest',
        type: type,
        timestamp: DateTime.now().subtract(Duration(days: i, hours: _random.nextInt(24))),
        content: _getContentForType(type, i),
        mood: type == PostType.mood ? moods[_random.nextInt(moods.length)] : null,
        trackTitle: type == PostType.track ? 'My Mix #${i + 1}' : null,
        trackArtist: type == PostType.track ? 'Guest User' : null,
        eventName: type == PostType.event ? 'My Event #${i + 1}' : null,
        eventLocation: type == PostType.event ? 'Miami Beach' : null,
        eventTime: type == PostType.event 
          ? DateTime.now().add(Duration(days: _random.nextInt(30)))
          : null,
        mediaUrls: type == PostType.photo 
          ? ['https://images.unsplash.com/photo-1514525253161-7a46d19cd819']
          : null,
        reactions: {
          ReactionType.hype: _random.nextInt(50),
          ReactionType.love: _random.nextInt(30),
          ReactionType.glow: _random.nextInt(20),
          ReactionType.vibe: _random.nextInt(40),
          ReactionType.bass: _random.nextInt(25),
          ReactionType.drop: _random.nextInt(15),
        },
        commentCount: _random.nextInt(20),
        shareCount: _random.nextInt(10),
      ));
    }
  }

  void initializeMockData() {
    if (_posts.isNotEmpty) return;
    
    const names = ['BassHead', 'RaveQueen', 'DropMaster', 'NeonVibes', 'TechnoSoul'];
    final moods = MoodType.values;
    
    for (int i = 0; i < 20; i++) {
      final postTypes = PostType.values;
      final type = postTypes[_random.nextInt(postTypes.length)];
      
      _posts.add(Post(
        id: 'post_$i',
        userId: 'user_$i',
        userName: '${names[i % names.length]}${i ~/ names.length > 0 ? i ~/ names.length : ''}',
        userHandle: '@${names[i % names.length].toLowerCase()}${i}',
        type: type,
        timestamp: DateTime.now().subtract(Duration(
          hours: _random.nextInt(24),
          minutes: _random.nextInt(60),
        )),
        content: _getContentForType(type, i),
        mood: type == PostType.mood ? moods[_random.nextInt(moods.length)] : null,
        trackTitle: type == PostType.track ? 'Underground Mix ${i + 1}' : null,
        trackArtist: type == PostType.track ? 'DJ ${names[i % names.length]}' : null,
        eventName: type == PostType.event ? 'Warehouse Sessions ${i + 1}' : null,
        eventLocation: type == PostType.event ? 'Secret Location' : null,
        eventTime: type == PostType.event 
          ? DateTime.now().add(Duration(days: _random.nextInt(7)))
          : null,
        reactions: _generateRandomReactions(),
        commentCount: _random.nextInt(50),
        shareCount: _random.nextInt(20),
      ));
    }
    
    _posts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  String _getContentForType(PostType type, int index) {
    switch (type) {
      case PostType.mood:
        return _moodContent[index % _moodContent.length];
      case PostType.text:
        return _textContent[index % _textContent.length];
      case PostType.photo:
        return _photoContent[index % _photoContent.length];
      case PostType.track:
        return _trackContent[index % _trackContent.length];
      case PostType.event:
        return _eventContent[index % _eventContent.length];
    }
  }

  Map<ReactionType, int> _generateRandomReactions() {
    final reactions = <ReactionType, int>{};
    for (final reaction in ReactionType.values) {
      if (_random.nextBool()) {
        reactions[reaction] = _random.nextInt(30);
      }
    }
    return reactions;
  }

  void addReaction(String postId, ReactionType reaction) {
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex != -1) {
      final post = _posts[postIndex];
      final newReactions = Map<ReactionType, int>.from(post.reactions);
      newReactions[reaction] = (newReactions[reaction] ?? 0) + 1;
      
      _posts[postIndex] = Post(
        id: post.id,
        userId: post.userId,
        userName: post.userName,
        userHandle: post.userHandle,
        userAvatar: post.userAvatar,
        type: post.type,
        timestamp: post.timestamp,
        content: post.content,
        mediaUrls: post.mediaUrls,
        mood: post.mood,
        trackTitle: post.trackTitle,
        trackArtist: post.trackArtist,
        trackUrl: post.trackUrl,
        eventName: post.eventName,
        eventLocation: post.eventLocation,
        eventTime: post.eventTime,
        reactions: newReactions,
        commentCount: post.commentCount,
        shareCount: post.shareCount,
        taggedUsers: post.taggedUsers,
        isSaved: post.isSaved,
      );
    }
  }

  void toggleSavePost(String postId) {
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex != -1) {
      final post = _posts[postIndex];
      _posts[postIndex] = Post(
        id: post.id,
        userId: post.userId,
        userName: post.userName,
        userHandle: post.userHandle,
        userAvatar: post.userAvatar,
        type: post.type,
        timestamp: post.timestamp,
        content: post.content,
        mediaUrls: post.mediaUrls,
        mood: post.mood,
        trackTitle: post.trackTitle,
        trackArtist: post.trackArtist,
        trackUrl: post.trackUrl,
        eventName: post.eventName,
        eventLocation: post.eventLocation,
        eventTime: post.eventTime,
        reactions: post.reactions,
        commentCount: post.commentCount,
        shareCount: post.shareCount,
        taggedUsers: post.taggedUsers,
        isSaved: !post.isSaved,
      );
    }
  }

  // Content arrays
  static const _moodContent = [
    'The bass is hitting different tonight ✨',
    'Lost in the rhythm 🌊',
    'This set is taking me places 🚀',
    'Pure euphoria on the dancefloor',
    'When the drop hits just right 🔥',
  ];

  static const _textContent = [
    'Remember when we thought 3am was late? Now that\'s when the real magic starts 🌙',
    'Shoutout to everyone who made last night unforgettable! You know who you are 💜',
    'That moment when the DJ reads the crowd perfectly... pure magic',
    'New underground spot discovered. If you know, you know 👁️',
    'The scene isn\'t dead, it\'s just gone deeper underground',
  ];

  static const _photoContent = [
    'Last night\'s energy captured in one frame 📸',
    'When the visuals match the beat perfectly',
    'Sunset to sunrise crew checking in',
    'This lineup though... 🔥',
    'Caught the perfect moment',
  ];

  static const _trackContent = [
    'This one\'s been on repeat all week',
    'ID on this absolute heater?',
    'Closing track from last night\'s set',
    'Underground gem alert 💎',
    'This breakdown gives me chills every time',
  ];

  static const _eventContent = [
    'Who\'s pulling up? Let\'s connect!',
    'Limited spots left, link in bio',
    'See you on the dancefloor',
    'This lineup is absolutely stacked',
    'Secret location drops 2 hours before',
  ];
}
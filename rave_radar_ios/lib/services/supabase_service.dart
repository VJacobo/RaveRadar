import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient _client = Supabase.instance.client;
  
  String? _currentUserId;
  
  Future<List<Post>> fetchPosts({MoodType? mood}) async {
    try {
      var query = _client
          .from('posts')
          .select('''
            *,
            profiles!posts_user_id_fkey(*),
            reactions(reaction_type, user_id),
            post_saves(user_id)
          ''');
      
      if (mood != null) {
        query = query.eq('mood', mood.name);
      }
      
      final response = await query
          .order('created_at', ascending: false)
          .limit(50);
      
      return _mapResponseToPosts(response);
    } catch (e) {
      throw Exception('Failed to fetch posts: $e');
    }
  }
  
  Future<void> addReaction(String postId, ReactionType reaction) async {
    try {
      final userId = await _getCurrentUserId();
      
      await _client.from('reactions').upsert({
        'post_id': postId,
        'user_id': userId,
        'reaction_type': reaction.name,
      }, onConflict: 'post_id,user_id,reaction_type');
    } catch (e) {
      throw Exception('Failed to add reaction: $e');
    }
  }
  
  Future<void> toggleSavePost(String postId) async {
    try {
      final userId = await _getCurrentUserId();
      
      final existing = await _client
          .from('post_saves')
          .select()
          .eq('post_id', postId)
          .eq('user_id', userId)
          .maybeSingle();
      
      if (existing != null) {
        await _client
            .from('post_saves')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', userId);
      } else {
        await _client.from('post_saves').insert({
          'post_id': postId,
          'user_id': userId,
        });
      }
    } catch (e) {
      throw Exception('Failed to toggle save: $e');
    }
  }
  
  Future<void> createPost(Post post) async {
    try {
      final userId = await _getCurrentUserId();
      
      final metadata = <String, dynamic>{};
      if (post.trackTitle != null) metadata['track_title'] = post.trackTitle;
      if (post.trackArtist != null) metadata['track_artist'] = post.trackArtist;
      if (post.eventName != null) metadata['event_name'] = post.eventName;
      if (post.eventLocation != null) metadata['event_location'] = post.eventLocation;
      if (post.eventTime != null) metadata['event_time'] = post.eventTime?.toIso8601String();
      
      await _client.from('posts').insert({
        'user_id': userId,
        'type': post.type.name,
        'content': post.content,
        'mood': post.mood?.name,
        'metadata': metadata,
      });
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }
  
  Future<String> _getCurrentUserId() async {
    if (_currentUserId != null) return _currentUserId!;
    
    final existing = await _client
        .from('profiles')
        .select('id')
        .limit(1)
        .maybeSingle();
    
    if (existing != null) {
      _currentUserId = existing['id'];
      return _currentUserId!;
    }
    
    final newProfile = await _client.from('profiles').insert({
      'username': 'user_${DateTime.now().millisecondsSinceEpoch}',
      'display_name': 'Demo User',
      'handle': '@demo_${DateTime.now().millisecondsSinceEpoch}',
      'avatar_color': '#9C27B0',
    }).select().single();
    
    _currentUserId = newProfile['id'];
    return _currentUserId!;
  }
  
  List<Post> _mapResponseToPosts(List<dynamic> response) {
    return response.map((item) {
      final profile = item['profiles'];
      final reactions = item['reactions'] as List? ?? [];
      final saves = item['post_saves'] as List? ?? [];
      final metadata = item['metadata'] as Map<String, dynamic>? ?? {};
      
      final reactionMap = <ReactionType, int>{};
      for (final r in reactions) {
        final type = ReactionType.values.firstWhere(
          (rt) => rt.name == r['reaction_type'],
          orElse: () => ReactionType.glow,
        );
        reactionMap[type] = (reactionMap[type] ?? 0) + 1;
      }
      
      final isSaved = saves.any((s) => s['user_id'] == _currentUserId);
      
      MoodType? mood;
      if (item['mood'] != null) {
        mood = MoodType.values.firstWhere(
          (m) => m.name == item['mood'],
          orElse: () => MoodType.vibing,
        );
      }
      
      return Post(
        id: item['id'],
        userId: item['user_id'],
        userName: profile['display_name'] ?? 'Unknown',
        userHandle: profile['handle'] ?? '@unknown',
        type: PostType.values.firstWhere(
          (t) => t.name == item['type'],
          orElse: () => PostType.text,
        ),
        timestamp: DateTime.parse(item['created_at']),
        content: item['content'],
        mood: mood,
        trackTitle: metadata['track_title'],
        trackArtist: metadata['track_artist'],
        eventName: metadata['event_name'],
        eventLocation: metadata['event_location'],
        eventTime: metadata['event_time'] != null 
            ? DateTime.parse(metadata['event_time']) 
            : null,
        reactions: reactionMap,
        commentCount: item['comment_count'] ?? 0,
        shareCount: item['share_count'] ?? 0,
        isSaved: isSaved,
      );
    }).toList();
  }
}
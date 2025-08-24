import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/post_model.dart';
import '../../services/supabase_service.dart';
import 'feed_event.dart';
import 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final SupabaseService _supabaseService;
  
  FeedBloc({SupabaseService? supabaseService}) 
    : _supabaseService = supabaseService ?? SupabaseService(),
      super(FeedInitial()) {
    on<LoadFeed>(_onLoadFeed);
    on<RefreshFeed>(_onRefreshFeed);
    on<FilterByMood>(_onFilterByMood);
    on<AddReaction>(_onAddReaction);
    on<ToggleSavePost>(_onToggleSavePost);
    on<CreatePost>(_onCreatePost);
  }
  
  Future<void> _onLoadFeed(LoadFeed event, Emitter<FeedState> emit) async {
    emit(FeedLoading());
    try {
      final posts = await _supabaseService.fetchPosts();
      emit(FeedLoaded(posts: posts));
    } catch (e) {
      emit(FeedError(e.toString()));
    }
  }
  
  Future<void> _onRefreshFeed(RefreshFeed event, Emitter<FeedState> emit) async {
    if (state is FeedLoaded) {
      final currentState = state as FeedLoaded;
      try {
        final posts = await _supabaseService.fetchPosts(
          mood: currentState.filterMood,
        );
        emit(currentState.copyWith(posts: posts));
      } catch (e) {
        emit(FeedError(e.toString()));
      }
    }
  }
  
  Future<void> _onFilterByMood(FilterByMood event, Emitter<FeedState> emit) async {
    emit(FeedLoading());
    try {
      final posts = await _supabaseService.fetchPosts(mood: event.mood);
      emit(FeedLoaded(posts: posts, filterMood: event.mood));
    } catch (e) {
      emit(FeedError(e.toString()));
    }
  }
  
  Future<void> _onAddReaction(AddReaction event, Emitter<FeedState> emit) async {
    if (state is FeedLoaded) {
      final currentState = state as FeedLoaded;
      try {
        await _supabaseService.addReaction(event.postId, event.reaction);
        
        final updatedPosts = currentState.posts.map((post) {
          if (post.id == event.postId) {
            final newReactions = Map<ReactionType, int>.from(post.reactions);
            newReactions[event.reaction] = (newReactions[event.reaction] ?? 0) + 1;
            
            return Post(
              id: post.id,
              userId: post.userId,
              userName: post.userName,
              userHandle: post.userHandle,
              type: post.type,
              timestamp: post.timestamp,
              content: post.content,
              mood: post.mood,
              trackTitle: post.trackTitle,
              trackArtist: post.trackArtist,
              eventName: post.eventName,
              eventLocation: post.eventLocation,
              eventTime: post.eventTime,
              reactions: newReactions,
              commentCount: post.commentCount,
              shareCount: post.shareCount,
              isSaved: post.isSaved,
            );
          }
          return post;
        }).toList();
        
        emit(currentState.copyWith(posts: updatedPosts));
      } catch (e) {
        add(RefreshFeed());
      }
    }
  }
  
  Future<void> _onToggleSavePost(ToggleSavePost event, Emitter<FeedState> emit) async {
    if (state is FeedLoaded) {
      final currentState = state as FeedLoaded;
      try {
        await _supabaseService.toggleSavePost(event.postId);
        
        final updatedPosts = currentState.posts.map((post) {
          if (post.id == event.postId) {
            return Post(
              id: post.id,
              userId: post.userId,
              userName: post.userName,
              userHandle: post.userHandle,
              type: post.type,
              timestamp: post.timestamp,
              content: post.content,
              mood: post.mood,
              trackTitle: post.trackTitle,
              trackArtist: post.trackArtist,
              eventName: post.eventName,
              eventLocation: post.eventLocation,
              eventTime: post.eventTime,
              reactions: post.reactions,
              commentCount: post.commentCount,
              shareCount: post.shareCount,
              isSaved: !post.isSaved,
            );
          }
          return post;
        }).toList();
        
        emit(currentState.copyWith(posts: updatedPosts));
      } catch (e) {
        add(RefreshFeed());
      }
    }
  }
  
  Future<void> _onCreatePost(CreatePost event, Emitter<FeedState> emit) async {
    try {
      await _supabaseService.createPost(event.post);
      add(RefreshFeed());
    } catch (e) {
      emit(FeedError(e.toString()));
    }
  }
}
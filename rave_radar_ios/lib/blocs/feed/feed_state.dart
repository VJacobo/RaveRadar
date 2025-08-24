import 'package:equatable/equatable.dart';
import '../../models/post_model.dart';

abstract class FeedState extends Equatable {
  const FeedState();
  
  @override
  List<Object?> get props => [];
}

class FeedInitial extends FeedState {}

class FeedLoading extends FeedState {}

class FeedLoaded extends FeedState {
  final List<Post> posts;
  final MoodType? filterMood;
  final bool hasMore;
  
  const FeedLoaded({
    required this.posts,
    this.filterMood,
    this.hasMore = false,
  });
  
  FeedLoaded copyWith({
    List<Post>? posts,
    MoodType? filterMood,
    bool? hasMore,
  }) {
    return FeedLoaded(
      posts: posts ?? this.posts,
      filterMood: filterMood,
      hasMore: hasMore ?? this.hasMore,
    );
  }
  
  @override
  List<Object?> get props => [posts, filterMood, hasMore];
}

class FeedError extends FeedState {
  final String message;
  
  const FeedError(this.message);
  
  @override
  List<Object> get props => [message];
}
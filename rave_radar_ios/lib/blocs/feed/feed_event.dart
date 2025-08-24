import 'package:equatable/equatable.dart';
import '../../models/post_model.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

class LoadFeed extends FeedEvent {}

class RefreshFeed extends FeedEvent {}

class FilterByMood extends FeedEvent {
  final MoodType? mood;
  
  const FilterByMood(this.mood);
  
  @override
  List<Object?> get props => [mood];
}

class AddReaction extends FeedEvent {
  final String postId;
  final ReactionType reaction;
  
  const AddReaction({required this.postId, required this.reaction});
  
  @override
  List<Object?> get props => [postId, reaction];
}

class ToggleSavePost extends FeedEvent {
  final String postId;
  
  const ToggleSavePost(this.postId);
  
  @override
  List<Object?> get props => [postId];
}

class CreatePost extends FeedEvent {
  final Post post;
  
  const CreatePost(this.post);
  
  @override
  List<Object?> get props => [post];
}
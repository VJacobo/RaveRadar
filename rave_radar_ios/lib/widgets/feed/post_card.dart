import 'package:flutter/material.dart';
import '../../models/post_model.dart';
import '../../utils/constants.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final Function(ReactionType) onReaction;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onComment;

  const PostCard({
    super.key,
    required this.post,
    required this.onReaction,
    required this.onSave,
    required this.onShare,
    required this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: post.mood?.color.withAlpha(51) ?? Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          if (post.mood != null) _buildMoodIndicator(),
          _buildContent(),
          _buildMediaContent(),
          _buildInteractionBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.primaries[
              post.userId.hashCode % Colors.primaries.length
            ],
            child: Text(
              post.userName[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.userName,
                  style: AppTextStyles.subtitle2,
                ),
                Text(
                  '${post.userHandle} • ${post.timeAgo}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.more_horiz,
              color: AppColors.textSecondary,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMoodIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: post.mood!.color.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.rounded),
        border: Border.all(
          color: post.mood!.color.withAlpha(77),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            post.mood!.label,
            style: TextStyle(
              color: post.mood!.color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (post.content == null) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Text(
        post.content!,
        style: AppTextStyles.body1.copyWith(
          color: AppColors.textPrimary,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildMediaContent() {
    switch (post.type) {
      case PostType.photo:
        return _buildPhotoContent();
      case PostType.track:
        return _buildTrackContent();
      case PostType.event:
        return _buildEventContent();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPhotoContent() {
    return Container(
      height: 300,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.primaries[post.id.hashCode % Colors.primaries.length],
            Colors.primaries[(post.id.hashCode + 1) % Colors.primaries.length],
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.image,
          color: Colors.white24,
          size: 64,
        ),
      ),
    );
  }

  Widget _buildTrackContent() {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withAlpha(26),
            Colors.pink.withAlpha(26),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: Colors.purple.withAlpha(51),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.purple.withAlpha(51),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.music_note,
              color: Colors.purple,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.trackTitle ?? 'Unknown Track',
                  style: AppTextStyles.subtitle2,
                ),
                Text(
                  post.trackArtist ?? 'Unknown Artist',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.play_circle_outline),
            color: Colors.purple,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildEventContent() {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withAlpha(26),
            Colors.red.withAlpha(26),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: Colors.orange.withAlpha(51),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.eventName ?? 'Event',
            style: AppTextStyles.subtitle1.copyWith(
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                post.eventLocation ?? 'TBA',
                style: AppTextStyles.body2,
              ),
            ],
          ),
          if (post.eventTime != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${post.eventTime!.month}/${post.eventTime!.day} at ${post.eventTime!.hour}:${post.eventTime!.minute.toString().padLeft(2, '0')}',
                  style: AppTextStyles.body2,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInteractionBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              _buildReactionButtons(),
              const Spacer(),
              _buildActionButtons(),
            ],
          ),
          if (post.totalReactions > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildReactionSummary(),
          ],
        ],
      ),
    );
  }

  Widget _buildReactionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundTertiary.withAlpha(128),
        borderRadius: BorderRadius.circular(AppRadius.rounded),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ReactionType.values.take(3).map((reaction) {
          final count = post.reactions[reaction] ?? 0;
          return InkWell(
            onTap: () => onReaction(reaction),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Text(reaction.emoji, style: const TextStyle(fontSize: 18)),
                  if (count > 0) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      count.toString(),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            Icons.chat_bubble_outline,
            color: AppColors.textSecondary,
            size: 20,
          ),
          onPressed: onComment,
        ),
        if (post.commentCount > 0)
          Text(
            post.commentCount.toString(),
            style: AppTextStyles.caption,
          ),
        const SizedBox(width: AppSpacing.sm),
        IconButton(
          icon: Icon(
            Icons.share_outlined,
            color: AppColors.textSecondary,
            size: 20,
          ),
          onPressed: onShare,
        ),
        const SizedBox(width: AppSpacing.sm),
        IconButton(
          icon: Icon(
            post.isSaved ? Icons.bookmark : Icons.bookmark_border,
            color: post.isSaved ? Colors.purple : AppColors.textSecondary,
            size: 20,
          ),
          onPressed: onSave,
        ),
      ],
    );
  }

  Widget _buildReactionSummary() {
    final topReactions = post.reactions.entries
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Row(
      children: [
        ...topReactions.take(3).map((e) => Text(e.key.emoji)),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '${post.totalReactions} reactions',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}
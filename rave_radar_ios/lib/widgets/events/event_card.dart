import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../utils/constants.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;
  final VoidCallback onInterested;
  final VoidCallback onShare;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    required this.onInterested,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: event.typeColor.withAlpha(51),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildEventDetails(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xl),
          topRight: Radius.circular(AppRadius.xl),
        ),
        gradient: LinearGradient(
          colors: [
            event.typeColor.withAlpha(128),
            event.typeColor.withAlpha(51),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: AppSpacing.lg,
            left: AppSpacing.lg,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(128),
                borderRadius: BorderRadius.circular(AppRadius.rounded),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    event.typeIcon,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    event.type.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: AppSpacing.lg,
            right: AppSpacing.lg,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: event.isSoldOut 
                  ? Colors.red.withAlpha(204)
                  : Colors.green.withAlpha(204),
                borderRadius: BorderRadius.circular(AppRadius.rounded),
              ),
              child: Text(
                event.isSoldOut ? 'SOLD OUT' : event.daysUntil.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: AppSpacing.lg,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  event.formattedDate.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white.withAlpha(204),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  event.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetails() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Artists
          if (event.artists.isNotEmpty) ...[
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: event.artists.take(3).map((artist) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: event.typeColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(AppRadius.rounded),
                    border: Border.all(
                      color: event.typeColor.withAlpha(77),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    artist,
                    style: TextStyle(
                      color: event.typeColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
            if (event.artists.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  '+${event.artists.length - 3} more artists',
                  style: AppTextStyles.caption,
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Venue and Location
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '${event.venue} • ${event.location}',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Time
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                event.formattedTime,
                style: AppTextStyles.body2,
              ),
              if (event.endTime != null) ...[
                Text(
                  ' - ',
                  style: AppTextStyles.body2,
                ),
                Text(
                  '${event.endTime!.hour > 12 ? event.endTime!.hour - 12 : event.endTime!.hour}:${event.endTime!.minute.toString().padLeft(2, '0')} ${event.endTime!.hour >= 12 ? 'PM' : 'AM'}',
                  style: AppTextStyles.body2,
                ),
              ],
            ],
          ),

          // Price
          if (event.price != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  Icons.confirmation_number_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  event.price == 0 ? 'Free' : '\$${event.price!.toStringAsFixed(2)}',
                  style: AppTextStyles.body2.copyWith(
                    color: event.price == 0 ? Colors.green : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],

          // Genres
          if (event.genres.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.xs,
              children: event.genres.map((genre) {
                return Text(
                  '#$genre',
                  style: AppTextStyles.caption.copyWith(
                    color: event.typeColor.withAlpha(179),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.backgroundTertiary,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Interested/Attending Count
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${event.interestedCount}',
                        style: AppTextStyles.subtitle2.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'interested',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xl),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${event.attendingCount}',
                        style: AppTextStyles.subtitle2.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'going',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.star_border,
                  color: AppColors.textSecondary,
                ),
                onPressed: onInterested,
              ),
              IconButton(
                icon: Icon(
                  Icons.share_outlined,
                  color: AppColors.textSecondary,
                ),
                onPressed: onShare,
              ),
              if (event.ticketUrl != null && !event.isSoldOut)
                Container(
                  margin: const EdgeInsets.only(left: AppSpacing.sm),
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: event.typeColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.rounded),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    child: const Text(
                      'Tickets',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
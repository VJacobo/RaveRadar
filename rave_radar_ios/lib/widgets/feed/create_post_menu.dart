import 'package:flutter/material.dart';
import '../../models/post_model.dart';
import '../../utils/constants.dart';

class CreatePostMenu extends StatelessWidget {
  final Animation<double> animation;
  final Function(PostType) onPostTypeSelected;

  const CreatePostMenu({
    super.key,
    required this.animation,
    required this.onPostTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        _buildMenuItem(
          index: 5,
          icon: Icons.location_on,
          label: 'Location',
          color: Colors.orange,
          onTap: () => onPostTypeSelected(PostType.location),
        ),
        _buildMenuItem(
          index: 4,
          icon: Icons.event,
          label: 'Event',
          color: Colors.teal,
          onTap: () => onPostTypeSelected(PostType.event),
        ),
        _buildMenuItem(
          index: 3,
          icon: Icons.music_note,
          label: 'Track',
          color: Colors.purple,
          onTap: () => onPostTypeSelected(PostType.track),
        ),
        _buildMenuItem(
          index: 2,
          icon: Icons.photo_camera,
          label: 'Photo',
          color: Colors.blue,
          onTap: () => onPostTypeSelected(PostType.photo),
        ),
        _buildMenuItem(
          index: 1,
          icon: Icons.text_fields,
          label: 'Text',
          color: Colors.green,
          onTap: () => onPostTypeSelected(PostType.text),
        ),
        _buildMenuItem(
          index: 0,
          icon: Icons.mood,
          label: 'Mood',
          color: Colors.pink,
          onTap: () => onPostTypeSelected(PostType.mood),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required int index,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final offset = Offset(
          0,
          -(80.0 * (index + 1)) * animation.value,
        );
        return Transform.translate(
          offset: offset,
          child: Opacity(
            opacity: animation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(AppRadius.rounded),
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  FloatingActionButton(
                    mini: true,
                    heroTag: 'fab_$index',
                    backgroundColor: color,
                    onPressed: onTap,
                    child: Icon(icon, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
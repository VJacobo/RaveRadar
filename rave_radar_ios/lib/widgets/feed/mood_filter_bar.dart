import 'package:flutter/material.dart';
import '../../models/post_model.dart';
import '../../utils/constants.dart';

class MoodFilterBar extends StatelessWidget {
  final MoodType? selectedMood;
  final Function(MoodType?) onMoodSelected;

  const MoodFilterBar({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip(
            label: 'All Vibes',
            isSelected: selectedMood == null,
            onTap: () => onMoodSelected(null),
          ),
          ...MoodType.values.map((mood) => _buildFilterChip(
            label: mood.label,
            isSelected: selectedMood == mood,
            color: mood.color,
            onTap: () => onMoodSelected(mood),
          )),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    Color? color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (color?.withAlpha(51) ?? AppColors.backgroundTertiary)
              : AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(AppRadius.rounded),
          border: Border.all(
            color: isSelected
                ? (color?.withAlpha(128) ?? AppColors.textSecondary)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? (color ?? AppColors.textPrimary)
                : AppColors.textSecondary,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
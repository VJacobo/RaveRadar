import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class GenreSelector extends StatelessWidget {
  final List<String> selectedGenres;
  final Function(String) onGenreToggled;
  final Color primaryColor;
  final int maxSelection;

  const GenreSelector({
    super.key,
    required this.selectedGenres,
    required this.onGenreToggled,
    required this.primaryColor,
    this.maxSelection = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.genresLabel,
          style: AppTextStyles.subtitle2,
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: AppGenres.all.map((genre) {
            final isSelected = selectedGenres.contains(genre);
            return FilterChip(
              label: Text(genre),
              selected: isSelected,
              onSelected: (selected) {
                if (!selected || selectedGenres.length < maxSelection) {
                  onGenreToggled(genre);
                }
              },
              backgroundColor: AppColors.backgroundSecondary,
              selectedColor: primaryColor.withAlpha(77), // 0.3 opacity
              labelStyle: TextStyle(
                color: isSelected ? primaryColor : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              checkmarkColor: primaryColor,
              side: BorderSide(
                color: isSelected ? primaryColor : AppColors.backgroundTertiary,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
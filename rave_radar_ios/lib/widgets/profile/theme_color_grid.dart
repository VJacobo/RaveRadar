import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class ThemeColorGrid extends StatelessWidget {
  final List<Color> availableColors;
  final Color selectedColor;
  final Function(Color) onColorSelected;

  const ThemeColorGrid({
    super.key,
    required this.availableColors,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.themeColorLabel,
          style: AppTextStyles.subtitle2,
        ),
        const SizedBox(height: AppSpacing.lg),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 1,
          ),
          itemCount: availableColors.length,
          itemBuilder: (context, index) {
            final color = availableColors[index];
            final isSelected = selectedColor == color;
            return GestureDetector(
              onTap: () => onColorSelected(color),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: isSelected ? Colors.white : AppColors.backgroundTertiary,
                    width: isSelected ? 3 : 1,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: color.withAlpha(128), // 0.5 opacity
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ] : [],
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 28,
                      )
                    : null,
              ),
            );
          },
        ),
      ],
    );
  }
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/constants.dart';

class ProfileImagePicker extends StatelessWidget {
  final File? selectedImage;
  final Color primaryColor;
  final VoidCallback onTap;

  const ProfileImagePicker({
    super.key,
    required this.selectedImage,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Stack(
            children: [
              GestureDetector(
                onTap: onTap,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.backgroundSecondary,
                    border: Border.all(
                      color: primaryColor,
                      width: 3,
                    ),
                  ),
                  child: selectedImage != null
                      ? ClipOval(
                          child: Image.file(
                            selectedImage!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          Icons.camera_alt,
                          color: primaryColor,
                          size: 40,
                        ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          selectedImage == null 
            ? AppStrings.addPhotoText 
            : AppStrings.changePhotoText,
          style: AppTextStyles.caption,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class ImagePickerBottomSheet extends StatelessWidget {
  final Color primaryColor;
  final Function(ImageSource) onImageSourceSelected;

  const ImagePickerBottomSheet({
    super.key,
    required this.primaryColor,
    required this.onImageSourceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.backgroundTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              AppStrings.chooseProfilePicture,
              style: AppTextStyles.headline3,
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ImageOption(
                  icon: Icons.camera_alt,
                  label: AppStrings.camera,
                  color: primaryColor,
                  onTap: () {
                    Navigator.pop(context);
                    onImageSourceSelected(ImageSource.camera);
                  },
                ),
                _ImageOption(
                  icon: Icons.photo_library,
                  label: AppStrings.gallery,
                  color: primaryColor,
                  onTap: () {
                    Navigator.pop(context);
                    onImageSourceSelected(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _ImageOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ImageOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withAlpha(51), // 0.2 opacity
              borderRadius: BorderRadius.circular(AppRadius.xxl),
            ),
            child: Icon(
              icon,
              color: color,
              size: 40,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: AppTextStyles.subtitle2,
          ),
        ],
      ),
    );
  }
}
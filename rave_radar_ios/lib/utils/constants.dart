import 'package:flutter/material.dart';

class AppColors {
  // Primary colors for ranks
  static const Color raveInitiate = Color(0xFF00E5FF);
  static const Color raveRegular = Color(0xFF9C27B0);
  static const Color raveVeteran = Color(0xFFE91E63);
  
  // Secondary colors for ranks
  static const Color raveInitiateSecondary = Color(0xFF00ACC1);
  static const Color raveRegularSecondary = Color(0xFF7B1FA2);
  static const Color raveVeteranSecondary = Color(0xFFC2185B);
  
  // Background colors
  static const Color backgroundPrimary = Colors.black;
  static final Color backgroundSecondary = Colors.grey[900]!;
  static final Color backgroundTertiary = Colors.grey[800]!;
  
  // Text colors
  static const Color textPrimary = Colors.white;
  static final Color textSecondary = Colors.grey[400]!;
  static final Color textTertiary = Colors.grey[600]!;
  
  // Status colors
  static final Color successColor = Colors.green[400]!;
  static const Color errorColor = Colors.red;
  static const Color warningColor = Colors.amber;
}

class AppTextStyles {
  static const TextStyle headline1 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle headline2 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle headline3 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle subtitle1 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle subtitle2 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  
  static TextStyle body1 = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 16,
  );
  
  static TextStyle body2 = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 14,
  );
  
  static TextStyle caption = TextStyle(
    color: AppColors.textTertiary,
    fontSize: 12,
  );
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 48.0;
  static const double massive = 60.0;
}

class AppRadius {
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double xxl = 20.0;
  static const double rounded = 100.0;
}

class AppDurations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration verySlow = Duration(milliseconds: 800);
}

class AppStrings {
  // Onboarding
  static const String welcomeTitle = 'Connect with the rave community';
  static const String djButton = 'I\'m a DJ';
  static const String raverButton = 'I\'m a Raver';
  static const String rankSelectionTitle = 'How long have you been\nin the scene?';
  
  // Profile customization
  static const String raverTagLabel = 'Display Name';
  static const String raverTagHint = 'What should we call you?';
  static const String usernameLabel = 'Username';
  static const String usernameHint = 'Create your unique handle';
  static const String genresLabel = 'What music do you vibe with?';
  static const String themeColorLabel = 'Pick your vibe';
  static const String continueButton = 'Join the Community';
  static const String addPhotoText = 'Tap to add photo';
  static const String changePhotoText = 'Tap to change photo';
  static const String chooseProfilePicture = 'Choose Profile Picture';
  static const String camera = 'Camera';
  static const String gallery = 'Gallery';
  
  // Dashboard
  static const String discover = 'Feed';
  static const String progress = 'Events';
  static const String community = 'Connect';
  static const String profile = 'Profile';
  
  // Error messages
  static const String errorPickingImage = 'Error picking image';
  static const String errorLoadingData = 'Error loading data';
}

class AppGenres {
  static const List<String> all = [
    'House',
    'Techno', 
    'Trance',
    'Drum & Bass',
    'Dubstep',
    'Hardstyle',
    'Progressive',
    'Electro',
    'Deep House',
    'Tech House',
    'Psytrance',
    'Trap',
  ];
}
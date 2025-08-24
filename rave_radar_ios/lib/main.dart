import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/rank_model.dart';
import 'screens/onboarding/profile_customization_screen_refactored.dart';
import 'screens/dashboard/enhanced_social_feed.dart';
import 'utils/constants.dart';
import 'widgets/common/rave_button.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://ufkyyjyxodahuvjhmmat.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVma3l5anl4b2RhaHV2amhtbWF0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3NDg5NjIsImV4cCI6MjA3MTMyNDk2Mn0.zBsIPgDXg5NtRBi2wMVP0lBAqbqbIthmpjEa2MEeYY0',
  );
  
  runApp(const RaveRadarApp());
}

class RaveRadarApp extends StatelessWidget {
  const RaveRadarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RaveRadar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _skipToMainApp(BuildContext context) {
    // Create a default user profile for skipping onboarding
    final defaultProfile = UserProfile(
      id: 'guest_user',
      djName: 'Guest User',
      username: '@guest',
      avatarUrl: null,
      currentRank: RankType.raveInitiate,
      totalPoints: 0,
      preferredGenres: ['House', 'Techno'],
      profileTheme: {
        'primaryColor': AppColors.raveInitiate.value,
        'secondaryColor': AppColors.raveInitiateSecondary.value,
      },
      unlockedBadges: [],
      joinedDate: DateTime.now(),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedSocialFeed(userProfile: defaultProfile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppStrings.welcomeTitle,
                  style: AppTextStyles.headline1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.massive),
                RaveButton(
                  text: AppStrings.djButton,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DJScreen()),
                    );
                  },
                  backgroundColor: Colors.deepPurple,
                ),
                const SizedBox(height: AppSpacing.xl),
                RaveButton(
                  text: AppStrings.raverButton,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RaverRankScreen()),
                    );
                  },
                  backgroundColor: Colors.pink,
                ),
                const SizedBox(height: AppSpacing.massive),
                TextButton(
                  onPressed: () => _skipToMainApp(context),
                  child: Text(
                    'Skip for now',
                    style: AppTextStyles.body1.copyWith(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RaverRankScreen extends StatelessWidget {
  const RaverRankScreen({super.key});

  void _skipToMainApp(BuildContext context) {
    // Create a default user profile for skipping onboarding
    final defaultProfile = UserProfile(
      id: 'guest_user',
      djName: 'Guest User',
      username: '@guest',
      avatarUrl: null,
      currentRank: RankType.raveInitiate,
      totalPoints: 0,
      preferredGenres: ['House', 'Techno'],
      profileTheme: {
        'primaryColor': AppColors.raveInitiate.value,
        'secondaryColor': AppColors.raveInitiateSecondary.value,
      },
      unlockedBadges: [],
      joinedDate: DateTime.now(),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedSocialFeed(userProfile: defaultProfile),
      ),
      (route) => false,
    );
  }

  void _navigateToProfile(BuildContext context, RankType rankType) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
          ProfileCustomizationScreen(selectedRank: rankType),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: AppDurations.normal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppStrings.rankSelectionTitle,
                  style: AppTextStyles.headline1.copyWith(fontSize: 26),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.massive),
                RaveButton(
                  text: 'Just getting started',
                  onPressed: () => _navigateToProfile(context, RankType.raveInitiate),
                  backgroundColor: AppColors.raveInitiate,
                ),
                const SizedBox(height: AppSpacing.xl),
                RaveButton(
                  text: 'Been here a while',
                  onPressed: () => _navigateToProfile(context, RankType.raveRegular),
                  backgroundColor: AppColors.raveRegular,
                ),
                const SizedBox(height: AppSpacing.xl),
                RaveButton(
                  text: 'Part of the culture',
                  onPressed: () => _navigateToProfile(context, RankType.raveVeteran),
                  backgroundColor: AppColors.raveVeteran,
                ),
                const SizedBox(height: AppSpacing.massive),
                TextButton(
                  onPressed: () => _skipToMainApp(context),
                  child: Text(
                    'Skip for now',
                    style: AppTextStyles.body1.copyWith(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DJScreen extends StatelessWidget {
  const DJScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'DJ Mode',
                style: AppTextStyles.headline1.copyWith(fontSize: 32),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Coming Soon',
                style: AppTextStyles.body1.copyWith(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
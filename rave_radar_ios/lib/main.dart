import 'package:flutter/material.dart';
import 'models/rank_model.dart';
import 'screens/onboarding/profile_customization_screen_refactored.dart';
import 'utils/constants.dart';
import 'widgets/common/rave_button.dart';

void main() {
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
                  text: 'Rave Initiate',
                  onPressed: () => _navigateToProfile(context, RankType.raveInitiate),
                  backgroundColor: AppColors.raveInitiate,
                ),
                const SizedBox(height: AppSpacing.xl),
                RaveButton(
                  text: 'Rave Regular',
                  onPressed: () => _navigateToProfile(context, RankType.raveRegular),
                  backgroundColor: AppColors.raveRegular,
                ),
                const SizedBox(height: AppSpacing.xl),
                RaveButton(
                  text: 'Rave Veteran',
                  onPressed: () => _navigateToProfile(context, RankType.raveVeteran),
                  backgroundColor: AppColors.raveVeteran,
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
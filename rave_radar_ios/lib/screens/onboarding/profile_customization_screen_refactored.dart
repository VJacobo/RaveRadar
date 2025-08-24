import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/rank_model.dart';
import '../../utils/constants.dart';
import '../../widgets/common/rave_button.dart';
import '../../widgets/common/rave_text_field.dart';
import '../../widgets/profile/profile_image_picker.dart';
import '../../widgets/profile/genre_selector.dart';
import '../../widgets/profile/theme_color_grid.dart';
import '../dashboard/social_feed_screen.dart';

class ProfileCustomizationScreen extends StatefulWidget {
  final RankType selectedRank;
  
  const ProfileCustomizationScreen({
    super.key, 
    required this.selectedRank,
  });

  @override
  State<ProfileCustomizationScreen> createState() => _ProfileCustomizationScreenState();
}

class _ProfileCustomizationScreenState extends State<ProfileCustomizationScreen> {
  final TextEditingController _raverTagController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  File? _selectedImage;
  final List<String> _selectedGenres = [];
  Color _selectedThemeColor = Colors.purple;
  bool _isLoading = false;
  
  late final RankModel _rank;
  late final Map<RankType, List<Color>> _rankThemes;

  @override
  void initState() {
    super.initState();
    _rank = RankModel.getRankByType(widget.selectedRank);
    _initializeThemes();
    _selectedThemeColor = _rankThemes[widget.selectedRank]?.first ?? Colors.purple;
  }

  @override
  void dispose() {
    _raverTagController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _initializeThemes() {
    _rankThemes = {
      RankType.raveInitiate: [
        Colors.cyan,
        Colors.blue,
        Colors.teal,
        Colors.lightBlue,
        Colors.indigo,
        AppColors.raveInitiate,
        AppColors.raveInitiateSecondary,
        const Color(0xFF0097A7),
        Colors.blueGrey,
        Colors.lightBlueAccent,
      ],
      RankType.raveRegular: [
        Colors.purple,
        Colors.deepPurple,
        Colors.indigo,
        Colors.pink,
        Colors.amber,
        AppColors.raveRegular,
        AppColors.raveRegularSecondary,
        Colors.purpleAccent,
        Colors.deepPurpleAccent,
        Colors.pinkAccent,
        Colors.orange,
        Colors.lime,
        Colors.teal,
        Colors.cyan,
        Colors.blue,
      ],
      RankType.raveVeteran: [
        Colors.pink,
        Colors.red,
        Colors.orange,
        Colors.deepOrange,
        Colors.yellow,
        Colors.green,
        Colors.black,
        AppColors.raveVeteran,
        AppColors.raveVeteranSecondary,
        Colors.redAccent,
        Colors.orangeAccent,
        Colors.amber,
        Colors.lime,
        Colors.lightGreen,
        Colors.teal,
        Colors.cyan,
        Colors.blue,
        Colors.indigo,
        Colors.purple,
        Colors.deepPurple,
      ],
    };
  }

  bool get _isFormValid {
    return _raverTagController.text.isNotEmpty && 
           _usernameController.text.isNotEmpty && 
           _selectedGenres.isNotEmpty;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar(AppStrings.errorPickingImage);
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (context) => ImagePickerBottomSheet(
        primaryColor: _rank.primaryColor,
        onImageSourceSelected: _pickImage,
      ),
    );
  }

  void _toggleGenre(String genre) {
    setState(() {
      if (_selectedGenres.contains(genre)) {
        _selectedGenres.remove(genre);
      } else if (_selectedGenres.length < 3) {
        _selectedGenres.add(genre);
      }
    });
  }

  void _navigateToDashboard() {
    if (!_isFormValid) return;
    
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
          SocialFeedScreen(
            userProfile: UserProfile(
              id: 'user_${DateTime.now().millisecondsSinceEpoch}',
              djName: _raverTagController.text,
              username: '@${_usernameController.text}',
              avatarUrl: _selectedImage?.path,
              currentRank: widget.selectedRank,
              totalPoints: 0,
              preferredGenres: _selectedGenres,
              profileTheme: {'color': _selectedThemeColor.value.toInt()},
              unlockedBadges: [],
              joinedDate: DateTime.now(),
            ),
          ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutQuart;
          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );
          var fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
            ),
          );
          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: fadeAnimation,
              child: child,
            ),
          );
        },
        transitionDuration: AppDurations.slow,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableThemes = _rankThemes[widget.selectedRank] ?? [Colors.purple];
    
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppSpacing.xxxl),
              
              // Profile Picture
              ProfileImagePicker(
                selectedImage: _selectedImage,
                primaryColor: _rank.primaryColor,
                onTap: _showImagePicker,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              
              // Raver Tag
              RaveTextField(
                controller: _raverTagController,
                labelText: AppStrings.raverTagLabel,
                hintText: AppStrings.raverTagHint,
                borderColor: _rank.primaryColor,
              ),
              const SizedBox(height: AppSpacing.xl),
              
              // Username
              RaveTextField(
                controller: _usernameController,
                labelText: AppStrings.usernameLabel,
                hintText: AppStrings.usernameHint,
                prefixText: '@',
                borderColor: _rank.primaryColor,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
                ],
              ),
              const SizedBox(height: AppSpacing.xxxl),
              
              // Genre Selection
              GenreSelector(
                selectedGenres: _selectedGenres,
                onGenreToggled: _toggleGenre,
                primaryColor: _rank.primaryColor,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              
              // Theme Color Grid
              ThemeColorGrid(
                availableColors: availableThemes,
                selectedColor: _selectedThemeColor,
                onColorSelected: (color) {
                  setState(() {
                    _selectedThemeColor = color;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.huge),
              
              // Continue Button
              RaveButton(
                text: AppStrings.continueButton,
                onPressed: _isFormValid ? _navigateToDashboard : null,
                backgroundColor: _rank.primaryColor,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Your Profile',
                style: AppTextStyles.headline2,
              ),
              Text(
                _rank.name,
                style: TextStyle(
                  color: _rank.primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
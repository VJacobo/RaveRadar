import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/rank_model.dart';
import '../dashboard/discovery_dashboard.dart';

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
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final List<String> _selectedGenres = [];
  Color _selectedThemeColor = Colors.purple;
  
  final List<String> _genres = [
    'House', 'Techno', 'Trance', 'Drum & Bass',
    'Dubstep', 'Hardstyle', 'Progressive', 'Electro',
    'Deep House', 'Tech House', 'Psytrance', 'Trap'
  ];
  
  final Map<RankType, List<Color>> _rankThemes = {
    RankType.raveInitiate: [
      Colors.cyan,
      Colors.blue,
      Colors.teal,
      Colors.lightBlue,
      Colors.indigo,
      const Color(0xFF00E5FF),
      const Color(0xFF00ACC1),
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
      const Color(0xFF9C27B0),
      const Color(0xFF7B1FA2),
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
      const Color(0xFFE91E63),
      const Color(0xFFC2185B),
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

  @override
  Widget build(BuildContext context) {
    final rank = RankModel.getRankByType(widget.selectedRank);
    final availableThemes = _rankThemes[widget.selectedRank] ?? [Colors.purple];
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Customize Your Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          rank.name,
                          style: TextStyle(
                            color: rank.primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Profile Picture Selection
              Center(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: _showImagePicker,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[900],
                          border: Border.all(
                            color: rank.primaryColor,
                            width: 3,
                          ),
                        ),
                        child: _selectedImage != null
                            ? ClipOval(
                                child: Image.file(
                                  _selectedImage!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(
                                Icons.camera_alt,
                                color: rank.primaryColor,
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
                          color: rank.primaryColor,
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
              const SizedBox(height: 8),
              Text(
                'Tap to ${_selectedImage == null ? 'add' : 'change'} photo',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Raver Tag
              _buildSectionTitle('Raver Tag'),
              const SizedBox(height: 12),
              TextField(
                controller: _raverTagController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter your raver tag',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: rank.primaryColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Username
              _buildSectionTitle('Username'),
              const SizedBox(height: 12),
              TextField(
                controller: _usernameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Choose your @username',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixText: '@',
                  prefixStyle: TextStyle(
                    color: rank.primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: rank.primaryColor, width: 2),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
                ],
              ),
              const SizedBox(height: 32),
              
              // Genre Selection
              _buildSectionTitle('Preferred Genres (Select up to 3)'),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _genres.map((genre) {
                  final isSelected = _selectedGenres.contains(genre);
                  return FilterChip(
                    label: Text(genre),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected && _selectedGenres.length < 3) {
                          _selectedGenres.add(genre);
                        } else if (!selected) {
                          _selectedGenres.remove(genre);
                        }
                      });
                    },
                    backgroundColor: Colors.grey[900],
                    selectedColor: rank.primaryColor.withOpacity(0.3),
                    labelStyle: TextStyle(
                      color: isSelected ? rank.primaryColor : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    checkmarkColor: rank.primaryColor,
                    side: BorderSide(
                      color: isSelected ? rank.primaryColor : Colors.grey[700]!,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              
              // Theme Color Selection
              _buildSectionTitle('Profile Theme Color'),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: availableThemes.length,
                itemBuilder: (context, index) {
                  final color = availableThemes[index];
                  final isSelected = _selectedThemeColor == color;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedThemeColor = color;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.grey[800]!,
                          width: isSelected ? 3 : 1,
                        ),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: color.withOpacity(0.5),
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
              const SizedBox(height: 48),
              
              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _raverTagController.text.isNotEmpty && 
                             _usernameController.text.isNotEmpty && 
                             _selectedGenres.isNotEmpty
                      ? () {
                          // Navigate to discovery dashboard with animation
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => 
                                DiscoveryDashboard(
                                  userProfile: UserProfile(
                                    id: 'user_${DateTime.now().millisecondsSinceEpoch}',
                                    djName: _raverTagController.text,
                                    username: '@${_usernameController.text}',
                                    avatarUrl: _selectedImage?.path,
                                    currentRank: widget.selectedRank,
                                    totalPoints: 0,
                                    preferredGenres: _selectedGenres,
                                    profileTheme: {'color': _selectedThemeColor.value},
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
                              transitionDuration: const Duration(milliseconds: 600),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: rank.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey[800],
                  ),
                  child: const Text(
                    'Continue to Dashboard',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }
  
  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        final rank = RankModel.getRankByType(widget.selectedRank);
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'Choose Profile Picture',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageOption(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      color: rank.primaryColor,
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                    _buildImageOption(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      color: rank.primaryColor,
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: color,
              size: 40,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
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
      print('Error picking image: $e');
    }
  }
}
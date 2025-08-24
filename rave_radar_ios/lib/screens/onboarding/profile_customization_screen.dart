import 'package:flutter/material.dart';
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
  final TextEditingController _djNameController = TextEditingController();
  String _selectedAvatar = 'avatar1';
  final List<String> _selectedGenres = [];
  Color _selectedThemeColor = Colors.purple;
  
  final List<String> _availableAvatars = [
    'avatar1', 'avatar2', 'avatar3', 'avatar4', 'avatar5', 'avatar6'
  ];
  
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
    ],
    RankType.raveRegular: [
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.pink,
      Colors.amber,
    ],
    RankType.raveVeteran: [
      Colors.pink,
      Colors.red,
      Colors.orange,
      Colors.deepOrange,
      Colors.yellow,
      Colors.green,
      Colors.black,
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
              
              // Avatar Selection
              _buildSectionTitle('Choose Your Avatar'),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _availableAvatars.length,
                  itemBuilder: (context, index) {
                    final avatar = _availableAvatars[index];
                    final isSelected = _selectedAvatar == avatar;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAvatar = avatar;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? rank.primaryColor : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey[800],
                          child: Text(
                            avatar[avatar.length - 1],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              
              // DJ Name
              _buildSectionTitle('Your DJ Name'),
              const SizedBox(height: 12),
              TextField(
                controller: _djNameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter your DJ name',
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
              Row(
                children: availableThemes.map((color) {
                  final isSelected = _selectedThemeColor == color;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedThemeColor = color;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 48),
              
              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _djNameController.text.isNotEmpty && _selectedGenres.isNotEmpty
                      ? () {
                          // Navigate to discovery dashboard with animation
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => 
                                DiscoveryDashboard(
                                  userProfile: UserProfile(
                                    id: 'user_${DateTime.now().millisecondsSinceEpoch}',
                                    djName: _djNameController.text,
                                    avatarUrl: _selectedAvatar,
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
}
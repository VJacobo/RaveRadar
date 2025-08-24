import 'package:flutter/material.dart';
import '../../models/rank_model.dart';

class CommunityScreen extends StatefulWidget {
  final UserProfile userProfile;
  
  const CommunityScreen({super.key, required this.userProfile});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final rank = widget.userProfile.rank;
    
    return Column(
      children: [
        Container(
          color: Colors.black,
          child: TabBar(
            controller: _tabController,
            labelColor: rank.primaryColor,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: rank.primaryColor,
            tabs: const [
              Tab(text: 'Your Rank'),
              Tab(text: 'All Ranks'),
              Tab(text: 'Following'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildRankCommunity(),
              _buildAllRanksCommunity(),
              _buildFollowingTab(),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildRankCommunity() {
    final rank = widget.userProfile.rank;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rank Room Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [rank.primaryColor.withOpacity(0.3), rank.secondaryColor.withOpacity(0.2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: rank.primaryColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.shield,
                        color: rank.primaryColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${rank.name} Room',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Exclusive community for ${rank.name}s',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildRoomStat('Members', '234', Icons.people),
                    const SizedBox(width: 24),
                    _buildRoomStat('Active', '89', Icons.circle),
                    const SizedBox(width: 24),
                    _buildRoomStat('Live Sets', '3', Icons.radio),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Suggested DJs to Follow
          _buildSectionTitle('Suggested DJs', 'Connect with DJs in your rank'),
          const SizedBox(height: 16),
          ...List.generate(5, (index) => _buildDJListItem(
            'DJ ${rank.name} ${index + 1}',
            rank.name,
            '${50 + index * 10} followers',
            rank.primaryColor,
            false,
          )),
          
          const SizedBox(height: 24),
          
          // Rank Chat Preview
          _buildSectionTitle('Rank Chat', 'Join the conversation'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildChatMessage('BassHead23', 'Who\'s ready for tonight\'s set?', '2m ago'),
                _buildChatMessage('DropMaster', 'Just unlocked the new FX pack!', '5m ago'),
                _buildChatMessage('RaveQueen', 'Anyone going to the warehouse party?', '8m ago'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: rank.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Join Chat'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAllRanksCommunity() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('All Rank Rooms', 'Explore different communities'),
          const SizedBox(height: 16),
          ...RankModel.ranks.map((rankModel) {
            final isCurrentRank = rankModel.type == widget.userProfile.currentRank;
            final canAccess = rankModel.level <= widget.userProfile.rank.level;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: canAccess ? () {} : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCurrentRank 
                          ? rankModel.primaryColor 
                          : canAccess 
                            ? rankModel.primaryColor.withOpacity(0.3)
                            : Colors.grey[800]!,
                        width: isCurrentRank ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: canAccess 
                              ? rankModel.primaryColor.withOpacity(0.2)
                              : Colors.grey[800],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            canAccess ? Icons.lock_open : Icons.lock,
                            color: canAccess ? rankModel.primaryColor : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    rankModel.name,
                                    style: TextStyle(
                                      color: canAccess ? Colors.white : Colors.grey[600],
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (isCurrentRank) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: rankModel.primaryColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'YOUR RANK',
                                        style: TextStyle(
                                          color: rankModel.primaryColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                canAccess 
                                  ? 'Access granted • ${200 + rankModel.level * 50} members'
                                  : 'Unlock at ${rankModel.minPoints} points',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (canAccess)
                          Icon(
                            Icons.arrow_forward_ios,
                            color: rankModel.primaryColor,
                            size: 16,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
  
  Widget _buildFollowingTab() {
    final rank = widget.userProfile.rank;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Following Stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFollowStat('Following', '0'),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey[800],
                ),
                _buildFollowStat('Followers', '0'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Recommended to Follow
          _buildSectionTitle('Recommended to Follow', 'Based on your rank'),
          const SizedBox(height: 16),
          ...List.generate(8, (index) {
            final isHigherRank = index < 3;
            final djRank = isHigherRank && widget.userProfile.rank.level < 3
              ? RankModel.ranks[widget.userProfile.rank.level]
              : widget.userProfile.rank;
            
            return _buildDJListItem(
              'DJ ${index + 1}',
              djRank.name,
              '${100 + index * 25} followers',
              djRank.primaryColor,
              isHigherRank,
            );
          }),
        ],
      ),
    );
  }
  
  Widget _buildDJListItem(String name, String rankName, String followers, Color color, bool isHigherRank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: color.withOpacity(0.2),
                child: Text(
                  name[3],
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isHigherRank)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.star,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        rankName,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      followers,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Follow'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRoomStat(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 16),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  Widget _buildChatMessage(String username, String message, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey[800],
            child: Text(
              username[0],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
      ],
    );
  }
  
  Widget _buildFollowStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
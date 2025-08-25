import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class UserTaggingWidget extends StatefulWidget {
  final List<String> taggedUsers;
  final Function(List<String>) onTagsChanged;
  final String? placeholder;

  const UserTaggingWidget({
    super.key,
    required this.taggedUsers,
    required this.onTagsChanged,
    this.placeholder,
  });

  @override
  State<UserTaggingWidget> createState() => _UserTaggingWidgetState();
}

class _UserTaggingWidgetState extends State<UserTaggingWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _suggestions = [];
  bool _isShowingSuggestions = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    if (text.isNotEmpty && text.startsWith('@')) {
      _searchUsers(text.substring(1));
    } else {
      setState(() {
        _isShowingSuggestions = false;
        _suggestions.clear();
      });
    }
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      setState(() {
        _isShowingSuggestions = false;
      });
    }
  }

  void _searchUsers(String query) {
    final mockUsers = [
      'djsarah',
      'mikebeats',
      'technoboy',
      'housegirl',
      'festivalfan',
      'undergroundlover',
      'basshead',
      'melodicvibes',
    ];

    setState(() {
      _suggestions = mockUsers
          .where((user) => 
              user.toLowerCase().contains(query.toLowerCase()) &&
              !widget.taggedUsers.contains(user)
          )
          .take(5)
          .toList();
      _isShowingSuggestions = _suggestions.isNotEmpty && query.isNotEmpty;
    });
  }

  void _addUser(String username) {
    final updatedTags = List<String>.from(widget.taggedUsers);
    if (!updatedTags.contains(username)) {
      updatedTags.add(username);
      widget.onTagsChanged(updatedTags);
    }
    _controller.clear();
    setState(() {
      _isShowingSuggestions = false;
    });
  }

  void _removeUser(String username) {
    final updatedTags = List<String>.from(widget.taggedUsers);
    updatedTags.remove(username);
    widget.onTagsChanged(updatedTags);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: widget.placeholder ?? 'Type @ to tag users...',
            prefixIcon: const Icon(Icons.alternate_email),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.rounded),
            ),
            filled: true,
            fillColor: AppColors.backgroundSecondary,
          ),
          style: const TextStyle(color: AppColors.textPrimary),
          onSubmitted: (text) {
            if (text.startsWith('@') && text.length > 1) {
              final username = text.substring(1);
              _addUser(username);
            }
          },
        ),
        
        if (_isShowingSuggestions) ...[
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(AppRadius.rounded),
              border: Border.all(color: Colors.grey.shade300),
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final username = _suggestions[index];
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.purple,
                    child: Text(
                      username[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  title: Text(
                    '@$username',
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  onTap: () => _addUser(username),
                );
              },
            ),
          ),
        ],
        
        if (widget.taggedUsers.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Tagged Users:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: widget.taggedUsers.map((username) => Chip(
              label: Text(
                '@$username',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.purple,
              deleteIcon: const Icon(
                Icons.close,
                size: 18,
                color: Colors.white70,
              ),
              onDeleted: () => _removeUser(username),
            )).toList(),
          ),
        ],
      ],
    );
  }
}
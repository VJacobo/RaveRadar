class Validators {
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;
  static const int minDisplayNameLength = 2;
  static const int maxDisplayNameLength = 30;
  static const int maxGenresSelection = 3;

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    
    if (value.length < minUsernameLength) {
      return 'Username must be at least $minUsernameLength characters';
    }
    
    if (value.length > maxUsernameLength) {
      return 'Username must be less than $maxUsernameLength characters';
    }
    
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    
    return null;
  }

  static String? validateDisplayName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Display name is required';
    }
    
    if (value.length < minDisplayNameLength) {
      return 'Display name must be at least $minDisplayNameLength characters';
    }
    
    if (value.length > maxDisplayNameLength) {
      return 'Display name must be less than $maxDisplayNameLength characters';
    }
    
    return null;
  }

  static String? validateGenreSelection(List<String> genres) {
    if (genres.isEmpty) {
      return 'Please select at least one genre';
    }
    
    if (genres.length > maxGenresSelection) {
      return 'You can select up to $maxGenresSelection genres';
    }
    
    return null;
  }

  static String? validatePostContent(String? content, int maxLength) {
    if (content == null || content.isEmpty) {
      return 'Content cannot be empty';
    }
    
    if (content.length > maxLength) {
      return 'Content must be less than $maxLength characters';
    }
    
    return null;
  }

  static String? validateEventName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Event name is required';
    }
    
    if (value.length > 100) {
      return 'Event name is too long';
    }
    
    return null;
  }

  static String? validateEventLocation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Event location is required';
    }
    
    if (value.length > 200) {
      return 'Location description is too long';
    }
    
    return null;
  }
}
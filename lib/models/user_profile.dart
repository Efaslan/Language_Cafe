class UserProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String bio;
  final List<String> learningLanguages;
  final bool isPublic;
  final String? avatarUrl;

  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.bio,
    required this.learningLanguages,
    required this.isPublic,
    this.avatarUrl,
  });

  // Convert JSON (from Supabase) to Model
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      bio: json['bio'] ?? '',
      // Safely convert dynamic list to String list
      learningLanguages: json['learning_languages'] != null
          ? List<String>.from(json['learning_languages'])
          : [],
      isPublic: json['is_public'] ?? true,
      avatarUrl: json['avatar_url'], // Nullable field mapping
    );
  }
}
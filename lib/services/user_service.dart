import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  Future<UserResponse> refreshUser() async {
    return await _supabase.auth.getUser();
  }

  String? get cachedFirstName {
    final metadata = _supabase.auth.currentUser?.userMetadata;
    return metadata?['first_name'];
  }

  Future<UserProfile> fetchUserProfile(String userId) async {
    final data = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    return UserProfile.fromJson(data);
  }

  Future<void> updateProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String bio,
    required List<String> languages,
    required bool isPublic,
  }) async {
    // 1. Veritabanını Güncelle (Kalıcı Depo)
    await _supabase.from('profiles').update({
      'first_name': firstName,
      'last_name': lastName,
      'bio': bio,
      'learning_languages': languages,
      'is_public': isPublic,
    }).eq('id', userId);

    // 2. Metadata'yı (Cache) Güncelle (Hızlı Erişim İçin)
    // Böylece Home ekranı veritabanına sormadan güncel ismi bilir.
    await _supabase.auth.updateUser(
        UserAttributes(
            data: {
              'first_name': firstName,
              'last_name': lastName,
              // İhtiyaç olursa diğerlerini de ekleyebilirsin
            }
        )
    );
  }

  Future<UserResponse> updateAccount({String? email, String? password}) async {
    final attributes = UserAttributes(email: email, password: password);
    return await _supabase.auth.updateUser(
      attributes,
      emailRedirectTo: 'https://language-cafe.netlify.app',
    );
  }
}
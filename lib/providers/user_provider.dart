import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

// 1. PROVIDER TANIMI (Nehri oluşturuyoruz)
// "autoDispose" sayesinde kullanıcı çıkış yaparsa veri otomatik temizlenir.
// "FutureProvider" kullandık çünkü veritabanından veri çekmek zaman alan (Future) bir iştir.
final userProfileProvider = FutureProvider.autoDispose<UserProfile>((ref) async {

  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) {
    throw Exception("Kullanıcı oturumu yok");
  }

  // Veritabanından veriyi çek
  final data = await supabase
      .from('profiles')
      .select()
      .eq('id', user.id)
      .single();

  // Modele çevir ve döndür (Cache burada oluşur)
  return UserProfile.fromJson(data);
});
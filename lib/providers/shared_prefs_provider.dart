import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Bu provider'ın içi başlangıçta boştur (UnimplementedError).
// Uygulama açılırken (main.dart) içini dolduracağız.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});
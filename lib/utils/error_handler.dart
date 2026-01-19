import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorHandler {
  static String getMessage(Object error) {
    if (error is AuthException) {
      final msg = error.message.toLowerCase();

      if (msg.contains("invalid login credentials")) {
        return "Giriş bilgileri hatalı. Lütfen kontrol edin.";
      }
      if (msg.contains("user not found") || msg.contains("not found")) {
        return "Bu email ile kayıtlı kullanıcı bulunamadı.";
      }
      if (msg.contains("user with this email")){
        return "Bu e-posta adresi zaten kullanımda. Lütfen başka bir adres deneyin.";
      }
      if (msg.contains("password should be")) {
        return "Şifre yeterince güvenli değil.";
      }
      if (msg.contains("email link is invalid")) {
        return "Linkin süresi dolmuş veya geçersiz.";
      }

      // unknown auth error
      return "Giriş hatası: ${error.message}";
    }

    if (error is PostgrestException) {
      return "Veritabanı hatası: ${error.message}";
    }

    // unknown error
    return "Beklenmedik bir hata oluştu: $error";
  }
}
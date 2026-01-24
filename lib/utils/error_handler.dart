import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/context_extensions.dart';

class ErrorHandler {
  // Static metoda BuildContext ekledik
  static String getMessage(Object error, BuildContext context) {
    // Çeviri dosyasına erişim
    final l10n = context.l10n;

    if (error is AuthException) {
      final msg = error.message.toLowerCase();

      if (msg.contains("invalid login credentials")) {
        return l10n.errorInvalidLogin;
      }
      if (msg.contains("user not found") || msg.contains("not found")) {
        return l10n.errorUserNotFound;
      }
      if (msg.contains("user with this email") || msg.contains("already registered")){
        return l10n.errorUserExists;
      }
      if (msg.contains("password should be")) {
        return l10n.errorWeakPassword;
      }
      if (msg.contains("email link is invalid")) {
        return l10n.errorInvalidLink;
      }

      // unknown auth error
      return l10n.errorAuthDefault(error.message);
    }

    if (error is PostgrestException) {
      return l10n.errorDbDefault(error.message);
    }

    // unknown error
    return l10n.errorUnknown(error.toString());
  }
}
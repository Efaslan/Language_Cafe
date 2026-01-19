class Validators {

  static String? validateEmail(String? value, {String? message}) {
    if (value == null || value.trim().isEmpty) {
      return message ?? 'Email alanı zorunludur.'; // default if no custom message given
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(value)) {
      return message ?? 'Geçerli bir email adresi giriniz.';
    }
    return null;
  }

  static String? validatePassword(String? value, {String? message}) {
    if (value == null || value.isEmpty) {
      return message ?? 'Şifre alanı zorunludur.';
    }
    if (value.length < 6) {
      return message ?? 'Şifre en az 6 karakter olmalıdır.';
    }
    return null;
  }

  static String? validateName(String? value, {String? message}) {
    if (value == null || value.trim().isEmpty) {
      return message ?? 'Bu alan zorunludur.';
    }
    return null;
  }
}
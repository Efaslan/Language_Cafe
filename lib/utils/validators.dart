import 'package:flutter/material.dart';
import '../utils/context_extensions.dart';

class Validators {

  static String? validateEmail(String? value, BuildContext context, {String? message}) {
    final l10n = context.l10n;

    if (value == null || value.trim().isEmpty) {
      return message ?? l10n.valEmailRequired;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(value)) {
      return message ?? l10n.valEmailInvalid;
    }
    return null;
  }

  static String? validatePassword(String? value, BuildContext context, {String? message}) {
    final l10n = context.l10n;

    if (value == null || value.isEmpty) {
      return message ?? l10n.valPassRequired;
    }
    if (value.length < 6) {
      return message ?? l10n.valPassTooShort;
    }
    return null;
  }

  static String? validateName(String? value, BuildContext context, {String? message}) {
    final l10n = context.l10n;

    if (value == null || value.trim().isEmpty) {
      return message ?? l10n.valRequired;
    }
    return null;
  }
}
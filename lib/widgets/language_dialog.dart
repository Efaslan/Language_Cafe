import 'package:flutter/material.dart';
import 'package:language_cafe/utils/context_extensions.dart';
import '../constants/app_colors.dart';

class AddLanguageDialog extends StatefulWidget {
  const AddLanguageDialog({super.key});

  @override
  State<AddLanguageDialog> createState() => _AddLanguageDialogState();
}

class _AddLanguageDialogState extends State<AddLanguageDialog> {
  final _languageController = TextEditingController();

  @override
  void dispose() {
    _languageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.addLang, style: TextStyle(color: AppColors.primary)),
      content: TextField(
        controller: _languageController,
        decoration: InputDecoration(
          hintText: context.l10n.egLang,
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary),
          ),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // Geriye null döner
          child: Text(context.l10n.cancelBtn, style: TextStyle(color: AppColors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_languageController.text.isNotEmpty) {
              // Girilen dili geriye döndür
              Navigator.pop(context, _languageController.text.trim());
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
          ),
          child: Text(context.l10n.addBtn),
        ),
      ],
    );
  }
}
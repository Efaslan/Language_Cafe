import 'package:flutter/material.dart';
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
      title: const Text("Dil Ekle", style: TextStyle(color: AppColors.primary)),
      content: TextField(
        controller: _languageController,
        decoration: const InputDecoration(
          hintText: "Örn: İngilizce, Fransızca",
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary),
          ),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // Geriye null döner
          child: const Text("İptal", style: TextStyle(color: Colors.grey)),
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
            foregroundColor: Colors.white,
          ),
          child: const Text("Ekle"),
        ),
      ],
    );
  }
}
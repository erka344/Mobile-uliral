import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/provider/globalProvider.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Global_provider>(
      builder: (context, provider, child) {
        return PopupMenuButton<String>(
          icon: const Icon(Icons.language),
          onSelected: (String languageCode) {
            provider.changeLanguage(languageCode);
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'en',
              child: Text('English'),
            ),
            const PopupMenuItem<String>(
              value: 'mn',
              child: Text('Монгол'),
            ),
          ],
        );
      },
    );
  }
} 
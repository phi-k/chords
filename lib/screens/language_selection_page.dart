import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/settings_provider.dart';

class LanguageSelectionPage extends ConsumerWidget {
  const LanguageSelectionPage({super.key});

  Future<void> _selectLanguage(
      BuildContext context, WidgetRef ref, String langCode) async {
    await ref.read(settingsProvider.notifier).setLocale(langCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_selected_language', true);

    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Choose your language\nChoisissez votre langue",
              textAlign: TextAlign.center,
              style: GoogleFonts.cormorant(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 50),
            _buildLanguageCard(
              context,
              ref,
              flag: "🇬🇧",
              name: "English",
              code: "en",
            ),
            const SizedBox(height: 20),
            _buildLanguageCard(
              context,
              ref,
              flag: "🇫🇷",
              name: "Français",
              code: "fr",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard(BuildContext context, WidgetRef ref,
      {required String flag, required String name, required String code}) {
    return InkWell(
      onTap: () => _selectLanguage(context, ref, code),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 200,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 15),
            Text(
              name,
              style: GoogleFonts.cormorant(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

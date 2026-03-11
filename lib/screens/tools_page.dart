// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import 'tools/export_song_list_page.dart';
import 'tools/export_tabs_page.dart';
import 'tools/tuner_page.dart';
import 'tools/metronome_page.dart';
import 'tools/version_page.dart';
import 'welcome_page.dart';

class ToolsPage extends ConsumerWidget {
  const ToolsPage({super.key});

  Future<void> _editApiKey(BuildContext context, WidgetRef ref, String title,
      String description, String currentValue, Function(String) onSave) async {
    final TextEditingController ctrl =
        TextEditingController(text: currentValue);
    final loc = AppLocalizations.of(context)!;
    bool obscure = true;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.key, color: Colors.red, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Cormorant',
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'Cormorant',
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    controller: ctrl,
                    obscureText: obscure,
                    style: const TextStyle(
                      fontFamily: 'UbuntuMono',
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: loc.settingsPasteApiKey,
                      hintStyle: TextStyle(
                        fontFamily: 'Cormorant',
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                        onPressed: () =>
                            setDialogState(() => obscure = !obscure),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: Text(
                          loc.commonCancel,
                          style: TextStyle(
                            fontFamily: 'Cormorant',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          onSave(ctrl.text);
                          Navigator.pop(ctx);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          loc.commonSave,
                          style: const TextStyle(
                            fontFamily: 'Cormorant',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.toolsTitle,
          style: TextStyle(
            fontFamily: 'Cormorant',
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(loc.toolsUtilities),
              _buildSectionContainer(
                context,
                Column(
                  children: [
                    _buildFeatureRow(
                      context,
                      loc.toolsTuner,
                      loc.toolsTunerDesc,
                      Icons.graphic_eq,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const TunerPage()),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 60),
                    _buildFeatureRow(
                      context,
                      loc.toolsMetronome,
                      loc.toolsMetronomeDesc,
                      Icons.timer_outlined,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MetronomePage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildSectionTitle(loc.toolsExport),
              _buildSectionContainer(
                context,
                Column(
                  children: [
                    _buildFeatureRow(
                      context,
                      loc.toolsExportList,
                      loc.toolsExportListDesc,
                      Icons.list_alt_outlined,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ExportSongListPage()),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 60),
                    _buildFeatureRow(
                      context,
                      loc.toolsExportTabs,
                      loc.toolsExportTabsDesc,
                      Icons.picture_as_pdf_outlined,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ExportTabsPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildSectionTitle(loc.settingsApiKeys),
              _buildSectionContainer(
                context,
                Column(
                  children: [
                    _buildFeatureRow(
                      context,
                      "Genius API",
                      settings.geniusKey.isEmpty
                          ? loc.settingsGeniusDesc
                          : "••••••••••••",
                      Icons.album_outlined,
                      () => _editApiKey(
                          context,
                          ref,
                          "Genius API",
                          loc.settingsGeniusDesc,
                          settings.geniusKey,
                          (val) => ref
                              .read(settingsProvider.notifier)
                              .setGeniusKey(val)),
                    ),
                    const Divider(height: 1, indent: 60),
                    _buildFeatureRow(
                      context,
                      "Google Gemini API",
                      settings.geminiKey.isEmpty
                          ? loc.settingsGeminiDesc
                          : "••••••••••••",
                      Icons.auto_awesome,
                      () => _editApiKey(
                          context,
                          ref,
                          "Google Gemini API",
                          loc.settingsGeminiDesc,
                          settings.geminiKey,
                          (val) => ref
                              .read(settingsProvider.notifier)
                              .setGeminiKey(val)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildSectionTitle(loc.toolsMisc),
              _buildSectionContainer(
                context,
                Column(
                  children: [
                    _buildFeatureRow(
                      context,
                      loc.toolsVersion,
                      loc.toolsVersionDesc,
                      Icons.system_update_outlined,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const VersionPage()),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 60),
                    _buildFeatureRow(
                      context,
                      loc.toolsWelcome,
                      loc.toolsWelcomeDesc,
                      Icons.rocket_launch_outlined,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const WelcomePage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Cormorant',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSectionContainer(BuildContext context, Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: child,
      ),
    );
  }

  Widget _buildFeatureRow(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Cormorant',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Cormorant',
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

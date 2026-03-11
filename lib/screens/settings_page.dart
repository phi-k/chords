// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';

import '../services/version_service.dart';
import '../data/collections/song.dart';
import '../providers/song_provider.dart';
import '../providers/settings_provider.dart';
import '../main.dart';
import 'tools_page.dart';
import 'tools/tuner_page.dart';
import 'tools/metronome_page.dart';
import 'tools/export_song_list_page.dart';
import 'tools/export_tabs_page.dart';
import 'tools/version_page.dart';
import 'welcome_page.dart';
import 'legal_page.dart';
import 'settings/data_sources_page.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  String _appVersion = 'Chargement...';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _itemMatches(List<String> keywords) {
    if (_searchQuery.isEmpty) return true;
    return keywords.any((k) => k.toLowerCase().contains(_searchQuery));
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    final String codename = VersionService.getVersionCodename(info.version);
    if (mounted) {
      setState(() {
        _appVersion = 'Version ${info.version} $codename';
      });
    }
  }

  Future<bool> _showReplaceConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) {
            final loc = AppLocalizations.of(context)!;
            return AlertDialog(
              title: Text(loc.settingsConfirmImport,
                  style: const TextStyle(
                      fontFamily: 'Cormorant', fontWeight: FontWeight.bold)),
              content: Text(
                loc.settingsReplaceLibrary,
                style: const TextStyle(fontFamily: 'Cormorant'),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black54,
                  ),
                  child: Text(loc.commonCancel,
                      style: const TextStyle(fontFamily: 'Cormorant')),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: Text(loc.commonConfirm,
                      style: const TextStyle(fontFamily: 'Cormorant')),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _importJson(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (!context.mounted) return;

    if (result != null && result.files.single.path != null) {
      bool confirmed = await _showReplaceConfirmation(context);
      if (!context.mounted) return;
      if (!confirmed) return;

      try {
        final importFile = File(result.files.single.path!);
        final content = await importFile.readAsString();
        final songsJson = json.decode(content);
        if (songsJson is List) {
          final List<Song> importedSongs = [];
          for (var item in songsJson) {
            if (item is Map<String, dynamic>) {
              importedSongs.add(Song.fromMap(item));
            }
          }

          final isar = ref.read(isarProvider);
          await isar.writeTxn(() async {
            await isar.songs.putAll(importedSongs);
          });

          if (!context.mounted) return;
          ref.invalidate(allSongsProvider);

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.settingsImportSuccess),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ));

          await Future.delayed(const Duration(seconds: 1));
          if (context.mounted) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/home', (route) => false);
          }
        } else {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.settingsInvalidFile),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ));
        }
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              AppLocalizations.of(context)!.settingsImportError(e.toString())),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ));
      }
    }
  }

  Future<void> _exportJson(BuildContext context) async {
    try {
      final songs = await ref.read(databaseServiceProvider).getSavedSongs();
      final List<Map<String, dynamic>> songsJson =
          songs.map((s) => s.toMap()).toList();
      final jsonContent = json.encode(songsJson);
      final Uint8List fileBytes = Uint8List.fromList(utf8.encode(jsonContent));

      final String date = DateFormat('dd-MM-yyyy_HH-mm').format(DateTime.now());
      final String fileName = 'songs_$date.json';

      final params = SaveFileDialogParams(
        data: fileBytes,
        fileName: fileName,
      );
      final savedPath = await FlutterFileDialog.saveFile(params: params);

      if (!context.mounted) return;

      if (savedPath != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              AppLocalizations.of(context)!.settingsExportSuccess(savedPath)),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.settingsExportCancelled),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ));
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            AppLocalizations.of(context)!.settingsExportError(e.toString())),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);

    final importKw = [
      loc.settingsImportLib,
      loc.settingsImportLibDesc,
      'import',
      'JSON',
      'bibliothèque',
      'library',
    ];
    final exportKw = [
      loc.settingsExportLib,
      loc.settingsExportLibDesc,
      'export',
      'JSON',
      'sauvegarde',
      'backup',
    ];

    final toolsPageKw = [
      loc.toolsTitle,
      loc.settingsToolsDesc,
      'tuner',
      'accordeur',
      'metronome',
      'métronome',
      'outils',
      'tools',
    ];
    final dataSourcesKw = [
      loc.settingsDataSources,
      loc.settingsDataSourcesDesc,
      'source',
      'database',
      'base de données',
      'REST',
      'API',
    ];
    final tunerKw = [
      loc.toolsTuner,
      loc.toolsTunerDesc,
      'tuner',
      'accordeur',
      'guitar',
      'guitare',
      'microphone',
    ];
    final metronomeKw = [
      loc.toolsMetronome,
      loc.toolsMetronomeDesc,
      'metronome',
      'métronome',
      'rhythm',
      'rythme',
      'tempo',
      'BPM',
    ];
    final exportListKw = [
      loc.toolsExportList,
      loc.toolsExportListDesc,
      'export',
      'list',
      'liste',
      'TXT',
      'PDF',
    ];
    final exportTabsKw = [
      loc.toolsExportTabs,
      loc.toolsExportTabsDesc,
      'export',
      'tabs',
      'tablatures',
      'PDF',
      'songbook',
    ];
    final geniusKw = [
      'Genius',
      'API',
      loc.settingsGeniusDesc,
      'album',
      'cover',
      'pochette',
    ];
    final geminiKw = [
      'Gemini',
      'Google',
      'API',
      loc.settingsGeminiDesc,
      'smart',
      'search',
      'intelligent',
      'recherche',
    ];
    final versionKw = [
      loc.toolsVersion,
      loc.toolsVersionDesc,
      'version',
      'update',
      'mise à jour',
    ];
    final welcomeKw = [
      loc.toolsWelcome,
      loc.toolsWelcomeDesc,
      'welcome',
      'introduction',
      'bienvenue',
    ];

    final devByKw = [
      loc.settingsDevBy,
      loc.settingsDevSubtitle,
      'developer',
      'développeur',
      'phi-k',
      'pianist',
      'pianiste',
    ];
    final devWithKw = [
      loc.settingsDevWith,
      loc.settingsDevWithDesc,
      'Flutter',
      'Isar',
      'Riverpod',
      'framework',
    ];
    final appVersionKw = [
      loc.settingsAppVersion,
      _appVersion,
      'version',
    ];

    final bool isSearching = _searchQuery.isNotEmpty;

    final List<Widget> searchResults = [];
    if (isSearching) {
      void addResult(
          String title, String subtitle, IconData icon, VoidCallback onTap) {
        searchResults
            .add(_buildFeatureRow(context, title, subtitle, icon, onTap));
      }

      if (_itemMatches(importKw)) {
        addResult(loc.settingsImportLib, loc.settingsImportLibDesc,
            Icons.file_upload_outlined, () => _importJson(context));
      }
      if (_itemMatches(exportKw)) {
        addResult(loc.settingsExportLib, loc.settingsExportLibDesc,
            Icons.file_download_outlined, () => _exportJson(context));
      }

      if (_itemMatches(toolsPageKw)) {
        addResult(
            loc.toolsTitle, loc.settingsToolsDesc, Icons.construction_outlined,
            () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const ToolsPage()));
        });
      }
      if (_itemMatches(dataSourcesKw)) {
        addResult(loc.settingsDataSources, loc.settingsDataSourcesDesc,
            Icons.dns_outlined, () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const DataSourcesPage()));
        });
      }

      if (_itemMatches(tunerKw)) {
        addResult(loc.toolsTuner, loc.toolsTunerDesc, Icons.graphic_eq, () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const TunerPage()));
        });
      }
      if (_itemMatches(metronomeKw)) {
        addResult(
            loc.toolsMetronome, loc.toolsMetronomeDesc, Icons.timer_outlined,
            () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const MetronomePage()));
        });
      }
      if (_itemMatches(exportListKw)) {
        addResult(loc.toolsExportList, loc.toolsExportListDesc,
            Icons.list_alt_outlined, () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ExportSongListPage()));
        });
      }
      if (_itemMatches(exportTabsKw)) {
        addResult(loc.toolsExportTabs, loc.toolsExportTabsDesc,
            Icons.picture_as_pdf_outlined, () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const ExportTabsPage()));
        });
      }
      if (_itemMatches(geniusKw)) {
        addResult(
            "Genius API",
            settings.geniusKey.isEmpty
                ? loc.settingsGeniusDesc
                : "••••••••••••",
            Icons.album_outlined, () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const ToolsPage()));
        });
      }
      if (_itemMatches(geminiKw)) {
        addResult(
            "Google Gemini API",
            settings.geminiKey.isEmpty
                ? loc.settingsGeminiDesc
                : "••••••••••••",
            Icons.auto_awesome, () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const ToolsPage()));
        });
      }
      if (_itemMatches(versionKw)) {
        addResult(loc.toolsVersion, loc.toolsVersionDesc,
            Icons.system_update_outlined, () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const VersionPage()));
        });
      }
      if (_itemMatches(welcomeKw)) {
        addResult(loc.toolsWelcome, loc.toolsWelcomeDesc,
            Icons.rocket_launch_outlined, () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const WelcomePage()));
        });
      }

      if (_itemMatches(devByKw)) {
        addResult(loc.settingsDevBy, loc.settingsDevSubtitle,
            Icons.person_outline, () {});
      }
      if (_itemMatches(devWithKw)) {
        addResult(
            loc.settingsDevWith, loc.settingsDevWithDesc, Icons.code, () {});
      }
      if (_itemMatches(appVersionKw)) {
        addResult(loc.settingsAppVersion, _appVersion,
            Icons.new_releases_outlined, () {});
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.settingsTitle,
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
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language, size: 22),
            tooltip: loc.settingsLanguage,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              ref.read(settingsProvider.notifier).setLocale(value);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'en',
                child: Row(
                  children: [
                    const Text("🇬🇧", style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Text("English",
                        style: TextStyle(
                          fontFamily: 'Cormorant',
                          fontSize: 16,
                          fontWeight: settings.locale.languageCode == 'en'
                              ? FontWeight.bold
                              : FontWeight.normal,
                        )),
                    if (settings.locale.languageCode == 'en') ...[
                      const Spacer(),
                      const Icon(Icons.check, size: 18, color: Colors.red),
                    ],
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'fr',
                child: Row(
                  children: [
                    const Text("🇫🇷", style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Text("Français",
                        style: TextStyle(
                          fontFamily: 'Cormorant',
                          fontSize: 16,
                          fontWeight: settings.locale.languageCode == 'fr'
                              ? FontWeight.bold
                              : FontWeight.normal,
                        )),
                    if (settings.locale.languageCode == 'fr') ...[
                      const Spacer(),
                      const Icon(Icons.check, size: 18, color: Colors.red),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) =>
                      setState(() => _searchQuery = val.toLowerCase()),
                  style: const TextStyle(fontFamily: 'Cormorant', fontSize: 16),
                  decoration: InputDecoration(
                    hintText: loc.settingsSearchHint,
                    prefixIcon: Icon(Icons.search,
                        color: Colors.grey.shade400, size: 22),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear,
                                color: Colors.grey.shade400, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    hintStyle: TextStyle(
                      fontFamily: 'Cormorant',
                      color: Colors.grey.shade400,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (isSearching) ...[
                if (searchResults.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        loc.settingsNoResults,
                        style: TextStyle(
                          fontFamily: 'Cormorant',
                          fontSize: 16,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  )
                else
                  _buildSectionContainer(
                    context,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < searchResults.length; i++) ...[
                          searchResults[i],
                          if (i < searchResults.length - 1)
                            const Divider(height: 20),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
              ] else ...[
                _buildSectionHeader(
                    context, loc.settingsBackups, Icons.save_alt),
                _buildSectionContainer(
                  context,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFeatureRow(
                        context,
                        loc.settingsImportLib,
                        loc.settingsImportLibDesc,
                        Icons.file_upload_outlined,
                        () => _importJson(context),
                      ),
                      const Divider(height: 20),
                      _buildFeatureRow(
                        context,
                        loc.settingsExportLib,
                        loc.settingsExportLibDesc,
                        Icons.file_download_outlined,
                        () => _exportJson(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(
                    context, loc.toolsTitle, Icons.build_outlined),
                _buildSectionContainer(
                  context,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFeatureRow(
                        context,
                        loc.toolsTitle,
                        loc.settingsToolsDesc,
                        Icons.construction_outlined,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ToolsPage()),
                          );
                        },
                      ),
                      const Divider(height: 20),
                      _buildFeatureRow(
                        context,
                        loc.settingsDataSources,
                        loc.settingsDataSourcesDesc,
                        Icons.dns_outlined,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const DataSourcesPage()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(
                    context, loc.settingsAbout, Icons.info_outline),
                _buildSectionContainer(
                  context,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        leading:
                            const Icon(Icons.person_outline, color: Colors.red),
                        title: Text(
                          loc.settingsDevBy,
                          style: const TextStyle(
                            fontFamily: 'Cormorant',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          loc.settingsDevSubtitle,
                          style: const TextStyle(
                            fontFamily: 'Cormorant',
                            fontSize: 15,
                          ),
                        ),
                      ),
                      ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        leading: const Icon(Icons.code, color: Colors.red),
                        title: Text(
                          loc.settingsDevWith,
                          style: const TextStyle(
                            fontFamily: 'Cormorant',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          loc.settingsDevWithDesc,
                          style: const TextStyle(
                            fontFamily: 'Cormorant',
                            fontSize: 15,
                          ),
                        ),
                      ),
                      ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        leading: const Icon(Icons.new_releases_outlined,
                            color: Colors.red),
                        title: Text(
                          loc.settingsAppVersion,
                          style: const TextStyle(
                            fontFamily: 'Cormorant',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          _appVersion,
                          style: const TextStyle(
                            fontFamily: 'Cormorant',
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LegalPage()),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                  ),
                  child: Text(
                    loc.settingsLegal,
                    style: const TextStyle(
                      fontFamily: 'Cormorant',
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.red, size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Cormorant',
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer(BuildContext context, Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Cormorant',
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black45,
            ),
          ],
        ),
      ),
    );
  }
}

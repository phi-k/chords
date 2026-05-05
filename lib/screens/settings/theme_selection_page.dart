import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../models/app_theme.dart';
import '../../models/bottom_bar_model.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/common/app_image.dart';
import 'theme_creator_page.dart';

class ThemeSelectionPage extends ConsumerWidget {
  const ThemeSelectionPage({super.key});

  String _getTranslatedString(BuildContext context, String key) {
    final loc = AppLocalizations.of(context)!;
    final translations = {
      'themeLightName': loc.themeLightName,
      'themeLightDesc': loc.themeLightDesc,
      'themeDarkName': loc.themeDarkName,
      'themeDarkDesc': loc.themeDarkDesc,
      'themeDarkSideName': loc.themeDarkSideName,
      'themeDarkSideDesc': loc.themeDarkSideDesc,
      'themeNevermindName': loc.themeNevermindName,
      'themeNevermindDesc': loc.themeNevermindDesc,
    };
    return translations[key] ?? key;
  }

  Future<void> _exportTheme(BuildContext context, AppTheme theme) async {
    try {
      final jsonStr = jsonEncode(theme.toJson());
      final fileBytes = Uint8List.fromList(utf8.encode(jsonStr));
      final date = DateFormat('dd-MM-yyyy').format(DateTime.now());

      final params = SaveFileDialogParams(
        data: fileBytes,
        fileName:
            'chords_theme_${theme.nameKey.replaceAll(" ", "_")}_$date.json',
      );
      await FlutterFileDialog.saveFile(params: params);
    } catch (_) {
    }
  }

  Future<void> _importTheme(BuildContext context, WidgetRef ref) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.single.path != null) {
      try {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final jsonMap = jsonDecode(content);

        final importedTheme = AppTheme.fromJson(jsonMap).copyWithNewId();

        ref.read(settingsProvider.notifier).addCustomTheme(importedTheme);
      } catch (_) {
        if (context.mounted) {
          BottomBarModel.showBottomBar(
            message: AppLocalizations.of(context)!.commonError("Fichier invalide"),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final themeBg = Theme.of(context).scaffoldBackgroundColor;
    final themeTxt = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: themeBg,
      appBar: AppBar(
        title: Text(loc.themeTitle,
            style: const TextStyle(
                fontFamily: 'Cormorant', fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: loc.themeImport,
            onPressed: () => _importTheme(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile.adaptive(
            title: Text(loc.themeFollowSystem),
            subtitle: Text(loc.themeFollowSystemDesc),
            value: settings.followSystem,
            onChanged: (v) =>
                ref.read(settingsProvider.notifier).setFollowSystem(v),
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: builtInThemes
                .map((t) => _buildThemeListItem(
                    context, ref, t, settings))
                .toList(),
          ),
          if (settings.customThemes.isNotEmpty) ...[
            const SizedBox(height: 30),
            Text(loc.themeCustoms,
                style: TextStyle(
                    color: themeTxt,
                    fontSize: 24,
                    fontFamily: 'Cormorant',
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: settings.customThemes
                  .map((t) => _buildThemeListItem(
                      context, ref, t, settings))
                  .toList(),
            ),
          ],
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ThemeCreatorPage())),
            icon:
                Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
            label: Text(loc.themeCreate,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontFamily: 'Cormorant',
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 20),
                elevation: 4,
                shadowColor:
                    Theme.of(context).colorScheme.shadow.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16))),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildThemeListItem(
      BuildContext context, WidgetRef ref, AppTheme theme, SettingsState settings) {
    final isDarkTheme = theme.backgroundColor.computeLuminance() < 0.5;
    final isCurrentMode = (Theme.of(context).brightness == Brightness.dark) == isDarkTheme;
    
    final isActive = settings.followSystem
        ? (isDarkTheme ? theme.id == settings.activeDarkThemeId : theme.id == settings.activeLightThemeId)
        : theme.id == settings.activeThemeId;
        
    final currentTheme = Theme.of(context);
    final isDimmed = settings.followSystem && !isCurrentMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final notifier = ref.read(settingsProvider.notifier);
          if (settings.followSystem) {
            if (isDarkTheme) {
              notifier.setDarkTheme(theme.id);
            } else {
              notifier.setLightTheme(theme.id);
            }
          } else {
            notifier.setTheme(theme.id);
          }
        },
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: isDimmed ? 0.4 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: isActive
                  ? theme.primaryColor.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: _buildThemePreview(theme),
                  ),
                ),
                const SizedBox(width: 16),
  
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getTranslatedString(context, theme.nameKey),
                        style: TextStyle(
                          fontFamily: 'Cormorant',
                          fontSize: 18,
                          fontWeight:
                              isActive ? FontWeight.bold : FontWeight.w600,
                          color: isActive
                              ? theme.primaryColor
                              : currentTheme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getTranslatedString(context, theme.descKey),
                        style: TextStyle(
                          fontFamily: 'Cormorant',
                          fontSize: 14,
                          color: currentTheme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
  
                const SizedBox(width: 12),
  
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildColorDot(theme.primaryColor),
                    const SizedBox(width: 4),
                    _buildColorDot(theme.backgroundColor),
                    const SizedBox(width: 4),
                    _buildColorDot(theme.textColor),
                  ],
                ),
  
                const SizedBox(width: 12),
  
                if (!theme.isBuiltIn)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert,
                        color: currentTheme.colorScheme.onSurfaceVariant,
                        size: 20),
                    padding: EdgeInsets.zero,
                    onSelected: (val) {
                      if (val == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ThemeCreatorPage(existingTheme: theme),
                          ),
                        );
                      }
                      if (val == 'delete') {
                        ref
                            .read(settingsProvider.notifier)
                            .deleteCustomTheme(theme.id);
                      }
                      if (val == 'export') _exportTheme(context, theme);
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                          value: 'edit',
                          child: Text(AppLocalizations.of(context)!.commonEdit)),
                      PopupMenuItem(
                          value: 'export',
                          child: Text(AppLocalizations.of(context)!.themeExport)),
                      PopupMenuItem(
                          value: 'delete',
                          child: Text(AppLocalizations.of(context)!.commonDelete,
                              style: const TextStyle(color: Colors.red))),
                    ],
                  ),
  
                const SizedBox(width: 8),
                if (isActive)
                  Icon(
                    settings.followSystem 
                        ? (isDarkTheme ? Icons.dark_mode_rounded : Icons.light_mode_rounded) 
                        : Icons.check_rounded, 
                    color: theme.primaryColor, 
                    size: 24
                  )
                else
                  const SizedBox(width: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemePreview(AppTheme theme) {
    if (theme.id == 'chords_light') {
      return _buildChordsInitialPreview(
        backgroundColor: Colors.white,
        accentColor: theme.primaryColor,
      );
    }

    if (theme.id == 'chords_dark') {
      return _buildChordsInitialPreview(
        backgroundColor: theme.backgroundColor,
        accentColor: theme.primaryColor,
      );
    }

    return AppImage(
      url: theme.coverUrl,
      fit: BoxFit.cover,
      borderRadius: 0,
    );
  }

  Widget _buildChordsInitialPreview({
    required Color backgroundColor,
    required Color accentColor,
  }) {
    return Container(
      color: backgroundColor,
      alignment: Alignment.center,
      child: Text(
        'C',
        style: TextStyle(
          fontFamily: 'Cormorant',
          fontSize: 36,
          fontWeight: FontWeight.bold,
          height: 0.9,
          color: accentColor,
        ),
      ),
    );
  }

  Widget _buildColorDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration:
          BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(1, 1))
      ]),
    );
  }
}

extension on AppTheme {
  AppTheme copyWithNewId() {
    return AppTheme(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      nameKey: nameKey,
      descKey: descKey,
      coverUrl: coverUrl,
      primaryColor: primaryColor,
      backgroundColor: backgroundColor,
      textColor: textColor,
      isBuiltIn: false,
    );
  }
}

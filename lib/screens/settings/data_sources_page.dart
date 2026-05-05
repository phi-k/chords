// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:share_plus/share_plus.dart';
import '../../l10n/app_localizations.dart';
import '../../models/tab_source.dart';
import '../../services/source_manager.dart';
import '../../widgets/common/custom_loader.dart';
import 'edit_source_page.dart';

class DataSourcesPage extends StatefulWidget {
  const DataSourcesPage({super.key});

  @override
  State<DataSourcesPage> createState() => _DataSourcesPageState();
}

class _DataSourcesPageState extends State<DataSourcesPage> {
  List<TabSource> _sources = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSources();
  }

  Future<void> _loadSources() async {
    final sources = await SourceManager.getSources();
    setState(() {
      _sources = sources;
      _isLoading = false;
    });
  }

  void _navigateToEdit([TabSource? source]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditSourcePage(source: source)),
    );
    _loadSources();
  }

  void _showHelpDialog() {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.help_outline,
                color: Theme.of(context).primaryColor, size: 24),
            SizedBox(width: 10),
            Expanded(
              child: Text(loc.dsHelpTitle,
                  style: TextStyle(
                      fontFamily: 'Cormorant',
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.dsHelpContent,
              style:
                  TextStyle(fontFamily: 'Cormorant', fontSize: 15, height: 1.4),
            ),
            SizedBox(height: 14),
            Text(
              loc.dsHelpBullets,
              style:
                  TextStyle(fontFamily: 'Cormorant', fontSize: 14, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.dsUnderstood,
                style: TextStyle(
                    fontFamily: 'Cormorant',
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDelete(TabSource source) async {
    final loc = AppLocalizations.of(context)!;
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(loc.dsDeleteConfirm,
                style: TextStyle(
                    fontFamily: 'Cormorant', fontWeight: FontWeight.bold)),
            content: Text(
              loc.dsDeleteMessage(source.name),
              style: TextStyle(fontFamily: 'Cormorant', fontSize: 15),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(loc.commonCancel,
                    style: TextStyle(
                        fontFamily: 'Cormorant', color: Colors.black54)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(loc.commonDelete,
                    style: TextStyle(
                        fontFamily: 'Cormorant',
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _exportSourceToFile(TabSource source) async {
    try {
      final jsonStr =
          const JsonEncoder.withIndent('  ').convert(source.toMap());
      final dir = await getTemporaryDirectory();
      final safeName =
          source.name.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
      final file = File('${dir.path}/chords_source_$safeName.json');
      await file.writeAsString(jsonStr);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Configuration de la source "${source.name}" pour Chords',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppLocalizations.of(context)!.dsExportError(e.toString()),
                style: TextStyle(fontFamily: 'Cormorant')),
          ),
        );
      }
    }
  }

  Future<void> _importSourceFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final map = json.decode(content) as Map<String, dynamic>;

      final source = TabSource.fromMap({...map, 'id': null, 'isActive': false});

      if (!mounted) return;
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          final loc = AppLocalizations.of(context)!;
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(loc.dsImportConfirm,
                style: TextStyle(
                    fontFamily: 'Cormorant', fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImportPreviewRow(loc.dsImportName, source.name),
                _buildImportPreviewRow(loc.dsImportUrl, source.baseUrl),
                _buildImportPreviewRow(
                    loc.dsImportHeaders, source.headers.length.toString()),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(loc.commonCancel,
                    style: TextStyle(
                        fontFamily: 'Cormorant', color: Colors.black54)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(loc.dsImport,
                    style: TextStyle(
                        fontFamily: 'Cormorant',
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      );

      if (confirm == true) {
        await SourceManager.saveSource(source);
        _loadSources();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  AppLocalizations.of(context)!.dsImportSuccess(source.name),
                  style: TextStyle(fontFamily: 'Cormorant')),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppLocalizations.of(context)!.dsInvalidFile(e.toString()),
                style: TextStyle(fontFamily: 'Cormorant')),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
      }
    }
  }

  Widget _buildImportPreviewRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(label,
                style: TextStyle(
                    fontFamily: 'Cormorant',
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5))),
          ),
          Expanded(
            child: Text(value.isNotEmpty ? value : '—',
                style: TextStyle(
                    fontFamily: 'Cormorant',
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  void _showQrCode(TabSource source) {
    final jsonStr = json.encode(source.toMap());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.qr_code_2_rounded,
                    color: Theme.of(context).primaryColor, size: 24),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                      AppLocalizations.of(context)!.dsShareTitle(source.name),
                      style: TextStyle(
                          fontFamily: 'Cormorant',
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.dsQrScanInfo,
              style: TextStyle(
                  fontFamily: 'Cormorant',
                  fontSize: 14,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                  height: 1.4),
            ),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: QrImageView(
                data: jsonStr,
                version: QrVersions.auto,
                size: 240,
                gapless: true,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Colors.black,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: Theme.of(context).primaryColor),
                  SizedBox(width: 6),
                  Text(AppLocalizations.of(context)!.dsQrHeadersIncluded,
                      style: TextStyle(
                          fontFamily: 'Cormorant',
                          fontSize: 13,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scanQrCode() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => _QrScannerPage(
                onSourceScanned: (source) async {
                  await SourceManager.saveSource(source);
                  _loadSources();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            AppLocalizations.of(context)!
                                .dsImportSuccess(source.name),
                            style: TextStyle(fontFamily: 'Cormorant')),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
              )),
    );
  }

  void _showShareOptions(TabSource source) {
    final loc = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.share_rounded,
                    color: Theme.of(context).primaryColor, size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Text(AppLocalizations.of(context)!.dsShareSource,
                      style: TextStyle(
                          fontFamily: 'Cormorant',
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildActionOption(
              icon: Icons.file_copy_outlined,
              title: loc.dsShareFile,
              subtitle: loc.dsShareFileDesc,
              color: Colors.blue,
              onTap: () {
                Navigator.pop(ctx);
                _exportSourceToFile(source);
              },
            ),
            SizedBox(height: 10),
            _buildActionOption(
              icon: Icons.qr_code_2_rounded,
              title: loc.dsShareQr,
              subtitle: loc.dsShareQrDesc,
              color: Colors.deepPurple,
              onTap: () {
                Navigator.pop(ctx);
                _showQrCode(source);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSourceOptions() {
    final loc = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.add_circle_outline_rounded,
                    color: Theme.of(context).primaryColor, size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Text(loc.dsAddSourceTitle,
                      style: TextStyle(
                          fontFamily: 'Cormorant',
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildActionOption(
              icon: Icons.qr_code_scanner_rounded,
              title: loc.dsScanQr,
              subtitle: loc.dsScanSubtitle,
              color: Colors.deepPurple,
              onTap: () {
                Navigator.pop(ctx);
                _scanQrCode();
              },
            ),
            SizedBox(height: 10),
            _buildActionOption(
              icon: Icons.file_open_outlined,
              title: loc.dsImportFile,
              subtitle: loc.dsImportFileSubtitle,
              color: Colors.blue,
              onTap: () {
                Navigator.pop(ctx);
                _importSourceFromFile();
              },
            ),
            SizedBox(height: 10),
            _buildActionOption(
              icon: Icons.edit_note_rounded,
              title: loc.dsManualConfig,
              subtitle: loc.dsManualSubtitle,
              color: Theme.of(context).primaryColor,
              onTap: () {
                Navigator.pop(ctx);
                _navigateToEdit();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontFamily: 'Cormorant',
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    Text(subtitle,
                        style: TextStyle(
                            fontFamily: 'Cormorant',
                            fontSize: 13,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5))),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          loc.dsTitle,
          style: TextStyle(
              fontFamily: 'Cormorant',
              fontWeight: FontWeight.bold,
              fontSize: 22),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline_rounded,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
                size: 22),
            tooltip: loc.dsHelp,
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      floatingActionButton: _sources.isNotEmpty
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: _showAddSourceOptions,
              child:
                  Icon(Icons.add, color: Theme.of(context).colorScheme.surface),
            )
          : null,
      body: _isLoading
          ? const CustomLoader()
          : _sources.isEmpty
              ? _buildEmptyState()
              : _buildList(),
    );
  }

  Widget _buildEmptyState() {
    final loc = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.dns_outlined,
                  size: 48, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 28),
            Text(
              loc.dsNoSource,
              style: TextStyle(
                  fontFamily: 'Cormorant',
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              loc.dsNoSourceDesc,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Cormorant',
                  fontSize: 16,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                  height: 1.4),
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showAddSourceOptions,
              icon: Icon(Icons.add,
                  size: 20, color: Theme.of(context).colorScheme.surface),
              label: Text(loc.dsAddSource,
                  style: TextStyle(
                      fontFamily: 'Cormorant',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.surface)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    final loc = AppLocalizations.of(context)!;
    final activeSources = _sources.where((s) => s.isActive).toList();
    final inactiveSources = _sources.where((s) => !s.isActive).toList();
    final orderedSources = [...activeSources, ...inactiveSources];

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 16, left: 4),
          child: Text(
            loc.dsSourceCount(_sources.length),
            style: TextStyle(
                fontFamily: 'Cormorant',
                fontSize: 14,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5)),
          ),
        ),
        ...orderedSources.map((source) => _buildSourceCard(source)),
      ],
    );
  }

  Widget _buildSourceCard(TabSource source) {
    final loc = AppLocalizations.of(context)!;
    final hasHeaders = source.headers.isNotEmpty;
    final endpointCount = (source.searchPath.isNotEmpty ? 1 : 0) +
        (source.detailsPath.isNotEmpty ? 1 : 0);

    return Padding(
      padding: EdgeInsets.only(bottom: 14),
      child: Dismissible(
        key: Key(source.id),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) => _confirmDelete(source),
        onDismissed: (_) async {
          await SourceManager.deleteSource(source.id);
          _loadSources();
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(Icons.delete_outline,
              color: Theme.of(context).colorScheme.surface, size: 28),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: source.isActive
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.4)
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
              width: source.isActive ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: source.isActive
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(18, 16, 12, 0),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: source.isActive
                            ? LinearGradient(
                                colors: [
                                  Theme.of(context).primaryColor,
                                  Theme.of(context).primaryColor
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: source.isActive
                            ? null
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        source.isActive
                            ? Icons.cloud_done_rounded
                            : Icons.dns_outlined,
                        color: source.isActive
                            ? Theme.of(context).colorScheme.surface
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5),
                        size: 22,
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            source.name,
                            style: TextStyle(
                                fontFamily: 'Cormorant',
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2),
                          Text(
                            source.baseUrl,
                            style: TextStyle(
                                fontFamily: 'UbuntuMono',
                                fontSize: 11,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.5)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Transform.scale(
                      scale: 0.8,
                      child: Switch.adaptive(
                        value: source.isActive,
                        activeThumbColor: Theme.of(context).colorScheme.surface,
                        activeTrackColor: Theme.of(context).primaryColor,
                        onChanged: (val) async {
                          await SourceManager.toggleSourceActive(source.id);
                          _loadSources();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(18, 10, 18, 4),
                child: Row(
                  children: [
                    _buildChip(
                      Icons.api_rounded,
                      "$endpointCount endpoint${endpointCount > 1 ? 's' : ''}",
                      source.isActive
                          ? Theme.of(context).primaryColor
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                    ),
                    SizedBox(width: 8),
                    if (hasHeaders)
                      _buildChip(
                        Icons.vpn_key_outlined,
                        "${source.headers.length} header${source.headers.length > 1 ? 's' : ''}",
                        source.isActive
                            ? Theme.of(context).primaryColor
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5),
                      ),
                    const Spacer(),
                    if (source.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Colors.green.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(loc.dsConnected,
                                style: const TextStyle(
                                    fontFamily: 'Cormorant',
                                    fontSize: 11,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.05),
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(18)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => _navigateToEdit(source),
                      icon: Icon(Icons.edit_outlined,
                          size: 16,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7)),
                      label: Text(loc.commonEdit,
                          style: TextStyle(
                              fontFamily: 'Cormorant',
                              fontSize: 13,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.7))),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: const Size(0, 36),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 20,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
                    TextButton.icon(
                      onPressed: () => _showShareOptions(source),
                      icon: Icon(Icons.share_outlined,
                          size: 16,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5)),
                      label: Text(loc.dsShare,
                          style: TextStyle(
                              fontFamily: 'Cormorant',
                              fontSize: 13,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.5))),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: const Size(0, 36),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.delete_outline_rounded,
                          size: 18, color: Theme.of(context).primaryColor),
                      onPressed: () async {
                        final confirmed = await _confirmDelete(source);
                        if (confirmed) {
                          await SourceManager.deleteSource(source.id);
                          _loadSources();
                        }
                      },
                      tooltip: loc.commonDelete,
                      splashRadius: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color.withValues(alpha: 0.7)),
          SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontFamily: 'Cormorant',
                  fontSize: 12,
                  color: color.withValues(alpha: 0.7))),
        ],
      ),
    );
  }
}

class _QrScannerPage extends StatefulWidget {
  final Future<void> Function(TabSource source) onSourceScanned;
  const _QrScannerPage({required this.onSourceScanned});

  @override
  State<_QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<_QrScannerPage> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _hasScanned = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_hasScanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    setState(() => _hasScanned = true);

    try {
      final map = json.decode(barcode.rawValue!) as Map<String, dynamic>;
      final source = TabSource.fromMap({...map, 'id': null, 'isActive': false});

      if (!mounted) return;

      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Importer cette source ?",
              style: TextStyle(
                  fontFamily: 'Cormorant', fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPreviewRow("Nom", source.name),
              _buildPreviewRow("URL", source.baseUrl),
              _buildPreviewRow("Headers", "${source.headers.length}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text("Annuler",
                  style: TextStyle(
                      fontFamily: 'Cormorant', color: Colors.black54)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text("Importer",
                  style: TextStyle(
                      fontFamily: 'Cormorant',
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await widget.onSourceScanned(source);
        if (mounted) Navigator.pop(context);
      } else {
        setState(() => _hasScanned = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("QR code invalide : $e",
                style: TextStyle(fontFamily: 'Cormorant')),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
        setState(() => _hasScanned = false);
      }
    }
  }

  Widget _buildPreviewRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(label,
                style: TextStyle(
                    fontFamily: 'Cormorant',
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5))),
          ),
          Expanded(
            child: Text(value.isNotEmpty ? value : '—',
                style: TextStyle(
                    fontFamily: 'Cormorant',
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Scanner un QR code",
            style: TextStyle(
                fontFamily: 'Cormorant',
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Theme.of(context).colorScheme.surface)),
        backgroundColor: Colors.black,
        foregroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .surface
                        .withValues(alpha: 0.6),
                    width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 40,
            right: 40,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                "Placez le QR code d'une source Chords dans le cadre",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Cormorant',
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.surface,
                    height: 1.3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
            Icon(Icons.help_outline, color: Colors.red.shade400, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(loc.dsHelpTitle,
                  style: const TextStyle(
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
              style: const TextStyle(
                  fontFamily: 'Cormorant', fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 14),
            Text(
              loc.dsHelpBullets,
              style: const TextStyle(
                  fontFamily: 'Cormorant', fontSize: 14, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.dsUnderstood,
                style: const TextStyle(
                    fontFamily: 'Cormorant',
                    color: Colors.red,
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
                style: const TextStyle(
                    fontFamily: 'Cormorant', fontWeight: FontWeight.bold)),
            content: Text(
              loc.dsDeleteMessage(source.name),
              style: const TextStyle(fontFamily: 'Cormorant', fontSize: 15),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(loc.commonCancel,
                    style: const TextStyle(
                        fontFamily: 'Cormorant', color: Colors.black54)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(loc.commonDelete,
                    style: const TextStyle(
                        fontFamily: 'Cormorant',
                        color: Colors.red,
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
                style: const TextStyle(fontFamily: 'Cormorant')),
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
                style: const TextStyle(
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
                    style: const TextStyle(
                        fontFamily: 'Cormorant', color: Colors.black54)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(loc.dsImport,
                    style: const TextStyle(
                        fontFamily: 'Cormorant',
                        color: Colors.red,
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
                  style: const TextStyle(fontFamily: 'Cormorant')),
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
                style: const TextStyle(fontFamily: 'Cormorant')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildImportPreviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(label,
                style: TextStyle(
                    fontFamily: 'Cormorant',
                    fontSize: 14,
                    color: Colors.grey.shade600)),
          ),
          Expanded(
            child: Text(value.isNotEmpty ? value : '—',
                style: const TextStyle(
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
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.qr_code_2_rounded,
                    color: Colors.red.shade400, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                      AppLocalizations.of(context)!.dsShareTitle(source.name),
                      style: const TextStyle(
                          fontFamily: 'Cormorant',
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.dsQrScanInfo,
              style: TextStyle(
                  fontFamily: 'Cormorant',
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.4),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
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
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Text(AppLocalizations.of(context)!.dsQrHeadersIncluded,
                      style: TextStyle(
                          fontFamily: 'Cormorant',
                          fontSize: 12,
                          color: Colors.grey.shade500)),
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
                            style: const TextStyle(fontFamily: 'Cormorant')),
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
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.share_rounded, color: Colors.red.shade400, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(AppLocalizations.of(context)!.dsShareSource,
                      style: const TextStyle(
                          fontFamily: 'Cormorant',
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 10),
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
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.add_circle_outline_rounded,
                    color: Colors.red.shade400, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(loc.dsAddSourceTitle,
                      style: const TextStyle(
                          fontFamily: 'Cormorant',
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 10),
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
            const SizedBox(height: 10),
            _buildActionOption(
              icon: Icons.edit_note_rounded,
              title: loc.dsManualConfig,
              subtitle: loc.dsManualSubtitle,
              color: Colors.red,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
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
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontFamily: 'Cormorant',
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    Text(subtitle,
                        style: TextStyle(
                            fontFamily: 'Cormorant',
                            fontSize: 13,
                            color: Colors.grey.shade500)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300),
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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          loc.dsTitle,
          style: TextStyle(
              fontFamily: 'Cormorant',
              fontWeight: FontWeight.bold,
              fontSize: 22),
        ),
        backgroundColor: Colors.grey.shade50,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline_rounded,
                color: Colors.grey.shade500, size: 22),
            tooltip: loc.dsHelp,
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      floatingActionButton: _sources.isNotEmpty
          ? FloatingActionButton(
              backgroundColor: Colors.red,
              onPressed: _showAddSourceOptions,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
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
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.dns_outlined,
                  size: 48, color: Colors.red.shade300),
            ),
            const SizedBox(height: 28),
            Text(
              loc.dsNoSource,
              style: const TextStyle(
                  fontFamily: 'Cormorant',
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              loc.dsNoSourceDesc,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Cormorant',
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.4),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showAddSourceOptions,
              icon: const Icon(Icons.add, size: 20, color: Colors.white),
              label: Text(loc.dsAddSource,
                  style: TextStyle(
                      fontFamily: 'Cormorant',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16, left: 4),
          child: Text(
            loc.dsSourceCount(_sources.length),
            style: TextStyle(
                fontFamily: 'Cormorant',
                fontSize: 14,
                color: Colors.grey.shade500),
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
      padding: const EdgeInsets.only(bottom: 14),
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
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(18),
          ),
          child:
              const Icon(Icons.delete_outline, color: Colors.white, size: 28),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: source.isActive
                  ? Colors.red.withValues(alpha: 0.4)
                  : Colors.grey.shade200,
              width: source.isActive ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: source.isActive
                    ? Colors.red.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 12, 0),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: source.isActive
                            ? LinearGradient(
                                colors: [
                                  Colors.red.shade400,
                                  Colors.red.shade600
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: source.isActive ? null : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        source.isActive
                            ? Icons.cloud_done_rounded
                            : Icons.dns_outlined,
                        color: source.isActive
                            ? Colors.white
                            : Colors.grey.shade500,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            source.name,
                            style: const TextStyle(
                                fontFamily: 'Cormorant',
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            source.baseUrl,
                            style: TextStyle(
                                fontFamily: 'UbuntuMono',
                                fontSize: 11,
                                color: Colors.grey.shade500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: source.isActive,
                        activeThumbColor: Colors.red,
                        activeTrackColor: Colors.red.shade100,
                        inactiveThumbColor: Colors.grey.shade400,
                        inactiveTrackColor: Colors.grey.shade200,
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
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
                child: Row(
                  children: [
                    _buildChip(
                      Icons.api_rounded,
                      "$endpointCount endpoint${endpointCount > 1 ? 's' : ''}",
                      source.isActive ? Colors.red : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    if (hasHeaders)
                      _buildChip(
                        Icons.vpn_key_outlined,
                        "${source.headers.length} header${source.headers.length > 1 ? 's' : ''}",
                        source.isActive ? Colors.red : Colors.grey,
                      ),
                    const Spacer(),
                    if (source.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.green.shade400,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(loc.dsConnected,
                                style: TextStyle(
                                    fontFamily: 'Cormorant',
                                    fontSize: 11,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(18)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => _navigateToEdit(source),
                      icon: Icon(Icons.edit_outlined,
                          size: 16, color: Colors.grey.shade600),
                      label: Text(loc.commonEdit,
                          style: TextStyle(
                              fontFamily: 'Cormorant',
                              fontSize: 13,
                              color: Colors.grey.shade600)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: const Size(0, 36),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 20,
                      color: Colors.grey.shade200,
                    ),
                    TextButton.icon(
                      onPressed: () => _showShareOptions(source),
                      icon: Icon(Icons.share_outlined,
                          size: 16, color: Colors.grey.shade600),
                      label: Text(loc.dsShare,
                          style: TextStyle(
                              fontFamily: 'Cormorant',
                              fontSize: 13,
                              color: Colors.grey.shade600)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: const Size(0, 36),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.delete_outline_rounded,
                          size: 18, color: Colors.red.shade300),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color.withValues(alpha: 0.7)),
          const SizedBox(width: 4),
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
          title: const Text("Importer cette source ?",
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
              child: const Text("Annuler",
                  style: TextStyle(
                      fontFamily: 'Cormorant', color: Colors.black54)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Importer",
                  style: TextStyle(
                      fontFamily: 'Cormorant',
                      color: Colors.red,
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
                style: const TextStyle(fontFamily: 'Cormorant')),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _hasScanned = false);
      }
    }
  }

  Widget _buildPreviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(label,
                style: TextStyle(
                    fontFamily: 'Cormorant',
                    fontSize: 14,
                    color: Colors.grey.shade600)),
          ),
          Expanded(
            child: Text(value.isNotEmpty ? value : '—',
                style: const TextStyle(
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
        title: const Text("Scanner un QR code",
            style: TextStyle(
                fontFamily: 'Cormorant',
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
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
                    color: Colors.white.withValues(alpha: 0.6), width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 40,
            right: 40,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                "Placez le QR code d'une source Chords dans le cadre",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Cormorant',
                    fontSize: 15,
                    color: Colors.white,
                    height: 1.3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

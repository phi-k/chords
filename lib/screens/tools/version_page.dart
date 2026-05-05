// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../services/update_service.dart';
import '../../services/version_service.dart';
import '../../widgets/update_dialog.dart';
import '../../widgets/common/custom_loader.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class VersionPage extends StatefulWidget {
  const VersionPage({super.key});

  @override
  State<VersionPage> createState() => _VersionPageState();
}

class _VersionPageState extends State<VersionPage> {
  String _currentVersion = '';
  String _versionCodename = '';
  List<Map<String, String>> _releases = [];
  bool _isLoading = true;
  bool _isCheckingUpdate = false;
  String? _updateStatus;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final updateService = UpdateService();
      final releases = await updateService.getAllReleases();

      setState(() {
        _currentVersion = packageInfo.version;
        _versionCodename = VersionService.getVersionCodename(_currentVersion);
        _releases = releases;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkForUpdate() async {
    if (!Platform.isAndroid) {
      setState(() {
        _updateStatus =
            "Les mises à jour automatiques ne sont disponibles que sur Android.";
      });
      return;
    }

    setState(() {
      _isCheckingUpdate = true;
      _updateStatus = null;
    });

    try {
      final updateService = UpdateService();
      final newVersion = await updateService.checkForUpdate();

      if (newVersion != null) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => UpdateDialog(appVersion: newVersion),
          );
        }
      } else {
        setState(() {
          _updateStatus = 'up_to_date';
        });
      }
    } catch (e) {
      setState(() {
        _updateStatus = 'error';
      });
    } finally {
      setState(() {
        _isCheckingUpdate = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          loc.versionTitle,
          style: TextStyle(
            fontFamily: 'Cormorant',
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: _isLoading
          ? const CustomLoader()
          : SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCurrentVersionCard(),
                  SizedBox(height: 20),
                  _buildCheckUpdateButton(),
                  if (_updateStatus != null) ...[
                    SizedBox(height: 12),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_updateStatus == 'up_to_date')
                            Icon(Icons.check_circle_outline,
                                color: Colors.green, size: 18),
                          if (_updateStatus == 'up_to_date') SizedBox(width: 6),
                          Text(
                            _updateStatus == 'up_to_date'
                                ? loc.versionUpToDate
                                : _updateStatus == 'android_only'
                                    ? loc.versionAutoUpdateAndroid
                                    : loc.versionCheckError,
                            style: TextStyle(
                              fontFamily: 'Cormorant',
                              fontSize: 15,
                              color: _updateStatus == 'up_to_date'
                                  ? Colors.green.shade600
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 40),
                  Text(
                    loc.versionHistory,
                    style: TextStyle(
                      fontFamily: 'Cormorant',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 16),
                  if (_releases.isEmpty)
                    Center(
                      child: Text(
                        loc.versionHistoryError,
                        style: TextStyle(
                          fontFamily: 'Cormorant',
                          fontSize: 16,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    )
                  else
                    ..._releases.map((release) => _buildReleaseCard(release)),
                ],
              ),
            ),
    );
  }

  Widget _buildCurrentVersionCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "C",
                style: GoogleFonts.cormorant(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Text(
                "hords",
                style: GoogleFonts.cormorant(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "v$_currentVersion",
              style: GoogleFonts.ubuntuMono(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
                letterSpacing: 1,
              ),
            ),
          ),
          if (_versionCodename.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              _versionCodename.replaceFirst(' - ', ''),
              style: GoogleFonts.cormorant(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCheckUpdateButton() {
    final loc = AppLocalizations.of(context)!;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isCheckingUpdate ? null : _checkForUpdate,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isCheckingUpdate)
                CustomLoader(
                    size: 18,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5))
              else
                Icon(Icons.refresh_rounded,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                    size: 20),
              SizedBox(width: 10),
              Text(
                _isCheckingUpdate
                    ? loc.versionChecking
                    : loc.versionCheckUpdate,
                style: TextStyle(
                  fontFamily: 'Cormorant',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReleaseCard(Map<String, String> release) {
    final version = release['version'] ?? '';
    final changelog = release['changelog'] ?? '';
    final isCurrentVersion = version == _currentVersion;
    final codename = VersionService.getVersionCodename(version);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentVersion
            ? Theme.of(context).primaryColor.withValues(alpha: 0.05)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentVersion
              ? Theme.of(context).primaryColor.withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isCurrentVersion
                      ? Theme.of(context).primaryColor
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "v$version",
                  style: TextStyle(
                    fontFamily: 'UbuntuMono',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isCurrentVersion
                        ? Theme.of(context).colorScheme.surface
                        : Colors.black87,
                  ),
                ),
              ),
              if (codename.isNotEmpty) ...[
                SizedBox(width: 8),
                Text(
                  codename,
                  style: TextStyle(
                    fontFamily: 'Cormorant',
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
                ),
              ],
              if (isCurrentVersion) ...[
                const Spacer(),
                Icon(Icons.check_circle,
                    color: Theme.of(context).primaryColor, size: 20),
              ],
            ],
          ),
          SizedBox(height: 12),
          MarkdownBody(
            data: changelog,
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(
                fontFamily: 'Cormorant',
                fontSize: 15,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

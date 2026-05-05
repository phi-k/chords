// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../l10n/app_localizations.dart';
import '../models/app_version.dart';
import '../services/update_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class UpdateDialog extends StatefulWidget {
  final AppVersion appVersion;

  const UpdateDialog({super.key, required this.appVersion});

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _isDownloading = false;
  double _progress = 0.0;
  String? _errorMessage;

  Future<void> _checkPermissionAndStartDownload() async {
    var status = await Permission.requestInstallPackages.status;

    if (!status.isGranted) {
      status = await Permission.requestInstallPackages.request();

      if (!status.isGranted) {
        if (mounted) {
          _showPermissionDeniedDialog();
        }
        return;
      }
    }

    _startDownload();
  }

  void _showPermissionDeniedDialog() {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.updatePermissionTitle,
            style: TextStyle(
                fontFamily: 'Cormorant', fontWeight: FontWeight.bold)),
        content: Text(
          loc.updatePermissionMessage,
          style: TextStyle(fontFamily: 'Cormorant'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.commonCancel,
                style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: Text(loc.updateOpenSettings,
                style: TextStyle(color: Theme.of(context).primaryColor)),
          ),
        ],
      ),
    );
  }

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _errorMessage = null;
      _progress = 0.0;
    });

    final service = UpdateService();

    final filePath = await service.downloadUpdate(
      widget.appVersion.downloadUrl,
      (progress) {
        if (mounted) {
          setState(() {
            _progress = progress;
          });
        }
      },
    );

    if (filePath != null) {
      await service.installUpdate(filePath);

      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _errorMessage = AppLocalizations.of(context)!.updateDownloadFailed;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Column(
        children: [
          Icon(Icons.system_update, color: Theme.of(context).primaryColor, size: 40),
          SizedBox(height: 10),
          Text(
            loc.updateAvailable,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cormorant',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            loc.updateVersion(widget.appVersion.version),
            style: TextStyle(
              fontFamily: 'Cormorant',
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
      content: Container(
        constraints: const BoxConstraints(maxHeight: 300),
        width: double.maxFinite,
        child: _isDownloading
            ? Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Text(loc.updateDownloading,
                      style: TextStyle(
                          fontFamily: 'Cormorant', fontSize: 16)),
                  SizedBox(height: 15),
                  LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    color: Theme.of(context).primaryColor,
                    minHeight: 6,
                  ),
                  SizedBox(height: 10),
                  Text("${(_progress * 100).toInt()}%",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_errorMessage != null)
                      Container(
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.only(bottom: 10),
                        width: double.infinity,
                        color: Theme.of(context).colorScheme.surface,
                        child: Text(
                          _errorMessage!,
                          style:
                              TextStyle(color: Theme.of(context).primaryColor, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    Text(
                      loc.updateChangelog,
                      style: TextStyle(
                        fontFamily: 'Cormorant',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 10),
                    MarkdownBody(
                      data: widget.appVersion.changelog,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          fontFamily: 'UbuntuMono',
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
      actions: _isDownloading
          ? []
          : [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  loc.updateLater,
                  style: TextStyle(
                    fontFamily: 'Cormorant',
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _checkPermissionAndStartDownload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Theme.of(context).colorScheme.surface,
                  elevation: 0,
                ),
                child: Text(
                  loc.updateInstall,
                  style: TextStyle(
                    fontFamily: 'Cormorant',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
    );
  }
}

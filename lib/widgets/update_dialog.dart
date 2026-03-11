// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../l10n/app_localizations.dart';
import '../models/app_version.dart';
import '../services/update_service.dart';

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
            style: const TextStyle(
                fontFamily: 'Cormorant', fontWeight: FontWeight.bold)),
        content: Text(
          loc.updatePermissionMessage,
          style: const TextStyle(fontFamily: 'Cormorant'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.commonCancel,
                style: const TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: Text(loc.updateOpenSettings,
                style: const TextStyle(color: Colors.red)),
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
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Column(
        children: [
          const Icon(Icons.system_update, color: Colors.red, size: 40),
          const SizedBox(height: 10),
          Text(
            loc.updateAvailable,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cormorant',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            loc.updateVersion(widget.appVersion.version),
            style: const TextStyle(
              fontFamily: 'Cormorant',
              fontSize: 16,
              color: Colors.grey,
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
                  const SizedBox(height: 20),
                  Text(loc.updateDownloading,
                      style: const TextStyle(
                          fontFamily: 'Cormorant', fontSize: 16)),
                  const SizedBox(height: 15),
                  LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.grey.shade200,
                    color: Colors.red,
                    minHeight: 6,
                  ),
                  const SizedBox(height: 10),
                  Text("${(_progress * 100).toInt()}%",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 10),
                        width: double.infinity,
                        color: Colors.white,
                        child: Text(
                          _errorMessage!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    Text(
                      loc.updateChangelog,
                      style: const TextStyle(
                        fontFamily: 'Cormorant',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.appVersion.changelog,
                      style: const TextStyle(
                        fontFamily: 'UbuntuMono',
                        fontSize: 14,
                        height: 1.4,
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
                  style: const TextStyle(
                    fontFamily: 'Cormorant',
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _checkPermissionAndStartDownload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                child: Text(
                  loc.updateInstall,
                  style: const TextStyle(
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

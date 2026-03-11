// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

class AppVersion {
  final String version;
  final String changelog;
  final String downloadUrl;

  AppVersion({
    required this.version,
    required this.changelog,
    required this.downloadUrl,
  });

  factory AppVersion.fromJson(Map<String, dynamic> json) {
    return AppVersion(
      version: json['version'] ?? '0.0.0',
      changelog: json['changelog'] ?? 'Pas de changelog disponible.',
      downloadUrl: json['url'] ?? '',
    );
  }
}
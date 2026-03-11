// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

class VersionService {
  static const Map<String, String> _versionNames = {
    '1.0': 'The Release',
    '1.1': 'The River Update',
    '1.2': 'The Stream Update',
  };
  static String getVersionCodename(String fullVersion) {
    if (fullVersion.isEmpty) {
      return '';
    }
    final parts = fullVersion.split('.').take(2);
    if (parts.length < 2) {
      return '';
    }
    final versionPrefix = parts.join('.');
    final codename = _versionNames[versionPrefix];
    return codename != null ? ' - "$codename"' : '';
  }
}

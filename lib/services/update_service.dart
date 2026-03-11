// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:io';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../models/app_version.dart';

class UpdateService {
  static const String githubLatestReleaseUrl =
      "https://api.github.com/repos/phi-k/chords/releases/latest";
  static const String _logName = 'UpdateService';

  Dio _getDio() {
    final dio = Dio();

    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);

    return dio;
  }

  Future<AppVersion?> checkForUpdate() async {
    if (!Platform.isAndroid) {
      developer.log(
          'Vérification de mise à jour ignorée : Plateforme non Android.',
          name: _logName);
      return null;
    }

    developer.log('Démarrage de la vérification de mise à jour...',
        name: _logName);

    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String localVersionStr = packageInfo.version.split('+')[0];
      List<int> localVersion = _parseVersion(localVersionStr);

      developer.log('Version locale détectée : $localVersionStr $localVersion',
          name: _logName);

      final dio = _getDio();
      final response = await dio.get(githubLatestReleaseUrl);

      developer.log('Réponse HTTP : ${response.statusCode}', name: _logName);

      if (response.statusCode == 200) {
        final data = response.data;

        String tagName = data['tag_name'] ?? '';
        if (tagName.startsWith('v')) tagName = tagName.substring(1);

        String latestVersionStr = tagName.split('+')[0];

        if (!_isNewer(latestVersionStr, localVersion)) {
          developer.log('L\'application est à jour.', name: _logName);
          return null;
        }

        developer.log('Une nouvelle version est disponible !', name: _logName);

        String downloadUrl = '';
        if (data['assets'] != null) {
          for (var asset in data['assets']) {
            String name = asset['name'].toString().toLowerCase();
            if (name.endsWith('.apk')) {
              downloadUrl = asset['browser_download_url'];
              break;
            }
          }
        }

        if (downloadUrl.isEmpty) return null;

        return AppVersion(
          version: latestVersionStr,
          changelog: data['body'] ?? '',
          downloadUrl: downloadUrl,
        );
      }
    } catch (e, stackTrace) {
      developer.log('Exception critique dans checkForUpdate',
          name: _logName, error: e, stackTrace: stackTrace);
    }
    return null;
  }

  Future<String?> downloadUpdate(
      String url, Function(double) onProgress) async {
    if (!Platform.isAndroid) return null;

    developer.log('Démarrage du téléchargement depuis : $url', name: _logName);
    try {
      final dir = await getTemporaryDirectory();
      final String savePath = "${dir.path}/chords_update.apk";

      final file = File(savePath);
      if (await file.exists()) {
        await file.delete();
      }

      final dio = _getDio();

      await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
      );

      developer.log('Téléchargement terminé.', name: _logName);
      return savePath;
    } catch (e, stackTrace) {
      developer.log('Erreur lors du téléchargement',
          name: _logName, error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<String?> getChangelogForVersion(String targetVersion) async {
    try {
      final releases = await getAllReleases();
      final matchingRelease = releases.cast<Map<String, String>?>().firstWhere(
            (release) => release!['version'] == targetVersion,
            orElse: () => null,
          );

      if (matchingRelease != null) {
        return matchingRelease['changelog'];
      }
    } catch (e) {
      developer.log('Erreur lors de la récupération du changelog : $e',
          name: _logName);
    }
    return null;
  }

  Future<void> installUpdate(String filePath) async {
    if (!Platform.isAndroid) return;

    if (await File(filePath).exists()) {
      await OpenFilex.open(filePath);
    }
  }

  Future<List<Map<String, String>>> getAllReleases() async {
    try {
      final dio = _getDio();
      final response =
          await dio.get("https://api.github.com/repos/phi-k/chords/releases");

      if (response.statusCode == 200) {
        final List<dynamic> releases = response.data;
        return releases.map<Map<String, String>>((release) {
          String tagName = release['tag_name'] ?? '';
          if (tagName.startsWith('v')) tagName = tagName.substring(1);

          return {
            'version': tagName,
            'changelog': release['body'] ?? '',
          };
        }).toList();
      }
    } catch (e) {
      developer.log('Erreur lors de la récupération des releases : $e',
          name: _logName);
    }
    return [];
  }

  List<int> _parseVersion(String version) {
    try {
      return version.split('.').map((e) {
        if (e.contains('+')) return int.parse(e.split('+')[0]);
        return int.tryParse(e) ?? 0;
      }).toList();
    } catch (e) {
      return [0, 0, 0];
    }
  }

  bool _isNewer(String remoteStr, List<int> local) {
    List<int> remote = _parseVersion(remoteStr);
    for (int i = 0; i < remote.length; i++) {
      if (i >= local.length) return true;
      if (remote[i] > local[i]) return true;
      if (remote[i] < local[i]) return false;
    }
    return false;
  }
}

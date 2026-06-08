// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';
import 'dart:io';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/tab_source.dart';
import '../utils/string_normalization.dart';
import 'source_manager.dart';

class SongService {
  static final Map<String, List<dynamic>> _memoryCache = {};

  static String _normalizeBaseUrl(String url) {
    String trimmed = url.trim();
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      return 'https://$trimmed';
    }
    return trimmed;
  }

  static dynamic _extractNestedValue(dynamic json, String path) {
    if (path.isEmpty || json == null) return json;
    List<String> keys = path.split('.');
    dynamic current = json;
    for (String key in keys) {
      if (current is Map && current.containsKey(key)) {
        current = current[key];
      } else {
        return null;
      }
    }
    return current;
  }

  static Future<File> _resolveStaticCacheFile(TabSource source) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/${source.id}_static_source.json');
  }

  static Future<void> cacheStaticSource(TabSource source,
      {bool force = false}) async {
    if (!source.isStaticJson) return;

    try {
      final file = await _resolveStaticCacheFile(source);
      if (await file.exists() && !force) return;

      dev.log('📦 Téléchargement du JSON statique: ${source.name}',
          name: 'SongService');
      final response =
          await http.get(Uri.parse(source.baseUrl), headers: source.headers);
      if (response.statusCode == 200) {
        await file.writeAsString(response.body);
        _memoryCache.remove(source.id);
        dev.log('✅ JSON statique mis en cache: ${file.path}',
            name: 'SongService');
      } else {
        dev.log('⚠️ Cache statique non téléchargé (${response.statusCode})',
            name: 'SongService');
      }
    } catch (e) {
      dev.log('⚠️ Erreur cache JSON statique: $e', name: 'SongService');
    }
  }

  static Future<void> updateStaticSourcesInBackground() async {
    try {
      final sources = await SourceManager.getActiveSources();
      for (final source in sources.where((s) => s.isStaticJson)) {
        dev.log('🔄 Mise à jour en arrière-plan de la source : ${source.name}',
            name: 'SongService');
        await cacheStaticSource(source, force: true);
      }
    } catch (e) {
      dev.log('Erreur lors de la mise à jour en arrière-plan : $e',
          name: 'SongService');
    }
  }

  static Future<List<dynamic>> _loadStaticJsonData(TabSource source) async {
    if (_memoryCache.containsKey(source.id)) {
      return _memoryCache[source.id]!;
    }

    final file = await _resolveStaticCacheFile(source);
    if (!await file.exists()) {
      await cacheStaticSource(source);
    }

    if (!await file.exists()) return [];

    final content = await file.readAsString();
    if (content.isEmpty) return [];

    final decoded = await compute(jsonDecode, content);
    List<dynamic> resultList;
    if (decoded is List) {
      resultList = decoded;
    } else if (source.listPath.isNotEmpty) {
      final nested = _extractNestedValue(decoded, source.listPath);
      resultList = nested is List ? nested : [decoded];
    } else {
      resultList = [decoded];
    }

    _memoryCache[source.id] = resultList;
    return resultList;
  }

  static Future<List<Map<String, dynamic>>> searchStaticSource(
      TabSource source, String query) async {
    final data = await _loadStaticJsonData(source);
    final cleanQuery = normalizeString(query);

    final filtered = data
        .where((item) {
          final title = normalizeString(
              (_extractNestedValue(item, source.titlePath) ?? '').toString());
          final artist = normalizeString(
              (_extractNestedValue(item, source.artistPath) ?? '').toString());
          return title.contains(cleanQuery) || artist.contains(cleanQuery);
        })
        .take(50)
        .toList();

    return filtered.map((r) {
      return <String, dynamic>{
        'artist':
            _extractNestedValue(r, source.artistPath)?.toString() ?? 'Inconnu',
        'title': _extractNestedValue(r, source.titlePath)?.toString() ??
            'Sans titre',
        'type': _extractNestedValue(r, source.typePath)?.toString() ?? 'Chords',
        'song_url': _extractNestedValue(r, source.urlPath)?.toString() ?? '',
        'votes': _extractNestedValue(r, source.votesPath)?.toString() ?? '0',
        'rating':
            _extractNestedValue(r, source.ratingPath)?.toString() ?? '0.0',
        'album_cover':
            _extractNestedValue(r, source.albumCoverPath)?.toString() ?? '',
        'artist_cover':
            _extractNestedValue(r, source.artistCoverPath)?.toString() ?? '',
        'source_name': source.name,
        'source_id': source.id,
      };
    }).toList();
  }

  static Future<List<Map<String, dynamic>>> getAllStaticSongs(TabSource source) async {
    final data = await _loadStaticJsonData(source);
    return data.map((r) {
      return <String, dynamic>{
        'artist': _extractNestedValue(r, source.artistPath)?.toString() ?? 'Inconnu',
        'title': _extractNestedValue(r, source.titlePath)?.toString() ?? 'Sans titre',
        'type': _extractNestedValue(r, source.typePath)?.toString() ?? 'Chords',
        'song_url': _extractNestedValue(r, source.urlPath)?.toString() ?? '',
        'votes': _extractNestedValue(r, source.votesPath)?.toString() ?? '0',
        'rating': _extractNestedValue(r, source.ratingPath)?.toString() ?? '0.0',
        'album_cover': _extractNestedValue(r, source.albumCoverPath)?.toString() ?? '',
        'source_name': source.name,
        'source_id': source.id,
      };
    }).toList();
  }


  static Future<List<Map<String, dynamic>>> searchSongs(String query) async {
    final sources = await SourceManager.getActiveSources();
    if (sources.isEmpty) throw Exception("Aucune source configurée.");

    final List<Map<String, dynamic>> allResults = [];

    for (final source in sources) {
      try {
        final results = await _searchFromSource(source, query);
        allResults.addAll(results);
        dev.log('✅ ${results.length} résultats de "${source.name}"',
            name: 'SongService');
      } catch (e) {
        dev.log('⚠️ Erreur sur la source "${source.name}": $e',
            name: 'SongService');
      }
    }

    return allResults;
  }

  static Future<List<Map<String, dynamic>>> _searchFromSource(
      TabSource source, String query) async {
    if (source.isStaticJson) {
      return searchStaticSource(source, query);
    }

    final baseUrl = _normalizeBaseUrl(source.baseUrl);
    final cleanQuery = Uri.encodeComponent(query.replaceAll(' ', '*'));
    final rawUrl = '$baseUrl${source.searchPath}';
    final url = rawUrl.replaceAll('{query}', cleanQuery);

    dev.log('📡 Search Request[${source.name}]: $url', name: 'SongService');

    final response = await http.get(Uri.parse(url), headers: source.headers);

    if (response.statusCode == 200) {
      final dynamic decoded = json.decode(response.body);
      final List<dynamic> results = source.listPath.isEmpty
          ? (decoded is List ? decoded : [decoded])
          : _extractNestedValue(decoded, source.listPath) ?? [];

      final mappedResults = results.map((r) {
        return <String, dynamic>{
          "artist": _extractNestedValue(r, source.artistPath)?.toString() ??
              "Inconnu",
          "title": _extractNestedValue(r, source.titlePath)?.toString() ??
              "Sans titre",
          "type":
              _extractNestedValue(r, source.typePath)?.toString() ?? "Chords",
          "song_url": _extractNestedValue(r, source.urlPath)?.toString() ?? "",
          "votes": _extractNestedValue(r, source.votesPath)?.toString() ?? "0",
          "rating":
              _extractNestedValue(r, source.ratingPath)?.toString() ?? "0.0",
          "album_cover":
              _extractNestedValue(r, source.albumCoverPath)?.toString() ?? "",
          "artist_cover":
              _extractNestedValue(r, source.artistCoverPath)?.toString() ?? "",
          "source_name": source.name,
          "source_id": source.id,
        };
      }).toList();

      return mappedResults;
    } else {
      throw Exception("Erreur API HTTP ${response.statusCode}");
    }
  }

  static Future<Map<String, dynamic>?> fetchSongDetails(String urlParam,
      {String? sourceId}) async {
    if (urlParam.isEmpty) return null;

    TabSource? source;
    if (sourceId != null && sourceId.isNotEmpty) {
      final sources = await SourceManager.getSources();
      try {
        source = sources.firstWhere((s) => s.id == sourceId);
      } catch (_) {
        source = await SourceManager.getActiveSource();
      }
    } else {
      source = await SourceManager.getActiveSource();
    }
    if (source == null) return null;

    if (source.isStaticJson) {
      return fetchStaticSourceDetails(source, urlParam);
    }

    final baseUrl = _normalizeBaseUrl(source.baseUrl);
    final encodedUrl = Uri.encodeComponent(urlParam);
    final rawUrl = '$baseUrl${source.detailsPath}';
    final url = rawUrl.replaceAll('{url}', encodedUrl);

    dev.log('📡 Details Request: $url', name: 'SongService');

    try {
      final response = await http.get(Uri.parse(url), headers: source.headers);
      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);

        final item =
            (decoded is List && decoded.isNotEmpty) ? decoded[0] : decoded;

        String content =
            _extractNestedValue(item, source.contentPath)?.toString() ??
                "Contenu indisponible";
        content = content.replaceAll(RegExp(r'\[/?tab\]'), '').trim();

        return {
          "artist": _extractNestedValue(item, source.artistPath)?.toString() ??
              'Inconnu',
          "title": _extractNestedValue(item, source.titlePath)?.toString() ??
              'Titre inconnu',
          "difficulty":
              _extractNestedValue(item, source.difficultyPath)?.toString() ??
                  'N/A',
          "capo":
              _extractNestedValue(item, source.capoPath)?.toString() ?? 'Aucun',
          "tuning": _extractNestedValue(item, source.tuningPath)?.toString() ??
              'Standard',
          "tonality":
              _extractNestedValue(item, source.tonalityPath)?.toString() ?? '',
          "votes":
              _extractNestedValue(item, source.votesPath)?.toString() ?? '0',
          "rating":
              _extractNestedValue(item, source.ratingPath)?.toString() ?? '0.0',
          "album_cover":
              _extractNestedValue(item, source.albumCoverPath)?.toString() ??
                  '',
          "artist_cover":
              _extractNestedValue(item, source.artistCoverPath)?.toString() ??
                  '',
          "chords_dict": jsonEncode(
              _extractNestedValue(item, source.chordsDictPath) ?? {}),
          "versions":
              jsonEncode(_extractNestedValue(item, source.versionsPath) ?? []),
          "top_tabs": jsonEncode(
              _extractNestedValue(item, source.artistTopTabsPath) ?? []),
          "lyrics_with_chords": content,
          "source_link": urlParam,
        };
      }
    } catch (e) {
      dev.log('❌ Details Error: $e', name: 'SongService');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> fetchStaticSourceDetails(
      TabSource source, String urlParam) async {
    try {
      final data = await _loadStaticJsonData(source);
      dynamic item;
      for (final candidate in data) {
        final candidateUrl =
            _extractNestedValue(candidate, source.urlPath)?.toString() ?? '';
        if (candidateUrl == urlParam) {
          item = candidate;
          break;
        }
      }
      if (item == null) return null;

      String content =
          _extractNestedValue(item, source.contentPath)?.toString() ??
              'Contenu indisponible';
      content = content.replaceAll(RegExp(r'\[/?tab\]'), '').trim();

      return {
        'artist': _extractNestedValue(item, source.artistPath)?.toString() ??
            'Inconnu',
        'title': _extractNestedValue(item, source.titlePath)?.toString() ??
            'Titre inconnu',
        'difficulty':
            _extractNestedValue(item, source.difficultyPath)?.toString() ??
                'N/A',
        'capo':
            _extractNestedValue(item, source.capoPath)?.toString() ?? 'Aucun',
        'tuning': _extractNestedValue(item, source.tuningPath)?.toString() ??
            'Standard',
        'tonality':
            _extractNestedValue(item, source.tonalityPath)?.toString() ?? '',
        'votes': _extractNestedValue(item, source.votesPath)?.toString() ?? '0',
        'rating':
            _extractNestedValue(item, source.ratingPath)?.toString() ?? '0.0',
        'album_cover':
            _extractNestedValue(item, source.albumCoverPath)?.toString() ?? '',
        'artist_cover':
            _extractNestedValue(item, source.artistCoverPath)?.toString() ?? '',
        'chords_dict':
            jsonEncode(_extractNestedValue(item, source.chordsDictPath) ?? {}),
        'versions':
            jsonEncode(_extractNestedValue(item, source.versionsPath) ?? []),
        'top_tabs': jsonEncode(
            _extractNestedValue(item, source.artistTopTabsPath) ?? []),
        'lyrics_with_chords': content,
        'source_link': urlParam,
      };
    } catch (e) {
      dev.log('❌ Details static Error: $e', name: 'SongService');
      return null;
    }
  }
}

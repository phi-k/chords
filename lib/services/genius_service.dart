// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

const geniusBaseUrl = "https://api.genius.com/";
const geniusSearchUrl = "${geniusBaseUrl}search/";

class GeniusService {
  static Future<List<Map<String, dynamic>>> searchSongs(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final String? geniusToken = prefs.getString('genius_key');

    if (geniusToken == null || geniusToken.isEmpty) {
      log("Info: Clé API Genius non configurée.");
      return [];
    }

    try {
      final dio = Dio();
      final searchUrl = "$geniusSearchUrl?q=$query&access_token=$geniusToken";
      final response = await dio.get(searchUrl);
      final hits = response.data['response']['hits'];
      return hits.map<Map<String, dynamic>>((hit) {
        final song = hit['result'];
        return {
          'title': song['title'],
          'artist': song['primary_artist']['name'],
          'coverUrl': song['song_art_image_url'],
          'songId': song['id'],
        };
      }).toList();
    } catch (e) {
      log("Erreur lors de la recherche : $e");
      return [];
    }
  }

  static Future<String?> fetchCoverUrl(String title, String artist) async {
    final query = "$title $artist";
    final results = await searchSongs(query);
    if (results.isNotEmpty) {
      return results.first['coverUrl'];
    }
    return null;
  }
}

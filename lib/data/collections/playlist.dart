// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:isar/isar.dart';
import 'song.dart';

part 'playlist.g.dart';

@Collection()
class Playlist {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  String? name;
  DateTime? createdAt;
  DateTime? lastModified;

  final songs = IsarLinks<Song>();

  List<int>? songOrder;
  String? coverUrl;

  List<Song> getOrderedSongs() {
    try {
      final loadedSongs = songs.toList();
      if (songOrder == null || songOrder!.isEmpty) {
        return loadedSongs;
      }
      final Map<int, int> orderMap = {
        for (int i = 0; i < songOrder!.length; i++) songOrder![i]: i
      };
      loadedSongs.sort((a, b) {
        final indexA = orderMap[a.id];
        final indexB = orderMap[b.id];
        if (indexA != null && indexB != null) {
          return indexA.compareTo(indexB);
        }
        if (indexA != null) return -1;
        if (indexB != null) return 1;
        return a.id.compareTo(b.id);
      });
      return loadedSongs;
    } catch (e, s) {
      print("[PLAYLIST_LOG] Error in getOrderedSongs: $e\n$s");
      rethrow;
    }
  }
}

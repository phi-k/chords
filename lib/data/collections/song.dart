// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:isar/isar.dart';

part 'song.g.dart';

@Collection()
class Song {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String songUrl;

  String? title;
  String? artist;
  String? difficulty;
  String? capo;
  String? tuning;
  String? lyricsWithChords;
  String? originalLyricsWithChords;
  int transpose = 0;
  bool simplified = false;
  DateTime? addedDate;
  DateTime? savedDate;
  int playCount = 0;
  DateTime? lastPlayed;
  List<String> playHistory = const [];
  String? coverUrl;
  List<String> tags = const [];

  Song({
    this.songUrl = '',
    this.title,
    this.artist,
    this.difficulty,
    this.capo,
    this.tuning,
    this.lyricsWithChords,
    this.originalLyricsWithChords,
    this.transpose = 0,
    this.simplified = false,
    this.addedDate,
    this.savedDate,
    this.playCount = 0,
    this.lastPlayed,
    this.playHistory = const [],
    this.coverUrl,
    this.tags = const [],
  });

  factory Song.fromMap(Map<String, dynamic> map) {
    String? originalTitle = map['title'];
    String? cleanTitle = originalTitle
        ?.replaceAll(
        RegExp(r'\s*\((ver|version)\s*\d+\)', caseSensitive: false), '')
        .trim();

    return Song(
      songUrl: map['songUrl'] ?? '',
      title: cleanTitle,
      artist: map['artist'],
      difficulty: map['difficulty'],
      capo: map['capo'],
      tuning: map['tuning'],
      lyricsWithChords: map['lyrics_with_chords'],
      originalLyricsWithChords: map['original_lyrics_with_chords'],
      transpose: map['transpose'] ?? 0,
      simplified: map['simplified'] ?? false,
      addedDate:
      map['addedDate'] != null ? DateTime.tryParse(map['addedDate']) : null,
      savedDate:
      map['savedDate'] != null ? DateTime.tryParse(map['savedDate']) : null,
      playCount: map['playCount'] ?? 0,
      lastPlayed: map['lastPlayed'] != null
          ? DateTime.tryParse(map['lastPlayed'])
          : null,
      playHistory: List<String>.from(map['playHistory'] ?? []),
      coverUrl: map['coverUrl'],
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'songUrl': songUrl,
      'title': title,
      'artist': artist,
      'difficulty': difficulty,
      'capo': capo,
      'tuning': tuning,
      'lyrics_with_chords': lyricsWithChords,
      'original_lyrics_with_chords': originalLyricsWithChords,
      'transpose': transpose,
      'simplified': simplified,
      'addedDate': addedDate?.toIso8601String(),
      'savedDate': savedDate?.toIso8601String(),
      'playCount': playCount,
      'lastPlayed': lastPlayed?.toIso8601String(),
      'playHistory': playHistory,
      'coverUrl': coverUrl,
      'tags': tags,
    };
  }
}
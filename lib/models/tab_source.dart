// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';
import 'package:uuid/uuid.dart';

class TabSource {
  final String id;
  final String name;
  final String baseUrl;

  // Endpoints
  final String searchPath;
  final String detailsPath;

  final String listPath;
  final String titlePath;
  final String artistPath;
  final String urlPath;
  final String typePath;

  final String votesPath;
  final String ratingPath;
  final String albumCoverPath;
  final String artistCoverPath;

  final String contentPath;
  final String capoPath;
  final String tuningPath;
  final String difficultyPath;
  final String tonalityPath;

  final String chordsDictPath;
  final String versionsPath;
  final String artistTopTabsPath;

  final Map<String, String> headers;
  final bool isActive;

  TabSource({
    String? id,
    required this.name,
    required this.baseUrl,
    this.searchPath =
        '/songs?select=id,artist,title,type,song_url,votes,rating&or=(title.ilike.*{query}*,artist.ilike.*{query}*)&order=votes.desc.nullslast&limit=50',
    this.detailsPath = '/songs?song_url=eq.{url}',
    this.listPath = '',
    this.titlePath = 'title',
    this.artistPath = 'artist',
    this.urlPath = 'song_url',
    this.typePath = 'type',
    this.votesPath = 'votes',
    this.ratingPath = 'rating',
    this.albumCoverPath = 'album_cover',
    this.artistCoverPath = 'artist_cover',
    this.contentPath = 'content',
    this.capoPath = 'capo',
    this.tuningPath = 'tuning',
    this.difficultyPath = 'difficulty',
    this.tonalityPath = 'tonality',
    this.chordsDictPath = 'chords_dict',
    this.versionsPath = 'versions',
    this.artistTopTabsPath = 'top_tabs',
    this.headers = const {},
    this.isActive = false,
  }) : id = id ?? const Uuid().v4();

  TabSource copyWith({
    String? name,
    String? baseUrl,
    String? searchPath,
    String? detailsPath,
    String? listPath,
    String? titlePath,
    String? artistPath,
    String? urlPath,
    String? typePath,
    String? votesPath,
    String? ratingPath,
    String? albumCoverPath,
    String? artistCoverPath,
    String? contentPath,
    String? capoPath,
    String? tuningPath,
    String? difficultyPath,
    String? tonalityPath,
    String? chordsDictPath,
    String? versionsPath,
    String? artistTopTabsPath,
    Map<String, String>? headers,
    bool? isActive,
  }) {
    return TabSource(
      id: id,
      name: name ?? this.name,
      baseUrl: baseUrl ?? this.baseUrl,
      searchPath: searchPath ?? this.searchPath,
      detailsPath: detailsPath ?? this.detailsPath,
      listPath: listPath ?? this.listPath,
      titlePath: titlePath ?? this.titlePath,
      artistPath: artistPath ?? this.artistPath,
      urlPath: urlPath ?? this.urlPath,
      typePath: typePath ?? this.typePath,
      votesPath: votesPath ?? this.votesPath,
      ratingPath: ratingPath ?? this.ratingPath,
      albumCoverPath: albumCoverPath ?? this.albumCoverPath,
      artistCoverPath: artistCoverPath ?? this.artistCoverPath,
      contentPath: contentPath ?? this.contentPath,
      capoPath: capoPath ?? this.capoPath,
      tuningPath: tuningPath ?? this.tuningPath,
      difficultyPath: difficultyPath ?? this.difficultyPath,
      tonalityPath: tonalityPath ?? this.tonalityPath,
      chordsDictPath: chordsDictPath ?? this.chordsDictPath,
      versionsPath: versionsPath ?? this.versionsPath,
      artistTopTabsPath: artistTopTabsPath ?? this.artistTopTabsPath,
      headers: headers ?? this.headers,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'baseUrl': baseUrl,
      'searchPath': searchPath,
      'detailsPath': detailsPath,
      'listPath': listPath,
      'titlePath': titlePath,
      'artistPath': artistPath,
      'urlPath': urlPath,
      'typePath': typePath,
      'votesPath': votesPath,
      'ratingPath': ratingPath,
      'albumCoverPath': albumCoverPath,
      'artistCoverPath': artistCoverPath,
      'contentPath': contentPath,
      'capoPath': capoPath,
      'tuningPath': tuningPath,
      'difficultyPath': difficultyPath,
      'tonalityPath': tonalityPath,
      'chordsDictPath': chordsDictPath,
      'versionsPath': versionsPath,
      'artistTopTabsPath': artistTopTabsPath,
      'headers': headers,
      'isActive': isActive,
    };
  }

  factory TabSource.fromMap(Map<String, dynamic> map) {
    return TabSource(
      id: map['id'],
      name: map['name'] ?? '',
      baseUrl: map['baseUrl'] ?? '',
      searchPath: map['searchPath'] ?? '',
      detailsPath: map['detailsPath'] ?? '',
      listPath: map['listPath'] ?? '',
      titlePath: map['titlePath'] ?? 'title',
      artistPath: map['artistPath'] ?? 'artist',
      urlPath: map['urlPath'] ?? 'url',
      typePath: map['typePath'] ?? 'type',
      votesPath: map['votesPath'] ?? '',
      ratingPath: map['ratingPath'] ?? '',
      albumCoverPath: map['albumCoverPath'] ?? '',
      artistCoverPath: map['artistCoverPath'] ?? '',
      contentPath: map['contentPath'] ?? 'content',
      capoPath: map['capoPath'] ?? 'capo',
      tuningPath: map['tuningPath'] ?? 'tuning',
      difficultyPath: map['difficultyPath'] ?? 'difficulty',
      tonalityPath: map['tonalityPath'] ?? '',
      chordsDictPath: map['chordsDictPath'] ?? '',
      versionsPath: map['versionsPath'] ?? '',
      artistTopTabsPath: map['artistTopTabsPath'] ?? '',
      headers: Map<String, String>.from(map['headers'] ?? {}),
      isActive: map['isActive'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory TabSource.fromJson(String source) =>
      TabSource.fromMap(json.decode(source));
}

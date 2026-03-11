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
}

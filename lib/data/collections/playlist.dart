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

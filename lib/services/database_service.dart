import 'package:isar/isar.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../data/collections/song.dart';
import '../data/collections/playlist.dart';
import 'genius_service.dart';

class DatabaseService {
  final Isar isar;

  DatabaseService(this.isar);

  Future<List<Song>> getSavedSongs() async {
    return await isar.songs.where().findAll();
  }

  Stream<List<Song>> watchSongs({
    String filterText = '',
    Sort titleSort = Sort.asc,
  }) {
    var query = isar.songs.filter().group((q) {
      return q
          .titleContains(filterText, caseSensitive: false)
          .or()
          .artistContains(filterText, caseSensitive: false);
    });

    if (titleSort == Sort.asc) {
      return query.sortByTitle().watch(fireImmediately: true);
    } else {
      return query.sortByTitleDesc().watch(fireImmediately: true);
    }
  }

  Stream<List<Song>> watchSongsByArtist(String artistName) {
    return isar.songs
        .filter()
        .artistEqualTo(artistName)
        .sortByTitle()
        .watch(fireImmediately: true);
  }

  Stream<List<Song>> watchRecentSongs({bool reversed = false}) {
    QueryBuilder<Song, Song, QAfterSortBy> query;
    if (reversed) {
      query = isar.songs.where().sortByLastPlayed();
    } else {
      query = isar.songs.where().sortByLastPlayedDesc();
    }
    return query.watch(fireImmediately: true);
  }

  Future<bool> isSongSaved(String songUrl) async {
    final song = await isar.songs.getBySongUrl(songUrl);
    return song != null;
  }

  Future<void> updateSong(Song updatedSong) async {
    await isar.writeTxn(() async {
      await isar.songs.put(updatedSong);
    });
  }

  Future<void> deleteSong(String songUrl) async {
    await isar.writeTxn(() async {
      await isar.songs.deleteBySongUrl(songUrl);
    });
  }

  Future<bool> toggleSong(Map<String, dynamic> songData) async {
    final existingSong = await isar.songs.getBySongUrl(songData['songUrl']);

    if (existingSong != null) {
      await isar.writeTxn(() async {
        await isar.songs.delete(existingSong.id);
      });
      return false;
    } else {
      final DateTime now = DateTime.now();
      final String formattedDate = DateFormat('yyyy-MM-dd').format(now);
      final String? coverUrl = await GeniusService.fetchCoverUrl(
          songData['title'], songData['artist']);

      final newSong = Song.fromMap(songData)
        ..addedDate = now
        ..savedDate = now
        ..playCount = 1
        ..playHistory = [formattedDate]
        ..lastPlayed = now
        ..coverUrl = coverUrl ?? "";

      await isar.writeTxn(() async {
        await isar.songs.put(newSong);
      });
      return true;
    }
  }

  Future<void> incrementPlayCount(String songUrl) async {
    await isar.writeTxn(() async {
      final song = await isar.songs.getBySongUrl(songUrl);
      if (song != null) {
        final DateTime now = DateTime.now();
        final String formattedDate = DateFormat('yyyy-MM-dd').format(now);

        song.playCount += 1;
        song.lastPlayed = now;
        song.playHistory = [...song.playHistory, formattedDate];

        await isar.songs.put(song);
      }
    });
  }

  Future<List<Playlist>> getPlaylists() async {
    return await isar.playlists.where().findAll();
  }

  Stream<List<Playlist>> watchPlaylists() {
    return isar.playlists.where().watch(fireImmediately: true);
  }

  Stream<Playlist?> watchPlaylist(int id) {
    return isar.playlists.watchObject(id, fireImmediately: true);
  }

  Future<Playlist> createPlaylist(String name) async {
    const uuid = Uuid();
    final newPlaylist = Playlist()
      ..name = name
      ..uuid = uuid.v4()
      ..createdAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.playlists.put(newPlaylist);
    });
    return newPlaylist;
  }

  Future<void> updatePlaylist(Playlist updatedPlaylist) async {
    await isar.writeTxn(() async {
      updatedPlaylist.lastModified = DateTime.now();
      await isar.playlists.put(updatedPlaylist);
      await updatedPlaylist.songs.save();
    });
  }

  Future<void> deletePlaylist(int playlistId) async {
    await isar.writeTxn(() async {
      await isar.playlists.delete(playlistId);
    });
  }

  Future<List<Song>> getSongsByIds(List<Id> ids) async {
    return await isar.songs
        .getAll(ids)
        .then((songs) => songs.whereType<Song>().toList());
  }
}
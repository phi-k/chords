// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/collections/playlist.dart';
import '../../data/collections/song.dart';
import '../../models/bottom_bar_model.dart';
import '../../services/export_service.dart';
import 'song_provider.dart';

final playlistsProvider = FutureProvider<List<Playlist>>((ref) async {
  return ref.watch(databaseServiceProvider).getPlaylists();
});

@immutable
class ExportOptionsState {
  final String displayChoice;
  final String exportFormat;
  final bool isLoading;

  final bool withStats;
  final String songSelection;
  final String songSortOrder;

  final bool showArtistSongCount;
  final bool withArtistStats;
  final String artistSortOrder;
  final String artistSelection;

  final bool filterByPlaylist;
  final String? selectedPlaylistId;
  final bool filterByPlayCount;
  final String playCountCondition;
  final String playCountValue;
  final bool filterByLastPlayed;
  final DateTime? selectedDate;
  final String lastPlayedCondition;
  final bool filterByTags;
  final Set<String> selectedTags;
  final Set<String> allTags;

  const ExportOptionsState({
    this.displayChoice = 'both',
    this.exportFormat = 'txt',
    this.isLoading = false,
    this.withStats = false,
    this.songSelection = 'all',
    this.songSortOrder = 'alpha',
    this.showArtistSongCount = false,
    this.withArtistStats = false,
    this.artistSortOrder = 'alpha',
    this.artistSelection = 'all',
    this.filterByPlaylist = false,
    this.selectedPlaylistId,
    this.filterByPlayCount = false,
    this.playCountCondition = 'greater',
    this.playCountValue = '',
    this.filterByLastPlayed = false,
    this.selectedDate,
    this.lastPlayedCondition = 'since',
    this.filterByTags = false,
    this.selectedTags = const {},
    this.allTags = const {},
  });

  ExportOptionsState copyWith({
    String? displayChoice,
    String? exportFormat,
    bool? isLoading,
    bool? withStats,
    String? songSelection,
    String? songSortOrder,
    bool? showArtistSongCount,
    bool? withArtistStats,
    String? artistSortOrder,
    String? artistSelection,
    bool? filterByPlaylist,
    String? selectedPlaylistId,
    bool? filterByPlayCount,
    String? playCountCondition,
    String? playCountValue,
    bool? filterByLastPlayed,
    DateTime? selectedDate,
    String? lastPlayedCondition,
    bool? filterByTags,
    Set<String>? selectedTags,
    Set<String>? allTags,
  }) {
    return ExportOptionsState(
      displayChoice: displayChoice ?? this.displayChoice,
      exportFormat: exportFormat ?? this.exportFormat,
      isLoading: isLoading ?? this.isLoading,
      withStats: withStats ?? this.withStats,
      songSelection: songSelection ?? this.songSelection,
      songSortOrder: songSortOrder ?? this.songSortOrder,
      showArtistSongCount: showArtistSongCount ?? this.showArtistSongCount,
      withArtistStats: withArtistStats ?? this.withArtistStats,
      artistSortOrder: artistSortOrder ?? this.artistSortOrder,
      artistSelection: artistSelection ?? this.artistSelection,
      filterByPlaylist: filterByPlaylist ?? this.filterByPlaylist,
      selectedPlaylistId: selectedPlaylistId ?? this.selectedPlaylistId,
      filterByPlayCount: filterByPlayCount ?? this.filterByPlayCount,
      playCountCondition: playCountCondition ?? this.playCountCondition,
      playCountValue: playCountValue ?? this.playCountValue,
      filterByLastPlayed: filterByLastPlayed ?? this.filterByLastPlayed,
      selectedDate: selectedDate ?? this.selectedDate,
      lastPlayedCondition: lastPlayedCondition ?? this.lastPlayedCondition,
      filterByTags: filterByTags ?? this.filterByTags,
      selectedTags: selectedTags ?? this.selectedTags,
      allTags: allTags ?? this.allTags,
    );
  }
}

class ExportOptionsNotifier extends Notifier<ExportOptionsState> {
  @override
  ExportOptionsState build() {
    return const ExportOptionsState();
  }

  void setDisplayChoice(String value) =>
      state = state.copyWith(displayChoice: value);
  void setExportFormat(String value) =>
      state = state.copyWith(exportFormat: value);
  void setWithStats(bool value) => state = state.copyWith(withStats: value);
  void setSongSelection(String value) =>
      state = state.copyWith(songSelection: value);
  void setSongSortOrder(String value) =>
      state = state.copyWith(songSortOrder: value);
  void setShowArtistSongCount(bool value) =>
      state = state.copyWith(showArtistSongCount: value);
  void setWithArtistStats(bool value) =>
      state = state.copyWith(withArtistStats: value);
  void setArtistSortOrder(String value) =>
      state = state.copyWith(artistSortOrder: value);
  void setArtistSelection(String value) =>
      state = state.copyWith(artistSelection: value);

  void setFilterByPlaylist(bool value) {
    if (!value) {
      state = state.copyWith(filterByPlaylist: value, selectedPlaylistId: null);
    } else {
      state = state.copyWith(filterByPlaylist: value);
    }
  }

  void setSelectedPlaylist(String? playlistId) =>
      state = state.copyWith(selectedPlaylistId: playlistId);
  void setFilterByPlayCount(bool value) =>
      state = state.copyWith(filterByPlayCount: value);
  void setPlayCountCondition(String value) =>
      state = state.copyWith(playCountCondition: value);
  void setPlayCountValue(String value) =>
      state = state.copyWith(playCountValue: value);
  void setFilterByLastPlayed(bool value) =>
      state = state.copyWith(filterByLastPlayed: value);
  void setSelectedDate(DateTime? value) =>
      state = state.copyWith(selectedDate: value);
  void setLastPlayedCondition(String value) =>
      state = state.copyWith(lastPlayedCondition: value);
  void setFilterByTags(bool value) =>
      state = state.copyWith(filterByTags: value);
  void toggleTagSelection(String tag) {
    final newTags = Set<String>.from(state.selectedTags);
    if (newTags.contains(tag)) {
      newTags.remove(tag);
    } else {
      newTags.add(tag);
    }
    state = state.copyWith(selectedTags: newTags);
  }

  void updateAllTags(List<Song> songs) {
    final tags = <String>{};
    for (var song in songs) {
      tags.addAll(song.tags);
    }
    if (tags.length != state.allTags.length ||
        !state.allTags.containsAll(tags)) {
      state = state.copyWith(allTags: tags);
    }
  }

  Future<void> export(BuildContext context, List<Song> allSongs) async {
    state = state.copyWith(isLoading: true);
    try {
      final buffer = StringBuffer();
      buffer.writeln(
          "Export réalisé le ${DateFormat('dd/MM/yyyy HH:mm', 'fr_FR').format(DateTime.now())}");

      List<Song> songsToProcess = List.from(allSongs);

      if (state.songSelection == 'filtered') {
        if (state.filterByPlaylist && state.selectedPlaylistId != null) {
          final playlists = await ref.read(playlistsProvider.future);
          if (!context.mounted) {
            state = state.copyWith(isLoading: false);
            return;
          }
          final selectedPlaylist = playlists.firstWhere(
            (p) => p.uuid == state.selectedPlaylistId,
            orElse: () => throw Exception("Playlist non trouvée"),
          );
          await selectedPlaylist.songs.load();
          final playlistUrls =
              selectedPlaylist.songs.map((s) => s.songUrl).toSet();
          songsToProcess = songsToProcess
              .where((s) => playlistUrls.contains(s.songUrl))
              .toList();
          buffer.writeln("Filtre : Playlist '${selectedPlaylist.name}'\n");
        }
      }

      if (state.displayChoice == 'auteurs') {
        _exportArtists(buffer, songsToProcess);
      } else {
        _exportSongs(buffer, songsToProcess);
      }

      if (!context.mounted) {
        return;
      }
      await ExportService.exportSongList(
        content: buffer.toString(),
        format: state.exportFormat,
        context: context,
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }
      BottomBarModel.showBottomBar(message: "Une erreur est survenue: $e");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void _exportArtists(StringBuffer buffer, List<Song> songsToProcess) {
    Map<String, Map<String, dynamic>> artistsData = {};
    for (var song in songsToProcess) {
      final artist = song.artist ?? 'Artiste inconnu';
      artistsData.putIfAbsent(
          artist,
          () => {
                'songs': <Song>[],
                'totalPlayCount': 0,
                'lastPlayed': null,
                'tags': <String>{},
              });
      (artistsData[artist]!['songs'] as List<Song>).add(song);
      artistsData[artist]!['totalPlayCount'] += song.playCount;
      final lastPlayedDate = song.lastPlayed;
      if (lastPlayedDate != null) {
        final currentLastPlayed =
            artistsData[artist]!['lastPlayed'] as DateTime?;
        if (currentLastPlayed == null ||
            lastPlayedDate.isAfter(currentLastPlayed)) {
          artistsData[artist]!['lastPlayed'] = lastPlayedDate;
        }
      }
      (artistsData[artist]!['tags'] as Set<String>).addAll(song.tags);
    }

    List<String> artistsToExport = artistsData.keys.toList();

    if (state.artistSelection == 'filtered') {
      _applyArtistFilters(artistsToExport, artistsData);
    }

    _sortArtists(artistsToExport, artistsData, songsToProcess);

    buffer.writeln(
        "Total : ${artistsToExport.length} artiste${artistsToExport.length > 1 ? 's' : ''}\n");
    for (var artist in artistsToExport) {
      String line = artist;
      final List<String> details = [];

      if (state.showArtistSongCount) {
        final count = (artistsData[artist]!['songs'] as List).length;
        details.add('$count morceau${count > 1 ? 'x' : ''}');
      }

      if (state.withArtistStats) {
        final totalPlayCount = artistsData[artist]!['totalPlayCount'] ?? 0;
        details.add('joué $totalPlayCount fois');
      }

      if (details.isNotEmpty) {
        line += ' (${details.join(', ')})';
      }

      buffer.writeln(line);
    }
    if (artistsToExport.isEmpty) {
      buffer.writeln("Aucun artiste ne correspond à vos critères.");
    }
  }

  void _exportSongs(StringBuffer buffer, List<Song> songsToProcess) {
    List<Song> songsToExport = List.from(songsToProcess);

    if (state.songSelection == 'filtered') {
      _applySongFilters(songsToExport);
    }

    _sortSongs(songsToExport);

    buffer.writeln(
        "Total : ${songsToExport.length} morceau${songsToExport.length > 1 ? 'x' : ''}\n");
    for (var song in songsToExport) {
      String line = '';
      final title = song.title ?? 'Titre inconnu';
      final artist = song.artist ?? 'Artiste inconnu';
      if (state.displayChoice == 'morceaux') {
        line = title;
      } else {
        line = '$title - $artist';
      }
      if (state.withStats) {
        final playCount = song.playCount;
        final lastPlayed = song.lastPlayed != null
            ? DateFormat('dd/MM/yy', 'fr_FR').format(song.lastPlayed!)
            : 'jamais';
        line += ' (joué $playCount fois, dernière fois: $lastPlayed)';
      }
      buffer.writeln(line);
    }
    if (songsToExport.isEmpty) {
      buffer.writeln("Aucun morceau ne correspond à vos critères.");
    }
  }

  void _applyArtistFilters(
      List<String> artists, Map<String, dynamic> artistsData) {
    if (state.filterByPlayCount && state.playCountValue.isNotEmpty) {
      final count = int.tryParse(state.playCountValue);
      if (count != null) {
        artists.retainWhere((artist) {
          final playCount = artistsData[artist]!['totalPlayCount'] ?? 0;
          if (state.playCountCondition == 'greater') {
            return playCount > count;
          }
          if (state.playCountCondition == 'less') {
            return playCount < count;
          }
          return playCount == count;
        });
      }
    }
    if (state.filterByLastPlayed && state.selectedDate != null) {
      artists.retainWhere((artist) {
        final lastPlayedDate = artistsData[artist]!['lastPlayed'] as DateTime?;
        if (lastPlayedDate == null) return false;
        final comparisonDate = DateTime(state.selectedDate!.year,
            state.selectedDate!.month, state.selectedDate!.day);
        if (state.lastPlayedCondition == 'since') {
          return !lastPlayedDate.isBefore(comparisonDate);
        }
        return lastPlayedDate.isBefore(comparisonDate);
      });
    }
    if (state.filterByTags && state.selectedTags.isNotEmpty) {
      artists.retainWhere((artist) {
        final artistTags = artistsData[artist]!['tags'] as Set<String>;
        return state.selectedTags.any((tag) => artistTags.contains(tag));
      });
    }
  }

  void _sortArtists(List<String> artists, Map<String, dynamic> artistsData,
      List<Song> allSongs) {
    if (state.artistSortOrder == 'alpha') {
      artists.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    } else if (state.artistSortOrder == 'chrono') {
      artists.sort((a, b) {
        final dateA = artistsData[a]!['lastPlayed'] as DateTime?;
        final dateB = artistsData[b]!['lastPlayed'] as DateTime?;
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateB.compareTo(dateA);
      });
    } else if (state.artistSortOrder == 'appearance') {
      final tempSongs =
          allSongs.where((s) => artists.contains(s.artist)).toList();
      tempSongs.sort((a, b) => (a.title ?? '')
          .toLowerCase()
          .compareTo((b.title ?? '').toLowerCase()));

      final uniqueArtistsInOrder = <String>[];
      for (var song in tempSongs) {
        final artist = song.artist ?? 'Artiste inconnu';
        if (!uniqueArtistsInOrder.contains(artist)) {
          uniqueArtistsInOrder.add(artist);
        }
      }
      artists.sort((a, b) => uniqueArtistsInOrder
          .indexOf(a)
          .compareTo(uniqueArtistsInOrder.indexOf(b)));
    }
  }

  void _applySongFilters(List<Song> songs) {
    if (state.filterByPlayCount && state.playCountValue.isNotEmpty) {
      final count = int.tryParse(state.playCountValue);
      if (count != null) {
        songs.retainWhere((song) {
          final playCount = song.playCount;
          if (state.playCountCondition == 'greater') {
            return playCount > count;
          }
          if (state.playCountCondition == 'less') {
            return playCount < count;
          }
          return playCount == count;
        });
      }
    }
    if (state.filterByLastPlayed && state.selectedDate != null) {
      songs.retainWhere((song) {
        final lastPlayedDate = song.lastPlayed;
        if (lastPlayedDate == null) return false;
        final comparisonDate = DateTime(state.selectedDate!.year,
            state.selectedDate!.month, state.selectedDate!.day);
        if (state.lastPlayedCondition == 'since') {
          return !lastPlayedDate.isBefore(comparisonDate);
        } else {
          return lastPlayedDate.isBefore(comparisonDate);
        }
      });
    }
    if (state.filterByTags && state.selectedTags.isNotEmpty) {
      songs.retainWhere((song) {
        final songTags = song.tags;
        if (songTags.isEmpty) return false;
        return state.selectedTags
            .any((selectedTag) => songTags.contains(selectedTag));
      });
    }
  }

  void _sortSongs(List<Song> songs) {
    if (state.songSortOrder == 'alpha') {
      songs.sort((a, b) => (a.title ?? '')
          .toLowerCase()
          .compareTo((b.title ?? '').toLowerCase()));
    } else {
      songs.sort((a, b) {
        final dateA = a.addedDate;
        final dateB = b.addedDate;
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateB.compareTo(dateA);
      });
    }
  }
}

final exportOptionsProvider =
    NotifierProvider<ExportOptionsNotifier, ExportOptionsState>(
  ExportOptionsNotifier.new,
);

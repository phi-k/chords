// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import '../data/collections/song.dart';
import '../data/collections/playlist.dart';
import '../widgets/filter_buttons.dart';
import '../main.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  final isar = ref.watch(isarProvider);
  return DatabaseService(isar);
});

final homeFilterProvider =
NotifierProvider<HomeFilterNotifier, HomeFilterState>(
  HomeFilterNotifier.new,
);

final allSongsProvider = StreamProvider<List<Song>>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  final filterText = ref.watch(homeFilterProvider).filterText;
  return dbService.watchSongs(filterText: filterText);
});

final artistSongsProvider =
StreamProvider.family<List<Song>, String>((ref, artistName) {
  final dbService = ref.watch(databaseServiceProvider);
  return dbService.watchSongsByArtist(artistName);
});

final recentSongsProvider = StreamProvider<List<Song>>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  final reversed = ref.watch(homeFilterProvider).recentFilterReversed;
  return dbService.watchRecentSongs(reversed: reversed);
});

final artistsProvider = FutureProvider<Map<String, int>>((ref) async {
  final songs = await ref.watch(allSongsProvider.future);
  final artistsCount = <String, int>{};
  for (var song in songs) {
    final artist = song.artist ?? "Inconnu";
    artistsCount[artist] = (artistsCount[artist] ?? 0) + 1;
  }
  return artistsCount;
});

final playlistsStreamProvider = StreamProvider<List<Playlist>>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return db.watchPlaylists();
});

final playlistProvider = StreamProvider.family<Playlist?, int>((ref, id) {
  final dbService = ref.watch(databaseServiceProvider);
  return dbService.watchPlaylist(id);
});

class HomeFilterState {
  final String filterText;
  final bool isSearchFocused;
  final Set<FilterMode> activeFilters;
  final bool recentFilterReversed;
  final String? selectedArtist;
  final Playlist? selectedPlaylist;

  HomeFilterState({
    this.filterText = "",
    this.isSearchFocused = false,
    this.activeFilters = const {},
    this.recentFilterReversed = false,
    this.selectedArtist,
    this.selectedPlaylist,
  });

  HomeFilterState copyWith({
    String? filterText,
    bool? isSearchFocused,
    Set<FilterMode>? activeFilters,
    bool? recentFilterReversed,
    String? selectedArtist,
    Playlist? selectedPlaylist,
    bool clearSelectedArtist = false,
    bool clearSelectedPlaylist = false,
  }) {
    return HomeFilterState(
      filterText: filterText ?? this.filterText,
      isSearchFocused: isSearchFocused ?? this.isSearchFocused,
      activeFilters: activeFilters ?? this.activeFilters,
      recentFilterReversed: recentFilterReversed ?? this.recentFilterReversed,
      selectedArtist:
      clearSelectedArtist ? null : selectedArtist ?? this.selectedArtist,
      selectedPlaylist: clearSelectedPlaylist
          ? null
          : selectedPlaylist ?? this.selectedPlaylist,
    );
  }
}

class HomeFilterNotifier extends Notifier<HomeFilterState> {
  @override
  HomeFilterState build() {
    return HomeFilterState();
  }

  void setFilterText(String text) {
    state = state.copyWith(filterText: text);
  }

  void setSearchFocused(bool hasFocus) {
    state = state.copyWith(isSearchFocused: hasFocus);
  }

  void toggleFilterMode(FilterMode mode) {
    final newFilters = Set<FilterMode>.from(state.activeFilters);
    if (newFilters.contains(mode)) {
      newFilters.remove(mode);
    } else {
      if (mode == FilterMode.artists &&
          newFilters.contains(FilterMode.playlists)) {
        newFilters.remove(FilterMode.playlists);
      } else if (mode == FilterMode.playlists &&
          newFilters.contains(FilterMode.artists)) {
        newFilters.remove(FilterMode.artists);
      }
      newFilters.add(mode);
    }

    state = state.copyWith(activeFilters: newFilters);

    if (mode == FilterMode.artists && !newFilters.contains(FilterMode.artists)) {
      state = state.copyWith(clearSelectedArtist: true);
    }
    if (mode == FilterMode.playlists &&
        !newFilters.contains(FilterMode.playlists)) {
      state = state.copyWith(clearSelectedPlaylist: true);
    }
  }

  void toggleRecentSortOrder() {
    state = state.copyWith(recentFilterReversed: !state.recentFilterReversed);
  }

  void selectArtist(String artist) {
    state = state.copyWith(selectedArtist: artist, clearSelectedPlaylist: true);
  }

  void selectPlaylist(Playlist playlist) {
    state =
        state.copyWith(selectedPlaylist: playlist, clearSelectedArtist: true);
  }

  void clearSelections() {
    state =
        state.copyWith(clearSelectedArtist: true, clearSelectedPlaylist: true);
  }
}
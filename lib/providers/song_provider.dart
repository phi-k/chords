// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../services/database_service.dart';
import '../data/collections/song.dart';
import '../data/collections/playlist.dart';
import '../widgets/filter_buttons.dart';
import '../main.dart';
import '../models/tab_source.dart';
import '../services/source_manager.dart';

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

final hasSongsProvider = StreamProvider<bool>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return dbService.watchSongs(filterText: '').map((songs) => songs.isNotEmpty);
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

class PlaylistSongsNotifier extends FamilyAsyncNotifier<List<Song>, int> {
  @override
  FutureOr<List<Song>> build(int arg) async {
    final playlistAsync = ref.watch(playlistProvider(arg));
    final playlist = playlistAsync.value;
    if (playlist == null) return [];
    await playlist.songs.load();
    return playlist.getOrderedSongs();
  }

  void reorder(int oldIndex, int newIndex) {
    final songs = state.value;
    if (songs == null) return;

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final List<Song> updated = List.from(songs);
    final Song moved = updated.removeAt(oldIndex);
    updated.insert(newIndex, moved);
    state = AsyncData(updated);
  }
}

final playlistSongsProvider = AsyncNotifierProvider.family<PlaylistSongsNotifier, List<Song>, int>(
  PlaylistSongsNotifier.new,
);

class HomeFilterState {
  final String filterText;
  final bool isSearchFocused;
  final Set<FilterMode> activeFilters;
  final bool recentFilterReversed;
  final String? selectedArtist;
  final int? selectedPlaylistId;

  HomeFilterState({
    this.filterText = "",
    this.isSearchFocused = false,
    this.activeFilters = const {},
    this.recentFilterReversed = false,
    this.selectedArtist,
    this.selectedPlaylistId,
  });

  HomeFilterState copyWith({
    String? filterText,
    bool? isSearchFocused,
    Set<FilterMode>? activeFilters,
    bool? recentFilterReversed,
    String? selectedArtist,
    int? selectedPlaylistId,
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
      selectedPlaylistId: clearSelectedPlaylist
          ? null
          : selectedPlaylistId ?? this.selectedPlaylistId,
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

    if (mode == FilterMode.artists &&
        !newFilters.contains(FilterMode.artists)) {
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

  void selectPlaylist(int playlistId) {
    state =
        state.copyWith(selectedPlaylistId: playlistId, clearSelectedArtist: true);
  }

  void clearSelections() {
    state =
        state.copyWith(clearSelectedArtist: true, clearSelectedPlaylist: true);
  }
}

final tabSourcesProvider = FutureProvider<List<TabSource>>((ref) async {
  return SourceManager.getSources();
});

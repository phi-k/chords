// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/collections/song.dart';
import '../data/collections/playlist.dart';
import '../services/pdf_export_service.dart';
import '../models/bottom_bar_model.dart';

class ExportTabsState {
  final String selectionMode;
  final String? selectedPlaylistId;
  final String? selectedArtistName;
  final Set<int> manualSelectionIds;
  final bool isLoading;
  final bool withTableOfContents;
  final bool withCoverPage;
  final String songbookTitle;

  final int? _recentCount;
  int get recentCount => _recentCount ?? 20;

  const ExportTabsState({
    this.selectionMode = 'all',
    this.selectedPlaylistId,
    this.selectedArtistName,
    this.manualSelectionIds = const {},
    this.isLoading = false,
    this.withTableOfContents = true,
    this.withCoverPage = true,
    this.songbookTitle = "Mon Recueil Chords",
    int? recentCount,
  }) : _recentCount = recentCount;

  ExportTabsState copyWith({
    String? selectionMode,
    String? selectedPlaylistId,
    String? selectedArtistName,
    Set<int>? manualSelectionIds,
    bool? isLoading,
    bool? withTableOfContents,
    bool? withCoverPage,
    String? songbookTitle,
    int? recentCount,
  }) {
    return ExportTabsState(
      selectionMode: selectionMode ?? this.selectionMode,
      selectedPlaylistId: selectedPlaylistId ?? this.selectedPlaylistId,
      selectedArtistName: selectedArtistName ?? this.selectedArtistName,
      manualSelectionIds: manualSelectionIds ?? this.manualSelectionIds,
      isLoading: isLoading ?? this.isLoading,
      withTableOfContents: withTableOfContents ?? this.withTableOfContents,
      withCoverPage: withCoverPage ?? this.withCoverPage,
      songbookTitle: songbookTitle ?? this.songbookTitle,
      recentCount: recentCount ?? _recentCount,
    );
  }
}

class ExportTabsNotifier extends Notifier<ExportTabsState> {
  @override
  ExportTabsState build() {
    return const ExportTabsState();
  }

  void setSelectionMode(String mode) {
    state = state.copyWith(
      selectionMode: mode,
      selectedPlaylistId: null,
      selectedArtistName: null,
      manualSelectionIds: mode == 'manual' ? state.manualSelectionIds : {},
    );
  }

  void setSelectedPlaylist(String? id) =>
      state = state.copyWith(selectedPlaylistId: id);
  void setSelectedArtist(String? name) =>
      state = state.copyWith(selectedArtistName: name);
  void toggleTableOfContents(bool value) =>
      state = state.copyWith(withTableOfContents: value);
  void toggleCoverPage(bool value) =>
      state = state.copyWith(withCoverPage: value);
  void setSongbookTitle(String value) =>
      state = state.copyWith(songbookTitle: value);

  void setRecentCount(int count) => state = state.copyWith(recentCount: count);

  void toggleManualSelection(int songId) {
    final newSet = Set<int>.from(state.manualSelectionIds);
    if (newSet.contains(songId)) {
      newSet.remove(songId);
    } else {
      newSet.add(songId);
    }
    state = state.copyWith(manualSelectionIds: newSet);
  }

  void clearManualSelection() {
    state = state.copyWith(manualSelectionIds: {});
  }

  void selectAllManual(List<Song> allSongs) {
    state =
        state.copyWith(manualSelectionIds: allSongs.map((s) => s.id).toSet());
  }

  Future<void> export(List<Song> allSongs, List<Playlist> allPlaylists) async {
    state = state.copyWith(isLoading: true);

    try {
      List<Song> songsToExport = [];

      switch (state.selectionMode) {
        case 'all':
          songsToExport = List.from(allSongs);
          break;
        case 'playlist':
          if (state.selectedPlaylistId != null) {
            Playlist? selectedPlaylist;
            for (var p in allPlaylists) {
              if (p.uuid == state.selectedPlaylistId) {
                selectedPlaylist = p;
                break;
              }
            }

            if (selectedPlaylist != null) {
              await selectedPlaylist.songs.load();
              songsToExport = selectedPlaylist.songs.toList();
            }
          }
          break;
        case 'artist':
          if (state.selectedArtistName != null) {
            songsToExport = allSongs
                .where((s) => s.artist == state.selectedArtistName)
                .toList();
          }
          break;
        case 'recent':
          final sorted = List<Song>.from(allSongs);
          sorted.sort((a, b) {
            final da = a.lastPlayed ?? a.addedDate ?? DateTime(2000);
            final db = b.lastPlayed ?? b.addedDate ?? DateTime(2000);
            return db.compareTo(da);
          });

          int countToTake = state.recentCount;
          if (countToTake > sorted.length) countToTake = sorted.length;
          songsToExport = sorted.take(countToTake).toList();
          break;
        case 'manual':
          songsToExport = allSongs
              .where((s) => state.manualSelectionIds.contains(s.id))
              .toList();
          break;
      }

      if (songsToExport.isEmpty) {
        BottomBarModel.showBottomBar(message: "Aucune chanson sélectionnée.");
        state = state.copyWith(isLoading: false);
        return;
      }

      songsToExport.sort((a, b) => (a.title ?? "").compareTo(b.title ?? ""));

      await PdfExportService.exportSongbook(
        songs: songsToExport,
        title: state.songbookTitle.isEmpty
            ? "Recueil Chords"
            : state.songbookTitle,
        withTableOfContents: state.withTableOfContents,
        withCoverPage: state.withCoverPage,
      );
    } catch (e) {
      BottomBarModel.showBottomBar(message: "Erreur lors de l'export: $e");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

final exportTabsProvider =
NotifierProvider<ExportTabsNotifier, ExportTabsState>(
    ExportTabsNotifier.new);
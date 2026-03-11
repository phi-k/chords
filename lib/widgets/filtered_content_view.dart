// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/collections/song.dart';
import '../l10n/app_localizations.dart';
import '../providers/song_provider.dart';
import '../widgets/filter_buttons.dart';
import '../widgets/artists_view.dart';
import '../widgets/playlists_view.dart';
import '../widgets/recent_songs_view.dart';
import '../widgets/recent_artists_view.dart';
import '../widgets/tags_view.dart';
import '../widgets/song_list.dart';
import '../widgets/empty_library_view.dart';
import 'alphabet_scroller_wrapper.dart';

class FilteredContentView extends ConsumerWidget {
  final List<Song> songs;
  final Map<String, int> artistsCount;

  const FilteredContentView({
    super.key,
    required this.songs,
    required this.artistsCount,
  });

  Widget _buildEmptyState(BuildContext context) {
    return const EmptyLibraryView();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(homeFilterProvider);
    final filterNotifier = ref.read(homeFilterProvider.notifier);

    const horizontalPadding = EdgeInsets.symmetric(horizontal: 40);

    if (songs.isEmpty &&
        filterState.activeFilters.isEmpty &&
        filterState.filterText.isEmpty) {
      return _buildEmptyState(context);
    }

    Widget buildContent() {
      if (filterState.activeFilters.isEmpty) {
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 40, right: 20),
              child: SongListWidget(
                songs: songs,
                onRefresh: () async => ref.invalidate(allSongsProvider),
                showAlphabetScroller: true,
              ),
            ),
            const Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              width: 40,
              child: AlphabetScrollerWrapper(),
            ),
          ],
        );
      }

      if (filterState.activeFilters.contains(FilterMode.artists) &&
          !filterState.activeFilters.contains(FilterMode.recent)) {
        return Padding(
          padding: horizontalPadding,
          child: ArtistsView(
            artistsCount: artistsCount,
            onArtistSelected: filterNotifier.selectArtist,
            songs: songs,
          ),
        );
      }

      if (filterState.activeFilters.contains(FilterMode.recent) &&
          !filterState.activeFilters.contains(FilterMode.artists)) {
        final asyncRecentSongs = ref.watch(recentSongsProvider);
        return asyncRecentSongs.when(
          data: (recentSongs) => Padding(
            padding: horizontalPadding,
            child: RecentSongsView(
              songs: recentSongs,
              reversed: filterState.recentFilterReversed,
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text(e.toString())),
        );
      }

      if (filterState.activeFilters.contains(FilterMode.artists) &&
          filterState.activeFilters.contains(FilterMode.recent)) {
        return Padding(
          padding: horizontalPadding,
          child: RecentArtistsView(
            songs: songs,
            artistsCount: artistsCount,
            onArtistSelected: filterNotifier.selectArtist,
            reversed: filterState.recentFilterReversed,
          ),
        );
      }

      if (filterState.activeFilters.contains(FilterMode.playlists)) {
        return PlaylistsView(
          onPlaylistSelected: filterNotifier.selectPlaylist,
        );
      }

      if (filterState.activeFilters.contains(FilterMode.tags)) {
        return const TagsView();
      }

      return SongListWidget(
        songs: songs,
        onRefresh: () async => ref.invalidate(allSongsProvider),
        showAlphabetScroller: true,
      );
    }

    return buildContent();
  }

  static String getHeaderText(
      Set<FilterMode> activeFilters,
      Map<String, int> artistsCount,
      List<Song> songs,
      String filterText,
      bool recentFilterReversed,
      AppLocalizations loc) {
    if (activeFilters.isEmpty) {
      return loc.headerSongs(songs.length);
    }
    if (activeFilters.contains(FilterMode.artists) &&
        activeFilters.contains(FilterMode.recent)) {
      return recentFilterReversed
          ? loc.headerArtistsOldest
          : loc.headerArtistsNewest;
    } else if (activeFilters.contains(FilterMode.artists)) {
      return loc.headerArtists(artistsCount.length);
    } else if (activeFilters.contains(FilterMode.recent)) {
      return recentFilterReversed ? loc.headerOldSongs : loc.headerRecentSongs;
    } else if (activeFilters.contains(FilterMode.playlists)) {
      return "Playlists";
    } else if (activeFilters.contains(FilterMode.tags)) {
      return "Tags";
    }
    return loc.headerSongs(songs.length);
  }
}

// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/collections/song.dart';
import '../providers/song_provider.dart';
import '../widgets/song_list.dart';
import '../widgets/common/custom_loader.dart';
import '../l10n/app_localizations.dart';

class PlaylistDetailPage extends ConsumerWidget {
  final int playlistId;

  const PlaylistDetailPage({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPlaylist = ref.watch(playlistProvider(playlistId));
    final loc = AppLocalizations.of(context)!;

    return asyncPlaylist.when(
      loading: () => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(elevation: 0, backgroundColor: Theme.of(context).colorScheme.surface),
        body: const CustomLoader(),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text(loc.commonError(err.toString()))),
      ),
      data: (playlist) {
        if (playlist == null) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: AppBar(
                elevation: 0,
                backgroundColor: Theme.of(context).colorScheme.surface,
                iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface)),
            body: Center(child: Text(loc.playlistNotFound)),
          );
        }

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            scrolledUnderElevation: 0,
            iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
            title: Text(
              playlist.name ?? "Playlist",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontFamily: 'Cormorant',
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/playlist_edit',
                    arguments: playlist.id,
                  );
                },
              ),
            ],
          ),
          body: FutureBuilder<List<Song>>(
            future: Future(() async {
              await playlist.songs.load();
              return playlist.songs.toList();
            }),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CustomLoader();
              }
              if (snapshot.hasError) {
                return Center(child: Text(loc.playlistSongLoadError));
              }

              final playlistSongs = snapshot.data ?? [];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      height: 1,
                      color: Theme.of(context).colorScheme.onSurface,
                      width: double.infinity,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      loc.homePieceCount(playlistSongs.length),
                      style: TextStyle(
                        fontFamily: 'Cormorant',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (playlistSongs.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              loc.playlistNoSongs,
                              style: TextStyle(
                                fontFamily: 'Cormorant',
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/playlist_edit',
                                  arguments: playlist.id,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Theme.of(context).colorScheme.surface,
                              ),
                              child: Text(loc.playlistAddSongs),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SongListWidget(
                          songs: playlistSongs,
                          onRefresh: () async =>
                              ref.invalidate(allSongsProvider),
                          showAlphabetScroller: false,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/collections/song.dart';
import '../providers/song_provider.dart';
import '../widgets/song_list.dart';
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
        backgroundColor: Colors.white,
        appBar: AppBar(elevation: 0, backgroundColor: Colors.white),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text(loc.commonError(err.toString()))),
      ),
      data: (playlist) {
        if (playlist == null) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.white,
                iconTheme: const IconThemeData(color: Colors.black)),
            body: Center(child: Text(loc.playlistNotFound)),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
            title: Text(
              playlist.name ?? "Playlist",
              style: const TextStyle(
                color: Colors.black,
                fontFamily: 'Cormorant',
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.red),
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
                return const Center(child: CircularProgressIndicator());
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
                      color: Colors.black,
                      width: double.infinity,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      loc.homePieceCount(playlistSongs.length),
                      style: const TextStyle(
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
                              style: const TextStyle(
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
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
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

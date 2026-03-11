// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../data/collections/playlist.dart';
import '../data/collections/song.dart';
import '../providers/song_provider.dart';
import '../widgets/common/app_image.dart';
import '../widgets/search_bar.dart';
import '../models/bottom_bar_model.dart';
import '../l10n/app_localizations.dart';

class PlaylistEditPage extends ConsumerStatefulWidget {
  final int playlistId;

  const PlaylistEditPage({super.key, required this.playlistId});

  @override
  ConsumerState<PlaylistEditPage> createState() => _PlaylistEditPageState();
}

class _PlaylistEditPageState extends ConsumerState<PlaylistEditPage> {
  Set<Id> selectedSongIds = {};
  String _currentSearchQuery = '';
  bool _isInitialized = false;

  List<Song> _getFilteredSongs(List<Song> allSongs) {
    if (_currentSearchQuery.isEmpty) {
      return allSongs;
    } else {
      final lowerCaseQuery = _currentSearchQuery.toLowerCase();
      return allSongs.where((song) {
        final title = (song.title ?? '').toLowerCase();
        final artist = (song.artist ?? '').toLowerCase();
        return title.contains(lowerCaseQuery) ||
            artist.contains(lowerCaseQuery);
      }).toList();
    }
  }

  Future<void> _savePlaylist(Playlist playlist) async {
    try {
      final loc = AppLocalizations.of(context)!;
      final songsToSave = await ref
          .read(databaseServiceProvider)
          .getSongsByIds(selectedSongIds.toList());
      playlist.songs.clear();
      playlist.songs.addAll(songsToSave);

      await ref.read(databaseServiceProvider).updatePlaylist(playlist);

      if (mounted) {
        BottomBarModel.showBottomBar(message: loc.playlistSaved);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        BottomBarModel.showBottomBar(
          message:
              AppLocalizations.of(context)!.playlistSaveError(e.toString()),
        );
      }
    }
  }

  void _toggleSongSelection(Id songId) {
    setState(() {
      if (selectedSongIds.contains(songId)) {
        selectedSongIds.remove(songId);
      } else {
        selectedSongIds.add(songId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncSongs = ref.watch(allSongsProvider);
    final asyncPlaylist = ref.watch(playlistProvider(widget.playlistId));
    final loc = AppLocalizations.of(context)!;

    return asyncPlaylist.when(
      loading: () => Scaffold(
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) =>
          Scaffold(body: Center(child: Text(loc.commonError(e.toString())))),
      data: (playlist) {
        if (playlist == null) {
          return Scaffold(
            appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.black)),
            body: Center(child: Text(loc.playlistNotFound)),
          );
        }

        if (!_isInitialized) {
          Future(() async {
            await playlist.songs.load();
            if (mounted) {
              setState(() {
                selectedSongIds = playlist.songs.map((s) => s.id).toSet();
                _isInitialized = true;
              });
            }
          });
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
            title: Text(
              loc.playlistEditTitle(playlist.name ?? 'Playlist'),
              style: const TextStyle(
                color: Colors.black,
                fontFamily: 'Cormorant',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: TextButton.icon(
                  onPressed: () => _savePlaylist(playlist),
                  icon: const Icon(Icons.save, color: Colors.black, size: 18),
                  label: Text(
                    loc.commonSave,
                    style: const TextStyle(
                      color: Colors.black,
                      fontFamily: 'Cormorant',
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
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
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  loc.playlistSelectedCount(selectedSongIds.length),
                  style: const TextStyle(
                    fontFamily: 'Cormorant',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: asyncSongs.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) =>
                      Center(child: Text(loc.commonError(err.toString()))),
                  data: (allSongs) {
                    final filteredSongs = _getFilteredSongs(allSongs);
                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: filteredSongs.length,
                            itemBuilder: (context, index) {
                              final song = filteredSongs[index];
                              final title = song.title ?? loc.commonUntitled;
                              final artist =
                                  song.artist ?? loc.commonUnknownArtist;
                              final songId = song.id;
                              final isSelected =
                                  selectedSongIds.contains(songId);

                              return CheckboxListTile(
                                  value: isSelected,
                                  onChanged: (_) =>
                                      _toggleSongSelection(songId),
                                  title: Text(
                                    title,
                                    style: const TextStyle(
                                      fontFamily: 'Cormorant',
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Text(
                                    artist,
                                    style: TextStyle(
                                      fontFamily: 'Cormorant',
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  activeColor: Colors.red,
                                  secondary: AppImage(url: song.coverUrl));
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: SearchBarWidget(
                            onTextChanged: (query) {
                              setState(() {
                                _currentSearchQuery = query;
                              });
                            },
                            filterText: _currentSearchQuery,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

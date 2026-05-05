// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../data/collections/playlist.dart';
import '../providers/song_provider.dart';
import '../models/bottom_bar_model.dart';
import 'common/app_image.dart';
import 'common/custom_loader.dart';

class PlaylistsView extends ConsumerWidget {
  final Function(Playlist)? onPlaylistSelected;

  const PlaylistsView({super.key, this.onPlaylistSelected});

  Future<void> _createPlaylist(BuildContext context, WidgetRef ref) async {
    final loc = AppLocalizations.of(context)!;
    final TextEditingController nameController = TextEditingController();
    if (!context.mounted) return;

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            loc.playlistNewTitle,
            style: TextStyle(
              fontFamily: 'Cormorant',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: nameController,
            autofocus: true,
            style: TextStyle(fontFamily: 'Cormorant', fontSize: 16),
            decoration: InputDecoration(
              hintText: loc.playlistNameHint,
              hintStyle: TextStyle(fontFamily: 'Cormorant', fontSize: 16),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                loc.commonCancel,
                style: TextStyle(
                  fontFamily: 'Cormorant',
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () async {
                final playlistName = nameController.text.trim();
                if (playlistName.isNotEmpty) {
                  Navigator.pop(dialogContext);
                  try {
                    final newPlaylist = await ref
                        .read(databaseServiceProvider)
                        .createPlaylist(playlistName);

                    if (!context.mounted) return;

                    await Navigator.pushNamed(
                      context,
                      '/playlist_edit',
                      arguments: newPlaylist.id,
                    );
                    ref.invalidate(playlistsStreamProvider);
                  } catch (e) {
                    if (!context.mounted) return;
                    BottomBarModel.showBottomBar(
                      message: loc.playlistCreateError,
                    );
                  }
                }
              },
              icon: Icon(Icons.check, size: 18, color: Colors.black),
              label: Text(
                loc.playlistCreateBtn,
                style: TextStyle(
                  fontFamily: 'Cormorant',
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Theme.of(context).primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _renamePlaylist(
      BuildContext context, WidgetRef ref, Playlist playlist) async {
    final loc = AppLocalizations.of(context)!;
    final TextEditingController nameController =
        TextEditingController(text: playlist.name);
    if (!context.mounted) return;

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            loc.playlistRenameTitle,
            style: TextStyle(
              fontFamily: 'Cormorant',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: nameController,
            autofocus: true,
            style: TextStyle(fontFamily: 'Cormorant', fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                loc.commonCancel,
                style: TextStyle(
                  fontFamily: 'Cormorant',
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () async {
                final String newName = nameController.text.trim();
                Navigator.pop(dialogContext);

                if (newName.isNotEmpty && newName != playlist.name) {
                  try {
                    playlist.name = newName;
                    await ref
                        .read(databaseServiceProvider)
                        .updatePlaylist(playlist);
                  } catch (e) {
                    if (!context.mounted) return;
                    BottomBarModel.showBottomBar(
                      message: loc.playlistRenameError,
                    );
                  }
                }
              },
              icon: Icon(Icons.check, size: 18, color: Colors.black),
              label: Text(
                loc.playlistRenameBtn,
                style: TextStyle(
                  fontFamily: 'Cormorant',
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Theme.of(context).primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePlaylist(
      BuildContext context, WidgetRef ref, Playlist playlist) async {
    final loc = AppLocalizations.of(context)!;
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            loc.playlistDeleteTitle,
            style: TextStyle(
              fontFamily: 'Cormorant',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            loc.playlistDeleteConfirm(playlist.name ?? ''),
            style: TextStyle(fontFamily: 'Cormorant', fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                loc.commonCancel,
                style: TextStyle(
                  fontFamily: 'Cormorant',
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () async {
                Navigator.pop(dialogContext);
                try {
                  await ref
                      .read(databaseServiceProvider)
                      .deletePlaylist(playlist.id);
                } catch (e) {
                  if (context.mounted) {
                    BottomBarModel.showBottomBar(
                      message: loc.playlistDeleteError,
                    );
                  }
                }
              },
              icon: Icon(Icons.delete,
                  size: 18, color: Theme.of(context).primaryColor),
              label: Text(
                loc.playlistDeleteBtn,
                style: TextStyle(
                  fontFamily: 'Cormorant',
                  fontSize: 16,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Theme.of(context).primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final asyncPlaylists = ref.watch(playlistsStreamProvider);

    return asyncPlaylists.when(
      loading: () => const CustomLoader(),
      error: (err, stack) =>
          Center(child: Text(loc.commonError(err.toString()))),
      data: (playlists) {
        if (playlists.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  loc.playlistNone,
                  style: TextStyle(fontFamily: 'Cormorant', fontSize: 18),
                ),
                SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () => _createPlaylist(context, ref),
                  icon: Icon(Icons.add, color: Colors.black),
                  label: Text(
                    loc.playlistCreateNew,
                    style: TextStyle(
                      fontFamily: 'Cormorant',
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    side: const BorderSide(color: Colors.black),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    shadowColor:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            ListView.builder(
              padding: EdgeInsets.only(bottom: 80, left: 40, right: 40),
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                final songCount = playlist.songs.length;
                final coverUrl = playlist.songs.isNotEmpty
                    ? playlist.songs.first.coverUrl
                    : null;

                return GestureDetector(
                  onTap: () {
                    if (onPlaylistSelected != null) {
                      onPlaylistSelected!(playlist);
                    } else {
                      Navigator.pushNamed(
                        context,
                        '/playlist_detail',
                        arguments: playlist.id,
                      );
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      border: index < playlists.length - 1
                          ? Border(
                              bottom: BorderSide(color: Colors.grey.shade200))
                          : null,
                    ),
                    child: Row(
                      children: [
                        AppImage(url: coverUrl),
                        SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                playlist.name ?? '',
                                style: TextStyle(
                                  fontFamily: 'Cormorant',
                                  fontSize: 18,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              Text(
                                loc.playlistSongCount(songCount),
                                style: TextStyle(
                                  fontFamily: 'Cormorant',
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.more_vert),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor:
                                  Theme.of(context).colorScheme.surface,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(15),
                                ),
                              ),
                              builder: (context) => SafeArea(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: Icon(Icons.edit),
                                      title: Text(
                                        loc.playlistEditBtn,
                                        style: TextStyle(
                                          fontFamily: 'Cormorant',
                                          fontSize: 16,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        Navigator.pushNamed(
                                          context,
                                          '/playlist_edit',
                                          arguments: playlist.id,
                                        );
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(
                                        Icons.drive_file_rename_outline,
                                      ),
                                      title: Text(
                                        loc.commonRename,
                                        style: TextStyle(
                                          fontFamily: 'Cormorant',
                                          fontSize: 16,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _renamePlaylist(context, ref, playlist);
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(
                                        Icons.delete,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      title: Text(
                                        loc.commonDelete,
                                        style: TextStyle(
                                          fontFamily: 'Cormorant',
                                          fontSize: 16,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _deletePlaylist(context, ref, playlist);
                                      },
                                    ),
                                    SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Positioned(
              right: 40,
              bottom: 0,
              child: GestureDetector(
                onTap: () => _createPlaylist(context, ref),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(
                        loc.filterPlaylists,
                        style: TextStyle(
                          fontFamily: 'Cormorant',
                          fontSize: 16,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.add,
                          size: 18,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

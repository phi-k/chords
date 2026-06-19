// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../data/collections/playlist.dart';
import '../data/collections/song.dart';
import '../providers/song_provider.dart';
import '../models/bottom_bar_model.dart';
import 'common/app_image.dart';
import 'common/custom_loader.dart';
import 'package:file_picker/file_picker.dart';

class PlaylistsView extends ConsumerWidget {
  final Function(int)? onPlaylistSelected;

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
                  color: Theme.of(context).colorScheme.onSurface,
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
              icon: Icon(Icons.check,
                  size: 18, color: Theme.of(context).colorScheme.primary),
              label: Text(
                loc.playlistCreateBtn,
                style: TextStyle(
                  fontFamily: 'Cormorant',
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
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
                  color: Theme.of(context).colorScheme.onSurface,
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
              icon: Icon(Icons.check,
                  size: 18, color: Theme.of(context).colorScheme.primary),
              label: Text(
                loc.playlistRenameBtn,
                style: TextStyle(
                  fontFamily: 'Cormorant',
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
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
                  color: Theme.of(context).colorScheme.onSurface,
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
                  icon: Icon(
                    Icons.add,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  label: Text(
                    loc.playlistCreateNew,
                    style: TextStyle(
                      fontFamily: 'Cormorant',
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    side: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(
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
              padding: const EdgeInsets.only(bottom: 80, left: 40, right: 40),
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                final songCount = playlist.songs.length;
                final coverUrl = playlist.coverUrl ??
                    (playlist.songs.isNotEmpty
                        ? playlist.songs.first.coverUrl
                        : null);

                return GestureDetector(
                  onTap: () {
                    if (onPlaylistSelected != null) {
                      onPlaylistSelected!(playlist.id);
                    }
                  },
                  onLongPress: () =>
                      _showPlaylistOptions(context, ref, playlist),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      border: index < playlists.length - 1
                          ? Border(
                              bottom: BorderSide(color: Colors.grey.shade200))
                          : null,
                    ),
                    child: Row(
                      children: [
                        AppImage(url: coverUrl),
                        const SizedBox(width: 15),
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

  void _showPlaylistOptions(
      BuildContext context, WidgetRef ref, Playlist playlist) {
    final loc = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
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
              leading: const Icon(Icons.photo_library),
              title: const Text(
                "Personnaliser la couverture",
                style: TextStyle(
                  fontFamily: 'Cormorant',
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _customizePlaylistCover(context, ref, playlist);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(
                loc.playlistEditBtn,
                style: const TextStyle(
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
              leading: const Icon(Icons.drive_file_rename_outline),
              title: Text(
                loc.commonRename,
                style: const TextStyle(
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
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _customizePlaylistCover(
      BuildContext context, WidgetRef ref, Playlist playlist) async {
    final allSongs = await ref.read(databaseServiceProvider).getSavedSongs();
    final songsWithCovers = allSongs
        .where((s) => s.coverUrl != null && s.coverUrl!.isNotEmpty)
        .toList();

    if (!context.mounted) return;

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return PlaylistCoverPickerDialog(
          playlist: playlist,
          songsWithCovers: songsWithCovers,
          onCoverSelected: (newCoverUrl) async {
            playlist.coverUrl = newCoverUrl;
            await ref.read(databaseServiceProvider).updatePlaylist(playlist);
            ref.invalidate(playlistsStreamProvider);
          },
        );
      },
    );
  }
}

class PlaylistCoverPickerDialog extends StatefulWidget {
  final Playlist playlist;
  final List<Song> songsWithCovers;
  final ValueChanged<String?> onCoverSelected;

  const PlaylistCoverPickerDialog({
    super.key,
    required this.playlist,
    required this.songsWithCovers,
    required this.onCoverSelected,
  });

  @override
  State<PlaylistCoverPickerDialog> createState() =>
      _PlaylistCoverPickerDialogState();
}

class _PlaylistCoverPickerDialogState extends State<PlaylistCoverPickerDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _tempCoverUrl;
  Color? _selectedBgColor;
  final TextEditingController _emojiController = TextEditingController();
  String _songSearchQuery = '';

  final List<String> _quickEmojis = const [
    '🎵',
    '🎸',
    '🎤',
    '📻',
    '💿',
    '❤️',
    '⭐',
    '🎧',
    '🎹',
    '🎼',
    '🔊',
    '🎶'
  ];

  final List<IconData> _quickIcons = const [
    Icons.music_note,
    Icons.folder,
    Icons.favorite,
    Icons.star,
    Icons.album,
    Icons.radio,
    Icons.headset,
    Icons.mic,
    Icons.playlist_play,
    Icons.audiotrack,
    Icons.volume_up,
    Icons.speaker,
  ];

  final List<Color> _presetColors = const [
    Color(0xFFE53935),
    Color(0xFFD81B60),
    Color(0xFF8E24AA),
    Color(0xFF5E35B1),
    Color(0xFF3949AB),
    Color(0xFF1E88E5),
    Color(0xFF039BE5),
    Color(0xFF00ACC1),
    Color(0xFF00897B),
    Color(0xFF43A047),
    Color(0xFF7CB342),
    Color(0xFFC0CA33),
    Color(0xFFFFB300),
    Color(0xFFFB8C00),
    Color(0xFFF4511E),
    Color(0xFF6D4C41),
    Color(0xFF546E7A),
    Color(0xFF37474F),
    Color(0xFF121212),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });

    _tempCoverUrl = widget.playlist.coverUrl;
    if (_tempCoverUrl != null) {
      if (_tempCoverUrl!.startsWith('emoji://')) {
        final content = _tempCoverUrl!.substring(8);
        final parts = content.split('|');
        _emojiController.text = parts[0];
        if (parts.length > 1) {
          final colorVal = int.tryParse(parts[1], radix: 16);
          if (colorVal != null) {
            _selectedBgColor = Color(colorVal);
          }
        }
      } else if (_tempCoverUrl!.startsWith('icon://')) {
        final content = _tempCoverUrl!.substring(7);
        final parts = content.split('|');
        if (parts.length > 1) {
          final colorVal = int.tryParse(parts[1], radix: 16);
          if (colorVal != null) {
            _selectedBgColor = Color(colorVal);
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  List<Song> _getFilteredSongs() {
    if (_songSearchQuery.isEmpty) {
      return widget.songsWithCovers;
    }
    final query = _songSearchQuery.toLowerCase();
    return widget.songsWithCovers.where((song) {
      final title = (song.title ?? '').toLowerCase();
      final artist = (song.artist ?? '').toLowerCase();
      return title.contains(query) || artist.contains(query);
    }).toList();
  }

  Future<void> _pickLocalImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _tempCoverUrl = 'local://${result.files.single.path}';
        });
      }
    } catch (e) {
    }
  }

  void _updateEmojiCover(String emoji) {
    final colorStr = _selectedBgColor != null
        ? '|${_selectedBgColor!.value.toRadixString(16).toUpperCase()}'
        : '';
    setState(() {
      _tempCoverUrl = 'emoji://$emoji$colorStr';
    });
  }

  void _updateIconCover(int codePoint) {
    final colorStr = _selectedBgColor != null
        ? '|${_selectedBgColor!.value.toRadixString(16).toUpperCase()}'
        : '';
    setState(() {
      _tempCoverUrl = 'icon://$codePoint$colorStr';
    });
  }

  void _updateBgColor(Color? color) {
    setState(() {
      _selectedBgColor = color;
      if (_tempCoverUrl != null) {
        if (_tempCoverUrl!.startsWith('emoji://')) {
          final content = _tempCoverUrl!.substring(8);
          final parts = content.split('|');
          final emoji = parts[0];
          final colorStr = color != null
              ? '|${color.value.toRadixString(16).toUpperCase()}'
              : '';
          _tempCoverUrl = 'emoji://$emoji$colorStr';
        } else if (_tempCoverUrl!.startsWith('icon://')) {
          final content = _tempCoverUrl!.substring(7);
          final parts = content.split('|');
          final codePoint = parts[0];
          final colorStr = color != null
              ? '|${color.value.toRadixString(16).toUpperCase()}'
              : '';
          _tempCoverUrl = 'icon://$codePoint$colorStr';
        }
      }
    });
  }

  Widget _buildColorSelector(ThemeData theme) {
    final List<Color?> colorOptions = [null, ..._presetColors];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
          child: Text(
            "Couleur d'arrière-plan",
            style: TextStyle(
              fontFamily: 'Cormorant',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: colorOptions.length,
            itemBuilder: (context, index) {
              final color = colorOptions[index];
              final isSelected = color == _selectedBgColor;
              final bool isDefault = color == null;
              final optionBgColor = isDefault
                  ? theme.colorScheme.primary.withValues(alpha: 0.15)
                  : color;
              final checkColor = isDefault
                  ? theme.colorScheme.primary
                  : (color.computeLuminance() > 0.6 ? Colors.black87 : Colors.white);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: GestureDetector(
                  onTap: () => _updateBgColor(color),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: optionBgColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Center(
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              size: 18,
                              color: checkColor,
                            )
                          : (isDefault
                              ? Tooltip(
                                  message: "Couleur par défaut",
                                  child: Icon(
                                    Icons.brightness_auto_outlined,
                                    size: 14,
                                    color: theme.colorScheme.primary.withValues(alpha: 0.7),
                                  ),
                                )
                              : null),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: theme.colorScheme.onPrimary,
        unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        dividerColor: Colors.transparent,
        labelPadding: EdgeInsets.zero,
        tabs: const [
          Tab(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_emotions_outlined, size: 16),
                SizedBox(height: 2),
                Text("Émoji", style: TextStyle(fontSize: 10, fontFamily: 'Cormorant', fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Tab(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.category_outlined, size: 16),
                SizedBox(height: 2),
                Text("Icône", style: TextStyle(fontSize: 10, fontFamily: 'Cormorant', fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Tab(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.music_note_outlined, size: 16),
                SizedBox(height: 2),
                Text("Morceau", style: TextStyle(fontSize: 10, fontFamily: 'Cormorant', fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Tab(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_outlined, size: 16),
                SizedBox(height: 2),
                Text("Image", style: TextStyle(fontSize: 10, fontFamily: 'Cormorant', fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiTab(ThemeData theme) {
    return Column(
      children: [
        TextField(
          controller: _emojiController,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: "Saisir un émoji...",
            hintStyle: TextStyle(
              fontFamily: 'Cormorant',
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            prefixIcon: const Icon(Icons.emoji_emotions_outlined, size: 18),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 1.5,
              ),
            ),
            isDense: true,
          ),
          onChanged: (val) {
            if (val.isNotEmpty) {
              final emoji = val.characters.last;
              if (_emojiController.text != emoji) {
                _emojiController.value = TextEditingValue(
                  text: emoji,
                  selection: TextSelection.collapsed(offset: emoji.length),
                );
              }
              _updateEmojiCover(emoji);
            }
          },
        ),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: _quickEmojis.length,
            itemBuilder: (context, index) {
              final emoji = _quickEmojis[index];
              final bool isSelected = _tempCoverUrl != null &&
                  _tempCoverUrl!.startsWith('emoji://') &&
                  _tempCoverUrl!.substring(8).split('|')[0] == emoji;

              return InkWell(
                onTap: () {
                  _emojiController.text = emoji;
                  _updateEmojiCover(emoji);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary.withValues(alpha: 0.15)
                        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: theme.colorScheme.primary, width: 2)
                        : Border.all(color: Colors.transparent, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        _buildColorSelector(theme),
      ],
    );
  }

  Widget _buildIconTab(ThemeData theme) {
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.1,
            ),
            itemCount: _quickIcons.length,
            itemBuilder: (context, index) {
              final iconData = _quickIcons[index];
              final bool isSelected = _tempCoverUrl != null &&
                  _tempCoverUrl!.startsWith('icon://') &&
                  _tempCoverUrl!.substring(7).split('|')[0] == iconData.codePoint.toString();

              return InkWell(
                onTap: () => _updateIconCover(iconData.codePoint),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary.withValues(alpha: 0.15)
                        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: theme.colorScheme.primary, width: 2)
                        : Border.all(color: Colors.transparent, width: 2),
                  ),
                  child: Icon(
                    iconData,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                    size: 26,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        _buildColorSelector(theme),
      ],
    );
  }

  Widget _buildSongTab(ThemeData theme) {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: "Rechercher un morceau...",
            hintStyle: TextStyle(
              fontFamily: 'Cormorant',
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            prefixIcon: const Icon(Icons.search, size: 18),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 1.5,
              ),
            ),
            isDense: true,
          ),
          onChanged: (val) {
            setState(() {
              _songSearchQuery = val;
            });
          },
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _getFilteredSongs().isEmpty
              ? const Center(
                  child: Text(
                    "Aucun morceau avec couverture trouvé",
                    style: TextStyle(
                      fontFamily: 'Cormorant',
                      fontSize: 14,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _getFilteredSongs().length,
                  itemBuilder: (context, index) {
                    final song = _getFilteredSongs()[index];
                    final isSelected = _tempCoverUrl == song.coverUrl;
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected
                            ? theme.colorScheme.primary.withValues(alpha: 0.08)
                            : Colors.transparent,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        dense: true,
                        leading: AppImage(
                          url: song.coverUrl,
                          width: 42,
                          height: 42,
                          borderRadius: 8,
                        ),
                        title: Text(
                          song.title ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Cormorant',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          song.artist ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Cormorant',
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: theme.colorScheme.primary,
                                size: 20,
                              )
                            : null,
                        onTap: () {
                          setState(() {
                            _tempCoverUrl = song.coverUrl;
                          });
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildImageTab(ThemeData theme) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 40,
              color: theme.colorScheme.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 8),
            Text(
              "Importer une image locale",
              style: TextStyle(
                fontFamily: 'Cormorant',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Sélectionnez un fichier depuis votre appareil",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cormorant',
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _pickLocalImage,
              icon: const Icon(Icons.folder_open, size: 16),
              label: const Text(
                "Parcourir...",
                style: TextStyle(
                  fontFamily: 'Cormorant',
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(ThemeData theme, AppLocalizations loc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            loc.commonCancel,
            style: TextStyle(
              fontFamily: 'Cormorant',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            widget.onCoverSelected(_tempCoverUrl);
            Navigator.pop(context);
          },
          icon: const Icon(Icons.check, size: 16),
          label: Text(
            loc.commonSave,
            style: const TextStyle(
              fontFamily: 'Cormorant',
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: theme.colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 660),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Personnaliser la couverture",
                  style: TextStyle(
                    fontFamily: 'Cormorant',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: AppImage(
                  url: _tempCoverUrl ??
                      (widget.playlist.songs.isNotEmpty
                          ? widget.playlist.songs.first.coverUrl
                          : null),
                  width: 100,
                  height: 100,
                  borderRadius: 18,
                 ),
              ),
            ),
            const SizedBox(height: 16),
            _buildTabBar(theme),
            const SizedBox(height: 14),
            Flexible(
              child: SizedBox(
                height: 300,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildEmojiTab(theme),
                    _buildIconTab(theme),
                    _buildSongTab(theme),
                    _buildImageTab(theme),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildActions(theme, loc),
          ],
        ),
      ),
    );
  }
}

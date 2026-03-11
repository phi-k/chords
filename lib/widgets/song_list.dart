// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../data/collections/song.dart';
import '../screens/song_page.dart';
import '../screens/creation_page.dart';
import '../screens/settings_page.dart';
import '../screens/blind_test_page.dart';
import '../services/alphabet_position_service.dart';
import '../utils/string_normalization.dart';
import 'common/song_tile.dart';
import 'song_options_popup.dart';
import 'alphabet_scroller_wrapper.dart';

class SongListWidget extends ConsumerStatefulWidget {
  final List<Song> songs;
  final Future<void> Function() onRefresh;
  final bool showAlphabetScroller;

  const SongListWidget({
    super.key,
    required this.songs,
    required this.onRefresh,
    required this.showAlphabetScroller,
  });

  @override
  ConsumerState<SongListWidget> createState() => _SongListWidgetState();
}

class _SongListWidgetState extends ConsumerState<SongListWidget>
    implements AlphabetScrollListener {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _groupKeys = {};
  final AlphabetPositionService _positionService = AlphabetPositionService();

  @override
  void initState() {
    super.initState();
    AlphabetScrollerBridge().registerListener(this);
    _initializeAllGroupKeys();
    if (widget.songs.isNotEmpty) {
      _positionService.updatePositions(widget.songs);
    }
  }

  @override
  void didUpdateWidget(covariant SongListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.songs.length != oldWidget.songs.length ||
        widget.songs != oldWidget.songs) {
      if (widget.songs.isNotEmpty) {
        _positionService.updatePositions(widget.songs);
      }
    }
  }

  void _initializeAllGroupKeys() {
    for (int i = 0; i < 26; i++) {
      String letter = String.fromCharCode(65 + i);
      _groupKeys.putIfAbsent(letter, () => GlobalKey());
    }
    _groupKeys.putIfAbsent("Autres", () => GlobalKey());
  }

  Map<String, List<Song>> _getGroupedSongs() {
    Map<String, List<Song>> groupedSongs = {};
    for (var song in widget.songs) {
      String title = song.title ?? "";
      String key = _groupKey(title);
      groupedSongs.putIfAbsent(key, () => []);
      groupedSongs[key]!.add(song);
    }
    return groupedSongs;
  }

  @override
  void scrollToLetter(String letter) {
    final targetKey = letter == "#" ? "Autres" : letter;

    final GlobalKey? key = _groupKeys[targetKey];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutQuad,
        alignment: 0.0,
      );
      return;
    }

    if (_scrollController.hasClients &&
        _scrollController.position.hasContentDimensions) {
      final double position = _positionService.getPositionForLetter(targetKey);

      final double clampedPosition = position.clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
      _scrollController.jumpTo(clampedPosition);

      Future.delayed(const Duration(milliseconds: 50), () {
        if (key?.currentContext != null) {
          Scrollable.ensureVisible(
            key!.currentContext!,
            duration: const Duration(milliseconds: 80),
            curve: Curves.easeOutQuad,
            alignment: 0.0,
          );

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (key.currentContext != null) {
              final RenderObject? renderObject =
                  key.currentContext!.findRenderObject();
              if (renderObject is RenderBox) {
                renderObject.localToGlobal(Offset.zero);
                _positionService.adjustPositionFromRealMeasurements(
                  targetKey,
                  _scrollController.offset,
                );
              }
            }
          });
        }
      });
    }
  }

  @override
  Map<String, GlobalKey> getGroupKeys() {
    return _groupKeys;
  }

  String _groupKey(String title) {
    if (title.isEmpty) return "Autres";
    final normalizedTitle = normalizeString(title);
    if (normalizedTitle.isEmpty) return "Autres";
    final firstChar = normalizedTitle[0].toUpperCase();
    if (firstChar.codeUnitAt(0) >= 'A'.codeUnitAt(0) &&
        firstChar.codeUnitAt(0) <= 'Z'.codeUnitAt(0)) {
      return firstChar;
    }
    return "Autres";
  }

  Widget _buildGroupHeader(String header, AppLocalizations loc) {
    _groupKeys.putIfAbsent(header, () => GlobalKey());
    final displayText = header == "Autres" ? loc.songListOther : header;
    return Container(
      key: _groupKeys[header],
      padding: const EdgeInsets.only(right: 30, top: 10, bottom: 10),
      child: Row(
        children: [
          Text(
            displayText,
            style: const TextStyle(
              fontFamily: 'Cormorant',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Divider(color: Colors.grey.shade400, thickness: 0.5)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    Map<String, List<Song>> groupedSongs = _getGroupedSongs();
    List<Widget> listItems = [];

    List<String> sortedKeys = groupedSongs.keys.toList()
      ..sort((a, b) {
        if (a == "Autres") return 1;
        if (b == "Autres") return -1;
        return a.compareTo(b);
      });

    for (var key in sortedKeys) {
      if (key == "Autres") continue;

      listItems.add(_buildGroupHeader(key, loc));
      for (var song in groupedSongs[key]!) {
        listItems.add(
          SongTile(
            song: song,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SongPage(songData: song)),
            ),
            onLongPress: () => showSongOptionsPopup(context, ref, song),
          ),
        );
      }
    }

    if (groupedSongs.containsKey("Autres")) {
      listItems.add(_buildGroupHeader("Autres", loc));
      for (var song in groupedSongs["Autres"]!) {
        listItems.add(
          SongTile(
            song: song,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SongPage(songData: song)),
            ),
            onLongPress: () => showSongOptionsPopup(context, ref, song),
          ),
        );
      }
    }

    listItems.add(
      InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreationPage()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 30.0, bottom: 5.0, right: 10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  width: 50,
                  height: 50,
                  color: Colors.black.withValues(alpha: 0.05),
                  child: const Icon(Icons.edit_note, color: Colors.black),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.songListNoteSong,
                    style: const TextStyle(
                      fontFamily: 'Cormorant',
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    listItems.add(
      InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BlindTestPage()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0, bottom: 5.0, right: 10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  width: 50,
                  height: 50,
                  color: Colors.red.shade100,
                  child: const Icon(Icons.music_note, color: Colors.red),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.songListBlindTest,
                    style: const TextStyle(
                        fontFamily: 'Cormorant',
                        fontSize: 20,
                        color: Colors.black),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    listItems.add(
      InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsPage()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0, bottom: 0.0, right: 10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.settings, color: Colors.black),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.songListSettings,
                    style: const TextStyle(
                        fontFamily: 'Cormorant',
                        fontSize: 20,
                        color: Colors.black),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: listItems,
      ),
    );
  }
}

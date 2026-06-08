// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../data/collections/song.dart';
import '../services/song_service.dart';
import '../services/source_manager.dart';
import '../utils/chord_format_converter.dart';
import '../utils/string_normalization.dart';
import '../widgets/common/custom_loader.dart';
import '../widgets/common/song_tile.dart';
import 'song_page.dart';

class ExploreCatalogPage extends ConsumerStatefulWidget {
  const ExploreCatalogPage({super.key});

  @override
  ConsumerState<ExploreCatalogPage> createState() => _ExploreCatalogPageState();
}

class _ExploreCatalogPageState extends ConsumerState<ExploreCatalogPage> {
  final TextEditingController _searchCtrl = TextEditingController();

  List<Map<String, dynamic>> _allSongs = [];
  List<Map<String, dynamic>> _filteredSongs = [];
  bool _isLoading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCatalog() async {
    try {
      final defaultSource = await SourceManager.ensureDefaultSource();
      if (defaultSource != null) {
        final results = await SongService.getAllStaticSongs(defaultSource);

        results.sort((a, b) {
          final titleA = normalizeString(a['title']?.toString() ?? '');
          final titleB = normalizeString(b['title']?.toString() ?? '');
          return titleA.compareTo(titleB);
        });

        if (mounted) {
          setState(() {
            _allSongs = results;
            _filteredSongs = results;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterSongs(String query) {
    setState(() {
      _query = query;
      if (query.isEmpty) {
        _filteredSongs = _allSongs;
      } else {
        final cleanQuery = normalizeString(query);
        _filteredSongs = _allSongs.where((song) {
          final title = normalizeString((song['title'] ?? '').toString());
          final artist = normalizeString((song['artist'] ?? '').toString());
          return title.contains(cleanQuery) || artist.contains(cleanQuery);
        }).toList();
      }
    });
  }

  Future<void> _openSong(Map<String, dynamic> songMap) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const Center(child: CustomLoader()),
    );

    final defaultSource = await SourceManager.ensureDefaultSource();
    if (defaultSource == null) {
      if (mounted) Navigator.pop(context);
      return;
    }

    final songDetails = await SongService.fetchStaticSourceDetails(
      defaultSource,
      songMap['song_url'] ?? '',
    );

    if (!mounted) return;
    Navigator.pop(context);

    if (songDetails != null) {
      final offlineLyrics = ChordFormatConverter.convertOnlineToOffline(
        songDetails['lyrics_with_chords'] ?? '',
      );
      final song = Song(
        songUrl: songMap['song_url'] ?? '',
        title: songDetails['title'],
        artist: songDetails['artist'],
        difficulty: songDetails['difficulty'],
        capo: songDetails['capo'],
        tuning: songDetails['tuning'],
        lyricsWithChords: offlineLyrics,
        originalLyricsWithChords: offlineLyrics,
        savedDate: null,
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SongPage(songData: song)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          loc.exploreAllTitle,
          style: const TextStyle(
            fontFamily: 'Cormorant',
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        centerTitle: false,
      ),
      body: _isLoading
          ? const CustomLoader()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 40, right: 40, top: 12, bottom: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _query.isEmpty
                          ? "${_allSongs.length} morceaux disponibles"
                          : "${_filteredSongs.length} résultats trouvés",
                      style: TextStyle(
                        fontFamily: 'Cormorant',
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(left: 40, right: 40, top: 8, bottom: 8),
                    itemCount: _filteredSongs.length,
                    itemBuilder: (context, index) {
                      final s = _filteredSongs[index];
                      final dummySong = Song(
                        title: s['title'],
                        artist: s['artist'],
                        coverUrl: s['album_cover'],
                        songUrl: s['song_url'] ?? '',
                      );
                      return SongTile(
                        song: dummySong,
                        onTap: () => _openSong(s),
                        trailing: Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 40, right: 40, top: 20, bottom: 28),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.onSurface,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: _filterSongs,
                            style: TextStyle(
                              fontFamily: 'Cormorant',
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              hintText: loc.exploreAllSearchHint,
                              hintStyle: const TextStyle(
                                fontFamily: 'Cormorant',
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 20),
                            ),
                          ),
                        ),
                        if (_query.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            color: Theme.of(context).colorScheme.onSurface,
                            onPressed: () {
                              _searchCtrl.clear();
                              _filterSongs('');
                            },
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Icon(
                              Icons.search,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

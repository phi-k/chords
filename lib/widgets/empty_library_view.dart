// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../data/collections/song.dart';
import '../services/song_service.dart';
import '../services/source_manager.dart';
import '../utils/chord_format_converter.dart';
import '../screens/creation_page.dart';
import '../screens/settings_page.dart';
import '../screens/song_page.dart';
import '../screens/explore_catalog_page.dart';
import 'common/custom_loader.dart';

class EmptyLibraryView extends StatefulWidget {
  const EmptyLibraryView({super.key});

  @override
  State<EmptyLibraryView> createState() => _EmptyLibraryViewState();
}

class _EmptyLibraryViewState extends State<EmptyLibraryView> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  List<Map<String, dynamic>> _line1Songs = [];
  List<Map<String, dynamic>> _line2Songs = [];
  List<Map<String, dynamic>> _line3Songs = [];
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
    _loadPopularSongs();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadPopularSongs() async {
    final defaultSource = await SourceManager.ensureDefaultSource();
    if (defaultSource != null) {
      try {
        final results = await SongService.getAllStaticSongs(defaultSource);
        if (results.isNotEmpty) {
          final sortedSongs = List<Map<String, dynamic>>.from(results);
          sortedSongs.sort((a, b) {
            final votesA = int.tryParse(a['votes']?.toString() ?? '0') ?? 0;
            final votesB = int.tryParse(b['votes']?.toString() ?? '0') ?? 0;
            return votesB.compareTo(votesA);
          });

          final popularPool = sortedSongs.take(120).toList()..shuffle();
          final selected = popularPool.take(30).toList();

          final List<Map<String, dynamic>> l1 = [];
          final List<Map<String, dynamic>> l2 = [];
          final List<Map<String, dynamic>> l3 = [];

          for (int i = 0; i < selected.length; i++) {
            if (i < 10) {
              l1.add(selected[i]);
            } else if (i < 20) {
              l2.add(selected[i]);
            } else {
              l3.add(selected[i]);
            }
          }

          if (mounted) {
            setState(() {
              _line1Songs = l1;
              _line2Songs = l2;
              _line3Songs = l3;
              _isDataLoaded = true;
            });
          }
        }
      } catch (e) {
        dev.log("Erreur lors de l'initialisation des suggestions d'accueil : $e", name: 'EmptyLibraryView');
      }
    }
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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.music_note_outlined,
                size: 50,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  loc.homeEmptyTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cormorant',
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  loc.homeEmptySubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cormorant',
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              if (_isDataLoaded) ...[
                _ScrollingSongsLine(songs: _line1Songs, scrollLeft: true, onSongTap: _openSong),
                const SizedBox(height: 10),
                _ScrollingSongsLine(songs: _line2Songs, scrollLeft: false, onSongTap: _openSong),
                const SizedBox(height: 10),
                _ScrollingSongsLine(songs: _line3Songs, scrollLeft: true, onSongTap: _openSong),
              ] else
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CustomLoader(size: 30),
                ),

              const SizedBox(height: 32),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ExploreCatalogPage()),
                        );
                      },
                      icon: const Icon(Icons.explore_outlined, size: 20),
                      label: Text(
                        loc.homeEmptyBrowseAllBtn,
                        style: const TextStyle(
                          fontFamily: 'Cormorant',
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CreationPage()),
                        );
                      },
                      icon: Icon(Icons.edit_note, color: Theme.of(context).colorScheme.onSurface, size: 18),
                      label: Text(
                        loc.homeEmptyBtnWrite,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontFamily: 'Cormorant',
                          fontSize: 15,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Theme.of(context).dividerColor),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SettingsPage()),
                        );
                      },
                      icon: Icon(
                        Icons.settings,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                      label: Text(
                        loc.settingsTitle,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontFamily: 'Cormorant',
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScrollingSongsLine extends StatefulWidget {
  final List<Map<String, dynamic>> songs;
  final bool scrollLeft;
  final Function(Map<String, dynamic>) onSongTap;

  const _ScrollingSongsLine({
    required this.songs,
    required this.scrollLeft,
    required this.onSongTap,
  });

  @override
  State<_ScrollingSongsLine> createState() => _ScrollingSongsLineState();
}

class _ScrollingSongsLineState extends State<_ScrollingSongsLine> {
  late final ScrollController _scrollController;
  Timer? _autoScrollTimer;

  static const int _initialIndex = 2000;
  static const double _itemWidth = 140.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: _initialIndex * _itemWidth,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!mounted || !_scrollController.hasClients) return;

      double currentScroll = _scrollController.offset;

      if (widget.scrollLeft) {
        currentScroll += 0.6;
      } else {
        currentScroll -= 0.6;
      }

      _scrollController.jumpTo(currentScroll);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.songs.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 44,
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: <Color>[
              Colors.transparent,
              Colors.black,
              Colors.black,
              Colors.transparent,
            ],
            stops: <double>[0.0, 0.15, 0.85, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is UserScrollNotification) {
              _autoScrollTimer?.cancel();
              Future.delayed(const Duration(seconds: 4), () {
                if (mounted) _startAutoScroll();
              });
            }
            return false;
          },
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: 1000000,
            itemBuilder: (context, index) {
              final song = widget.songs[index % widget.songs.length];
              final title = song['title'] ?? 'Sans titre';
              final cleanTitle = title == 'Очи Чёрные' ? 'Les Yeux Noirs' : title;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: ActionChip(
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  label: Text(
                    cleanTitle,
                    style: TextStyle(
                      fontFamily: 'Cormorant',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  onPressed: () => widget.onSongTap(song),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

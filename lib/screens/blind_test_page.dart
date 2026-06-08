// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/collections/song.dart';
import '../providers/song_provider.dart';
import '../widgets/chords_lyrics_display.dart';
import '../screens/song_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/blind_test_utils.dart';
import '../widgets/common/app_image.dart';
import '../widgets/common/custom_loader.dart';
import '../widgets/common/onboarding_popup.dart';
import '../l10n/app_localizations.dart';

class BlindTestPage extends ConsumerStatefulWidget {
  const BlindTestPage({super.key});

  @override
  ConsumerState<BlindTestPage> createState() => _BlindTestPageState();
}

class _BlindTestPageState extends ConsumerState<BlindTestPage> {
  List<Song> blindTestSongs = [];
  Map<int, String> beginningLyrics = {};
  Map<int, bool> expandedItems = {};
  bool showTitlesAndArtists = true;
  int? songListHash;
  bool _showOnboardingPopup = false;
  bool _onboardingLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadOnboardingStatus();
  }

  Future<void> _loadOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeen = prefs.getBool('has_seen_blind_test_onboarding') ?? false;
      if (mounted) {
        setState(() {
          _showOnboardingPopup = !hasSeen;
          _onboardingLoaded = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _onboardingLoaded = true;
        });
      }
    }
  }

  Future<void> _dismissOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_blind_test_onboarding', true);
    } catch (_) {}
    if (mounted) {
      setState(() {
        _showOnboardingPopup = false;
      });
    }
  }

  void _processSongs(List<Song> allSongs) {
    final shuffledSongs = BlindTestUtils.shuffleSongs(allSongs);

    final lyricsMap = <int, String>{};
    final List<Song> processedSongs = [];

    for (var song in shuffledSongs) {
      final String lyrics = song.lyricsWithChords ?? '';
      final String beginning = BlindTestUtils.extractSongBeginning(lyrics);

      if (beginning.isNotEmpty) {
        processedSongs.add(song);
        lyricsMap[song.id] = beginning;
      }
    }

    if (mounted) {
      setState(() {
        blindTestSongs = processedSongs;
        beginningLyrics = lyricsMap;
        songListHash = allSongs.hashCode;
      });
    }
  }

  void _shuffle() {
    final allSongs = ref.read(allSongsProvider).valueOrNull;
    if (allSongs != null) {
      _processSongs(allSongs);
    }
  }

  void _toggleTitlesVisibility() {
    setState(() {
      showTitlesAndArtists = !showTitlesAndArtists;
    });
  }

  void _toggleExpanded(int index) {
    setState(() {
      expandedItems[index] = !(expandedItems[index] ?? false);
    });
  }

  void _navigateToSong(Song song) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SongPage(songData: song)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncSongs = ref.watch(allSongsProvider);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        title: Row(
          children: [
            Icon(Icons.music_note, color: Theme.of(context).colorScheme.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              loc.blindTestTitle,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontFamily: 'Cormorant',
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              showTitlesAndArtists ? Icons.visibility : Icons.visibility_off,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: _toggleTitlesVisibility,
            tooltip: showTitlesAndArtists
                ? loc.blindTestHideTitles
                : loc.blindTestShowTitles,
          ),
          IconButton(
            icon: Icon(Icons.shuffle, color: Theme.of(context).colorScheme.primary),
            onPressed: _shuffle,
            tooltip: loc.blindTestShuffle,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
                height: 1, color: Theme.of(context).colorScheme.onSurface, width: double.infinity),
          ),
          if (_onboardingLoaded && _showOnboardingPopup) ...[
            const SizedBox(height: 16),
            OnboardingPopup(
              title: loc.blindTestOnboardingTitle,
              message: loc.blindTestOnboardingMessage,
              dismissText: loc.blindTestOnboardingDismiss,
              onDismiss: _dismissOnboarding,
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
          ],
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              asyncSongs.maybeWhen(
                data: (_) => loc.blindTestCount(blindTestSongs.length),
                orElse: () => loc.commonLoading,
              ),
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
              loading: () => const CustomLoader(),
              error: (err, stack) =>
                  Center(child: Text(loc.commonError(err.toString()))),
              data: (allSongs) {
                if (songListHash == null || songListHash != allSongs.hashCode) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _processSongs(allSongs);
                  });
                  return const CustomLoader();
                }

                if (blindTestSongs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.music_off,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          loc.blindTestNoSongs,
                          style: const TextStyle(
                            fontFamily: 'Cormorant',
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          loc.blindTestNoSongsHint,
                          style: const TextStyle(
                            fontFamily: 'Cormorant',
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: blindTestSongs.length,
                  itemBuilder: (context, index) {
                    final song = blindTestSongs[index];
                    final isExpanded = expandedItems[index] ?? false;
                    final songLyrics = beginningLyrics[song.id] ?? '';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () => _toggleExpanded(index),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(15),
                              bottom: Radius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  AppImage(
                                    url: song.coverUrl,
                                    borderRadius: 8,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (showTitlesAndArtists) ...[
                                          Text(
                                            song.title ??
                                                loc.blindTestUnknownTitle,
                                            style: TextStyle(
                                              fontFamily: 'Cormorant',
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            song.artist ??
                                                loc.blindTestUnknownArtist,
                                            style: TextStyle(
                                              fontFamily: 'Cormorant',
                                              fontSize: 16,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ] else ...[
                                          Text(
                                            loc.blindTestSongNumber(index + 1),
                                            style: TextStyle(
                                              fontFamily: 'Cormorant',
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            loc.blindTestTitleHidden,
                                            style: TextStyle(
                                              fontFamily: 'Cormorant',
                                              fontSize: 16,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    isExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isExpanded) ...[
                            const Divider(height: 1),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ChordLyricsDisplay(
                                    text: songLyrics,
                                    chordStyle: TextStyle(
                                        fontFamily: 'UbuntuMono',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onSurface),
                                    lyricStyle: TextStyle(
                                        fontFamily: 'UbuntuMono',
                                        fontSize: 16,
                                        color: Theme.of(context).colorScheme.onSurface),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () => _navigateToSong(song),
                                        icon: Icon(Icons.launch,
                                            size: 18, color: Theme.of(context).colorScheme.surface),
                                        label: Text(loc.blindTestViewSong,
                                            style: TextStyle(
                                                fontFamily: 'Cormorant',
                                                fontSize: 14,
                                                color: Theme.of(context).colorScheme.surface)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context).colorScheme.primary,
                                          foregroundColor: Theme.of(context).colorScheme.surface,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

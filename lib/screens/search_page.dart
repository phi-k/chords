// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/collections/song.dart';
import '../services/song_service.dart';
import '../providers/search_provider.dart';
import '../models/search_result_model.dart';
import '../utils/chord_format_converter.dart';
import '../widgets/common/app_image.dart';
import 'song_page.dart';
import '../l10n/app_localizations.dart';

class SearchPage extends ConsumerStatefulWidget {
  final String searchTerm;

  const SearchPage({super.key, required this.searchTerm});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(searchProvider.notifier).fetchInitial(widget.searchTerm));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);

    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.searchResultsFor(widget.searchTerm),
            style: const TextStyle(fontFamily: 'Cormorant')),
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: _buildBody(state),
    );
  }

  Widget _buildBody(SearchState state) {
    if (state.isLoadingInitial) {
      return const Center(child: CircularProgressIndicator(color: Colors.red));
    }

    if (state.error != null && state.songs.isEmpty) {
      return Center(
          child: Text(state.error!,
              style: const TextStyle(fontFamily: 'Cormorant')));
    }

    if (state.songs.isEmpty) {
      return Center(
          child: Text(AppLocalizations.of(context)!.searchNoResults,
              style: const TextStyle(fontFamily: 'Cormorant')));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
      itemCount: state.songs.length + 1,
      itemBuilder: (context, index) {
        if (index == state.songs.length) {
          if (state.isLoadingMore) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child:
                  Center(child: CircularProgressIndicator(color: Colors.red)),
            );
          }
          if (state.canLoadMore) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: OutlinedButton.icon(
                  onPressed: () => ref
                      .read(searchProvider.notifier)
                      .fetchMore(widget.searchTerm),
                  icon: const Icon(Icons.add, color: Colors.black),
                  label: Text(
                    AppLocalizations.of(context)!.searchLoadMore,
                    style: const TextStyle(
                        fontFamily: 'Cormorant',
                        fontSize: 16,
                        color: Colors.black),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade400),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }
        return _SongResultGroupWidget(songGroup: state.songs[index]);
      },
    );
  }
}

class _SongResultGroupWidget extends StatefulWidget {
  final GroupedSong songGroup;
  const _SongResultGroupWidget({required this.songGroup});
  @override
  _SongResultGroupWidgetState createState() => _SongResultGroupWidgetState();
}

class _SongResultGroupWidgetState extends State<_SongResultGroupWidget> {
  bool _isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onExpansionChanged: (isExpanded) =>
            setState(() => _isExpanded = isExpanded),
        leading: AppImage(
          url: widget.songGroup.coverUrl,
          width: 50,
          height: 50,
          borderRadius: 8,
        ),
        title: Text(
          widget.songGroup.title,
          style: const TextStyle(
              fontFamily: 'Cormorant',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red),
        ),
        subtitle: Text(
          widget.songGroup.artist,
          style: TextStyle(
              fontFamily: 'Cormorant',
              fontSize: 16,
              color: Colors.grey.shade700),
        ),
        trailing: Icon(
          _isExpanded ? Icons.expand_less : Icons.expand_more,
          color: Colors.black,
        ),
        children: widget.songGroup.versions.asMap().entries.map((entry) {
          final int displayIndex = entry.key + 1;
          final SongVersion version = entry.value;
          Widget? rankIcon;
          if (version.rank != null) {
            switch (version.rank) {
              case 1:
                rankIcon = const Icon(Icons.emoji_events,
                    color: Color(0xFFD4AF37), size: 16);
                break;
              case 2:
                rankIcon = const Icon(Icons.emoji_events,
                    color: Color(0xFFC0C0C0), size: 16);
                break;
              case 3:
                rankIcon = const Icon(Icons.emoji_events,
                    color: Color(0xFFCD7F32), size: 16);
                break;
            }
          }
          return Material(
            color: Colors.grey.shade50,
            child: InkWell(
              onTap: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const Center(
                        child: CircularProgressIndicator(color: Colors.red));
                  },
                );
                final songDetailsMap = await SongService.fetchSongDetails(
                    version.lien,
                    sourceId: version.sourceId);
                if (!context.mounted) return;
                Navigator.of(context).pop();
                if (songDetailsMap != null) {
                  final offlineLyrics =
                      ChordFormatConverter.convertOnlineToOffline(
                          songDetailsMap['lyrics_with_chords'] ?? '');
                  final tempSong = Song(
                    songUrl: version.lien,
                    title: songDetailsMap['title'],
                    artist: songDetailsMap['artist'],
                    difficulty: songDetailsMap['difficulty'],
                    capo: songDetailsMap['capo'],
                    tuning: songDetailsMap['tuning'],
                    lyricsWithChords: offlineLyrics,
                    originalLyricsWithChords: offlineLyrics,
                    savedDate: null,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SongPage(songData: tempSong),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Impossible de charger cette chanson.")),
                  );
                }
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Version $displayIndex - ${version.type}',
                            style: const TextStyle(
                                fontFamily: 'Cormorant', fontSize: 16),
                          ),
                          if (version.sourceName.isNotEmpty)
                            Text(
                              version.sourceName,
                              style: TextStyle(
                                  fontFamily: 'Cormorant',
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                  fontStyle: FontStyle.italic),
                            ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        if (rankIcon != null) ...[
                          rankIcon,
                          const SizedBox(width: 8),
                        ],
                        Text(
                          version.note,
                          style: TextStyle(
                              fontFamily: 'Cormorant',
                              fontSize: 14,
                              color: Colors.grey.shade800),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

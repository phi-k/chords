// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../data/collections/song.dart';

class RecentArtistsView extends StatelessWidget {
  final List<Song> songs;
  final Map<String, int> artistsCount;
  final Function(String) onArtistSelected;
  final bool reversed;

  const RecentArtistsView({
    super.key,
    required this.songs,
    required this.artistsCount,
    required this.onArtistSelected,
    required this.reversed,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    Map<String, DateTime> artistLastPlayed = {};
    Map<String, List<dynamic>> artistRecentSongs = {};

    final playedSongs = songs.where((song) => song.lastPlayed != null).toList();

    for (var song in playedSongs) {
      final artist = (song.artist ?? loc.artistsUnknown).toString();
      final DateTime songDate = song.lastPlayed!;

      if (!artistRecentSongs.containsKey(artist)) {
        artistRecentSongs[artist] = [];
      }

      artistRecentSongs[artist]!.add(song);

      if (!artistLastPlayed.containsKey(artist) ||
          songDate.isAfter(artistLastPlayed[artist]!)) {
        artistLastPlayed[artist] = songDate;
      }
    }

    artistRecentSongs.forEach((artist, songList) {
      songList.sort((a, b) {
        final dateA = a.lastPlayed!;
        final dateB = b.lastPlayed!;
        return dateB.compareTo(dateA);
      });
    });

    final List<String> sortedArtists = artistLastPlayed.keys.toList();
    sortedArtists.sort((a, b) {
      final dateA = artistLastPlayed[a]!;
      final dateB = artistLastPlayed[b]!;
      return reversed ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    });

    final List<String> nonPlayedArtists = artistsCount.keys
        .where((artist) => !artistLastPlayed.containsKey(artist))
        .toList()
      ..sort();

    final List<String> allArtists = [...sortedArtists, ...nonPlayedArtists];

    return ListView.separated(
      padding: const EdgeInsets.only(top: 10),
      itemCount: allArtists.length,
      separatorBuilder: (context, index) => const SizedBox(height: 5),
      itemBuilder: (context, index) {
        final artist = allArtists[index];
        final count = artistsCount[artist] ?? 0;
        final hasBeenPlayed = artistLastPlayed.containsKey(artist);

        String songsText = "";
        if (hasBeenPlayed) {
          final recentSongsList = artistRecentSongs[artist]!;
          final topSongs = recentSongsList.take(3).toList();
          final titles = topSongs
              .map<String>((song) => (song.title ?? "").toString())
              .toList();
          songsText = titles.join(", ");

          if (recentSongsList.length > 3) {
            songsText += "...";
          }
        }

        String formattedDate = "";
        if (hasBeenPlayed) {
          formattedDate = DateFormat('d MMMM yyyy', 'fr_FR')
              .format(artistLastPlayed[artist]!);
        }

        return InkWell(
          onTap: () => onArtistSelected(artist),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: index > 0 && (index == sortedArtists.length)
                  ? Border(
                      top: BorderSide(color: Colors.grey.shade300, width: 1))
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        artist,
                        style: TextStyle(
                          fontFamily: 'Cormorant',
                          fontSize: 18,
                          color: hasBeenPlayed
                              ? Colors.black
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                    Text(
                      "$count chord${count > 1 ? 's' : ''}",
                      style: TextStyle(
                        fontFamily: 'Cormorant',
                        fontSize: 14,
                        color:
                            hasBeenPlayed ? Colors.black : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                if (songsText.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            songsText,
                            style: TextStyle(
                              fontFamily: 'Cormorant',
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontFamily: 'Cormorant',
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../utils/string_normalization.dart';
import '../data/collections/song.dart';

class ArtistsView extends StatelessWidget {
  final Map<String, int> artistsCount;
  final Function(String) onArtistSelected;
  final List<Song> songs;

  const ArtistsView({
    super.key,
    required this.artistsCount,
    required this.onArtistSelected,
    required this.songs,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final artists = artistsCount.keys.toList()
      ..sort((a, b) => normalizeString(a).compareTo(normalizeString(b)));
    final Map<String, List<String>> groupedArtists = {};
    final Map<String, List<dynamic>> artistSongs = {};

    for (var song in songs) {
      final artist = (song.artist ?? loc.artistsUnknown).toString();
      artistSongs[artist] = (artistSongs[artist] ?? [])..add(song);
    }

    artistSongs.forEach((artist, songsList) {
      songsList.sort((a, b) {
        final titleA = normalizeString(a.title ?? "");
        final titleB = normalizeString(b.title ?? "");
        return titleA.compareTo(titleB);
      });
    });

    for (var artist in artists) {
      String normalizedArtist = normalizeString(artist);
      String firstLetter = normalizedArtist.isNotEmpty
          ? normalizedArtist[0].toUpperCase()
          : loc.artistsOther;

      if (!RegExp(r'[A-Z]').hasMatch(firstLetter)) {
        firstLetter = loc.artistsOther;
      }

      groupedArtists[firstLetter] = (groupedArtists[firstLetter] ?? [])
        ..add(artist);
    }

    final sortedKeys = groupedArtists.keys.toList()
      ..sort((a, b) {
        if (a == loc.artistsOther) return 1;
        if (b == loc.artistsOther) return -1;
        return a.compareTo(b);
      });

    return ListView.builder(
      padding: const EdgeInsets.only(top: 20),
      itemCount: sortedKeys.length * 2,
      itemBuilder: (context, index) {
        final isHeader = index % 2 == 0;
        final keyIndex = index ~/ 2;

        if (keyIndex >= sortedKeys.length) {
          return const SizedBox.shrink();
        }

        final key = sortedKeys[keyIndex];

        if (isHeader) {
          return Container(
            padding: keyIndex == 0
                ? EdgeInsets.zero
                : const EdgeInsets.only(top: 15, bottom: 5),
            child: Row(
              children: [
                Text(
                  key,
                  style: const TextStyle(
                    fontFamily: 'Cormorant',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Divider(
                    color: Colors.grey.shade400,
                    thickness: 0.5,
                  ),
                ),
              ],
            ),
          );
        } else {
          return Column(
            children: groupedArtists[key]!.map((artist) {
              final count = artistsCount[artist] ?? 0;
              final artistSongsList = artistSongs[artist] ?? [];
              final topSongs = artistSongsList.take(3).toList();
              final artistStyle =
                  const TextStyle(fontFamily: 'Cormorant', fontSize: 18);
              final dynamicArtistStyle =
                  getDynamicTextStyle(artist, artistStyle);

              String songsText = "";
              if (topSongs.isNotEmpty) {
                final titles = topSongs
                    .map<String>((song) => (song.title ?? "").toString())
                    .toList();
                songsText = titles.join(", ");

                if (artistSongsList.length > 3) {
                  songsText += "...";
                }
              }

              return InkWell(
                onTap: () => onArtistSelected(artist),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              artist,
                              style: dynamicArtistStyle,
                            ),
                          ),
                          Text(
                            "$count chord${count > 1 ? 's' : ''}",
                            style: const TextStyle(
                              fontFamily: 'Cormorant',
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      if (songsText.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Padding(
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
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }
      },
    );
  }
}

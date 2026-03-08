import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/collections/song.dart';
import '../screens/song_page.dart';
import 'common/song_tile.dart';
import 'song_options_popup.dart';

class ArtistSongsListWidget extends ConsumerWidget {
  final List<Song> songs;

  const ArtistSongsListWidget({super.key, required this.songs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortedSongs = List<Song>.from(songs);
    sortedSongs.sort((a, b) {
      final titleA = (a.title ?? "").toLowerCase();
      final titleB = (b.title ?? "").toLowerCase();
      return titleA.compareTo(titleB);
    });

    return ListView.builder(
      padding: const EdgeInsets.only(top: 10),
      itemCount: sortedSongs.length,
      itemBuilder: (context, index) {
        final song = sortedSongs[index];

        return SongTile(
          song: song,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SongPage(songData: song)),
            );
          },
          onLongPress: () => showSongOptionsPopup(context, ref, song),
        );
      },
    );
  }
}

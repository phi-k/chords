import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../data/collections/song.dart';
import '../screens/song_page.dart';
import 'common/song_tile.dart';
import 'song_options_popup.dart';

class RecentSongsView extends ConsumerWidget {
  final List<Song> songs;
  final bool reversed;

  const RecentSongsView({
    super.key,
    required this.songs,
    required this.reversed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playedSongs = songs.where((song) => song.lastPlayed != null).toList();

    if (playedSongs.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.recentNoSongsPlayed,
          style: TextStyle(fontFamily: 'Cormorant', fontSize: 18),
        ),
      );
    }

    playedSongs.sort((a, b) {
      final DateTime dateA = a.lastPlayed ?? DateTime(2000, 1, 1);
      final DateTime dateB = b.lastPlayed ?? DateTime(2000, 1, 1);
      return reversed ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    });

    return ListView.builder(
      padding: const EdgeInsets.only(top: 10),
      itemCount: playedSongs.length,
      itemBuilder: (context, index) {
        final song = playedSongs[index];

        String lastPlayedDate = "";
        if (song.lastPlayed != null) {
          final DateTime lastPlayed = song.lastPlayed!;
          lastPlayedDate = DateFormat(
            'd MMMM yyyy',
            'fr_FR',
          ).format(lastPlayed);
        }

        return SongTile(
          song: song,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SongPage(songData: song)),
            );
          },
          onLongPress: () => showSongOptionsPopup(context, ref, song),
          subtitleTrailing: Text(
            lastPlayedDate,
            style: TextStyle(
              fontFamily: 'Cormorant',
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        );
      },
    );
  }
}

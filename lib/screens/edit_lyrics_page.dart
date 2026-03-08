import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/collections/song.dart';
import '../l10n/app_localizations.dart';

class EditLyricsPage extends StatefulWidget {
  final Song songData;
  final Function(Song) onLyricsUpdated;

  const EditLyricsPage({
    super.key,
    required this.songData,
    required this.onLyricsUpdated,
  });

  @override
  State<EditLyricsPage> createState() => _EditLyricsPageState();
}

class _EditLyricsPageState extends State<EditLyricsPage> {
  late TextEditingController _lyricsController;
  late String _originalLyrics;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _originalLyrics = widget.songData.lyricsWithChords ?? '';
    _lyricsController = TextEditingController(text: _originalLyrics);

    _lyricsController.addListener(() {
      if (_lyricsController.text != _originalLyrics && !_hasChanges) {
        setState(() {
          _hasChanges = true;
        });
      } else if (_lyricsController.text == _originalLyrics && _hasChanges) {
        setState(() {
          _hasChanges = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _lyricsController.dispose();
    super.dispose();
  }

  Future<void> _saveLyrics() async {
    final Song updatedSong = Song(
      songUrl: widget.songData.songUrl,
      title: widget.songData.title,
      artist: widget.songData.artist,
      difficulty: widget.songData.difficulty,
      capo: widget.songData.capo,
      tuning: widget.songData.tuning,
      lyricsWithChords: _lyricsController.text,
      originalLyricsWithChords:
          widget.songData.originalLyricsWithChords ?? _originalLyrics,
      transpose: widget.songData.transpose,
      simplified: widget.songData.simplified,
      addedDate: widget.songData.addedDate,
      savedDate: widget.songData.savedDate,
      playCount: widget.songData.playCount,
      lastPlayed: widget.songData.lastPlayed,
      playHistory: List<String>.from(widget.songData.playHistory),
      coverUrl: widget.songData.coverUrl,
      tags: List<String>.from(widget.songData.tags),
    );

    widget.onLyricsUpdated(updatedSong);
    Navigator.pop(context, updatedSong);
  }

  void _resetLyrics() {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            loc.editLyricsResetTitle,
            style: GoogleFonts.cormorant(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            loc.editLyricsResetMessage,
            style: GoogleFonts.cormorant(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                loc.commonCancel,
                style: GoogleFonts.cormorant(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                final originalLyrics =
                    widget.songData.originalLyricsWithChords ?? _originalLyrics;
                setState(() {
                  _lyricsController.text = originalLyrics;
                });
                Navigator.of(context).pop();
              },
              child: Text(
                loc.editLyricsReset,
                style: GoogleFonts.cormorant(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          loc.editLyricsTitle(widget.songData.title ?? ''),
          style: GoogleFonts.cormorant(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
                height: MediaQuery.of(context).padding.top +
                    AppBar().preferredSize.height),
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ThemeData().colorScheme.copyWith(
                        primary: Colors.red,
                      ),
                ),
                child: TextField(
                  controller: _lyricsController,
                  maxLines: null,
                  expands: true,
                  cursorColor: Colors.red,
                  style: const TextStyle(
                    fontFamily: 'UbuntuMono',
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                    hintText: loc.editLyricsHint,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: _resetLyrics,
                  icon: const Icon(Icons.restore, color: Colors.black),
                  tooltip: loc.editLyricsResetTooltip,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close, color: Colors.black),
                  tooltip: loc.commonCancel,
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _saveLyrics,
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: Text(
                    loc.commonSave,
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

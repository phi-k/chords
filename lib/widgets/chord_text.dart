import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class ChordText extends StatelessWidget {
  final String text;
  final TextStyle chordStyle;
  final TextStyle lyricStyle;

  const ChordText({
    super.key,
    required this.text,
    required this.chordStyle,
    required this.lyricStyle,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: formatChords(context, text, chordStyle, lyricStyle),
    );
  }

  static final Set<String> chordTypes = {
    "",
    "m",
    "maj",
    "min",
    "dim",
    "aug",
    "sus2",
    "sus4",
    "sus",
    "add9",
    "5",
    "6",
    "7",
    "9",
    "11",
    "13",
    "4",
    "m6",
    "m7",
    "maj7",
    "m9",
    "maj9",
    "dim7",
    "aug7",
    "7sus4",
    "7b9",
    "m11",
    "maj13",
    "7#9",
    "b5",
    "#5",
    "b9",
    "#9",
    "#11",
    "b13",
    "(m)",
    "(maj)",
    "(min)",
    "(dim)",
    "(aug)",
    "(sus2)",
    "(sus4)",
    "(sus)",
    "(add9)",
    "(b5)",
    "(#5)",
    "(b9)",
    "(#9)",
    "(#11)",
    "(b13)",
    "(6)",
    "(m6)",
    "(4)"
  };

  static bool isValidChord(String input) {
    final String baseChordPattern = r'[A-G](?:#|b)?'
        r'(?:m|maj|min|dim|aug|sus2|sus4|sus|add9|5|6|7|9|11|13|4|m6|m7|maj7|m9|maj9|dim7|aug7|7sus4|7b9|m11|maj13|7#9|b5|#5|b9|#9|#11|b13)?'
        r'(?:\([^)]+\))?'
        r'(?:\/[A-G](?:#|b)?)?'
        r'\*?';

    final RegExp chordRegex = RegExp(
        r'^(?:\(' + baseChordPattern + r'\)|' + baseChordPattern + r')$');

    return chordRegex.hasMatch(input.trim());
  }

  static bool isPositionIndicator(String input) {
    final RegExp positionRegex = RegExp(
        r'^\[(Intro|Interlude|Verse|Chorus|Pre-chorus|Bridge|Break|Solo|Instrumental|Outro)(?:\s+\d+)?\]$');
    return positionRegex.hasMatch(input);
  }

  static InlineSpan formatChords(BuildContext context, String text,
      TextStyle chordStyle, TextStyle lyricStyle) {
    final lines = text.split('\n');

    return TextSpan(
      children: lines.expand((line) {
        final trimmedLine = line.trim();
        if (isPositionIndicator(trimmedLine)) {
          return [
            WidgetSpan(
              child: Container(
                margin: EdgeInsets.only(
                  top: lines.indexOf(line) > 0 &&
                          lines[lines.indexOf(line) - 1].trim().isNotEmpty
                      ? 18
                      : 8,
                  bottom: 8,
                ),
                child: Text(
                  trimmedLine,
                  style: lyricStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: lyricStyle.fontSize! * 0.8,
                  ),
                ),
              ),
            ),
            const TextSpan(text: "\n")
          ];
        } else {
          final words = line.split(' ');
          return words.map((word) {
            if (isValidChord(word)) {
              return WidgetSpan(
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.white,
                        content: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(
                            AppLocalizations.of(context)!.songNoCheat,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Cormorant',
                              color: Colors.black,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        actionsAlignment: MainAxisAlignment.center,
                        actions: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 1),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                AppLocalizations.of(context)!
                                    .songNoCheatDismiss,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Cormorant',
                                  color: Colors.black,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 2.5, vertical: 0),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE2E2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      word,
                      style: chordStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return TextSpan(
                text: '$word ',
                style: lyricStyle,
              );
            }
          }).toList()
            ..add(const TextSpan(text: "\n"));
        }
      }).toList(),
    );
  }
}

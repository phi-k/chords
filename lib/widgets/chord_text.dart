// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../utils/chord_detector.dart';

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

  static InlineSpan buildBubble(
      BuildContext context, String word, TextStyle chordStyle) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
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
                  style: const TextStyle(
                      fontFamily: 'Cormorant',
                      color: Colors.black,
                      fontSize: 20),
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
                      AppLocalizations.of(context)!.songNoCheatDismiss,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontFamily: 'Cormorant',
                          color: Colors.black,
                          fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE2E2),
            borderRadius: BorderRadius.circular(4),
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
  }

  static InlineSpan formatChords(BuildContext context, String text,
      TextStyle chordStyle, TextStyle lyricStyle) {
    final String safeText = text.replaceAll('\r', '');
    final lines = safeText.split('\n');

    return TextSpan(
      children: lines.expand((line) {
        final trimmedLine = line.trim();

        if (ChordDetector.isPositionIndicator(trimmedLine)) {
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
        } else if (ChordDetector.isChordLine(line)) {
          final words = line.split(' ');
          final List<InlineSpan> spans = [];

          final textStyleForDecorations = chordStyle.copyWith(
            fontWeight: FontWeight.normal,
            color: Colors.grey.shade800,
          );

          for (int i = 0; i < words.length; i++) {
            final word = words[i];

            if (word.isEmpty) {
              if (i < words.length - 1) {
                spans.add(TextSpan(text: ' ', style: textStyleForDecorations));
              }
              continue;
            }

            bool handled = false;
            final cleanWord = ChordDetector.cleanToken(word);

            if (ChordDetector.isChordOrNC(cleanWord)) {
              spans.add(buildBubble(context, word, chordStyle));
              handled = true;
            } else if (word.contains('-')) {
              final subWords = word.split('-');
              bool allValid = true;

              for (String sub in subWords) {
                if (sub.isNotEmpty &&
                    !ChordDetector.isChordOrNC(ChordDetector.cleanToken(sub))) {
                  allValid = false;
                  break;
                }
              }

              if (allValid && subWords.length > 1) {
                for (int j = 0; j < subWords.length; j++) {
                  final sub = subWords[j];
                  if (sub.isNotEmpty) {
                    spans.add(buildBubble(context, sub, chordStyle));
                  }
                  if (j < subWords.length - 1) {
                    spans.add(
                        TextSpan(text: '-', style: textStyleForDecorations));
                  }
                }
                handled = true;
              }
            }

            if (!handled) {
              spans.add(TextSpan(text: word, style: textStyleForDecorations));
            }

            if (i < words.length - 1) {
              spans.add(TextSpan(text: ' ', style: textStyleForDecorations));
            }
          }
          spans.add(const TextSpan(text: "\n"));
          return spans;
        } else {
          return [
            TextSpan(
              text: '$line\n',
              style: lyricStyle,
            )
          ];
        }
      }).toList(),
    );
  }
}

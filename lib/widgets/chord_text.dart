// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

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

  static String cleanToken(String input) {
    String cleaned = input.replaceAll(RegExp(r'^[\(\[\{\<]+|[\)\]\}\>]+$|[,;!?]+$'), '');
    if (!cleaned.toUpperCase().startsWith('N.C') && cleaned.endsWith('.')) {
      cleaned = cleaned.replaceAll(RegExp(r'\.+$'), '');
    }
    return cleaned;
  }

  static bool isNC(String cleanInput) {
    final upper = cleanInput.toUpperCase();
    return upper == 'N.C.' || upper == 'NC' || upper == 'N.C';
  }

  static bool isValidChord(String cleanInput) {
    if (cleanInput.isEmpty) return false;

    final RegExp chordRegex = RegExp(
        r'^[A-G][#b]?(?:m|min|maj|M|dim|aug|sus\d*|add\d*|m?\d+|[#b]\d+|\+|-|°|\(|\))*?(?:\/(?:[A-G][#b]?|\d+))?\**$'
    );

    return chordRegex.hasMatch(cleanInput);
  }

  static bool isChordOrNC(String token) {
    final clean = cleanToken(token);
    if (clean.isEmpty) return false;
    if (isNC(clean)) return true;
    return isValidChord(clean);
  }

  static bool isTabDecoration(String cleanToken) {
    if (cleanToken.isEmpty) return true;

    if (RegExp(r'^[\d\|\/\-\.\\\:\%\*\~]+$').hasMatch(cleanToken)) return true;
    if (RegExp(r'^[xX]\d+$').hasMatch(cleanToken)) return true;

    final upper = cleanToken.toUpperCase();
    if (['RIFF', 'FILL', 'STOP', 'PAUSE', 'BASS', 'DRUMS', 'ALL', 'TAB', 'PM', 'P.M.'].contains(upper)) {
      return true;
    }
    return false;
  }

  static bool isPositionIndicator(String input) {
    final RegExp positionRegex = RegExp(
        r'^\[(Intro|Interlude|Verse|Chorus|Pre-chorus|Bridge|Break|Solo|Instrumental|Outro)(?:\s+\d+)?\]$',
        caseSensitive: false);
    return positionRegex.hasMatch(input);
  }

  static bool isChordLine(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) return false;
    if (isPositionIndicator(trimmed)) return false;

    final tokens = trimmed.split(RegExp(r'\s+'));

    int chordCount = 0;
    int textCount = 0;
    bool inParens = false;

    for (String rawToken in tokens) {
      if (rawToken.isEmpty) continue;

      bool startsParen = rawToken.startsWith('(') || rawToken.startsWith('[') || rawToken.startsWith('{');
      bool endsParen = rawToken.endsWith(')') || rawToken.endsWith(']') || rawToken.endsWith('}');

      if (startsParen) inParens = true;

      if (isChordOrNC(rawToken)) {
        chordCount++;
      } else if (isTabDecoration(cleanToken(rawToken))) {
      } else if (rawToken.contains('-')) {
        final subTokens = rawToken.split('-');
        bool allValid = true;
        int localChordCount = 0;

        for (String sub in subTokens) {
          if (sub.isNotEmpty) {
            if (isChordOrNC(sub)) {
              localChordCount++;
            } else {
              allValid = false; break;
            }
          }
        }

        if (allValid && localChordCount > 0) {
          chordCount += localChordCount;
        } else {
          if (inParens || startsParen || endsParen) {
            textCount++;
          } else {
            return false;
          }
        }
      } else {
        if (inParens || startsParen || endsParen) {
          textCount++;
        } else {
          return false;
        }
      }

      if (endsParen) inParens = false;
    }

    return chordCount > 0 && (chordCount * 2 >= textCount);
  }

  static InlineSpan buildBubble(BuildContext context, String word, TextStyle chordStyle) {
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
                  style: const TextStyle(fontFamily: 'Cormorant', color: Colors.black, fontSize: 20),
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions:[
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
                      style: const TextStyle(fontFamily: 'Cormorant', color: Colors.black, fontSize: 20),
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

  static InlineSpan formatChords(BuildContext context, String text, TextStyle chordStyle, TextStyle lyricStyle) {
    final lines = text.split('\n');

    return TextSpan(
      children: lines.expand((line) {
        final trimmedLine = line.trim();

        if (isPositionIndicator(trimmedLine)) {
          return[
            WidgetSpan(
              child: Container(
                margin: EdgeInsets.only(
                  top: lines.indexOf(line) > 0 && lines[lines.indexOf(line) - 1].trim().isNotEmpty ? 18 : 8,
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
        }

        else if (isChordLine(line)) {
          final words = line.split(' ');
          final List<InlineSpan> spans =[];

          final textStyleForDecorations = chordStyle.copyWith(
            fontWeight: FontWeight.normal,
            color: Colors.grey.shade800,
          );

          for (int i = 0; i < words.length; i++) {
            final word = words[i];

            if (word.isEmpty) {
              if (i < words.length - 1) spans.add(TextSpan(text: ' ', style: textStyleForDecorations));
              continue;
            }

            bool handled = false;

            if (isChordOrNC(word)) {
              spans.add(buildBubble(context, word, chordStyle));
              handled = true;
            }
            else if (word.contains('-')) {
              final subWords = word.split('-');
              bool allValid = true;

              for (String sub in subWords) {
                if (sub.isNotEmpty && !isChordOrNC(sub)) {
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
                    spans.add(TextSpan(text: '-', style: textStyleForDecorations));
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
        }

        else {
          return[
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
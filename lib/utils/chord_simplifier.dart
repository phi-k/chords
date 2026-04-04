// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'chord_detector.dart';

String simplifyChord(String chord) {
  if (chord.startsWith('(') && chord.endsWith(')')) {
    String inner = chord.substring(1, chord.length - 1);
    String simplifiedInner = simplifyChord(inner);
    return '($simplifiedInner)';
  }

  final RegExp exp = RegExp(r'^([A-G][#b]?)(m)?', caseSensitive: false);
  final Match? match = exp.firstMatch(chord);
  if (match == null) return chord;
  String kept = match.group(0)!;
  int keepLength = kept.length;

  String tailReplacement =
      chord.length > keepLength ? ' ' * (chord.length - keepLength) : '';
  return kept + tailReplacement;
}

String simplifyChordsInText(String text) {
  final lines = text.split('\n');
  final simplifiedLines = <String>[];

  for (final line in lines) {
    if (ChordDetector.isChordLine(line)) {
      final matches = RegExp(r'\S+').allMatches(line);
      var newLine = StringBuffer();
      int currentPos = 0;

      for (var match in matches) {
        newLine.write(line.substring(currentPos, match.start));
        var token = match.group(0)!;

        if (token.contains('-')) {
          final subTokens = token.split('-');
          final simplifiedSubs = subTokens.map((sub) {
            if (ChordDetector.isValidChord(ChordDetector.cleanToken(sub))) {
              return simplifyChord(sub);
            }
            return sub;
          }).join('-');
          newLine.write(simplifiedSubs);
        } else {
          if (ChordDetector.isValidChord(ChordDetector.cleanToken(token))) {
            newLine.write(simplifyChord(token));
          } else {
            newLine.write(token);
          }
        }

        currentPos = match.end;
      }
      if (currentPos < line.length) {
        newLine.write(line.substring(currentPos));
      }
      simplifiedLines.add(newLine.toString());
    } else {
      simplifiedLines.add(line);
    }
  }
  return simplifiedLines.join('\n');
}

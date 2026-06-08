// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

class ChordDetector {
  static String cleanToken(String input) {
    String cleaned =
        input.replaceAll(RegExp(r'^[\(\[\{\<]+|[\)\]\}\>]+$|[,;!?]+$'), '');
    if (!cleaned.toUpperCase().startsWith('N.C') && cleaned.endsWith('.')) {
      cleaned = cleaned.replaceAll(RegExp(r'\.+$'), '');
    }
    return cleaned.trim();
  }

  static bool isNC(String cleanInput) {
    final upper = cleanInput.toUpperCase();
    return upper == 'N.C.' || upper == 'NC' || upper == 'N.C';
  }

  static bool isValidChord(String cleanInput) {
    if (cleanInput.isEmpty) return false;

    final RegExp chordRegex = RegExp(
      r'^[A-G][#b]?(?:m|min|maj|M|dim|aug|sus\d*|add\d*|m?\d+|[#b]\d+|\+|-|°|\(|\))*?(?:\/(?:[A-G][#b]?|\d+))?\**$',
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
    if ([
      'RIFF',
      'FILL',
      'STOP',
      'PAUSE',
      'BASS',
      'DRUMS',
      'ALL',
      'TAB',
      'PM',
      'P.M.'
    ].contains(upper)) {
      return true;
    }
    return false;
  }

  static bool isPositionIndicator(String input) {
    final RegExp positionRegex = RegExp(
      r'^\[(Intro|Interlude|Verse|Chorus|Pre-chorus|Bridge|Break|Solo|Instrumental|Outro)(?:\s+\d+)?\]$',
      caseSensitive: false,
    );
    return positionRegex.hasMatch(input.replaceAll('\r', '').trim());
  }

  static bool isChordLine(String line) {
    final normalized = line
        .replaceAll(RegExp(r'[\u00A0\u2007\u202F]'), ' ')
        .replaceAll('\t', '    ');
    final trimmed = normalized.replaceAll('\r', '').trim();
    if (trimmed.isEmpty) return false;
    if (isPositionIndicator(trimmed)) return false;

    final tokens = trimmed.split(RegExp(r'\s+'));

    int chordCount = 0;
    int textCount = 0;
    bool inParens = false;

    for (String rawToken in tokens) {
      if (rawToken.isEmpty) continue;

      bool startsParen = rawToken.startsWith('(') ||
          rawToken.startsWith('[') ||
          rawToken.startsWith('{');
      bool endsParen = rawToken.endsWith(')') ||
          rawToken.endsWith(']') ||
          rawToken.endsWith('}');

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
              allValid = false;
              break;
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
}

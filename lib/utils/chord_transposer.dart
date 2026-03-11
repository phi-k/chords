// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

class ChordTransposer {
  static const List<String> _sharpNotes = ['A', 'A#', 'B', 'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#'];
  static const List<String> _flatNotes  = ['A', 'Bb', 'B', 'C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab'];

  static final Map<String, String> enharmonics = {
    'A#': 'Bb', 'C#': 'Db', 'D#': 'Eb', 'F#': 'Gb', 'G#': 'Ab',
    'Bb': 'A#', 'Db': 'C#', 'Eb': 'D#', 'Gb': 'F#', 'Ab': 'G#'
  };

  static final Set<String> chordTypes = {
    "", "m", "maj", "min", "dim", "aug", "sus2", "sus4", "sus", "add9",
    "5", "6", "7", "9", "11", "13", "4", "m6", "m7", "maj7", "m9", "maj9", "dim7",
    "aug7", "7sus4", "7b9", "m11", "maj13", "7#9", "b5", "#5", "b9", "#9", "#11", "b13",
    "(m)", "(maj)", "(min)", "(dim)", "(aug)", "(sus2)", "(sus4)", "(sus)", "(add9)",
    "(b5)", "(#5)", "(b9)", "(#9)", "(#11)", "(b13)", "(6)", "(m6)", "(4)"
  };

  static bool isValidChord(String input) {
    final String baseChordPattern =
        r'[A-G](?:#|b)?'
        r'(?:m|maj|min|dim|aug|sus2|sus4|sus|add9|5|6|7|9|11|13|4|m6|m7|maj7|m9|maj9|dim7|aug7|7sus4|7b9|m11|maj13|7#9|b5|#5|b9|#9|#11|b13)?'
        r'(?:\([^)]+\))?'
        r'(?:\/[A-G](?:#|b)?)?'
        r'\*?';

    final RegExp chordRegex = RegExp(
        r'^(?:\(' + baseChordPattern + r'\)|' + baseChordPattern + r')$'
    );

    return chordRegex.hasMatch(input.trim());
  }

  static int _getNoteIndex(String note) {
    int index = _sharpNotes.indexOf(note);
    if (index != -1) return index;
    return _flatNotes.indexOf(note);
  }

  static String _getTransposedNote(String note, int semitones, bool preferFlats) {
    int index = _getNoteIndex(note);
    if (index == -1) return note;

    int newIndex = (index + semitones) % 12;
    if (newIndex < 0) newIndex += 12;

    return preferFlats ? _flatNotes[newIndex] : _sharpNotes[newIndex];
  }

  static String transposeChord(String chord, int semitones, {bool preferFlats = false}) {
    if (!isValidChord(chord)) return chord;

    bool startsWithParenthesis = chord.startsWith('(');
    String chordWithoutParentheses = startsWithParenthesis ? chord.substring(1, chord.length - 1) : chord;

    final rootMatch = RegExp(r'^([A-G][#b]?)').firstMatch(chordWithoutParentheses);
    if (rootMatch == null) return chord;

    String rootNote = rootMatch.group(1)!;
    String remainder = chordWithoutParentheses.substring(rootNote.length);

    String transposedRoot = _getTransposedNote(rootNote, semitones, preferFlats);

    if (remainder.contains('/')) {
      int slashIndex = remainder.indexOf('/');
      String bassNote = remainder.substring(slashIndex + 1);
      String middle = remainder.substring(0, slashIndex);

      final bassMatch = RegExp(r'^([A-G][#b]?)').firstMatch(bassNote);
      if (bassMatch != null) {
        String bassRoot = bassMatch.group(1)!;
        String bassRest = bassNote.substring(bassRoot.length);
        String transposedBass = _getTransposedNote(bassRoot, semitones, preferFlats);
        String transposed = '$transposedRoot$middle/$transposedBass$bassRest';
        return startsWithParenthesis ? '($transposed)' : transposed;
      }
    }

    String transposed = '$transposedRoot$remainder';
    return startsWithParenthesis ? '($transposed)' : transposed;
  }

  static bool _isTabDecoration(String token) {
    if (RegExp(r'^[\d\|\/\-\.\\\:\(\)\%]+$').hasMatch(token)) return true;
    if (RegExp(r'^[\(]?[xX]\d+[\)]?$').hasMatch(token)) return true;
    if (token == 'N.C.' || token == 'NC') return true;

    return false;
  }

  static bool _isChordLine(String line) {
    final trimmedLine = line.trim();
    if (trimmedLine.isEmpty) return false;
    if (trimmedLine.startsWith('[') && trimmedLine.endsWith(']')) return false;

    return trimmedLine
        .split(RegExp(r'\s+'))
        .every((token) => token.isEmpty || isValidChord(token) || _isTabDecoration(token));
  }

  static String transposeLyricsWithChords(String lyricsWithChords, int semitones) {
    if (semitones == 0) return lyricsWithChords;

    final lines = lyricsWithChords.split('\n');
    final transposedLines = <String>[];
    bool preferFlats = lyricsWithChords.contains(RegExp(r'[A-G]b'));

    for (final line in lines) {
      if (_isChordLine(line)) {
        final matches = RegExp(r'\S+').allMatches(line);
        var newLine = StringBuffer();
        int currentPos = 0;
        for (var match in matches) {
          newLine.write(line.substring(currentPos, match.start));
          var token = match.group(0)!;
          if (isValidChord(token)) {
            newLine.write(transposeChord(token, semitones, preferFlats: preferFlats));
          } else {
            newLine.write(token);
          }
          currentPos = match.end;
        }
        if (currentPos < line.length) {
          newLine.write(line.substring(currentPos));
        }
        transposedLines.add(newLine.toString());
      } else {
        transposedLines.add(line);
      }
    }
    return transposedLines.join('\n');
  }
}
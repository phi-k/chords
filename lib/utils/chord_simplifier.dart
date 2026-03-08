bool isValidChord(String input) {
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

  String tailReplacement = chord.length > keepLength
      ? ' ' * (chord.length - keepLength)
      : '';
  return kept + tailReplacement;
}

bool _isChordLine(String line) {
  final trimmedLine = line.trim();
  if (trimmedLine.isEmpty) return false;
  if (trimmedLine.startsWith('[') && trimmedLine.endsWith(']')) return false;

  return trimmedLine
      .split(RegExp(r'\s+'))
      .every((token) => token.isEmpty || isValidChord(token));
}

String simplifyChordsInText(String text) {
  final lines = text.split('\n');
  final simplifiedLines = <String>[];

  for (final line in lines) {
    if (_isChordLine(line)) {
      final matches = RegExp(r'\S+').allMatches(line);
      var newLine = StringBuffer();
      int currentPos = 0;
      for (var match in matches) {
        newLine.write(line.substring(currentPos, match.start));
        var token = match.group(0)!;
        if (isValidChord(token)) {
          newLine.write(simplifyChord(token));
        } else {
          newLine.write(token);
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
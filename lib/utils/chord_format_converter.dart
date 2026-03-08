import 'dart:developer';

class ChordFormatConverter {
  static String convertOnlineToOffline(String onlineLyrics) {
    log('--------------- AVANT CONVERSION ---------------');
    log('Format: Chordpro (accords en ligne)');
    log('---------------------------------------------');
    log(onlineLyrics.trim());

    String cleanedLyrics =
        onlineLyrics.replaceAll(RegExp(r'\[/?tab\]'), '').trim();

    final lines = cleanedLyrics.split('\n');
    final resultBuffer = StringBuffer();

    for (var line in lines) {
      if (line.trim().isEmpty) {
        resultBuffer.writeln();
        continue;
      }

      final chordLine = StringBuffer();
      final lyricLine = StringBuffer();
      int lastIndex = 0;

      final matches = RegExp(r'\[ch\](.*?)\[/ch\]').allMatches(line);

      if (matches.isEmpty) {
        resultBuffer.writeln(line);
        continue;
      }

      for (var match in matches) {
        final precedingText = line.substring(lastIndex, match.start);
        final chord = match.group(1)!;

        lyricLine.write(precedingText);
        chordLine.write(' ' * precedingText.length);
        chordLine.write(chord);

        lastIndex = match.end;
      }

      lyricLine.write(line.substring(lastIndex));

      final finalLyricLine = lyricLine.toString().trim();
      final finalChordLine = chordLine.toString().trimRight();

      if (finalChordLine.isNotEmpty) {
        resultBuffer.writeln(finalChordLine);
      }

      if (finalLyricLine.isNotEmpty) {
        resultBuffer.writeln(finalLyricLine);
      }
    }

    final convertedText = resultBuffer.toString();

    log('\n\n--------------- APRÈS CONVERSION ---------------');
    log('Format: Accords au-dessus des paroles');
    log('----------------------------------------------');
    log(convertedText.trim());
    log('\n\n');

    return convertedText;
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'chord_text.dart';

class ChordLyricsDisplay extends StatelessWidget {
  final String text;
  final TextStyle chordStyle;
  final TextStyle lyricStyle;

  const ChordLyricsDisplay({
    super.key,
    required this.text,
    TextStyle? chordStyle,
    TextStyle? lyricStyle,
  })  : chordStyle = chordStyle ??
            const TextStyle(
              fontFamily: 'UbuntuMono',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
        lyricStyle = lyricStyle ??
            const TextStyle(
              fontFamily: 'UbuntuMono',
              fontSize: 16,
              color: Colors.black,
            );

  bool isChordToken(String token) {
    final chordRegex = RegExp(
        r'^[A-G][#b]?(?:m|maj|min|sus|dim|aug|add|7|9|11|13)?(?:/[A-G][#b]?(?:m|maj|min|sus|dim|aug|add|7|9|11|13)?)?$');
    return chordRegex.hasMatch(token);
  }

  bool isChordLine(String line) {
    if (line.trim().isEmpty) return false;
    List<String> tokens = line.trim().split(RegExp(r'\s+'));
    bool hasChord = tokens.any((token) => isChordToken(token));
    return hasChord && line.contains('  ');
  }

  int nextBreakIndex(String line, int pos, int maxChars) {
    if (pos >= line.length) return line.length;

    int tentative = pos + maxChars;
    if (tentative >= line.length) return line.length;

    int lastSpace = line.lastIndexOf(' ', tentative);

    return (lastSpace > pos) ? lastSpace : tentative;
  }

  List<Widget> buildChordLyricsPair(
      String chordLine, String lyricLine, int maxChars) {
    List<Widget> widgets = [];

    if (lyricLine.length <= maxChars && chordLine.length <= maxChars) {
      widgets.add(Text(chordLine, style: chordStyle));
      widgets.add(Text(lyricLine, style: lyricStyle));
      return widgets;
    }

    int pos = 0;
    int lyricLen = lyricLine.length;
    int chordLen = chordLine.length;
    int maxLen = max(lyricLen, chordLen);

    while (pos < maxLen) {
      int lyricBreak = (pos < lyricLen)
          ? nextBreakIndex(lyricLine, pos, maxChars)
          : pos + maxChars;

      int chordBreak = (pos < chordLen)
          ? nextBreakIndex(chordLine, pos, maxChars)
          : pos + maxChars;

      int breakIndex = max(lyricBreak, chordBreak);

      if (breakIndex <= pos) breakIndex = pos + 1;

      String lyricSegment = '';
      if (pos < lyricLen) {
        int end = min(breakIndex, lyricLen);
        if (end > pos) lyricSegment = lyricLine.substring(pos, end);
      }

      String chordSegment = '';
      if (pos < chordLen) {
        int end = min(breakIndex, chordLen);
        if (end > pos) chordSegment = chordLine.substring(pos, end);
      }

      lyricSegment = lyricSegment.replaceAll(RegExp(r'\s+$'), '');
      chordSegment = chordSegment.replaceAll(RegExp(r'\s+$'), '');

      widgets.add(Text(chordSegment, style: chordStyle));
      if (lyricSegment.isNotEmpty) {
        widgets.add(Text(lyricSegment, style: lyricStyle));
      }

      pos = breakIndex;

      while (pos < lyricLen && lyricLine[pos] == ' ') {
        pos++;
      }
    }
    return widgets;
  }

  List<Widget> buildChordLyricsWidgets(BuildContext context, double maxWidth) {
    List<Widget> widgets = [];
    List<String> lines = text.split('\n');
    int i = 0;

    final TextPainter tp = TextPainter(
      text: TextSpan(text: 'M', style: chordStyle),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    double charWidth = tp.size.width;
    int maxChars = max(1, ((maxWidth / charWidth).floor()) - 1);

    while (i < lines.length) {
      String currentLine = lines[i];

      if (isChordLine(currentLine) &&
          i + 1 < lines.length &&
          !isChordLine(lines[i + 1])) {
        String chordLine = currentLine;
        String lyricLine = lines[i + 1];
        widgets.addAll(buildChordLyricsPair(chordLine, lyricLine, maxChars));
        i += 2;
      } else {
        widgets.add(Text(currentLine, style: lyricStyle));
        i++;
      }
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double maxWidth = constraints.maxWidth;
      if (maxWidth == double.infinity) {
        maxWidth = MediaQuery.of(context).size.width - 60;
      }

      List<Widget> children = buildChordLyricsWidgets(context, maxWidth);

      final formattedText = ChordText.formatChords(
        context,
        children.map((widget) => (widget as Text).data ?? '').join('\n'),
        chordStyle,
        lyricStyle,
      );

      return RichText(
        text: formattedText,
      );
    });
  }
}

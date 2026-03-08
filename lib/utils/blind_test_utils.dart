import 'dart:math';
import 'dart:math' as math;
import '../data/collections/song.dart';

class BlindTestUtils {
  static List<Song> shuffleSongs(List<Song> songs) {
    final random = Random();
    final shuffled = List<Song>.from(songs);

    for (int i = shuffled.length - 1; i > 0; i--) {
      int j = random.nextInt(i + 1);
      final temp = shuffled[i];
      shuffled[i] = shuffled[j];
      shuffled[j] = temp;
    }

    return shuffled;
  }

  static String extractSongBeginning(String lyricsWithChords) {
    if (lyricsWithChords.isEmpty) return '';

    final lines = lyricsWithChords.split('\n');
    final result = <String>[];
    bool foundFirstChorus = false;
    bool insideChorus = false;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmedLine = line.trim();

      if (_isSectionMarker(trimmedLine)) {
        final sectionType = _getSectionType(trimmedLine);

        if (foundFirstChorus && insideChorus && sectionType != 'chorus') {
          break;
        }

        if (sectionType == 'chorus') {
          insideChorus = true;
          foundFirstChorus = true;
        } else {
          insideChorus = false;
        }

        result.add(line);
      } else {
        result.add(line);

        if (insideChorus && trimmedLine.isEmpty) {
          bool isEndOfChorus = true;
          for (int j = i + 1; j < lines.length && j < i + 4; j++) {
            final nextLine = lines[j].trim();

            if (_isSectionMarker(nextLine)) {
              final nextSectionType = _getSectionType(nextLine);
              if (nextSectionType == 'chorus') {
                isEndOfChorus = false;
              }
              break;
            }

            if (nextLine.isNotEmpty) {
              isEndOfChorus = false;
              break;
            }
          }

          if (isEndOfChorus && foundFirstChorus) {
            break;
          }
        }
      }
    }

    if (!foundFirstChorus) {
      result.clear();
      final maxLines = math.min(30, lines.length);
      for (int i = 0; i < maxLines; i++) {
        result.add(lines[i]);
      }
    }

    return result.join('\n').trim();
  }

  static bool _isSectionMarker(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) return false;

    final sectionRegex = RegExp(
      r'^\[(Intro|Interlude|Verse|Chorus|Refrain|Couplet|Pre-chorus|Pre-refrain|Bridge|Pont|Break|Solo|Instrumental|Outro|End)(?:\s+\d+)?\]$',
      caseSensitive: false,
    );

    return sectionRegex.hasMatch(trimmed);
  }

  static String _getSectionType(String line) {
    final trimmed = line.trim().toLowerCase();

    if (trimmed.contains('chorus') || trimmed.contains('refrain')) {
      return 'chorus';
    } else if (trimmed.contains('verse') || trimmed.contains('couplet')) {
      return 'verse';
    } else if (trimmed.contains('intro')) {
      return 'intro';
    } else if (trimmed.contains('bridge') || trimmed.contains('pont')) {
      return 'bridge';
    } else if (trimmed.contains('outro') || trimmed.contains('end')) {
      return 'outro';
    } else if (trimmed.contains('solo') || trimmed.contains('instrumental')) {
      return 'instrumental';
    } else if (trimmed.contains('pre-chorus') ||
        trimmed.contains('pre-refrain')) {
      return 'pre-chorus';
    } else if (trimmed.contains('break')) {
      return 'break';
    } else if (trimmed.contains('interlude')) {
      return 'interlude';
    } else {
      return 'other';
    }
  }
}
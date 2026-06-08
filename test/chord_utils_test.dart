// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:chords/utils/chord_detector.dart';
import 'package:chords/utils/chord_transposer.dart';
import 'package:chords/utils/chord_format_converter.dart';

void main() {
  group('ChordDetector.isChordLine tests', () {
    test('standard spacing is recognized', () {
      expect(ChordDetector.isChordLine('Am    C    G'), isTrue);
    });

    test('non-breaking spaces are handled correctly', () {
      expect(ChordDetector.isChordLine('Am\u00A0\u00A0\u00A0C\u00A0\u00A0\u00A0G'), isTrue);
      expect(ChordDetector.isChordLine('Am\u2007\u2007C\u2007\u2007G'), isTrue);
      expect(ChordDetector.isChordLine('Am\u202FC\u202FG'), isTrue);
    });

    test('tabs are handled correctly', () {
      expect(ChordDetector.isChordLine('Am\tC\tG'), isTrue);
    });

    test('mixed normal, tabs and non-breaking spaces are handled correctly', () {
      expect(ChordDetector.isChordLine('Am\t C\u00A0 G'), isTrue);
    });

    test('non-chord lines with weird spaces are rejected', () {
      expect(ChordDetector.isChordLine('This\u00A0is\u00A0a\u00A0normal\u00A0sentence'), isFalse);
    });
  });

  group('ChordTransposer transposition tests', () {
    test('transposes with standard spaces', () {
      final input = 'Am    C';
      final result = ChordTransposer.transposeLyricsWithChords(input, 2);
      expect(result, 'Bm    D');
    });

    test('transposes with non-breaking spaces', () {
      final input = 'Am\u00A0\u00A0\u00A0\u00A0C';
      final result = ChordTransposer.transposeLyricsWithChords(input, 2);
      expect(result, 'Bm    D');
    });

    test('transposes with tabs and expands them', () {
      final input = 'Am\tC';
      final result = ChordTransposer.transposeLyricsWithChords(input, 2);
      expect(result, 'Bm    D');
    });
  });

  group('ChordFormatConverter tests', () {
    test('converts online chords to offline standard chords', () {
      final input = '[ch]Am[/ch]\t[ch]C[/ch]';
      final result = ChordFormatConverter.convertOnlineToOffline(input);
      expect(result.trim(), 'Am C');
    });
  });
}

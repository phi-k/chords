import '../data/collections/song.dart';
import '../utils/string_normalization.dart';

class AlphabetPositionService {
  static final AlphabetPositionService _instance =
  AlphabetPositionService._internal();

  factory AlphabetPositionService() {
    return _instance;
  }

  AlphabetPositionService._internal();
  Map<String, int> _songCountByLetter = {};
  Map<String, double> _letterPositions = {};

  final double _headerHeight = 42.0;
  final double _headerTopPadding = 10.0;
  final double _headerBottomPadding = 10.0;
  final double _itemHeight = 50.0;
  final double _itemTopPadding = 10.0;
  final double _itemBottomPadding = 10.0;
  final double _scrollCorrection = 8.0;
  final double _listTopPadding = 10.0;

  void _calculateSongCountByLetter(List<Song> songs) {
    _songCountByLetter = {};

    for (int i = 0; i < 26; i++) {
      String letter = String.fromCharCode(65 + i);
      _songCountByLetter[letter] = 0;
    }
    _songCountByLetter["Autres"] = 0;

    for (var song in songs) {
      String title = song.title ?? "";
      String key = _getLetterKey(title);
      _songCountByLetter[key] = (_songCountByLetter[key] ?? 0) + 1;
    }
  }

  void _calculateLetterPositions() {
    _letterPositions = {};

    double currentOffset = _listTopPadding;

    List<String> presentLetters = [];
    Map<String, double> actualPositions = {};

    for (int i = 0; i < 26; i++) {
      String letter = String.fromCharCode(65 + i);
      int songCount = _songCountByLetter[letter] ?? 0;

      if (songCount > 0) {
        presentLetters.add(letter);
        actualPositions[letter] = currentOffset;
        currentOffset +=
            _headerHeight + _headerTopPadding + _headerBottomPadding;
        currentOffset +=
            songCount * (_itemHeight + _itemTopPadding + _itemBottomPadding);
      }
    }

    int autresCount = _songCountByLetter["Autres"] ?? 0;
    if (autresCount > 0) {
      presentLetters.add("Autres");
      actualPositions["Autres"] = currentOffset;
      currentOffset +=
          _headerHeight + _headerTopPadding + _headerBottomPadding;
      currentOffset +=
          autresCount * (_itemHeight + _itemTopPadding + _itemBottomPadding);
    }

    for (String letter in actualPositions.keys) {
      actualPositions[letter] = actualPositions[letter]! - _scrollCorrection;
    }

    for (int i = 0; i < 26; i++) {
      String letter = String.fromCharCode(65 + i);
      if (!actualPositions.containsKey(letter)) {
        _letterPositions[letter] =
            _interpolateLetterPosition(letter, presentLetters, actualPositions);
      } else {
        _letterPositions[letter] = actualPositions[letter]!;
      }
    }

    if (actualPositions.containsKey("Autres")) {
      _letterPositions["Autres"] = actualPositions["Autres"]!;
    } else {
      _letterPositions["Autres"] = currentOffset;
    }

    _ensureMonotonicPositions();
  }

  void _ensureMonotonicPositions() {
    double lastPosition = -1;
    List<String> letters = [];

    for (int i = 0; i < 26; i++) {
      letters.add(String.fromCharCode(65 + i));
    }
    letters.add("Autres");

    for (String letter in letters) {
      double position = _letterPositions[letter] ?? 0;
      if (position <= lastPosition) {
        _letterPositions[letter] = lastPosition + 10;
      }
      lastPosition = _letterPositions[letter] ?? lastPosition;
    }
  }

  double _interpolateLetterPosition(String letter, List<String> presentLetters,
      Map<String, double> actualPositions) {
    if (presentLetters.isEmpty) {
      return 0;
    }

    String? prevLetter;
    String? nextLetter;

    for (String present in presentLetters) {
      if (present == "Autres") continue;

      if (present.compareTo(letter) < 0) {
        if (prevLetter == null || present.compareTo(prevLetter) > 0) {
          prevLetter = present;
        }
      } else if (present.compareTo(letter) > 0) {
        if (nextLetter == null || present.compareTo(nextLetter) < 0) {
          nextLetter = present;
        }
      }
    }

    if (prevLetter != null && nextLetter != null) {
      int prevIndex = prevLetter.codeUnitAt(0) - 'A'.codeUnitAt(0);
      int nextIndex = nextLetter.codeUnitAt(0) - 'A'.codeUnitAt(0);
      int targetIndex = letter.codeUnitAt(0) - 'A'.codeUnitAt(0);

      double prevPos = actualPositions[prevLetter]!;
      double nextPos = actualPositions[nextLetter]!;

      double fraction = (targetIndex - prevIndex) / (nextIndex - prevIndex);
      return prevPos + (nextPos - prevPos) * fraction;
    } else if (nextLetter != null) {
      return actualPositions[nextLetter]! / 2;
    } else if (prevLetter != null) {
      double lastKnownPosition = actualPositions[prevLetter]!;
      int letterGap = letter.codeUnitAt(0) - prevLetter.codeUnitAt(0);

      return lastKnownPosition + (letterGap * 20);
    }

    return 0;
  }

  String _getLetterKey(String title) {
    if (title.isEmpty) return "Autres";
    final normalizedTitle = normalizeString(title);
    final firstChar = normalizedTitle[0].toUpperCase();

    if (firstChar.codeUnitAt(0) >= 'A'.codeUnitAt(0) &&
        firstChar.codeUnitAt(0) <= 'Z'.codeUnitAt(0)) {
      return firstChar;
    }
    return "Autres";
  }

  void updatePositions(List<Song> songs) {
    _calculateSongCountByLetter(songs);
    _calculateLetterPositions();
  }

  double getPositionForLetter(String letter) {
    return _letterPositions[letter] ?? 0.0;
  }

  Map<String, double> getAllPositions() {
    return Map<String, double>.from(_letterPositions);
  }

  void adjustPositionFromRealMeasurements(String letter, double actualPosition) {
    if (_letterPositions.containsKey(letter)) {
      double diff = actualPosition - _letterPositions[letter]!;

      if (diff.abs() > 10) {
        for (String key in _letterPositions.keys) {
          _letterPositions[key] = _letterPositions[key]! + (diff * 0.5);
        }
      }
    }
  }
}
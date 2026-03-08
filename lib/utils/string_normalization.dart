import 'package:flutter/material.dart';

String normalizeString(String input) {
  return input
      .toLowerCase()
      .replaceAll(RegExp(r'[éèê]'), 'e')
      .replaceAll('à', 'a')
      .replaceAll('ç', 'c');
}

final RegExp _greekRegex = RegExp(r'[\u0370-\u03FF]');

bool containsGreekCharacters(String text) {
  return _greekRegex.hasMatch(text);
}

TextStyle getDynamicTextStyle(String text, TextStyle originalStyle) {
  if (containsGreekCharacters(text)) {
    return originalStyle.copyWith(fontFamily: 'LibertinusSerif');
  }
  return originalStyle;
}

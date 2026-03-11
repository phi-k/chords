// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'alphabet_scroller.dart';

abstract class AlphabetScrollListener {
  void scrollToLetter(String letter);
  Map<String, GlobalKey> getGroupKeys();
}

class AlphabetScrollerBridge {
  static final AlphabetScrollerBridge _instance = AlphabetScrollerBridge._internal();
  
  factory AlphabetScrollerBridge() {
    return _instance;
  }
  
  AlphabetScrollerBridge._internal();
  
  AlphabetScrollListener? _listener;
  
  void registerListener(AlphabetScrollListener listener) {
    _listener = listener;
  }
  
  void scrollToLetter(String letter) {
    _listener?.scrollToLetter(letter);
  }
  
  Map<String, GlobalKey> getGroupKeys() {
    return _listener?.getGroupKeys() ?? {};
  }
}

class AlphabetScrollerWrapper extends StatefulWidget {
  const AlphabetScrollerWrapper({super.key});

  @override
  State<AlphabetScrollerWrapper> createState() => _AlphabetScrollerWrapperState();
}

class _AlphabetScrollerWrapperState extends State<AlphabetScrollerWrapper> {
  void _scrollToLetter(String letter) {
    AlphabetScrollerBridge().scrollToLetter(letter);
  }

  @override
  Widget build(BuildContext context) {
    return AlphabetScroller(
      groupKeys: AlphabetScrollerBridge().getGroupKeys(),
      onLetterSelected: _scrollToLetter,
    );
  }
}
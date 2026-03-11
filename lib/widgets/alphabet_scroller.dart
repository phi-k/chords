// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';

class AlphabetScroller extends StatefulWidget {
  final Function(String) onLetterSelected;
  final Map<String, GlobalKey> groupKeys;

  const AlphabetScroller({
    super.key,
    required this.onLetterSelected,
    required this.groupKeys,
  });

  @override
  State<AlphabetScroller> createState() => _AlphabetScrollerState();
}

class _AlphabetScrollerState extends State<AlphabetScroller> {
  String? _currentSelectedLetter;
  bool _isDragging = false;

  static const String _verticalDots = "⋮";

  List<String> _getFullLetters() {
    List<String> letters =
    List.generate(26, (i) => String.fromCharCode(65 + i));
    letters.add("#");
    return letters;
  }

  void _handleDragGesture(
      double dragPosition,
      double containerHeight,
      List<String> displayedLetters,
      StateSetter setInnerState) {
    if (containerHeight <= 0 || displayedLetters.isEmpty) return;

    final letterHeight = containerHeight / displayedLetters.length;
    final adjustedPosition = dragPosition.clamp(0.0, containerHeight - 1);
    final selectedIndex = (adjustedPosition / letterHeight)
        .floor()
        .clamp(0, displayedLetters.length - 1);

    final selectedLetter = displayedLetters[selectedIndex];

    if (selectedLetter == _verticalDots) return;

    if (_currentSelectedLetter != selectedLetter) {
      setInnerState(() {
        _currentSelectedLetter = selectedLetter;
      });

      Future.microtask(() {
        widget.onLetterSelected(selectedLetter);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullLetters = _getFullLetters();
    const double minLetterHeight = 14.0;

    return Container(
      width: 40,
      alignment: Alignment.centerRight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double totalHeight = constraints.maxHeight;

          List<String> displayLetters = fullLetters;
          double itemHeight = totalHeight / fullLetters.length;

          if (itemHeight < minLetterHeight) {
            int capacity = (totalHeight / minLetterHeight).floor();

            if (capacity > 1 && capacity < fullLetters.length) {
              displayLetters = fullLetters.take(capacity - 1).toList();
              displayLetters.add(_verticalDots);
            } else if (capacity <= 1) {
              displayLetters = [_verticalDots];
            }

            itemHeight = totalHeight / displayLetters.length;
          }

          return StatefulBuilder(
            builder: (context, setInnerState) {
              return Listener(
                onPointerDown: (event) {
                  setInnerState(() {
                    _isDragging = true;
                  });
                  _handleDragGesture(event.localPosition.dy, totalHeight,
                      displayLetters, setInnerState);
                },
                onPointerMove: (event) {
                  if (_isDragging) {
                    _handleDragGesture(event.localPosition.dy, totalHeight,
                        displayLetters, setInnerState);
                  }
                },
                onPointerUp: (event) {
                  setInnerState(() {
                    _isDragging = false;
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (mounted) {
                        setInnerState(() {
                          _currentSelectedLetter = null;
                        });
                      }
                    });
                  });
                },
                child: Container(
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(128),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: displayLetters.map((letter) {
                      final isSelected = _currentSelectedLetter == letter;
                      final isDots = letter == _verticalDots;

                      return SizedBox(
                        height: itemHeight,
                        width: 40,
                        child: Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 100),
                            transform: isSelected && !isDots
                                ? Matrix4.translationValues(-3.0, 0.0, 0.0)
                                : null,
                            child: Text(
                              letter,
                              style: TextStyle(
                                fontFamily: 'Cormorant',
                                fontSize: isDots ? 14 : 10,
                                fontWeight: isSelected && !isDots
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isDots
                                    ? Colors.grey
                                    : (isSelected ? Colors.red : Colors.black),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
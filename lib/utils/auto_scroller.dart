// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'package:flutter/widgets.dart';

class AutoScroller {
  final ScrollController scrollController;
  Timer? _timer;
  bool isScrolling = false;

  AutoScroller({required this.scrollController});

  void start() {
    if (isScrolling) return;
    isScrolling = true;
    _timer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (scrollController.hasClients) {
        final maxScroll = scrollController.position.maxScrollExtent;
        double currentScroll = scrollController.offset;
        if (currentScroll >= maxScroll) {
          stop();
        } else {
          scrollController.animateTo(
            currentScroll + 1,
            duration: Duration(milliseconds: 50),
            curve: Curves.linear,
          );
        }
      }
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    isScrolling = false;
  }

  void toggle() {
    isScrolling ? stop() : start();
  }
}
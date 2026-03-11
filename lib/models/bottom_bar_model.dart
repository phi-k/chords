// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

class BottomBarModel {
  static void showBottomBar({
    required String message,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(navigatorKey.currentContext!);
    if (messenger != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.cormorant(fontSize: 16, color: Colors.black),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          shape: const Border(
            top: BorderSide(color: Colors.black, width: 1),
          ),
        ),
      );
    }
  }
}
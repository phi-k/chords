// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

class BottomBarModel {
  static void showBottomBar({
    required String message,
  }) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final messenger = ScaffoldMessenger.maybeOf(context);
    final theme = Theme.of(context);

    if (messenger != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.cormorant(
              fontSize: 16, 
              color: theme.colorScheme.onSurface
            ),
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          shape: Border(
            top: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.2), width: 1),
          ),
        ),
      );
    }
  }
}

// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import '../models/bottom_bar_model.dart';

class ClipboardUtils {
  static Future<void> copyLinkToClipboard(String? link) async {
    if (link != null && link.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: link));
      BottomBarModel.showBottomBar(
        message: 'Lien copié !',
      );
    } else {
      BottomBarModel.showBottomBar(
        message: 'Lien indisponible.',
      );
    }
  }
}

// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

Future<String?> showSongEditOptionsPopup(BuildContext context) async {
  final loc = AppLocalizations.of(context)!;
  return await showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (BuildContext ctx) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit_attributes,
                  color: Theme.of(context).colorScheme.onSurface),
              title: Text(
                loc.editOptionsMetadata,
                style: TextStyle(
                    fontFamily: 'Cormorant',
                    color: Theme.of(context).colorScheme.onSurface),
              ),
              onTap: () {
                Navigator.pop(ctx, 'metadata');
              },
            ),
            ListTile(
              leading: Icon(Icons.music_note,
                  color: Theme.of(context).colorScheme.onSurface),
              title: Text(
                loc.editOptionsLyrics,
                style: TextStyle(
                    fontFamily: 'Cormorant',
                    color: Theme.of(context).colorScheme.onSurface),
              ),
              onTap: () {
                Navigator.pop(ctx, 'lyrics');
              },
            ),
          ],
        ),
      );
    },
  );
}

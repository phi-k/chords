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
          color: Colors.white,
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
              leading: const Icon(Icons.edit_attributes, color: Colors.black),
              title: Text(
                loc.editOptionsMetadata,
                style: const TextStyle(
                    fontFamily: 'Cormorant', color: Colors.black),
              ),
              onTap: () {
                Navigator.pop(ctx, 'metadata');
              },
            ),
            ListTile(
              leading: const Icon(Icons.music_note, color: Colors.black),
              title: Text(
                loc.editOptionsLyrics,
                style: const TextStyle(
                    fontFamily: 'Cormorant', color: Colors.black),
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

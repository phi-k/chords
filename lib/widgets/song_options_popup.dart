// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../data/collections/song.dart';
import '../providers/song_provider.dart';
import '../services/genius_service.dart';
import '../screens/song_statistics_page.dart';

Future<void> showSongOptionsPopup(
  BuildContext context,
  WidgetRef ref,
  Song song,
) async {
  final loc = AppLocalizations.of(context)!;
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (BuildContext ctx) {
      return Container(
        decoration: const BoxDecoration(
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
              leading: const Icon(Icons.edit, color: Colors.black),
              title: Text(
                loc.songOptionsMetadata,
                style: const TextStyle(
                    fontFamily: 'Cormorant', color: Colors.black),
              ),
              onTap: () {
                Navigator.pop(ctx);
                showEditMetadataDialog(context, ref, song);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart, color: Colors.black),
              title: Text(
                loc.songViewStats,
                style: const TextStyle(
                    fontFamily: 'Cormorant', color: Colors.black),
              ),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SongStatisticsPage(songData: song),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(
                loc.songOptionsDelete,
                style:
                    const TextStyle(fontFamily: 'Cormorant', color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _showDeleteConfirmationDialog(
                  context,
                  ref,
                  song,
                );
              },
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _showDeleteConfirmationDialog(
  BuildContext context,
  WidgetRef ref,
  Song song,
) async {
  final loc = AppLocalizations.of(context)!;
  await showDialog(
    context: context,
    builder: (BuildContext ctx) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          loc.songDeleteConfirmTitle,
          style: GoogleFonts.cormorant(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        content: Text(
          loc.songDeleteConfirmMessage(song.title ?? '', song.artist ?? ''),
          style: GoogleFonts.cormorant(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              loc.commonCancel,
              style: GoogleFonts.cormorant(color: Colors.black),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
            ),
            onPressed: () async {
              if (ctx.mounted) {
                Navigator.pop(ctx);
              }
              await ref.read(databaseServiceProvider).deleteSong(song.songUrl);
            },
            child: Text(
              loc.commonDelete,
              style: GoogleFonts.cormorant(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}

Future<void> showEditMetadataDialog(
  BuildContext context,
  WidgetRef ref,
  Song song,
) async {
  final loc = AppLocalizations.of(context)!;
  final titleController = TextEditingController(text: song.title);
  final artistController = TextEditingController(text: song.artist);
  final coverUrlController = TextEditingController(text: song.coverUrl);

  await showDialog(
    context: context,
    builder: (BuildContext ctx) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Text(
          loc.metadataEditTitle,
          style: const TextStyle(
            fontFamily: 'Cormorant',
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: loc.metadataTitle,
                  labelStyle: const TextStyle(
                    fontFamily: 'Cormorant',
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
                style: const TextStyle(
                  fontFamily: 'Cormorant',
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
              TextField(
                controller: artistController,
                decoration: InputDecoration(
                  labelText: loc.metadataArtist,
                  labelStyle: const TextStyle(
                    fontFamily: 'Cormorant',
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
                style: const TextStyle(
                  fontFamily: 'Cormorant',
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
              TextField(
                controller: coverUrlController,
                decoration: InputDecoration(
                  labelText: loc.metadataCoverUrl,
                  labelStyle: const TextStyle(
                    fontFamily: 'Cormorant',
                    color: Colors.black,
                    fontSize: 14,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.black,
                      size: 18,
                    ),
                    tooltip: loc.metadataFetchGenius,
                    onPressed: () async {
                      final newCoverUrl = await GeniusService.fetchCoverUrl(
                        titleController.text,
                        artistController.text,
                      );
                      if (newCoverUrl != null) {
                        coverUrlController.text = newCoverUrl;
                      }
                    },
                  ),
                ),
                style: const TextStyle(
                  fontFamily: 'Cormorant',
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              loc.commonCancel,
              style: const TextStyle(
                fontFamily: 'Cormorant',
                color: Colors.black,
                fontSize: 14,
              ),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Colors.red, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () async {
              song.title = titleController.text;
              song.artist = artistController.text;
              song.coverUrl = coverUrlController.text;
              await ref.read(databaseServiceProvider).updateSong(song);
              if (ctx.mounted) {
                Navigator.pop(ctx);
              }
            },
            child: Text(
              loc.commonSave,
              style: const TextStyle(
                fontFamily: 'Cormorant',
                color: Colors.black,
                fontSize: 14,
              ),
            ),
          ),
        ],
      );
    },
  );
}

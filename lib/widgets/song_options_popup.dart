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
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit,
                  color: Theme.of(context).colorScheme.onSurface),
              title: Text(
                loc.songOptionsMetadata,
                style: TextStyle(
                    fontFamily: 'Cormorant',
                    color: Theme.of(context).colorScheme.onSurface),
              ),
              onTap: () {
                Navigator.pop(ctx);
                showEditMetadataDialog(context, ref, song);
              },
            ),
            ListTile(
              leading: Icon(Icons.bar_chart,
                  color: Theme.of(context).colorScheme.onSurface),
              title: Text(
                loc.songViewStats,
                style: TextStyle(
                    fontFamily: 'Cormorant',
                    color: Theme.of(context).colorScheme.onSurface),
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
              leading:
                  Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
              title: Text(
                loc.songOptionsDelete,
                style: TextStyle(
                    fontFamily: 'Cormorant',
                    color: Theme.of(context).colorScheme.error),
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          loc.songDeleteConfirmTitle,
          style: GoogleFonts.cormorant(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Text(
          loc.songDeleteConfirmMessage(song.title ?? '', song.artist ?? ''),
          style: GoogleFonts.cormorant(
              color: Theme.of(context).colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              loc.commonCancel,
              style: GoogleFonts.cormorant(
                  color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
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
                color: Theme.of(context).colorScheme.error,
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Text(
          loc.metadataEditTitle,
          style: TextStyle(
            fontFamily: 'Cormorant',
            color: Theme.of(context).colorScheme.onSurface,
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
                  labelStyle: TextStyle(
                    fontFamily: 'Cormorant',
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                  ),
                ),
                style: TextStyle(
                  fontFamily: 'Cormorant',
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                ),
              ),
              TextField(
                controller: artistController,
                decoration: InputDecoration(
                  labelText: loc.metadataArtist,
                  labelStyle: TextStyle(
                    fontFamily: 'Cormorant',
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                  ),
                ),
                style: TextStyle(
                  fontFamily: 'Cormorant',
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                ),
              ),
              TextField(
                controller: coverUrlController,
                decoration: InputDecoration(
                  labelText: loc.metadataCoverUrl,
                  labelStyle: TextStyle(
                    fontFamily: 'Cormorant',
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: Theme.of(context).colorScheme.onSurface,
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
                style: TextStyle(
                  fontFamily: 'Cormorant',
                  color: Theme.of(context).colorScheme.onSurface,
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
              style: TextStyle(
                fontFamily: 'Cormorant',
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
              ),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
              side: BorderSide(color: Theme.of(context).colorScheme.error, width: 1),
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
              style: TextStyle(
                fontFamily: 'Cormorant',
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
              ),
            ),
          ),
        ],
      );
    },
  );
}

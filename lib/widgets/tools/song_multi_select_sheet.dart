// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/collections/song.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/export_tabs_provider.dart';
import '../../widgets/common/app_image.dart';

class SongMultiSelectSheet extends ConsumerStatefulWidget {
  final List<Song> allSongs;

  const SongMultiSelectSheet({super.key, required this.allSongs});

  @override
  ConsumerState<SongMultiSelectSheet> createState() =>
      _SongMultiSelectSheetState();
}

class _SongMultiSelectSheetState extends ConsumerState<SongMultiSelectSheet> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final state = ref.watch(exportTabsProvider);
    final notifier = ref.read(exportTabsProvider.notifier);

    final filteredSongs = widget.allSongs.where((s) {
      final q = searchQuery.toLowerCase();
      return (s.title ?? "").toLowerCase().contains(q) ||
          (s.artist ?? "").toLowerCase().contains(q);
    }).toList();

    filteredSongs.sort((a, b) => (a.title ?? "").compareTo(b.title ?? ""));

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(loc.multiSelectTitle,
                    style: TextStyle(
                        fontFamily: 'Cormorant',
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close,
                      color: Theme.of(context).colorScheme.onSurface),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              cursorColor: Theme.of(context).primaryColor,
              style: TextStyle(fontFamily: 'Cormorant', fontSize: 18),
              decoration: InputDecoration(
                hintText: loc.multiSelectSearchHint,
                hintStyle: TextStyle(
                    fontFamily: 'Cormorant', color: Colors.grey.shade500),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: Theme.of(context).primaryColor, width: 2),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (val) => setState(() => searchQuery = val),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
            child: Row(
              children: [
                Text(
                  "${state.manualSelectionIds.length} ${loc.multiSelectCount}",
                  style: TextStyle(
                      fontFamily: 'Cormorant',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).primaryColor),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => notifier.selectAllManual(widget.allSongs),
                  icon: Icon(Icons.playlist_add_check,
                      color: Theme.of(context).colorScheme.onSurface),
                  tooltip: loc.multiSelectAll,
                ),
                IconButton(
                  onPressed: () => notifier.clearManualSelection(),
                  icon: Icon(Icons.playlist_remove,
                      color: Theme.of(context).colorScheme.onSurface),
                  tooltip: loc.multiSelectNone,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 10),
              itemCount: filteredSongs.length,
              itemBuilder: (context, index) {
                final song = filteredSongs[index];
                final isSelected = state.manualSelectionIds.contains(song.id);
                return CheckboxListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  value: isSelected,
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: (_) => notifier.toggleManualSelection(song.id),
                  secondary: AppImage(
                    url: song.coverUrl,
                    width: 45,
                    height: 45,
                    borderRadius: 8,
                  ),
                  title: Text(song.title ?? "",
                      style: TextStyle(
                          fontFamily: 'Cormorant',
                          fontSize: 18,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: Theme.of(context).colorScheme.onSurface)),
                  subtitle: Text(song.artist ?? "",
                      style: TextStyle(
                          fontFamily: 'Cormorant',
                          fontSize: 15,
                          color: Colors.grey.shade600)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

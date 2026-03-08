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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(loc.multiSelectTitle,
                    style: const TextStyle(
                        fontFamily: 'Cormorant',
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.black),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              cursorColor: Colors.red,
              style: const TextStyle(fontFamily: 'Cormorant', fontSize: 18),
              decoration: InputDecoration(
                hintText: loc.multiSelectSearchHint,
                hintStyle: TextStyle(
                    fontFamily: 'Cormorant', color: Colors.grey.shade500),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (val) => setState(() => searchQuery = val),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
            child: Row(
              children: [
                Text(
                  "${state.manualSelectionIds.length} ${loc.multiSelectCount}",
                  style: const TextStyle(
                      fontFamily: 'Cormorant',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.red),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => notifier.selectAllManual(widget.allSongs),
                  icon:
                      const Icon(Icons.playlist_add_check, color: Colors.black),
                  tooltip: loc.multiSelectAll,
                ),
                IconButton(
                  onPressed: () => notifier.clearManualSelection(),
                  icon: const Icon(Icons.playlist_remove, color: Colors.black),
                  tooltip: loc.multiSelectNone,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: filteredSongs.length,
              itemBuilder: (context, index) {
                final song = filteredSongs[index];
                final isSelected = state.manualSelectionIds.contains(song.id);
                return CheckboxListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  value: isSelected,
                  activeColor: Colors.red,
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
                          color: Colors.black)),
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

// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/export_tabs_provider.dart';
import '../../providers/song_provider.dart';
import '../../providers/export_song_list_provider.dart';
import '../../data/collections/song.dart';
import '../../data/collections/playlist.dart';
import '../../widgets/tools/song_multi_select_sheet.dart';
import '../../l10n/app_localizations.dart';

class ExportTabsPage extends ConsumerWidget {
  const ExportTabsPage({super.key});

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontFamily: 'Cormorant',
        fontSize: 16,
        color: Colors.grey.shade600,
      ),
      floatingLabelStyle: const TextStyle(
        fontFamily: 'Cormorant',
        fontSize: 18,
        color: Colors.red,
        fontWeight: FontWeight.bold,
      ),
      prefixIcon: Icon(icon, color: Colors.red.withValues(alpha: 0.7)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  Widget _buildSwitch({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Cormorant',
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeThumbColor: Colors.white,
      activeTrackColor: Colors.red,
      inactiveThumbColor: Colors.grey.shade400,
      inactiveTrackColor: Colors.white,
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.transparent;
        }
        return Colors.grey.shade300;
      }),
      contentPadding: EdgeInsets.zero,
    );
  }

  Future<void> _showCountDialog(
    BuildContext context,
    int currentCount,
    int maxCount,
    ExportTabsNotifier notifier,
  ) async {
    final loc = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: currentCount.toString());
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            loc.exportTabsSetCount,
            style: const TextStyle(
              fontFamily: 'Cormorant',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.exportTabsCountHint(maxCount),
                style: const TextStyle(fontFamily: 'Cormorant', fontSize: 16),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                cursorColor: Colors.red,
                style: const TextStyle(fontFamily: 'Cormorant', fontSize: 18),
                decoration: InputDecoration(
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
                onSubmitted: (_) {
                  _submitCount(controller.text, maxCount, notifier, context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(loc.commonCancel,
                  style: const TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () =>
                  _submitCount(controller.text, maxCount, notifier, context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _submitCount(String text, int maxCount, ExportTabsNotifier notifier,
      BuildContext context) {
    final int? val = int.tryParse(text);
    if (val != null) {
      final int clamped = val.clamp(1, maxCount);
      notifier.setRecentCount(clamped);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(exportTabsProvider);
    final notifier = ref.read(exportTabsProvider.notifier);
    final allSongsAsync = ref.watch(allSongsProvider);
    final playlistsAsync = ref.watch(playlistsProvider);
    final artistsAsync = ref.watch(artistsProvider);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.exportTabsTitle,
          style: const TextStyle(
            fontFamily: 'Cormorant',
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: allSongsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text(loc.commonError(e.toString()))),
        data: (allSongs) {
          if (allSongs.isEmpty) {
            return Center(child: Text(loc.exportTabsNoSongs));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(loc.exportTabsContentTitle),
                const SizedBox(height: 15),
                _buildModeSelector(state, notifier, loc),
                if (state.selectionMode != 'all') ...[
                  const SizedBox(height: 25),
                  _buildConditionalSelectors(context, ref, state, notifier,
                      allSongs, playlistsAsync, artistsAsync, loc),
                ],
                const SizedBox(height: 35),
                _buildSectionTitle(loc.exportTabsCustomTitle),
                const SizedBox(height: 15),
                TextField(
                  onChanged: notifier.setSongbookTitle,
                  style: const TextStyle(
                    fontFamily: 'Cormorant',
                    fontSize: 18,
                    color: Colors.black,
                  ),
                  cursorColor: Colors.red,
                  decoration: _buildInputDecoration(
                    label: loc.exportTabsSongbookTitle,
                    icon: Icons.book_outlined,
                  ),
                  controller: TextEditingController(text: state.songbookTitle),
                ),
                const SizedBox(height: 15),
                _buildSwitch(
                  title: loc.exportTabsCoverPage,
                  value: state.withCoverPage,
                  onChanged: notifier.toggleCoverPage,
                ),
                _buildSwitch(
                  title: loc.exportTabsToc,
                  value: state.withTableOfContents,
                  onChanged: notifier.toggleTableOfContents,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: state.isLoading
                        ? null
                        : () async {
                            final List<Playlist> playlists =
                                (playlistsAsync.value ?? []).cast<Playlist>();
                            await notifier.export(allSongs, playlists);
                          },
                    icon: state.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.picture_as_pdf, color: Colors.white),
                    label: Text(
                      state.isLoading
                          ? loc.exportTabsGenerating
                          : loc.exportTabsGeneratePdf,
                      style: const TextStyle(
                          fontFamily: 'Cormorant',
                          fontSize: 18,
                          color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      loc.exportTabsFooter,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontFamily: 'Cormorant',
                          color: Colors.grey,
                          fontSize: 14,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Cormorant',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildModeSelector(ExportTabsState state, ExportTabsNotifier notifier,
      AppLocalizations loc) {
    final modes = {
      'all': loc.exportTabsAll,
      'playlist': loc.exportTabsPlaylist,
      'artist': loc.exportTabsArtist,
      'recent': loc.exportTabsRecent,
      'manual': loc.exportTabsManual,
    };

    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: 10.0,
        runSpacing: 10.0,
        alignment: WrapAlignment.start,
        children: modes.entries.map((entry) {
          final isSelected = state.selectionMode == entry.key;
          return ChoiceChip(
            label: Text(entry.value),
            selected: isSelected,
            onSelected: (_) => notifier.setSelectionMode(entry.key),
            selectedColor: Colors.red.withValues(alpha: 0.1),
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              fontFamily: 'Cormorant',
              fontSize: 16,
              color: isSelected ? Colors.red : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            shape: StadiumBorder(
                side: BorderSide(
              color: isSelected ? Colors.red : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1.0,
            )),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildConditionalSelectors(
    BuildContext context,
    WidgetRef ref,
    ExportTabsState state,
    ExportTabsNotifier notifier,
    List<Song> allSongs,
    AsyncValue<List<dynamic>> playlistsAsync,
    AsyncValue<Map<String, int>> artistsAsync,
    AppLocalizations loc,
  ) {
    if (state.selectionMode == 'playlist') {
      return playlistsAsync.when(
        data: (playlists) {
          if (playlists.isEmpty) return Text(loc.exportTabsNoPlaylist);
          return DropdownButtonFormField<String>(
            decoration: _buildInputDecoration(
                label: loc.exportTabsChoosePlaylist, icon: Icons.queue_music),
            initialValue: state.selectedPlaylistId,
            items: playlists.map<DropdownMenuItem<String>>((p) {
              return DropdownMenuItem(
                  value: p.uuid,
                  child: Text(p.name ?? loc.exportTabsUnnamed,
                      style: const TextStyle(
                          fontFamily: 'Cormorant',
                          fontSize: 18,
                          color: Colors.black)));
            }).toList(),
            onChanged: (val) => notifier.setSelectedPlaylist(val),
            dropdownColor: Colors.white,
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.red),
            borderRadius: BorderRadius.circular(12),
          );
        },
        loading: () => const LinearProgressIndicator(color: Colors.red),
        error: (_, __) => const SizedBox(),
      );
    }

    if (state.selectionMode == 'artist') {
      return artistsAsync.when(
        data: (artistsMap) {
          final sortedArtists = artistsMap.keys.toList()..sort();
          return DropdownButtonFormField<String>(
            decoration: _buildInputDecoration(
                label: loc.exportTabsChooseArtist, icon: Icons.person_outline),
            initialValue: state.selectedArtistName,
            items: sortedArtists.map<DropdownMenuItem<String>>((a) {
              return DropdownMenuItem(
                  value: a,
                  child: Text(a,
                      style: const TextStyle(
                          fontFamily: 'Cormorant',
                          fontSize: 18,
                          color: Colors.black)));
            }).toList(),
            onChanged: (val) => notifier.setSelectedArtist(val),
            dropdownColor: Colors.white,
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.red),
            borderRadius: BorderRadius.circular(12),
          );
        },
        loading: () => const LinearProgressIndicator(color: Colors.red),
        error: (_, __) => const SizedBox(),
      );
    }

    if (state.selectionMode == 'manual') {
      return InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => SongMultiSelectSheet(allSongs: allSongs),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: InputDecorator(
          decoration: _buildInputDecoration(
            label: loc.exportTabsManualSelection,
            icon: Icons.checklist,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                state.manualSelectionIds.isEmpty
                    ? loc.exportTabsClickToChoose
                    : loc
                        .exportTabsSongsChosen(state.manualSelectionIds.length),
                style: const TextStyle(
                  fontFamily: 'Cormorant',
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      );
    }

    if (state.selectionMode == 'recent') {
      final int totalSongs = allSongs.length;
      final int safeRecentCount = state.recentCount;

      final int currentCount =
          safeRecentCount > totalSongs ? totalSongs : safeRecentCount;
      final double maxVal = totalSongs > 0 ? totalSongs.toDouble() : 1.0;
      final double sliderVal = currentCount.toDouble().clamp(1.0, maxVal);

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.history,
                        color: Colors.red.withValues(alpha: 0.7)),
                    const SizedBox(width: 10),
                    Text(
                      loc.exportTabsSongCount,
                      style: const TextStyle(
                          fontFamily: 'Cormorant',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => _showCountDialog(
                      context, currentCount, totalSongs, notifier),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      "${currentCount.toInt()}",
                      style: TextStyle(
                          fontFamily: 'Cormorant',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.red.withValues(alpha: 0.3)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              loc.exportTabsRecentDesc,
              style: const TextStyle(
                  fontFamily: 'Cormorant',
                  fontSize: 15,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 15),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.red,
                inactiveTrackColor: Colors.grey.shade200,
                thumbColor: Colors.white,
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10, elevation: 3, pressedElevation: 6),
                overlayColor: Colors.red.withValues(alpha: 0.1),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              ),
              child: Slider(
                value: sliderVal,
                min: 1,
                max: maxVal,
                divisions: (totalSongs > 1) ? totalSongs - 1 : 1,
                onChanged: (value) {
                  notifier.setRecentCount(value.round());
                },
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

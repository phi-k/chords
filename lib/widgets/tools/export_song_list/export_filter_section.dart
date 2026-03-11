// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/export_song_list_provider.dart';
import 'shared_export_widgets.dart';

class ExportFilterSection extends ConsumerWidget {
  const ExportFilterSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final options = ref.watch(exportOptionsProvider);
    final notifier = ref.read(exportOptionsProvider.notifier);
    final playlistsAsync = ref.watch(playlistsProvider);
    final playCountController =
        TextEditingController(text: options.playCountValue);

    playCountController.addListener(() {
      notifier.setPlayCountValue(playCountController.text);
    });

    const formTextStyle =
        TextStyle(fontFamily: 'Cormorant', color: Colors.black);

    return Container(
      margin: const EdgeInsets.only(top: 12, left: 16, right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSwitchOption(
            loc.exportFilterPlaylist,
            loc.exportFilterPlaylistDesc,
            options.filterByPlaylist,
            notifier.setFilterByPlaylist,
          ),
          if (options.filterByPlaylist)
            Padding(
              padding:
                  const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
              child: playlistsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text(loc.exportFilterPlaylistLoadError,
                    style: formTextStyle),
                data: (playlists) {
                  if (playlists.isEmpty) {
                    return Text(loc.exportFilterPlaylistNone,
                        style: formTextStyle);
                  }
                  return DropdownButtonFormField<String>(
                    initialValue: options.selectedPlaylistId,
                    hint: Text(loc.exportFilterPlaylistSelect,
                        style: formTextStyle),
                    isExpanded: true,
                    items: playlists.map((playlist) {
                      return DropdownMenuItem(
                        value: playlist.uuid,
                        child: Text(
                            playlist.name ?? loc.exportFilterPlaylistUnnamed,
                            style: formTextStyle),
                      );
                    }).toList(),
                    onChanged: (String? value) =>
                        notifier.setSelectedPlaylist(value),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                    ),
                    dropdownColor: Colors.white,
                    style: formTextStyle,
                  );
                },
              ),
            ),
          const Divider(),
          buildSwitchOption(
            loc.exportFilterPlayCount,
            "",
            options.filterByPlayCount,
            notifier.setFilterByPlayCount,
          ),
          if (options.filterByPlayCount)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  DropdownButton<String>(
                    value: options.playCountCondition,
                    items: const [
                      DropdownMenuItem(
                          value: 'greater',
                          child: Text('>', style: formTextStyle)),
                      DropdownMenuItem(
                          value: 'less',
                          child: Text('<', style: formTextStyle)),
                      DropdownMenuItem(
                          value: 'equal',
                          child: Text('=', style: formTextStyle)),
                    ],
                    onChanged: (value) {
                      if (value != null) notifier.setPlayCountCondition(value);
                    },
                    dropdownColor: Colors.white,
                    style: formTextStyle,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: playCountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: loc.exportFilterPlayCountLabel,
                          labelStyle: formTextStyle),
                      style: formTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          const Divider(),
          buildSwitchOption(
            loc.exportFilterLastPlayed,
            "",
            options.filterByLastPlayed,
            notifier.setFilterByLastPlayed,
          ),
          if (options.filterByLastPlayed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  DropdownButton<String>(
                    value: options.lastPlayedCondition,
                    items: [
                      DropdownMenuItem(
                          value: 'since',
                          child: Text(loc.exportFilterSince,
                              style: formTextStyle)),
                      DropdownMenuItem(
                          value: 'before',
                          child: Text(loc.exportFilterBefore,
                              style: formTextStyle)),
                    ],
                    onChanged: (value) {
                      if (value != null) notifier.setLastPlayedCondition(value);
                    },
                    dropdownColor: Colors.white,
                    style: formTextStyle,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: options.selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Colors.red,
                                  onPrimary: Colors.white,
                                  onSurface: Colors.black,
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    textStyle: const TextStyle(
                                      fontFamily: 'Cormorant',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                dialogTheme: DialogThemeData(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        notifier.setSelectedDate(date);
                      },
                      child: Text(
                        options.selectedDate == null
                            ? loc.exportFilterChooseDate
                            : DateFormat('dd/MM/yyyy')
                                .format(options.selectedDate!),
                        style: formTextStyle.copyWith(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const Divider(),
          buildSwitchOption(
            loc.exportFilterTags,
            "",
            options.filterByTags,
            notifier.setFilterByTags,
          ),
          if (options.filterByTags)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc.exportFilterTagsSoon,
                      style: formTextStyle.copyWith(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    children: options.allTags.map((tag) {
                      final isSelected = options.selectedTags.contains(tag);
                      return FilterChip(
                        label: Text(tag, style: formTextStyle),
                        selected: isSelected,
                        onSelected: (selected) =>
                            notifier.toggleTagSelection(tag),
                        selectedColor: Colors.red.withAlpha(26),
                        checkmarkColor: Colors.red,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

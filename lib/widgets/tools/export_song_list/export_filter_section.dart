// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/export_song_list_provider.dart';
import 'shared_export_widgets.dart';
import '../../../widgets/common/custom_loader.dart';

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

    final formTextStyle =
        TextStyle(fontFamily: 'Cormorant', color: Theme.of(context).colorScheme.onSurface);

    return Container(
      margin: const EdgeInsets.only(top: 12, left: 16, right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSwitchOption(context, 
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
                loading: () => const CustomLoader(),
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
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                      ),
                    ),
                    dropdownColor: Theme.of(context).colorScheme.surface,
                    style: formTextStyle,
                  );
                },
              ),
            ),
          const Divider(),
          buildSwitchOption(context, 
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
                    items: [
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
                    dropdownColor: Theme.of(context).colorScheme.surface,
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
          buildSwitchOption(context, 
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
                    dropdownColor: Theme.of(context).colorScheme.surface,
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
                                colorScheme: ColorScheme.light(
                                  primary: Theme.of(context).primaryColor,
                                  onPrimary: Colors.white,
                                  onSurface: Theme.of(context).colorScheme.onSurface,
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Theme.of(context).primaryColor,
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
                        style: formTextStyle.copyWith(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const Divider(),
          buildSwitchOption(context, 
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
                        selectedColor: Theme.of(context).primaryColor.withAlpha(26),
                        checkmarkColor: Theme.of(context).primaryColor,
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

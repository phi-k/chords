// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

enum FilterMode {
  none,
  artists,
  playlists,
  recent,
  tags,
}

class FilterButtons extends StatelessWidget {
  final Set<FilterMode> activeFilters;
  final Function(FilterMode) onFilterToggled;

  const FilterButtons({
    super.key,
    required this.activeFilters,
    required this.onFilterToggled,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildFilterButton(
              context, loc.filterArtists, FilterMode.artists),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildFilterButton(
              context, loc.filterPlaylists, FilterMode.playlists),
        ),
        const SizedBox(width: 8),
        Expanded(
          child:
              _buildFilterButton(context, loc.filterRecent, FilterMode.recent),
        ),
        const SizedBox(width: 8),
        _buildTagFilterButton(context, FilterMode.tags),
      ],
    );
  }

  Widget _buildFilterButton(
      BuildContext context, String label, FilterMode mode) {
    final isSelected = activeFilters.contains(mode);

    return GestureDetector(
      onTap: () => onFilterToggled(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surface,
          border: Border.all(
              color: Theme.of(context).colorScheme.outline, width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Cormorant',
            fontSize: 12,
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTagFilterButton(BuildContext context, FilterMode mode) {
    final isSelected = activeFilters.contains(mode);

    return SizedBox(
      width: 40,
      height: 36,
      child: GestureDetector(
        onTap: () => onFilterToggled(mode),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Icon(
            Icons.local_offer,
            size: 20,
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

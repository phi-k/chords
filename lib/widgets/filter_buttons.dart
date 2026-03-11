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
          child: _buildFilterButton(loc.filterArtists, FilterMode.artists),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildFilterButton(loc.filterPlaylists, FilterMode.playlists),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildFilterButton(loc.filterRecent, FilterMode.recent),
        ),
        const SizedBox(width: 8),
        _buildTagFilterButton(FilterMode.tags),
      ],
    );
  }

  Widget _buildFilterButton(String label, FilterMode mode) {
    final isSelected = activeFilters.contains(mode);

    return GestureDetector(
      onTap: () => onFilterToggled(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFEE0E0) : Colors.white,
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Cormorant',
            fontSize: 12,
            color: Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTagFilterButton(FilterMode mode) {
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
            color: isSelected ? Colors.red : Colors.black,
          ),
        ),
      ),
    );
  }
}

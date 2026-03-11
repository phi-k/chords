// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/source_manager.dart';
import '../screens/settings/data_sources_page.dart';
import '../screens/creation_page.dart';
import '../screens/settings_page.dart';

class EmptyLibraryView extends StatefulWidget {
  const EmptyLibraryView({super.key});

  @override
  State<EmptyLibraryView> createState() => _EmptyLibraryViewState();
}

class _EmptyLibraryViewState extends State<EmptyLibraryView>
    with SingleTickerProviderStateMixin {
  bool _hasSource = false;
  late AnimationController _animController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _colorAnimation = ColorTween(
      begin: Colors.red,
      end: Colors.green,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    ));
    _checkSources();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _checkSources() async {
    final sources = await SourceManager.getSources();
    if (mounted && sources.isNotEmpty && !_hasSource) {
      setState(() => _hasSource = true);
      _animController.forward();
    }
  }

  void _navigateToDataSources() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DataSourcesPage()),
    );
    _checkSources();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_music_outlined,
                size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 24),
            Text(
              loc.homeEmptyTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cormorant',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                _hasSource
                    ? loc.homeEmptySourceDoneSubtitle
                    : loc.homeEmptySubtitle,
                key: ValueKey(_hasSource),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cormorant',
                  fontSize: 16,
                  height: 1.4,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _colorAnimation,
                    builder: (context, child) {
                      return ElevatedButton.icon(
                        onPressed: _navigateToDataSources,
                        icon: Icon(
                          _hasSource
                              ? Icons.check_circle_outline
                              : Icons.dns_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: Text(
                          _hasSource
                              ? loc.homeEmptyBtnSourceDone
                              : loc.homeEmptyBtnSource,
                          style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Cormorant',
                              fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _colorAnimation.value,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 24),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CreationPage()));
                    },
                    icon: const Icon(Icons.edit_note,
                        color: Colors.black, size: 18),
                    label: Text(loc.homeEmptyBtnWrite,
                        style: const TextStyle(
                            color: Colors.black,
                            fontFamily: 'Cormorant',
                            fontSize: 16)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade400),
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 24),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SettingsPage()));
                    },
                    icon: const Icon(Icons.settings,
                        color: Colors.black54, size: 18),
                    label: Text(loc.settingsTitle,
                        style: const TextStyle(
                            color: Colors.black54,
                            fontFamily: 'Cormorant',
                            fontSize: 16)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

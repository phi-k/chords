// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final Locale locale;
  final String geniusKey;
  final String geminiKey;

  SettingsState({
    required this.locale,
    this.geniusKey = '',
    this.geminiKey = '',
  });

  SettingsState copyWith({
    Locale? locale,
    String? geniusKey,
    String? geminiKey,
  }) {
    return SettingsState(
      locale: locale ?? this.locale,
      geniusKey: geniusKey ?? this.geniusKey,
      geminiKey: geminiKey ?? this.geminiKey,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    return SettingsState(locale: const Locale('en', 'US'));
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language_code') ?? 'en';
    final genius = prefs.getString('genius_key') ?? '';
    final gemini = prefs.getString('gemini_key') ?? '';

    state = SettingsState(
      locale: Locale(langCode),
      geniusKey: genius,
      geminiKey: gemini,
    );
  }

  Future<void> setLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
    state = state.copyWith(locale: Locale(languageCode));
  }

  Future<void> setGeniusKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('genius_key', key.trim());
    state = state.copyWith(geniusKey: key.trim());
  }

  Future<void> setGeminiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_key', key.trim());
    state = state.copyWith(geminiKey: key.trim());
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);

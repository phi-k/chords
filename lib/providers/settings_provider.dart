// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_theme.dart';

final List<AppTheme> builtInThemes = [
  const AppTheme(
    id: 'chords_light',
    nameKey: 'themeLightName',
    descKey: 'themeLightDesc',
    coverUrl:
        'https://images.unsplash.com/photo-1550684376-efcbd6e3f031?q=80&w=400&auto=format&fit=crop',
    primaryColor: Color(0xFFD32F2F),
    backgroundColor: Color(
        0xFFFAFAFA),
    textColor: Color(0xFF1C1B1F),
    isBuiltIn: true,
  ),
  const AppTheme(
    id: 'chords_dark',
    nameKey: 'themeDarkName',
    descKey: 'themeDarkDesc',
    coverUrl:
        'https://images.unsplash.com/photo-1510915361894-db8b60106cb1?q=80&w=400&auto=format&fit=crop',
    primaryColor: Color(0xFFF44336),
    backgroundColor: Color(0xFF121212),
    textColor: Color(0xDEFFFFFF),
    isBuiltIn: true,
  ),
  const AppTheme(
    id: 'dark_side',
    nameKey: 'themeDarkSideName',
    descKey: 'themeDarkSideDesc',
    coverUrl:
        'https://upload.wikimedia.org/wikipedia/en/3/3b/Dark_Side_of_the_Moon.png',
    primaryColor: Color(0xFFFFFFFF),
    backgroundColor: Color(0xFF000000),
    textColor: Color(0xFFFFFFFF),
    isBuiltIn: true,
  ),
  const AppTheme(
    id: 'nevermind',
    nameKey: 'themeNevermindName',
    descKey: 'themeNevermindDesc',
    coverUrl:
        'https://t2.genius.com/unsafe/1424x0/https%3A%2F%2Fimages.genius.com%2Fdab0f7854a0a3833f4a7a3edb0838202.1000x1000x1.png',
    primaryColor: Color(0xFFFFC107),
    backgroundColor: Color(0xFF111111),
    textColor: Color(0xFFFFFFFF),
    isBuiltIn: true,
  ),
];

class SettingsState {
  final Locale locale;
  final String geniusKey;
  final String geminiKey;
  final String activeThemeId;
  final String activeLightThemeId;
  final String activeDarkThemeId;
  final bool followSystem;
  final List<AppTheme> customThemes;

  SettingsState({
    required this.locale,
    this.geniusKey = '',
    this.geminiKey = '',
    this.activeThemeId = 'chords_light',
    this.activeLightThemeId = 'chords_light',
    this.activeDarkThemeId = 'chords_dark',
    this.followSystem = false,
    this.customThemes = const [],
  });

  SettingsState copyWith({
    Locale? locale,
    String? geniusKey,
    String? geminiKey,
    String? activeThemeId,
    String? activeLightThemeId,
    String? activeDarkThemeId,
    bool? followSystem,
    List<AppTheme>? customThemes,
  }) {
    return SettingsState(
      locale: locale ?? this.locale,
      geniusKey: geniusKey ?? this.geniusKey,
      geminiKey: geminiKey ?? this.geminiKey,
      activeThemeId: activeThemeId ?? this.activeThemeId,
      activeLightThemeId: activeLightThemeId ?? this.activeLightThemeId,
      activeDarkThemeId: activeDarkThemeId ?? this.activeDarkThemeId,
      followSystem: followSystem ?? this.followSystem,
      customThemes: customThemes ?? this.customThemes,
    );
  }

  AppTheme get currentTheme {
    final allThemes = [...builtInThemes, ...customThemes];
    return allThemes.firstWhere((t) => t.id == activeThemeId,
        orElse: () => builtInThemes.first);
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
    final themeId = prefs.getString('active_theme') ?? 'chords_light';
    final lightThemeId =
        prefs.getString('active_light_theme') ?? 'chords_light';
    final darkThemeId = prefs.getString('active_dark_theme') ?? 'chords_dark';
    final followSystem = prefs.getBool('follow_system_theme') ?? false;

    final customThemesJson = prefs.getStringList('custom_themes') ?? [];
    final loadedCustoms =
        customThemesJson.map((t) => AppTheme.fromJson(jsonDecode(t))).toList();

    state = SettingsState(
      locale: Locale(langCode),
      geniusKey: genius,
      geminiKey: gemini,
      activeThemeId: themeId,
      activeLightThemeId: lightThemeId,
      activeDarkThemeId: darkThemeId,
      followSystem: followSystem,
      customThemes: loadedCustoms,
    );
  }

  Future<void> setTheme(String themeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_theme', themeId);
    state = state.copyWith(activeThemeId: themeId);
  }

  Future<void> setLightTheme(String themeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_light_theme', themeId);
    state = state.copyWith(activeLightThemeId: themeId);
  }

  Future<void> setDarkTheme(String themeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_dark_theme', themeId);
    state = state.copyWith(activeDarkThemeId: themeId);
  }

  Future<void> setFollowSystem(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('follow_system_theme', value);
    state = state.copyWith(followSystem: value);
  }

  Future<void> addCustomTheme(AppTheme theme) async {
    final newThemes = [...state.customThemes, theme];
    state = state.copyWith(customThemes: newThemes);
    _saveCustomThemes(newThemes);
  }

  Future<void> updateCustomTheme(AppTheme theme) async {
    final newThemes =
        state.customThemes.map((t) => t.id == theme.id ? theme : t).toList();
    state = state.copyWith(customThemes: newThemes);
    _saveCustomThemes(newThemes);
  }

  Future<void> deleteCustomTheme(String themeId) async {
    final newThemes = state.customThemes.where((t) => t.id != themeId).toList();
    state = state.copyWith(
      customThemes: newThemes,
      activeThemeId:
          state.activeThemeId == themeId ? 'chords_light' : state.activeThemeId,
    );
    _saveCustomThemes(newThemes);
    if (state.activeThemeId == 'chords_light') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('active_theme', 'chords_light');
    }
  }

  Future<void> _saveCustomThemes(List<AppTheme> themes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = themes.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList('custom_themes', jsonList);
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

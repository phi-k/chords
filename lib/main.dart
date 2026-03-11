// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:developer';
import 'l10n/app_localizations.dart';
import 'data/collections/playlist.dart' as isar_playlist;
import 'data/collections/song.dart' as isar_song;
import 'providers/settings_provider.dart';
import 'screens/home_page.dart';
import 'screens/playlist_detail_page.dart';
import 'screens/playlist_edit_page.dart';
import 'screens/welcome_page.dart';
import 'screens/language_selection_page.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError();
});

Future<void> _migrateJsonToIsar(Isar isar) async {
  final bool isarIsEmpty =
      await isar.songs.count() == 0 && await isar.playlists.count() == 0;
  if (!isarIsEmpty) {
    log("La base de données Isar contient déjà des données. Migration ignorée.");
    return;
  }

  log("Base de données Isar vide. Tentative de migration depuis un fichier JSON...");

  try {
    final directory = await getApplicationDocumentsDirectory();
    final List<String> possibleFilePaths = [
      '${directory.path}/saved_songs.json',
      '${directory.path}/assets/json/saved_songs.json'
    ];
    File? migrationFile;

    for (final filePath in possibleFilePaths) {
      final file = File(filePath);
      if (await file.exists()) {
        migrationFile = file;
        log("Fichier de migration trouvé à l'emplacement : ${file.path}");
        break;
      }
    }

    if (migrationFile == null) {
      log("Aucun fichier de données JSON à migrer n'a été trouvé.");
      return;
    }

    final content = await migrationFile.readAsString();
    if (content.isEmpty) return;

    final List<dynamic> oldData = json.decode(content);
    final List<isar_song.Song> newSongs = [];
    final List<Map<String, dynamic>> oldPlaylistsData = [];

    for (var dataBlock in oldData) {
      if (dataBlock is Map<String, dynamic>) {
        if (dataBlock['type'] == 'playlists') {
          final items = dataBlock['items'] as List?;
          if (items != null) {
            oldPlaylistsData.addAll(items.cast<Map<String, dynamic>>());
          }
        } else if (dataBlock.containsKey('songUrl')) {
          newSongs.add(isar_song.Song.fromMap(dataBlock));
        }
      }
    }

    await isar.writeTxn(() async {
      await isar.songs.clear();
      await isar.playlists.clear();

      final Map<String, int> songUrlToId = {};
      final List<int> newSongIds = await isar.songs.putAll(newSongs);
      for (int i = 0; i < newSongs.length; i++) {
        songUrlToId[newSongs[i].songUrl] = newSongIds[i];
      }

      log("Migration réussie : ${newSongs.length} chansons importées dans Isar.");

      if (oldPlaylistsData.isNotEmpty) {
        final List<isar_playlist.Playlist> newPlaylists = [];
        for (var oldPlaylistMap in oldPlaylistsData) {
          final newPlaylist = isar_playlist.Playlist()
            ..uuid = oldPlaylistMap['id'] ?? const Uuid().v4()
            ..name = oldPlaylistMap['name']
            ..createdAt = DateTime.tryParse(oldPlaylistMap['createdAt'] ?? '')
            ..lastModified =
                DateTime.tryParse(oldPlaylistMap['lastModified'] ?? '');

          final List<String> songUrls =
              List<String>.from(oldPlaylistMap['songUrls'] ?? []);
          final List<int> songIdsToLink =
              songUrls.map((url) => songUrlToId[url]).whereType<int>().toList();

          final songsToLink = await isar.songs.getAll(songIdsToLink);
          newPlaylist.songs.addAll(songsToLink.whereType<isar_song.Song>());

          newPlaylists.add(newPlaylist);
        }

        await isar.playlists.putAll(newPlaylists);
        for (var playlist in newPlaylists) {
          await playlist.songs.save();
        }
      }
    });
  } catch (e) {
    log("Erreur pendant la migration de JSON vers Isar: $e");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();
  final isarInstance = await Isar.open(
    [isar_song.SongSchema, isar_playlist.PlaylistSchema],
    directory: dir.path,
  );

  await _migrateJsonToIsar(isarInstance);

  await initializeDateFormatting('fr_FR', null);
  Intl.defaultLocale = 'fr_FR';

  final prefs = await SharedPreferences.getInstance();
  final bool hasSelectedLanguage =
      prefs.getBool('has_selected_language') ?? false;
  final bool hasSeenWelcome = prefs.getBool('has_seen_welcome') ?? false;

  Widget initialScreen;
  if (!hasSelectedLanguage) {
    initialScreen = const LanguageSelectionPage();
  } else if (!hasSeenWelcome) {
    initialScreen = const WelcomePage();
  } else {
    initialScreen = const HomePage();
  }

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isarInstance),
      ],
      child: MyApp(startScreen: initialScreen),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  final Widget startScreen;

  const MyApp({super.key, required this.startScreen});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    ref.read(settingsProvider.notifier).loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver],
      locale: settings.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          primary: Colors.red,
          surface: Colors.white,
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.red,
          selectionColor: Color(0xFFFFCDD2),
          selectionHandleColor: Colors.red,
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: widget.startScreen,
      routes: {
        '/home': (context) => const HomePage(),
        '/welcome': (context) => const WelcomePage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/playlist_detail') {
          final playlistId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => PlaylistDetailPage(playlistId: playlistId),
          );
        } else if (settings.name == '/playlist_edit') {
          final playlistId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => PlaylistEditPage(playlistId: playlistId),
          );
        }
        return null;
      },
    );
  }
}

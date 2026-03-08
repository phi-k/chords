import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/song_provider.dart';
import '../widgets/search_bar.dart';
import '../widgets/filter_buttons.dart';
import '../widgets/filtered_content_view.dart';
import '../widgets/artist_songs_list_widget.dart';
import '../widgets/song_list.dart';
import '../services/update_service.dart';
import '../widgets/update_dialog.dart';
import '../l10n/app_localizations.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkPostUpdate();
      _checkForUpdates();
    });
  }

  Future<void> _checkPostUpdate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final packageInfo = await PackageInfo.fromPlatform();

      final String currentVersion = packageInfo.version;
      final String? lastRunVersion = prefs.getString('last_run_version');

      if (lastRunVersion == null) {
        await prefs.setString('last_run_version', currentVersion);
        return;
      }

      if (lastRunVersion != currentVersion) {
        await prefs.setString('last_run_version', currentVersion);

        final updateService = UpdateService();
        final changelog =
            await updateService.getChangelogForVersion(currentVersion);

        if (!mounted) return;

        showDialog(
          context: context,
          builder: (context) =>
              _buildUpdateSuccessDialog(currentVersion, changelog),
        );
      }
    } catch (e) {
      debugPrint("Erreur lors de la vérification post-update : $e");
    }
  }

  Widget _buildUpdateSuccessDialog(String version, String? changelog) {
    final loc = AppLocalizations.of(context)!;
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Column(
        children: [
          const Text(
            "🎉",
            style: TextStyle(fontSize: 40),
          ),
          const SizedBox(height: 10),
          Text(
            loc.homeUpdateSuccess,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cormorant',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              loc.homeUpdateSuccessMessage(version),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cormorant',
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            if (changelog != null && changelog.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  loc.homeWhatsNew,
                  style: TextStyle(
                    fontFamily: 'Cormorant',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.red,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  changelog,
                  style: const TextStyle(
                    fontFamily: 'UbuntuMono',
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            ),
            child: Text(
              loc.homeGreat,
              style: TextStyle(
                fontFamily: 'Cormorant',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _checkForUpdates() async {
    final updateService = UpdateService();
    final newVersion = await updateService.checkForUpdate();

    if (newVersion != null) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => UpdateDialog(appVersion: newVersion),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(homeFilterProvider);
    final filterNotifier = ref.read(homeFilterProvider.notifier);

    const horizontalPadding = EdgeInsets.symmetric(horizontal: 40);
    const songListPadding = EdgeInsets.only(left: 40, right: 0);

    return PopScope(
      canPop: filterState.selectedArtist == null &&
          filterState.selectedPlaylist == null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          filterNotifier.clearSelections();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Builder(
          builder: (context) {
            final loc = AppLocalizations.of(context)!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                Padding(
                  padding: horizontalPadding,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: const [
                      Text("C",
                          style: TextStyle(
                              fontFamily: 'Cormorant',
                              fontSize: 50,
                              color: Colors.red)),
                      Text("hords",
                          style: TextStyle(
                              fontFamily: 'Cormorant',
                              fontSize: 50,
                              color: Colors.black)),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Padding(
                    padding: horizontalPadding,
                    child: Container(height: 1, color: Colors.black)),
                const SizedBox(height: 15),
                Padding(
                  padding: horizontalPadding,
                  child: FilterButtons(
                    activeFilters: filterState.activeFilters,
                    onFilterToggled: filterNotifier.toggleFilterMode,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Consumer(
                    builder: (context, ref, _) {
                      final asyncSongs = ref.watch(allSongsProvider);
                      final asyncArtists = ref.watch(artistsProvider);

                      return asyncSongs.when(
                        skipLoadingOnReload: true,
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, stackTrace) => Center(
                            child: Text(loc.commonError(error.toString()))),
                        data: (savedSongs) {
                          final artistsCount = asyncArtists.value ?? {};

                          String headerText = filterState.selectedArtist != null
                              ? loc.homeSongsOf(filterState.selectedArtist!)
                              : filterState.selectedPlaylist != null
                                  ? loc.homePlaylistLabel(
                                      filterState.selectedPlaylist!.name ?? '')
                                  : FilteredContentView.getHeaderText(
                                      filterState.activeFilters,
                                      artistsCount,
                                      savedSongs,
                                      filterState.filterText,
                                      filterState.recentFilterReversed,
                                      loc);

                          Widget contentView;

                          if (filterState.selectedArtist != null) {
                            contentView = Consumer(
                              builder: (context, ref, child) {
                                final asyncArtistSongs = ref.watch(
                                    artistSongsProvider(
                                        filterState.selectedArtist!));
                                return asyncArtistSongs.when(
                                  loading: () => const Center(
                                      child: CircularProgressIndicator()),
                                  error: (err, stack) => Center(
                                      child: Text(
                                          loc.commonError(err.toString()))),
                                  data: (artistSongs) {
                                    return Padding(
                                      padding: songListPadding,
                                      child: ArtistSongsListWidget(
                                          songs: artistSongs),
                                    );
                                  },
                                );
                              },
                            );
                          } else if (filterState.selectedPlaylist != null) {
                            final playlistSongIds = filterState
                                .selectedPlaylist!.songs
                                .map((s) => s.id)
                                .toSet();
                            final playlistSongs = savedSongs
                                .where((s) => playlistSongIds.contains(s.id))
                                .toList();
                            contentView = Padding(
                              padding: songListPadding,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Text(
                                      loc.homePieceCount(playlistSongs.length),
                                      style: TextStyle(
                                          fontFamily: 'Cormorant',
                                          fontSize: 14,
                                          color: Colors.grey.shade600),
                                    ),
                                  ),
                                  Expanded(
                                    child: SongListWidget(
                                      songs: playlistSongs,
                                      onRefresh: () async =>
                                          ref.invalidate(allSongsProvider),
                                      showAlphabetScroller: false,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            contentView = FilteredContentView(
                              songs: savedSongs,
                              artistsCount: artistsCount,
                            );
                          }

                          Widget? sortToggleButton;
                          if (filterState.activeFilters
                                  .contains(FilterMode.recent) &&
                              (filterState.activeFilters
                                      .contains(FilterMode.artists) ||
                                  (filterState.activeFilters.length == 1 &&
                                      filterState.activeFilters
                                          .contains(FilterMode.recent)))) {
                            sortToggleButton = GestureDetector(
                              onTap: filterNotifier.toggleRecentSortOrder,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.shade100,
                                ),
                                child: Icon(
                                  filterState.recentFilterReversed
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  size: 16,
                                  color: Colors.black,
                                ),
                              ),
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: horizontalPadding,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        headerText,
                                        style: const TextStyle(
                                            fontFamily: 'Cormorant',
                                            fontSize: 16,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    if (sortToggleButton != null)
                                      sortToggleButton,
                                  ],
                                ),
                              ),
                              Expanded(child: contentView),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Focus(
                    onFocusChange: filterNotifier.setSearchFocused,
                    child: SearchBarWidget(
                      onTextChanged: filterNotifier.setFilterText,
                      filterText: filterState.filterText,
                      filteredCount:
                          ref.watch(allSongsProvider).value?.length ?? 0,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

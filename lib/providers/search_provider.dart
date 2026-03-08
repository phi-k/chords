import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/search_result_model.dart';
import '../services/genius_service.dart';
import '../services/song_service.dart';

class SearchState {
  final List<GroupedSong> songs;
  final bool isLoadingInitial;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final int totalPages;

  SearchState({
    this.songs = const [],
    this.isLoadingInitial = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 0,
    this.totalPages = 1,
  });

  bool get canLoadMore => !isLoadingMore && currentPage < totalPages;

  SearchState copyWith({
    List<GroupedSong>? songs,
    bool? isLoadingInitial,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    int? totalPages,
  }) {
    return SearchState(
      songs: songs ?? this.songs,
      isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(SearchState());

  int _getSortRank(String type) {
    final lowerType = type.toLowerCase();
    if (lowerType == 'chords') return 0;
    if (lowerType == 'piano chords') return 1;
    if (lowerType == 'ukulele chords') return 2;
    return 3;
  }

  Map<String, dynamic> _parseTitle(String rawTitle) {
    final RegExp versionRegex = RegExp(r'\(ver (\d+)\) - (.*)');
    final match = versionRegex.firstMatch(rawTitle);
    if (match != null && match.groupCount == 2) {
      final baseTitle = rawTitle.substring(0, match.start).trim();
      final version = int.tryParse(match.group(1)!) ?? 1;
      final type = match.group(2)!.trim();
      return {'title': baseTitle, 'version': version, 'type': type};
    }
    return {
      'title': rawTitle.split('-')[0].trim(),
      'version': 1,
      'type': 'Chords'
    };
  }

  Future<void> fetchInitial(String searchTerm) async {
    state = state.copyWith(isLoadingInitial: true, error: null);
    try {
      final results = await SongService.searchSongs(searchTerm);

      List<Map<String, dynamic>> mappedResults = results.map((r) {
        String votesStr = (r['votes'] ?? '').toString();
        String ratingStr = (r['rating'] ?? '').toString();
        double rating = double.tryParse(ratingStr) ?? 0.0;

        String noteDisplay = "Source Database";
        if (votesStr.isNotEmpty && votesStr != "0") {
          noteDisplay =
              "${rating > 0 ? rating.toStringAsFixed(1) : ''} ($votesStr avis)"
                  .trim();
        }

        return {
          "artiste": (r['artist'] ?? 'Inconnu') as String,
          "titre": "${r['title']} - ${r['type'] ?? 'Chords'}",
          "note": noteDisplay,
          "lien": (r['song_url'] ?? '') as String,
          "type": (r['type'] ?? 'Chords') as String,
          "source_name": (r['source_name'] ?? '') as String,
          "source_id": (r['source_id'] ?? '') as String,
          "votes": int.tryParse(votesStr) ?? 0,
          "rating": rating,
        };
      }).toList();

      final groupedSongs = await _groupAndProcessResults(mappedResults, []);

      state = state.copyWith(
        isLoadingInitial: false,
        songs: groupedSongs,
        currentPage: 1,
        totalPages: 1,
      );
    } catch (e) {
      state = state.copyWith(isLoadingInitial: false, error: e.toString());
    }
  }

  Future<void> fetchMore(String searchTerm) async {
    return;
  }

  Future<List<GroupedSong>> _groupAndProcessResults(
      List<Map<String, dynamic>> results,
      List<GroupedSong> existingSongs) async {
    final songMap = {for (var s in existingSongs) '${s.artist}|${s.title}': s};

    for (var result in results) {
      final parsedTitle = _parseTitle(result['titre']!);
      final key = '${result['artiste']}|${parsedTitle['title']}';
      final newVersion = SongVersion(
        title: result['titre']!,
        note: result['note']!,
        lien: result['lien']!,
        versionNumber: parsedTitle['version'] as int,
        type: result['type'] ?? parsedTitle['type'] as String,
        sourceName: result['source_name'] ?? '',
        sourceId: result['source_id'] ?? '',
        votes: result['votes'] as int,
        rating: result['rating'] as double,
      );

      if (songMap.containsKey(key)) {
        if (!songMap[key]!.versions.any((v) => v.lien == newVersion.lien)) {
          songMap[key]!.versions.add(newVersion);
        }
      } else {
        songMap[key] = GroupedSong(
          title: parsedTitle['title'] as String,
          artist: result['artiste'] as String,
          versions: [newVersion],
        );
      }
    }

    final validatedSongs = songMap.values.toList();

    final newSongs = validatedSongs.where((s) => s.coverUrl == null).toList();
    await Future.wait(newSongs.map((song) async {
      song.coverUrl =
          await GeniusService.fetchCoverUrl(song.title, song.artist);
    }));

    for (var song in validatedSongs) {
      final chordsVersions =
          song.versions.where((v) => v.type.toLowerCase() == 'chords').toList();

      chordsVersions.sort((a, b) => b.votes.compareTo(a.votes));

      if (chordsVersions.isNotEmpty) {
        if (chordsVersions.length >= 2 && chordsVersions.length <= 4) {
          chordsVersions[0].rank = 1;
        } else if (chordsVersions.length >= 5) {
          for (int i = 0; i < 3 && i < chordsVersions.length; i++) {
            chordsVersions[i].rank = i + 1;
          }
        }
      }
      song.versions.sort((a, b) {
        final rankA = _getSortRank(a.type);
        final rankB = _getSortRank(b.type);
        if (rankA != rankB) return rankA.compareTo(rankB);
        return a.versionNumber.compareTo(b.versionNumber);
      });
    }

    return validatedSongs;
  }
}

final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier();
});

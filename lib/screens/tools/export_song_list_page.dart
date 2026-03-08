import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/collections/song.dart';
import '../../models/bottom_bar_model.dart';
import '../../providers/export_song_list_provider.dart';
import '../../providers/song_provider.dart';
import '../../widgets/tools/export_song_list/export_options_view.dart';
import '../../l10n/app_localizations.dart';

class ExportSongListPage extends ConsumerWidget {
  const ExportSongListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = ref.watch(exportOptionsProvider);
    final notifier = ref.read(exportOptionsProvider.notifier);
    final songsAsync = ref.watch(allSongsProvider);
    final loc = AppLocalizations.of(context)!;

    ref.listen<AsyncValue<List<Song>>>(allSongsProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        notifier.updateAllTags(next.value!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.exportListTitle,
            style: const TextStyle(
                fontFamily: 'Cormorant',
                fontWeight: FontWeight.bold,
                fontSize: 22)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: ExportOptionsView(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: options.isLoading
                      ? null
                      : () {
                          if (songsAsync.hasValue) {
                            notifier.export(context, songsAsync.value!);
                          } else {
                            BottomBarModel.showBottomBar(
                                message: loc.exportSongsLoading);
                          }
                        },
                  icon:
                      const Icon(Icons.download_outlined, color: Colors.white),
                  label: Text(
                      options.isLoading
                          ? loc.exportGenerating
                          : loc.exportExport,
                      style: const TextStyle(
                          fontFamily: 'Cormorant',
                          fontSize: 18,
                          color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

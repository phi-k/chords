import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/export_song_list_provider.dart';
import 'export_filter_section.dart';
import 'shared_export_widgets.dart';

class ExportOptionsView extends ConsumerWidget {
  const ExportOptionsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final options = ref.watch(exportOptionsProvider);
    final notifier = ref.read(exportOptionsProvider.notifier);
    final isArtistMode = options.displayChoice == 'auteurs';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionTitle(loc.exportOptDisplayContent),
        buildChoiceChip(
            [loc.exportOptSongs, loc.exportOptAuthors, loc.exportOptBoth],
            ['morceaux', 'auteurs', 'both'],
            options.displayChoice,
            notifier.setDisplayChoice),
        const SizedBox(height: 24),
        if (isArtistMode) ...[
          buildSwitchOption(
              loc.exportOptShowSongCount,
              loc.exportOptShowSongCountDesc,
              options.showArtistSongCount,
              notifier.setShowArtistSongCount),
          buildSwitchOption(
              loc.exportOptIncludePlayStats,
              loc.exportOptIncludePlayStatsDescArtist,
              options.withArtistStats,
              notifier.setWithArtistStats),
          const SizedBox(height: 24),
          buildSectionTitle(loc.exportOptArtistSelection),
          buildRadioGroup({
            'all': loc.exportOptAllArtists,
            'filtered': loc.exportOptFilteredArtists
          }, options.artistSelection,
              (value) => notifier.setArtistSelection(value!)),
          if (options.artistSelection == 'filtered')
            const ExportFilterSection(),
          const SizedBox(height: 24),
          buildSectionTitle(loc.exportOptSortOrder),
          buildRadioGroup({
            'alpha': loc.exportOptSortAlpha,
            'chrono': loc.exportOptSortLastPlayed,
            'appearance': loc.exportOptSortAppearance
          }, options.artistSortOrder,
              (value) => notifier.setArtistSortOrder(value!)),
        ] else ...[
          buildSwitchOption(
              loc.exportOptIncludeStats,
              loc.exportOptIncludeStatsDesc,
              options.withStats,
              notifier.setWithStats),
          const SizedBox(height: 24),
          buildSectionTitle(loc.exportOptSongSelection),
          buildRadioGroup({
            'all': loc.exportOptAllSongs,
            'filtered': loc.exportOptFilteredSongs
          }, options.songSelection,
              (value) => notifier.setSongSelection(value!)),
          if (options.songSelection == 'filtered') const ExportFilterSection(),
          const SizedBox(height: 24),
          buildSectionTitle(loc.exportOptSortOrder),
          buildRadioGroup({
            'alpha': loc.exportOptSortAlpha,
            'chrono': loc.exportOptSortChrono
          }, options.songSortOrder,
              (value) => notifier.setSongSortOrder(value!)),
        ],
        const SizedBox(height: 24),
        buildSectionTitle(loc.exportOptExportFormat),
        buildChoiceChip(['TXT', 'PDF'], ['txt', 'pdf'], options.exportFormat,
            notifier.setExportFormat),
        const SizedBox(height: 100),
      ],
    );
  }
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcomePass => 'SKIP';

  @override
  String get welcomeStart => 'START';

  @override
  String get welcomeNext => 'NEXT';

  @override
  String get welcomeSlide1Title => 'The Essentials,\nRefined.';

  @override
  String get welcomeSlide1Subtitle =>
      'Your favorite songs. Your chords.\nA clean interface, designed for musicians.';

  @override
  String get welcomeSlide2Title => 'Your Data,\nYour Rules.';

  @override
  String get welcomeSlide2Subtitle =>
      'Connect any external data source via REST API.\nChords is a neutral player for your personal databases.';

  @override
  String get welcomeSlide3Title => 'Smart\nTools.';

  @override
  String get welcomeSlide3Subtitle =>
      'Transpose in one click, simplify\ncomplex chords. Adapt the song to you.';

  @override
  String get welcomeSlide4Title => 'Master\nyour Art.';

  @override
  String get welcomeSlide4Subtitle =>
      'Play statistics, history, playlists.\nTrack your musical progress day after day.';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonSearch => 'Search...';

  @override
  String get commonLoading => 'Loading...';

  @override
  String commonError(String error) {
    return 'Error: $error';
  }

  @override
  String get commonUnknownArtist => 'Unknown artist';

  @override
  String get commonUntitled => 'Untitled';

  @override
  String get commonOk => 'OK';

  @override
  String get commonClose => 'Close';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonRename => 'Rename';

  @override
  String get commonCreate => 'Create';

  @override
  String get commonOther => 'Other';

  @override
  String get homeArtists => 'Artists';

  @override
  String get homePlaylists => 'Playlists';

  @override
  String get homeRecent => 'Recent';

  @override
  String get homeTags => 'Tags';

  @override
  String get homeEmptyTitle => 'Your library is empty';

  @override
  String get homeEmptySubtitle =>
      'To get started, you can connect a data source to search for tabs, or write your first song manually.';

  @override
  String get homeEmptyBtnSource => 'Configure a source';

  @override
  String get homeEmptyBtnSourceDone => 'Source configured';

  @override
  String get homeEmptySourceDoneSubtitle =>
      'Your source is ready! Try the search to find your first songs.';

  @override
  String get homeEmptyBtnWrite => 'Write a song';

  @override
  String get homeNoSongs => 'No songs saved yet.';

  @override
  String homeSongCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count songs',
      one: '1 song',
      zero: '0 songs',
    );
    return '$_temp0';
  }

  @override
  String get homeUpdateSuccess => 'Update successful!';

  @override
  String homeUpdateSuccessMessage(String version) {
    return 'Chords has been updated to version $version!';
  }

  @override
  String get homeWhatsNew => 'What\'s new:';

  @override
  String get homeGreat => 'Great!';

  @override
  String homeSongsOf(String artist) {
    return 'Songs by $artist';
  }

  @override
  String homePlaylistLabel(String name) {
    return 'Playlist: $name';
  }

  @override
  String homePieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count songs',
      one: '1 song',
      zero: '0 songs',
    );
    return '$_temp0';
  }

  @override
  String get songDifficulty => 'Difficulty';

  @override
  String get songCapo => 'Capo';

  @override
  String get songTuning => 'Tuning';

  @override
  String get songTranspose => 'Transpose';

  @override
  String get songViewStats => 'View statistics';

  @override
  String get songOptionsMetadata => 'Edit metadata';

  @override
  String get songOptionsLyrics => 'Edit lyrics & chords';

  @override
  String get songOptionsDelete => 'Delete song';

  @override
  String get songDeleteConfirmTitle => 'Delete this song?';

  @override
  String songDeleteConfirmMessage(String title, String artist) {
    return 'Are you sure you want to delete \"$title\" by $artist? This action is irreversible.';
  }

  @override
  String get songNoCheat => 'No cheating here! ;)';

  @override
  String get songNoCheatDismiss => 'Boo';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get statsSavedDate => 'Saved date';

  @override
  String get statsPlayCount => 'Times played';

  @override
  String get statsLastPlayed => 'Last played';

  @override
  String get statsHistory => 'Play history';

  @override
  String get statsNoHistory => 'No history available';

  @override
  String get statsTags => 'Tags';

  @override
  String get statsNoTags => 'No tags';

  @override
  String get statsShowList => 'Show as list';

  @override
  String get statsShowGraph => 'Show as graph';

  @override
  String get statsUnknownTitle => 'Unknown title';

  @override
  String get toolsTitle => 'Tools';

  @override
  String get toolsUtilities => 'Utilities';

  @override
  String get toolsTuner => 'Tuner';

  @override
  String get toolsTunerDesc => 'Tune your guitar via microphone';

  @override
  String get toolsMetronome => 'Metronome';

  @override
  String get toolsMetronomeDesc => 'Keep the rhythm with precision';

  @override
  String get toolsExport => 'Export';

  @override
  String get toolsExportList => 'Export list';

  @override
  String get toolsExportListDesc => 'Generate a list (TXT/PDF) of your songs';

  @override
  String get toolsExportTabs => 'Export tabs';

  @override
  String get toolsExportTabsDesc => 'Create a complete PDF Songbook';

  @override
  String get toolsMisc => 'Miscellaneous';

  @override
  String get toolsVersion => 'Version and updates';

  @override
  String get toolsVersionDesc => 'See current version and history';

  @override
  String get toolsWelcome => 'Replay introduction';

  @override
  String get toolsWelcomeDesc => 'Show the welcome screen';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSearchHint => 'Search settings...';

  @override
  String get settingsNoResults => 'No results found';

  @override
  String get settingsToolsDesc => 'Tuner, metronome, export...';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsApiKeys => 'API Keys';

  @override
  String get settingsGeniusDesc => 'Used to fetch album covers';

  @override
  String get settingsGeminiDesc => 'Used for smart search suggestions';

  @override
  String get settingsBackups => 'Backups';

  @override
  String get settingsImportLib => 'Import library';

  @override
  String get settingsImportLibDesc =>
      'Import a JSON file containing saved songs';

  @override
  String get settingsExportLib => 'Export library';

  @override
  String get settingsExportLibDesc => 'Save your songs to a JSON file';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsDevBy => 'Developed with passion by';

  @override
  String get settingsDataSources => 'Data sources';

  @override
  String get settingsDataSourcesDesc => 'Connect a tab database';

  @override
  String get settingsPasteApiKey => 'Paste your API key here';

  @override
  String get settingsConfirmImport => 'Confirm import';

  @override
  String get settingsReplaceLibrary =>
      'This will replace the existing library. Continue?';

  @override
  String get settingsImportSuccess => 'Import successful. Returning to home...';

  @override
  String get settingsInvalidFile => 'Invalid file';

  @override
  String settingsImportError(String error) {
    return 'Import error: $error';
  }

  @override
  String settingsExportSuccess(String path) {
    return 'Export successful to $path';
  }

  @override
  String get settingsExportCancelled => 'Export cancelled';

  @override
  String settingsExportError(String error) {
    return 'Export error: $error';
  }

  @override
  String get settingsDevWith => 'Developed with';

  @override
  String get settingsDevWithDesc =>
      'Flutter - Thanks to the Isar, Riverpod, fl_charts libraries and all the others!';

  @override
  String get settingsAppVersion => 'App version';

  @override
  String get settingsLegal => 'Legal notices & License';

  @override
  String get settingsDevSubtitle => 'phi-k - pianist and developer';

  @override
  String get dsTitle => 'Data Sources';

  @override
  String get dsNoSource => 'No source configured';

  @override
  String get dsNoSourceDesc =>
      'Chords does not contain any music by default. Connect your own database or a community API to search for tabs.';

  @override
  String get dsAddSource => 'Add a source';

  @override
  String get dsScanQr => 'Scan a QR code';

  @override
  String get dsImportFile => 'Import a file';

  @override
  String get dsManualConfig => 'Configure manually';

  @override
  String get dsHelp => 'Help';

  @override
  String get dsHelpTitle => 'Data Sources';

  @override
  String get dsHelpContent =>
      'Chords does not contain any music. You must connect an external database (REST API) to search for tabs and chords.';

  @override
  String get dsHelpBullets =>
      '• Press + to add a source\n• Use the switch to enable/disable\n• Swipe left to delete\n• Only one source can be active at a time\n• Share your sources via file or QR code';

  @override
  String get dsUnderstood => 'Got it';

  @override
  String get dsDeleteConfirm => 'Delete this source?';

  @override
  String dsDeleteMessage(String name) {
    return 'The source \"$name\" will be permanently deleted.';
  }

  @override
  String dsExportError(String error) {
    return 'Export error: $error';
  }

  @override
  String get dsImportConfirm => 'Import this source?';

  @override
  String get dsImportName => 'Name';

  @override
  String get dsImportUrl => 'URL';

  @override
  String get dsImportHeaders => 'Headers';

  @override
  String dsImportSuccess(String name) {
    return 'Source \"$name\" imported successfully!';
  }

  @override
  String dsInvalidFile(String error) {
    return 'Invalid file: $error';
  }

  @override
  String get dsImport => 'Import';

  @override
  String get dsShareSource => 'Share this source';

  @override
  String get dsShareFile => 'Export as file';

  @override
  String get dsShareFileDesc => 'Send a shareable JSON file';

  @override
  String get dsShareQr => 'QR Code';

  @override
  String get dsShareQrDesc => 'Display a scannable QR code';

  @override
  String dsShareTitle(String name) {
    return 'Share \"$name\"';
  }

  @override
  String get dsQrScanInfo =>
      'Scan this QR code from another device to import this source.';

  @override
  String get dsQrHeadersIncluded => 'Headers included in the QR code';

  @override
  String get dsAddSourceTitle => 'Add a source';

  @override
  String get dsScanSubtitle => 'Import from another device\'s camera';

  @override
  String get dsImportFileSubtitle => 'Load a JSON configuration file';

  @override
  String get dsManualSubtitle => 'Enter connection information manually';

  @override
  String dsSourceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sources configured',
      one: '1 source configured',
    );
    return '$_temp0';
  }

  @override
  String get dsConnected => 'Connected';

  @override
  String get dsShare => 'Share';

  @override
  String get editSourceUnsavedTitle => 'Unsaved changes';

  @override
  String get editSourceUnsavedMessage =>
      'You have unsaved changes. What would you like to do?';

  @override
  String get editSourceContinue => 'Continue editing';

  @override
  String get editSourceDiscard => 'Discard';

  @override
  String get editSourceFillRequired =>
      'Fill in at least the base URL and the search path.';

  @override
  String searchResultsFor(String term) {
    return 'Results for \"$term\"';
  }

  @override
  String get searchNoResults => 'No results found for this search.';

  @override
  String get searchLoadMore => 'Load more';

  @override
  String get searchBarHint => 'Find anything.';

  @override
  String get creationTitle => 'New song';

  @override
  String get creationTitleRequired => 'Title is required.';

  @override
  String get creationArtistRequired => 'Author is required.';

  @override
  String get creationSongAdded => 'Song added to library!';

  @override
  String creationSaveError(String error) {
    return 'Error saving: $error';
  }

  @override
  String get creationClipboardEmpty => 'Clipboard is empty.';

  @override
  String get creationTitleHint => 'Song title';

  @override
  String get creationArtistHint => 'Author';

  @override
  String get creationMetadata => 'Additional metadata';

  @override
  String get creationCapo => 'Capo';

  @override
  String get creationTonality => 'Tonality';

  @override
  String get creationDifficulty => 'Difficulty';

  @override
  String get creationTuning => 'Tuning';

  @override
  String get creationContentHint =>
      '[Intro]\n\nAm           F\nWrite your chords here...\nC            G\nAbove the lyrics.';

  @override
  String get creationPaste => 'Paste';

  @override
  String get creationUndoPaste => 'Undo paste';

  @override
  String editLyricsTitle(String title) {
    return 'Edit \"$title\"';
  }

  @override
  String get editLyricsReset => 'Reset';

  @override
  String get editLyricsResetTitle => 'Reset';

  @override
  String get editLyricsResetMessage =>
      'This action will restore the original version of lyrics and chords, and delete all your previous changes. Are you sure?';

  @override
  String get editLyricsHint => 'Enter lyrics and chords here...';

  @override
  String get editLyricsResetTooltip => 'Reset to original version';

  @override
  String get blindTestTitle => 'Blind Test';

  @override
  String get blindTestHideTitles => 'Hide titles';

  @override
  String get blindTestShowTitles => 'Show titles';

  @override
  String get blindTestShuffle => 'Shuffle again';

  @override
  String blindTestCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count songs shuffled',
      one: '1 song shuffled',
    );
    return '$_temp0';
  }

  @override
  String get blindTestNoSongs => 'No songs available';

  @override
  String get blindTestNoSongsHint => 'Save some songs to play the blind test!';

  @override
  String get blindTestUnknownTitle => 'Unknown title';

  @override
  String get blindTestUnknownArtist => 'Unknown artist';

  @override
  String blindTestSongNumber(int number) {
    return 'Song $number';
  }

  @override
  String get blindTestTitleHidden => 'Title view disabled';

  @override
  String get blindTestViewSong => 'View song';

  @override
  String get blindTestCancelTooltip => 'Cancel';

  @override
  String get playlistNotFound => 'Playlist not found.';

  @override
  String get playlistNoSongs => 'No songs in this playlist';

  @override
  String get playlistAddSongs => 'Add songs';

  @override
  String get playlistSongLoadError => 'Error loading songs.';

  @override
  String get playlistSaved => 'Playlist saved';

  @override
  String playlistSaveError(String error) {
    return 'Error saving playlist: $error';
  }

  @override
  String playlistEditTitle(String name) {
    return 'Edit $name';
  }

  @override
  String playlistSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count songs selected',
      one: '1 song selected',
    );
    return '$_temp0';
  }

  @override
  String get playlistNewTitle => 'New Playlist';

  @override
  String get playlistNameHint => 'Playlist name...';

  @override
  String get playlistRenameTitle => 'Rename Playlist';

  @override
  String get playlistDeleteTitle => 'Delete Playlist';

  @override
  String playlistDeleteMessage(String name) {
    return 'Do you really want to delete the playlist \"$name\"?';
  }

  @override
  String get playlistCreateError => 'Error creating the playlist';

  @override
  String get playlistRenameError => 'Error renaming the playlist';

  @override
  String filterSongsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count songs',
      one: '1 song',
      zero: '0 songs',
    );
    return '$_temp0';
  }

  @override
  String filterArtistsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artists',
      one: '1 artist',
      zero: '0 artists',
    );
    return '$_temp0';
  }

  @override
  String get filterOldestArtists => 'Least recent artists';

  @override
  String get filterNewestArtists => 'Most recent artists';

  @override
  String get filterOldSongs => 'Older songs';

  @override
  String get filterRecentSongs => 'Recent songs';

  @override
  String get filterNoPlayed => 'No song has been played yet';

  @override
  String filterChordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chords',
      one: '1 chord',
    );
    return '$_temp0';
  }

  @override
  String get filterTagsNotImplemented => 'Tag filtering not implemented';

  @override
  String get updatePermissionTitle => 'Permission required';

  @override
  String get updatePermissionMessage =>
      'To update Chords, you must allow the installation of apps from unknown sources in settings.';

  @override
  String get updateOpenSettings => 'Open settings';

  @override
  String get updateAvailable => 'Update available';

  @override
  String updateVersion(String version) {
    return 'Version $version';
  }

  @override
  String get updateDownloading => 'Downloading...';

  @override
  String get updateDownloadFailed => 'Download failed. Check your connection.';

  @override
  String get updateMissed => 'What you missed:';

  @override
  String get updateLater => 'Later';

  @override
  String get updateInstall => 'Install';

  @override
  String get versionTitle => 'Version and updates';

  @override
  String get versionAutoUpdateAndroid =>
      'Automatic updates are only available on Android.';

  @override
  String get versionUpToDate => 'You are up to date!';

  @override
  String get versionCheckError => 'Error checking for updates.';

  @override
  String get versionChecking => 'Checking...';

  @override
  String get versionCheckUpdate => 'Check for updates';

  @override
  String get versionHistory => 'Version history';

  @override
  String get versionHistoryError => 'Unable to load history.';

  @override
  String get tunerTitle => 'Tuner';

  @override
  String get tunerPlayString => 'Play a string';

  @override
  String get tunerMicPermission =>
      'Microphone permission required for the tuner.';

  @override
  String get tunerMicOff => 'Mic off';

  @override
  String get tunerTuned => 'Tuned';

  @override
  String get tunerTooLow => 'Too low';

  @override
  String get tunerTooHigh => 'Too high';

  @override
  String get tunerListening => 'Listening…';

  @override
  String get tunerMuteBtn => 'Mute mic';

  @override
  String get tunerActivateBtn => 'Activate mic';

  @override
  String get metronomeTitle => 'Metronome';

  @override
  String get exportListTitle => 'Export list';

  @override
  String get exportGenerating => 'Generating...';

  @override
  String get exportExport => 'Export';

  @override
  String get exportSongsLoading => 'The song list is loading.';

  @override
  String get exportTabsTitle => 'Generate a Songbook';

  @override
  String get exportTabsSetCount => 'Set the number';

  @override
  String exportTabsCountHint(int max) {
    return 'Enter a number between 1 and $max:';
  }

  @override
  String get exportTabsContentTitle => '1. Songbook content';

  @override
  String get exportTabsAll => 'All';

  @override
  String get exportTabsPlaylist => 'Playlist';

  @override
  String get exportTabsArtist => 'Artist';

  @override
  String get exportTabsRecent => 'Recent';

  @override
  String get exportTabsManual => 'Manual';

  @override
  String get exportTabsCustomTitle => '2. Customization';

  @override
  String get exportTabsSongbookTitle => 'Songbook title';

  @override
  String get exportTabsCoverPage => 'Include cover page';

  @override
  String get exportTabsToc => 'Include table of contents';

  @override
  String get exportTabsGeneratePdf => 'Generate PDF';

  @override
  String get exportTabsGenerating => 'Generating...';

  @override
  String get exportTabsFooter =>
      'The generated document will contain all selected tabs laid out for printing.';

  @override
  String get exportTabsNoSongs => 'No songs in your library.';

  @override
  String get exportTabsNoPlaylist => 'No playlist.';

  @override
  String get exportTabsChoosePlaylist => 'Choose a playlist';

  @override
  String get exportTabsChooseArtist => 'Choose an artist';

  @override
  String get exportTabsManualSelection => 'Manual selection';

  @override
  String get exportTabsClickToChoose => 'Click to choose';

  @override
  String exportTabsSongsChosen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count songs chosen',
      one: '1 song chosen',
    );
    return '$_temp0';
  }

  @override
  String get exportTabsSongCount => 'Number of songs';

  @override
  String get exportTabsRecentDesc => 'The most recently played or added songs.';

  @override
  String get exportTabsUnnamed => 'Unnamed';

  @override
  String get multiSelectTitle => 'Manual selection';

  @override
  String get multiSelectSearchHint => 'Search...';

  @override
  String multiSelectCount(int count) {
    return '$count selected';
  }

  @override
  String get multiSelectAll => 'Select all';

  @override
  String get multiSelectNone => 'Deselect all';

  @override
  String get metadataEditTitle => 'Edit metadata';

  @override
  String get metadataTitle => 'Title';

  @override
  String get metadataArtist => 'Author';

  @override
  String get metadataCoverUrl => 'Cover URL';

  @override
  String get metadataFetchGenius => 'Fetch from Genius';

  @override
  String get editOptionsMetadata => 'Edit metadata';

  @override
  String get editOptionsLyrics => 'Edit lyrics and chords';

  @override
  String get langChooseTitle => 'Choose your language\nChoisissez votre langue';

  @override
  String get welcomeFinalGreeting => 'Welcome to ';

  @override
  String get welcomeFinalSubtitle =>
      'Your music catalog\n100% free and open-source.';

  @override
  String get filterArtists => 'Artists';

  @override
  String get filterPlaylists => 'Playlists';

  @override
  String get filterRecent => 'Recent';

  @override
  String headerSongs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count songs',
      one: '1 song',
      zero: '0 songs',
    );
    return '$_temp0';
  }

  @override
  String get headerArtistsOldest => 'Least recent artists';

  @override
  String get headerArtistsNewest => 'Most recent artists';

  @override
  String headerArtists(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artists',
      one: '1 artist',
      zero: '0 artists',
    );
    return '$_temp0';
  }

  @override
  String get headerOldSongs => 'Old songs';

  @override
  String get headerRecentSongs => 'Recent songs';

  @override
  String get artistsUnknown => 'Unknown';

  @override
  String get artistsOther => 'Other';

  @override
  String get recentNoSongsPlayed => 'No songs have been played yet';

  @override
  String get tagsNotImplemented => 'Tag filtering not implemented';

  @override
  String get playlistCreateBtn => 'Create';

  @override
  String get playlistRenameBtn => 'Rename';

  @override
  String playlistDeleteConfirm(String name) {
    return 'Are you sure you want to delete the playlist \"$name\"?';
  }

  @override
  String get playlistDeleteBtn => 'Delete';

  @override
  String get playlistDeleteError => 'Error deleting the playlist';

  @override
  String get playlistNone => 'No playlists';

  @override
  String get playlistCreateNew => 'Create a playlist';

  @override
  String playlistSongCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count songs',
      one: '1 song',
      zero: '0 songs',
    );
    return '$_temp0';
  }

  @override
  String get playlistEditBtn => 'Edit';

  @override
  String get songListOther => 'Other';

  @override
  String get songListNoteSong => 'Write a song';

  @override
  String get songListBlindTest => 'Blind Test';

  @override
  String get songListSettings => 'Settings';

  @override
  String get updateChangelog => 'What you\'ve missed:';

  @override
  String get exportFilterPlaylist => 'Filter by playlist';

  @override
  String get exportFilterPlaylistDesc => 'Include only songs from a playlist.';

  @override
  String get exportFilterPlaylistLoadError => 'Error loading playlists';

  @override
  String get exportFilterPlaylistNone => 'No playlists available.';

  @override
  String get exportFilterPlaylistSelect => 'Select a playlist';

  @override
  String get exportFilterPlaylistUnnamed => 'Unnamed';

  @override
  String get exportFilterPlayCount => 'Filter by play count';

  @override
  String get exportFilterPlayCountLabel => 'Plays';

  @override
  String get exportFilterLastPlayed => 'Filter by last played date';

  @override
  String get exportFilterSince => 'Since';

  @override
  String get exportFilterBefore => 'Before';

  @override
  String get exportFilterChooseDate => 'Choose a date';

  @override
  String get exportFilterTags => 'Filter by tags';

  @override
  String get exportFilterTagsSoon => 'Coming soon!';

  @override
  String get exportOptDisplayContent => 'Content to display';

  @override
  String get exportOptSongs => 'Songs';

  @override
  String get exportOptAuthors => 'Authors';

  @override
  String get exportOptBoth => 'Both';

  @override
  String get exportOptShowSongCount => 'Show song count';

  @override
  String get exportOptShowSongCountDesc =>
      'Adds the number of songs for each artist.';

  @override
  String get exportOptIncludePlayStats => 'Include play statistics';

  @override
  String get exportOptIncludePlayStatsDescArtist =>
      'Adds the total play count for each artist.';

  @override
  String get exportOptArtistSelection => 'Artist selection';

  @override
  String get exportOptAllArtists => 'All artists';

  @override
  String get exportOptFilteredArtists => 'Only those meeting certain criteria';

  @override
  String get exportOptSortOrder => 'Sort order';

  @override
  String get exportOptSortAlpha => 'Alphabetical';

  @override
  String get exportOptSortLastPlayed => 'Last played';

  @override
  String get exportOptSortAppearance => 'Appearance order';

  @override
  String get exportOptIncludeStats => 'Include statistics';

  @override
  String get exportOptIncludeStatsDesc =>
      'Adds play count and last played date.';

  @override
  String get exportOptSongSelection => 'Song selection';

  @override
  String get exportOptAllSongs => 'All songs';

  @override
  String get exportOptFilteredSongs => 'Only those meeting certain criteria';

  @override
  String get exportOptSortChrono => 'Chronological (recent addition)';

  @override
  String get exportOptExportFormat => 'Export format';

  @override
  String get legalAppBarTitle => 'License & Philosophy';

  @override
  String get legalPartLicenseHeader => 'Open-source License';

  @override
  String get legalSection1Title => '1. License and Source Code';

  @override
  String get legalSection1P1 =>
      'The Chords application is free software distributed under the GNU Affero General Public License v3.0 (AGPL-3.0). The source code is publicly available on the official GitHub repository:';

  @override
  String get legalSection1Link => 'https://github.com/phi-k/chords';

  @override
  String get legalSection1P2 =>
      'Under the AGPL-3.0 license, anyone is free to:';

  @override
  String get legalSection1Bullet1 => 'View, copy and fork the source code.';

  @override
  String get legalSection1Bullet2 =>
      'Modify and redistribute the application, provided the same AGPL-3.0 license is retained.';

  @override
  String get legalSection1Bullet3 =>
      'Use the application for any purpose, including commercial use.';

  @override
  String get legalSection1P3 =>
      'Any modified or derived version must be distributed under the same AGPL-3.0 license, include the full license text, and make the source code available. The full license text can be found in the LICENSE file of the repository.';

  @override
  String get legalSection2Title => '2. Attribution';

  @override
  String get legalSection2P1 =>
      'In accordance with the AGPL-3.0 license, copyright and attribution notices must be retained in any copy or derived version of the software. The original application was created by phi-k.';

  @override
  String get legalSection2P2 =>
      'Contributors are free to add their name to indicate their contributions.';

  @override
  String get legalSection3Title => '3. Third-Party Services';

  @override
  String get legalSection3P1 =>
      'The website \'chords.ovh\' is an entity independent from the open-source application. It provides optional services (setlist sharing) and its source code is not covered by this license.';

  @override
  String get legalSection3P2 =>
      'Official application updates are published via the GitHub repository. Versions distributed from other sources are not under the responsibility of the original author.';

  @override
  String get legalSection4Title => '4. Contact';

  @override
  String get legalSection4P1 =>
      'To report a bug, suggest an improvement or for any other inquiry, you can contact the creator:';

  @override
  String get legalPartPhilosophyHeader => 'Project Philosophy';

  @override
  String get legalPhilosophyIntro =>
      'The following commitments are not legal obligations, but they represent the founding values of the Chords project. They are detailed in the PHILOSOPHY.md file of the repository.';

  @override
  String get legalPhiloQuote =>
      'Chords is a free music tool, available to everyone, and we hope it will remain so forever.';

  @override
  String get legalPhiloP1 =>
      'The author commits to ensuring that the official version of Chords:';

  @override
  String get legalPhiloBullet1 => 'Remains free and ad-free.';

  @override
  String get legalPhiloBullet2 => 'Does not collect any personal data.';

  @override
  String get legalPhiloBullet3 =>
      'Remains a tool for musicians, without commercial compromise.';

  @override
  String get legalPhiloP2 =>
      'We encourage forks and derived versions to share these values, but the AGPL-3.0 license does not impose any restriction on commercial use or interface modification.';

  @override
  String get legalDonationTitle => 'Contribution & Support';

  @override
  String get legalDonationContent =>
      'Chords is and will remain free and ad-free. Development is maintained by the author in their spare time. Donations are possible to support the project but are absolutely optional.';

  @override
  String get legalEmailCopied => 'Email address copied!';
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @welcomePass.
  ///
  /// In en, this message translates to:
  /// **'SKIP'**
  String get welcomePass;

  /// No description provided for @welcomeStart.
  ///
  /// In en, this message translates to:
  /// **'START'**
  String get welcomeStart;

  /// No description provided for @welcomeNext.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get welcomeNext;

  /// No description provided for @welcomeSlide1Title.
  ///
  /// In en, this message translates to:
  /// **'The Essentials,\nRefined.'**
  String get welcomeSlide1Title;

  /// No description provided for @welcomeSlide1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Your favorite songs. Your chords.\nA clean interface, designed for musicians.'**
  String get welcomeSlide1Subtitle;

  /// No description provided for @welcomeSlide2Title.
  ///
  /// In en, this message translates to:
  /// **'Your Data,\nYour Rules.'**
  String get welcomeSlide2Title;

  /// No description provided for @welcomeSlide2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect any external data source via REST API.\nChords is a neutral player for your personal databases.'**
  String get welcomeSlide2Subtitle;

  /// No description provided for @welcomeSlide3Title.
  ///
  /// In en, this message translates to:
  /// **'Smart\nTools.'**
  String get welcomeSlide3Title;

  /// No description provided for @welcomeSlide3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Transpose in one click, simplify\ncomplex chords. Adapt the song to you.'**
  String get welcomeSlide3Subtitle;

  /// No description provided for @welcomeSlide4Title.
  ///
  /// In en, this message translates to:
  /// **'Master\nyour Art.'**
  String get welcomeSlide4Title;

  /// No description provided for @welcomeSlide4Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Play statistics, history, playlists.\nTrack your musical progress day after day.'**
  String get welcomeSlide4Subtitle;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get commonSearch;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String commonError(String error);

  /// No description provided for @commonUnknownArtist.
  ///
  /// In en, this message translates to:
  /// **'Unknown artist'**
  String get commonUnknownArtist;

  /// No description provided for @commonUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get commonUntitled;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get commonRename;

  /// No description provided for @commonCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get commonCreate;

  /// No description provided for @commonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get commonOther;

  /// No description provided for @homeArtists.
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get homeArtists;

  /// No description provided for @homePlaylists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get homePlaylists;

  /// No description provided for @homeRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get homeRecent;

  /// No description provided for @homeTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get homeTags;

  /// No description provided for @homeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your library is empty'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'To get started, you can connect a data source to search for tabs, or write your first song manually.'**
  String get homeEmptySubtitle;

  /// No description provided for @homeEmptyBtnSource.
  ///
  /// In en, this message translates to:
  /// **'Configure a source'**
  String get homeEmptyBtnSource;

  /// No description provided for @homeEmptyBtnSourceDone.
  ///
  /// In en, this message translates to:
  /// **'Source configured'**
  String get homeEmptyBtnSourceDone;

  /// No description provided for @homeEmptySourceDoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your source is ready! Try the search to find your first songs.'**
  String get homeEmptySourceDoneSubtitle;

  /// No description provided for @homeEmptyBtnWrite.
  ///
  /// In en, this message translates to:
  /// **'Write a song'**
  String get homeEmptyBtnWrite;

  /// No description provided for @homeNoSongs.
  ///
  /// In en, this message translates to:
  /// **'No songs saved yet.'**
  String get homeNoSongs;

  /// No description provided for @homeSongCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 songs} =1{1 song} other{{count} songs}}'**
  String homeSongCount(int count);

  /// No description provided for @homeUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Update successful!'**
  String get homeUpdateSuccess;

  /// No description provided for @homeUpdateSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Chords has been updated to version {version}!'**
  String homeUpdateSuccessMessage(String version);

  /// No description provided for @homeWhatsNew.
  ///
  /// In en, this message translates to:
  /// **'What\'s new:'**
  String get homeWhatsNew;

  /// No description provided for @homeGreat.
  ///
  /// In en, this message translates to:
  /// **'Great!'**
  String get homeGreat;

  /// No description provided for @homeSongsOf.
  ///
  /// In en, this message translates to:
  /// **'Songs by {artist}'**
  String homeSongsOf(String artist);

  /// No description provided for @homePlaylistLabel.
  ///
  /// In en, this message translates to:
  /// **'Playlist: {name}'**
  String homePlaylistLabel(String name);

  /// No description provided for @homePieceCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 songs} =1{1 song} other{{count} songs}}'**
  String homePieceCount(int count);

  /// No description provided for @songDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get songDifficulty;

  /// No description provided for @songCapo.
  ///
  /// In en, this message translates to:
  /// **'Capo'**
  String get songCapo;

  /// No description provided for @songTuning.
  ///
  /// In en, this message translates to:
  /// **'Tuning'**
  String get songTuning;

  /// No description provided for @songTranspose.
  ///
  /// In en, this message translates to:
  /// **'Transpose'**
  String get songTranspose;

  /// No description provided for @songViewStats.
  ///
  /// In en, this message translates to:
  /// **'View statistics'**
  String get songViewStats;

  /// No description provided for @songOptionsMetadata.
  ///
  /// In en, this message translates to:
  /// **'Edit metadata'**
  String get songOptionsMetadata;

  /// No description provided for @songOptionsLyrics.
  ///
  /// In en, this message translates to:
  /// **'Edit lyrics & chords'**
  String get songOptionsLyrics;

  /// No description provided for @songOptionsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete song'**
  String get songOptionsDelete;

  /// No description provided for @songDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this song?'**
  String get songDeleteConfirmTitle;

  /// No description provided for @songDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\" by {artist}? This action is irreversible.'**
  String songDeleteConfirmMessage(String title, String artist);

  /// No description provided for @songNoCheat.
  ///
  /// In en, this message translates to:
  /// **'No cheating here! ;)'**
  String get songNoCheat;

  /// No description provided for @songNoCheatDismiss.
  ///
  /// In en, this message translates to:
  /// **'Boo'**
  String get songNoCheatDismiss;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  /// No description provided for @statsSavedDate.
  ///
  /// In en, this message translates to:
  /// **'Saved date'**
  String get statsSavedDate;

  /// No description provided for @statsPlayCount.
  ///
  /// In en, this message translates to:
  /// **'Times played'**
  String get statsPlayCount;

  /// No description provided for @statsLastPlayed.
  ///
  /// In en, this message translates to:
  /// **'Last played'**
  String get statsLastPlayed;

  /// No description provided for @statsHistory.
  ///
  /// In en, this message translates to:
  /// **'Play history'**
  String get statsHistory;

  /// No description provided for @statsNoHistory.
  ///
  /// In en, this message translates to:
  /// **'No history available'**
  String get statsNoHistory;

  /// No description provided for @statsTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get statsTags;

  /// No description provided for @statsNoTags.
  ///
  /// In en, this message translates to:
  /// **'No tags'**
  String get statsNoTags;

  /// No description provided for @statsShowList.
  ///
  /// In en, this message translates to:
  /// **'Show as list'**
  String get statsShowList;

  /// No description provided for @statsShowGraph.
  ///
  /// In en, this message translates to:
  /// **'Show as graph'**
  String get statsShowGraph;

  /// No description provided for @statsUnknownTitle.
  ///
  /// In en, this message translates to:
  /// **'Unknown title'**
  String get statsUnknownTitle;

  /// No description provided for @toolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get toolsTitle;

  /// No description provided for @toolsUtilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get toolsUtilities;

  /// No description provided for @toolsTuner.
  ///
  /// In en, this message translates to:
  /// **'Tuner'**
  String get toolsTuner;

  /// No description provided for @toolsTunerDesc.
  ///
  /// In en, this message translates to:
  /// **'Tune your guitar via microphone'**
  String get toolsTunerDesc;

  /// No description provided for @toolsMetronome.
  ///
  /// In en, this message translates to:
  /// **'Metronome'**
  String get toolsMetronome;

  /// No description provided for @toolsMetronomeDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep the rhythm with precision'**
  String get toolsMetronomeDesc;

  /// No description provided for @toolsExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get toolsExport;

  /// No description provided for @toolsExportList.
  ///
  /// In en, this message translates to:
  /// **'Export list'**
  String get toolsExportList;

  /// No description provided for @toolsExportListDesc.
  ///
  /// In en, this message translates to:
  /// **'Generate a list (TXT/PDF) of your songs'**
  String get toolsExportListDesc;

  /// No description provided for @toolsExportTabs.
  ///
  /// In en, this message translates to:
  /// **'Export tabs'**
  String get toolsExportTabs;

  /// No description provided for @toolsExportTabsDesc.
  ///
  /// In en, this message translates to:
  /// **'Create a complete PDF Songbook'**
  String get toolsExportTabsDesc;

  /// No description provided for @toolsMisc.
  ///
  /// In en, this message translates to:
  /// **'Miscellaneous'**
  String get toolsMisc;

  /// No description provided for @toolsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version and updates'**
  String get toolsVersion;

  /// No description provided for @toolsVersionDesc.
  ///
  /// In en, this message translates to:
  /// **'See current version and history'**
  String get toolsVersionDesc;

  /// No description provided for @toolsWelcome.
  ///
  /// In en, this message translates to:
  /// **'Replay introduction'**
  String get toolsWelcome;

  /// No description provided for @toolsWelcomeDesc.
  ///
  /// In en, this message translates to:
  /// **'Show the welcome screen'**
  String get toolsWelcomeDesc;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search settings...'**
  String get settingsSearchHint;

  /// No description provided for @settingsNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get settingsNoResults;

  /// No description provided for @settingsToolsDesc.
  ///
  /// In en, this message translates to:
  /// **'Tuner, metronome, export...'**
  String get settingsToolsDesc;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsApiKeys.
  ///
  /// In en, this message translates to:
  /// **'API Keys'**
  String get settingsApiKeys;

  /// No description provided for @settingsGeniusDesc.
  ///
  /// In en, this message translates to:
  /// **'Used to fetch album covers'**
  String get settingsGeniusDesc;

  /// No description provided for @settingsGeminiDesc.
  ///
  /// In en, this message translates to:
  /// **'Used for smart search suggestions'**
  String get settingsGeminiDesc;

  /// No description provided for @settingsBackups.
  ///
  /// In en, this message translates to:
  /// **'Backups'**
  String get settingsBackups;

  /// No description provided for @settingsImportLib.
  ///
  /// In en, this message translates to:
  /// **'Import library'**
  String get settingsImportLib;

  /// No description provided for @settingsImportLibDesc.
  ///
  /// In en, this message translates to:
  /// **'Import a JSON file containing saved songs'**
  String get settingsImportLibDesc;

  /// No description provided for @settingsExportLib.
  ///
  /// In en, this message translates to:
  /// **'Export library'**
  String get settingsExportLib;

  /// No description provided for @settingsExportLibDesc.
  ///
  /// In en, this message translates to:
  /// **'Save your songs to a JSON file'**
  String get settingsExportLibDesc;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsDevBy.
  ///
  /// In en, this message translates to:
  /// **'Developed with passion by'**
  String get settingsDevBy;

  /// No description provided for @settingsDataSources.
  ///
  /// In en, this message translates to:
  /// **'Data sources'**
  String get settingsDataSources;

  /// No description provided for @settingsDataSourcesDesc.
  ///
  /// In en, this message translates to:
  /// **'Connect a tab database'**
  String get settingsDataSourcesDesc;

  /// No description provided for @settingsPasteApiKey.
  ///
  /// In en, this message translates to:
  /// **'Paste your API key here'**
  String get settingsPasteApiKey;

  /// No description provided for @settingsConfirmImport.
  ///
  /// In en, this message translates to:
  /// **'Confirm import'**
  String get settingsConfirmImport;

  /// No description provided for @settingsReplaceLibrary.
  ///
  /// In en, this message translates to:
  /// **'This will replace the existing library. Continue?'**
  String get settingsReplaceLibrary;

  /// No description provided for @settingsImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Import successful. Returning to home...'**
  String get settingsImportSuccess;

  /// No description provided for @settingsInvalidFile.
  ///
  /// In en, this message translates to:
  /// **'Invalid file'**
  String get settingsInvalidFile;

  /// No description provided for @settingsImportError.
  ///
  /// In en, this message translates to:
  /// **'Import error: {error}'**
  String settingsImportError(String error);

  /// No description provided for @settingsExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Export successful to {path}'**
  String settingsExportSuccess(String path);

  /// No description provided for @settingsExportCancelled.
  ///
  /// In en, this message translates to:
  /// **'Export cancelled'**
  String get settingsExportCancelled;

  /// No description provided for @settingsExportError.
  ///
  /// In en, this message translates to:
  /// **'Export error: {error}'**
  String settingsExportError(String error);

  /// No description provided for @settingsDevWith.
  ///
  /// In en, this message translates to:
  /// **'Developed with'**
  String get settingsDevWith;

  /// No description provided for @settingsDevWithDesc.
  ///
  /// In en, this message translates to:
  /// **'Flutter - Thanks to the Isar, Riverpod, fl_charts libraries and all the others!'**
  String get settingsDevWithDesc;

  /// No description provided for @settingsAppVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get settingsAppVersion;

  /// No description provided for @settingsLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal notices & License'**
  String get settingsLegal;

  /// No description provided for @settingsDevSubtitle.
  ///
  /// In en, this message translates to:
  /// **'phi-k - pianist and developer'**
  String get settingsDevSubtitle;

  /// No description provided for @dsTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Sources'**
  String get dsTitle;

  /// No description provided for @dsNoSource.
  ///
  /// In en, this message translates to:
  /// **'No source configured'**
  String get dsNoSource;

  /// No description provided for @dsNoSourceDesc.
  ///
  /// In en, this message translates to:
  /// **'Chords does not contain any music by default. Connect your own database or a community API to search for tabs.'**
  String get dsNoSourceDesc;

  /// No description provided for @dsAddSource.
  ///
  /// In en, this message translates to:
  /// **'Add a source'**
  String get dsAddSource;

  /// No description provided for @dsScanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan a QR code'**
  String get dsScanQr;

  /// No description provided for @dsImportFile.
  ///
  /// In en, this message translates to:
  /// **'Import a file'**
  String get dsImportFile;

  /// No description provided for @dsManualConfig.
  ///
  /// In en, this message translates to:
  /// **'Configure manually'**
  String get dsManualConfig;

  /// No description provided for @dsHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get dsHelp;

  /// No description provided for @dsHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Sources'**
  String get dsHelpTitle;

  /// No description provided for @dsHelpContent.
  ///
  /// In en, this message translates to:
  /// **'Chords does not contain any music. You must connect an external database (REST API) to search for tabs and chords.'**
  String get dsHelpContent;

  /// No description provided for @dsHelpBullets.
  ///
  /// In en, this message translates to:
  /// **'• Press + to add a source\n• Use the switch to enable/disable\n• Swipe left to delete\n• Only one source can be active at a time\n• Share your sources via file or QR code'**
  String get dsHelpBullets;

  /// No description provided for @dsUnderstood.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get dsUnderstood;

  /// No description provided for @dsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this source?'**
  String get dsDeleteConfirm;

  /// No description provided for @dsDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'The source \"{name}\" will be permanently deleted.'**
  String dsDeleteMessage(String name);

  /// No description provided for @dsExportError.
  ///
  /// In en, this message translates to:
  /// **'Export error: {error}'**
  String dsExportError(String error);

  /// No description provided for @dsImportConfirm.
  ///
  /// In en, this message translates to:
  /// **'Import this source?'**
  String get dsImportConfirm;

  /// No description provided for @dsImportName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get dsImportName;

  /// No description provided for @dsImportUrl.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get dsImportUrl;

  /// No description provided for @dsImportHeaders.
  ///
  /// In en, this message translates to:
  /// **'Headers'**
  String get dsImportHeaders;

  /// No description provided for @dsImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Source \"{name}\" imported successfully!'**
  String dsImportSuccess(String name);

  /// No description provided for @dsInvalidFile.
  ///
  /// In en, this message translates to:
  /// **'Invalid file: {error}'**
  String dsInvalidFile(String error);

  /// No description provided for @dsImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get dsImport;

  /// No description provided for @dsShareSource.
  ///
  /// In en, this message translates to:
  /// **'Share this source'**
  String get dsShareSource;

  /// No description provided for @dsShareFile.
  ///
  /// In en, this message translates to:
  /// **'Export as file'**
  String get dsShareFile;

  /// No description provided for @dsShareFileDesc.
  ///
  /// In en, this message translates to:
  /// **'Send a shareable JSON file'**
  String get dsShareFileDesc;

  /// No description provided for @dsShareQr.
  ///
  /// In en, this message translates to:
  /// **'QR Code'**
  String get dsShareQr;

  /// No description provided for @dsShareQrDesc.
  ///
  /// In en, this message translates to:
  /// **'Display a scannable QR code'**
  String get dsShareQrDesc;

  /// No description provided for @dsShareTitle.
  ///
  /// In en, this message translates to:
  /// **'Share \"{name}\"'**
  String dsShareTitle(String name);

  /// No description provided for @dsQrScanInfo.
  ///
  /// In en, this message translates to:
  /// **'Scan this QR code from another device to import this source.'**
  String get dsQrScanInfo;

  /// No description provided for @dsQrHeadersIncluded.
  ///
  /// In en, this message translates to:
  /// **'Headers included in the QR code'**
  String get dsQrHeadersIncluded;

  /// No description provided for @dsAddSourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a source'**
  String get dsAddSourceTitle;

  /// No description provided for @dsScanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import from another device\'s camera'**
  String get dsScanSubtitle;

  /// No description provided for @dsImportFileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Load a JSON configuration file'**
  String get dsImportFileSubtitle;

  /// No description provided for @dsManualSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter connection information manually'**
  String get dsManualSubtitle;

  /// No description provided for @dsSourceCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 source configured} other{{count} sources configured}}'**
  String dsSourceCount(int count);

  /// No description provided for @dsConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get dsConnected;

  /// No description provided for @dsShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get dsShare;

  /// No description provided for @editSourceUnsavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes'**
  String get editSourceUnsavedTitle;

  /// No description provided for @editSourceUnsavedMessage.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. What would you like to do?'**
  String get editSourceUnsavedMessage;

  /// No description provided for @editSourceContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue editing'**
  String get editSourceContinue;

  /// No description provided for @editSourceDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get editSourceDiscard;

  /// No description provided for @editSourceFillRequired.
  ///
  /// In en, this message translates to:
  /// **'Fill in at least the base URL and the search path.'**
  String get editSourceFillRequired;

  /// No description provided for @searchResultsFor.
  ///
  /// In en, this message translates to:
  /// **'Results for \"{term}\"'**
  String searchResultsFor(String term);

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results found for this search.'**
  String get searchNoResults;

  /// No description provided for @searchLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get searchLoadMore;

  /// No description provided for @searchBarHint.
  ///
  /// In en, this message translates to:
  /// **'Find anything.'**
  String get searchBarHint;

  /// No description provided for @creationTitle.
  ///
  /// In en, this message translates to:
  /// **'New song'**
  String get creationTitle;

  /// No description provided for @creationTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required.'**
  String get creationTitleRequired;

  /// No description provided for @creationArtistRequired.
  ///
  /// In en, this message translates to:
  /// **'Author is required.'**
  String get creationArtistRequired;

  /// No description provided for @creationSongAdded.
  ///
  /// In en, this message translates to:
  /// **'Song added to library!'**
  String get creationSongAdded;

  /// No description provided for @creationSaveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving: {error}'**
  String creationSaveError(String error);

  /// No description provided for @creationClipboardEmpty.
  ///
  /// In en, this message translates to:
  /// **'Clipboard is empty.'**
  String get creationClipboardEmpty;

  /// No description provided for @creationTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Song title'**
  String get creationTitleHint;

  /// No description provided for @creationArtistHint.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get creationArtistHint;

  /// No description provided for @creationMetadata.
  ///
  /// In en, this message translates to:
  /// **'Additional metadata'**
  String get creationMetadata;

  /// No description provided for @creationCapo.
  ///
  /// In en, this message translates to:
  /// **'Capo'**
  String get creationCapo;

  /// No description provided for @creationTonality.
  ///
  /// In en, this message translates to:
  /// **'Tonality'**
  String get creationTonality;

  /// No description provided for @creationDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get creationDifficulty;

  /// No description provided for @creationTuning.
  ///
  /// In en, this message translates to:
  /// **'Tuning'**
  String get creationTuning;

  /// No description provided for @creationContentHint.
  ///
  /// In en, this message translates to:
  /// **'[Intro]\n\nAm           F\nWrite your chords here...\nC            G\nAbove the lyrics.'**
  String get creationContentHint;

  /// No description provided for @creationPaste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get creationPaste;

  /// No description provided for @creationUndoPaste.
  ///
  /// In en, this message translates to:
  /// **'Undo paste'**
  String get creationUndoPaste;

  /// No description provided for @editLyricsTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit \"{title}\"'**
  String editLyricsTitle(String title);

  /// No description provided for @editLyricsReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get editLyricsReset;

  /// No description provided for @editLyricsResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get editLyricsResetTitle;

  /// No description provided for @editLyricsResetMessage.
  ///
  /// In en, this message translates to:
  /// **'This action will restore the original version of lyrics and chords, and delete all your previous changes. Are you sure?'**
  String get editLyricsResetMessage;

  /// No description provided for @editLyricsHint.
  ///
  /// In en, this message translates to:
  /// **'Enter lyrics and chords here...'**
  String get editLyricsHint;

  /// No description provided for @editLyricsResetTooltip.
  ///
  /// In en, this message translates to:
  /// **'Reset to original version'**
  String get editLyricsResetTooltip;

  /// No description provided for @blindTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Blind Test'**
  String get blindTestTitle;

  /// No description provided for @blindTestHideTitles.
  ///
  /// In en, this message translates to:
  /// **'Hide titles'**
  String get blindTestHideTitles;

  /// No description provided for @blindTestShowTitles.
  ///
  /// In en, this message translates to:
  /// **'Show titles'**
  String get blindTestShowTitles;

  /// No description provided for @blindTestShuffle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle again'**
  String get blindTestShuffle;

  /// No description provided for @blindTestCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 song shuffled} other{{count} songs shuffled}}'**
  String blindTestCount(int count);

  /// No description provided for @blindTestNoSongs.
  ///
  /// In en, this message translates to:
  /// **'No songs available'**
  String get blindTestNoSongs;

  /// No description provided for @blindTestNoSongsHint.
  ///
  /// In en, this message translates to:
  /// **'Save some songs to play the blind test!'**
  String get blindTestNoSongsHint;

  /// No description provided for @blindTestUnknownTitle.
  ///
  /// In en, this message translates to:
  /// **'Unknown title'**
  String get blindTestUnknownTitle;

  /// No description provided for @blindTestUnknownArtist.
  ///
  /// In en, this message translates to:
  /// **'Unknown artist'**
  String get blindTestUnknownArtist;

  /// No description provided for @blindTestSongNumber.
  ///
  /// In en, this message translates to:
  /// **'Song {number}'**
  String blindTestSongNumber(int number);

  /// No description provided for @blindTestTitleHidden.
  ///
  /// In en, this message translates to:
  /// **'Title view disabled'**
  String get blindTestTitleHidden;

  /// No description provided for @blindTestViewSong.
  ///
  /// In en, this message translates to:
  /// **'View song'**
  String get blindTestViewSong;

  /// No description provided for @blindTestCancelTooltip.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get blindTestCancelTooltip;

  /// No description provided for @playlistNotFound.
  ///
  /// In en, this message translates to:
  /// **'Playlist not found.'**
  String get playlistNotFound;

  /// No description provided for @playlistNoSongs.
  ///
  /// In en, this message translates to:
  /// **'No songs in this playlist'**
  String get playlistNoSongs;

  /// No description provided for @playlistAddSongs.
  ///
  /// In en, this message translates to:
  /// **'Add songs'**
  String get playlistAddSongs;

  /// No description provided for @playlistSongLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading songs.'**
  String get playlistSongLoadError;

  /// No description provided for @playlistSaved.
  ///
  /// In en, this message translates to:
  /// **'Playlist saved'**
  String get playlistSaved;

  /// No description provided for @playlistSaveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving playlist: {error}'**
  String playlistSaveError(String error);

  /// No description provided for @playlistEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit {name}'**
  String playlistEditTitle(String name);

  /// No description provided for @playlistSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 song selected} other{{count} songs selected}}'**
  String playlistSelectedCount(int count);

  /// No description provided for @playlistNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Playlist'**
  String get playlistNewTitle;

  /// No description provided for @playlistNameHint.
  ///
  /// In en, this message translates to:
  /// **'Playlist name...'**
  String get playlistNameHint;

  /// No description provided for @playlistRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename Playlist'**
  String get playlistRenameTitle;

  /// No description provided for @playlistDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Playlist'**
  String get playlistDeleteTitle;

  /// No description provided for @playlistDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete the playlist \"{name}\"?'**
  String playlistDeleteMessage(String name);

  /// No description provided for @playlistCreateError.
  ///
  /// In en, this message translates to:
  /// **'Error creating the playlist'**
  String get playlistCreateError;

  /// No description provided for @playlistRenameError.
  ///
  /// In en, this message translates to:
  /// **'Error renaming the playlist'**
  String get playlistRenameError;

  /// No description provided for @filterSongsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 songs} =1{1 song} other{{count} songs}}'**
  String filterSongsCount(int count);

  /// No description provided for @filterArtistsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 artists} =1{1 artist} other{{count} artists}}'**
  String filterArtistsCount(int count);

  /// No description provided for @filterOldestArtists.
  ///
  /// In en, this message translates to:
  /// **'Least recent artists'**
  String get filterOldestArtists;

  /// No description provided for @filterNewestArtists.
  ///
  /// In en, this message translates to:
  /// **'Most recent artists'**
  String get filterNewestArtists;

  /// No description provided for @filterOldSongs.
  ///
  /// In en, this message translates to:
  /// **'Older songs'**
  String get filterOldSongs;

  /// No description provided for @filterRecentSongs.
  ///
  /// In en, this message translates to:
  /// **'Recent songs'**
  String get filterRecentSongs;

  /// No description provided for @filterNoPlayed.
  ///
  /// In en, this message translates to:
  /// **'No song has been played yet'**
  String get filterNoPlayed;

  /// No description provided for @filterChordCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 chord} other{{count} chords}}'**
  String filterChordCount(int count);

  /// No description provided for @filterTagsNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Tag filtering not implemented'**
  String get filterTagsNotImplemented;

  /// No description provided for @updatePermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Permission required'**
  String get updatePermissionTitle;

  /// No description provided for @updatePermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'To update Chords, you must allow the installation of apps from unknown sources in settings.'**
  String get updatePermissionMessage;

  /// No description provided for @updateOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get updateOpenSettings;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updateAvailable;

  /// No description provided for @updateVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String updateVersion(String version);

  /// No description provided for @updateDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get updateDownloading;

  /// No description provided for @updateDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed. Check your connection.'**
  String get updateDownloadFailed;

  /// No description provided for @updateMissed.
  ///
  /// In en, this message translates to:
  /// **'What you missed:'**
  String get updateMissed;

  /// No description provided for @updateLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get updateLater;

  /// No description provided for @updateInstall.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get updateInstall;

  /// No description provided for @versionTitle.
  ///
  /// In en, this message translates to:
  /// **'Version and updates'**
  String get versionTitle;

  /// No description provided for @versionAutoUpdateAndroid.
  ///
  /// In en, this message translates to:
  /// **'Automatic updates are only available on Android.'**
  String get versionAutoUpdateAndroid;

  /// No description provided for @versionUpToDate.
  ///
  /// In en, this message translates to:
  /// **'You are up to date!'**
  String get versionUpToDate;

  /// No description provided for @versionCheckError.
  ///
  /// In en, this message translates to:
  /// **'Error checking for updates.'**
  String get versionCheckError;

  /// No description provided for @versionChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get versionChecking;

  /// No description provided for @versionCheckUpdate.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get versionCheckUpdate;

  /// No description provided for @versionHistory.
  ///
  /// In en, this message translates to:
  /// **'Version history'**
  String get versionHistory;

  /// No description provided for @versionHistoryError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load history.'**
  String get versionHistoryError;

  /// No description provided for @tunerTitle.
  ///
  /// In en, this message translates to:
  /// **'Tuner'**
  String get tunerTitle;

  /// No description provided for @tunerPlayString.
  ///
  /// In en, this message translates to:
  /// **'Play a string'**
  String get tunerPlayString;

  /// No description provided for @tunerMicPermission.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission required for the tuner.'**
  String get tunerMicPermission;

  /// No description provided for @tunerMicOff.
  ///
  /// In en, this message translates to:
  /// **'Mic off'**
  String get tunerMicOff;

  /// No description provided for @tunerTuned.
  ///
  /// In en, this message translates to:
  /// **'Tuned'**
  String get tunerTuned;

  /// No description provided for @tunerTooLow.
  ///
  /// In en, this message translates to:
  /// **'Too low'**
  String get tunerTooLow;

  /// No description provided for @tunerTooHigh.
  ///
  /// In en, this message translates to:
  /// **'Too high'**
  String get tunerTooHigh;

  /// No description provided for @tunerListening.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get tunerListening;

  /// No description provided for @tunerMuteBtn.
  ///
  /// In en, this message translates to:
  /// **'Mute mic'**
  String get tunerMuteBtn;

  /// No description provided for @tunerActivateBtn.
  ///
  /// In en, this message translates to:
  /// **'Activate mic'**
  String get tunerActivateBtn;

  /// No description provided for @metronomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Metronome'**
  String get metronomeTitle;

  /// No description provided for @exportListTitle.
  ///
  /// In en, this message translates to:
  /// **'Export list'**
  String get exportListTitle;

  /// No description provided for @exportGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get exportGenerating;

  /// No description provided for @exportExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportExport;

  /// No description provided for @exportSongsLoading.
  ///
  /// In en, this message translates to:
  /// **'The song list is loading.'**
  String get exportSongsLoading;

  /// No description provided for @exportTabsTitle.
  ///
  /// In en, this message translates to:
  /// **'Generate a Songbook'**
  String get exportTabsTitle;

  /// No description provided for @exportTabsSetCount.
  ///
  /// In en, this message translates to:
  /// **'Set the number'**
  String get exportTabsSetCount;

  /// No description provided for @exportTabsCountHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a number between 1 and {max}:'**
  String exportTabsCountHint(int max);

  /// No description provided for @exportTabsContentTitle.
  ///
  /// In en, this message translates to:
  /// **'1. Songbook content'**
  String get exportTabsContentTitle;

  /// No description provided for @exportTabsAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get exportTabsAll;

  /// No description provided for @exportTabsPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get exportTabsPlaylist;

  /// No description provided for @exportTabsArtist.
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get exportTabsArtist;

  /// No description provided for @exportTabsRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get exportTabsRecent;

  /// No description provided for @exportTabsManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get exportTabsManual;

  /// No description provided for @exportTabsCustomTitle.
  ///
  /// In en, this message translates to:
  /// **'2. Customization'**
  String get exportTabsCustomTitle;

  /// No description provided for @exportTabsSongbookTitle.
  ///
  /// In en, this message translates to:
  /// **'Songbook title'**
  String get exportTabsSongbookTitle;

  /// No description provided for @exportTabsCoverPage.
  ///
  /// In en, this message translates to:
  /// **'Include cover page'**
  String get exportTabsCoverPage;

  /// No description provided for @exportTabsToc.
  ///
  /// In en, this message translates to:
  /// **'Include table of contents'**
  String get exportTabsToc;

  /// No description provided for @exportTabsGeneratePdf.
  ///
  /// In en, this message translates to:
  /// **'Generate PDF'**
  String get exportTabsGeneratePdf;

  /// No description provided for @exportTabsGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get exportTabsGenerating;

  /// No description provided for @exportTabsFooter.
  ///
  /// In en, this message translates to:
  /// **'The generated document will contain all selected tabs laid out for printing.'**
  String get exportTabsFooter;

  /// No description provided for @exportTabsNoSongs.
  ///
  /// In en, this message translates to:
  /// **'No songs in your library.'**
  String get exportTabsNoSongs;

  /// No description provided for @exportTabsNoPlaylist.
  ///
  /// In en, this message translates to:
  /// **'No playlist.'**
  String get exportTabsNoPlaylist;

  /// No description provided for @exportTabsChoosePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Choose a playlist'**
  String get exportTabsChoosePlaylist;

  /// No description provided for @exportTabsChooseArtist.
  ///
  /// In en, this message translates to:
  /// **'Choose an artist'**
  String get exportTabsChooseArtist;

  /// No description provided for @exportTabsManualSelection.
  ///
  /// In en, this message translates to:
  /// **'Manual selection'**
  String get exportTabsManualSelection;

  /// No description provided for @exportTabsClickToChoose.
  ///
  /// In en, this message translates to:
  /// **'Click to choose'**
  String get exportTabsClickToChoose;

  /// No description provided for @exportTabsSongsChosen.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 song chosen} other{{count} songs chosen}}'**
  String exportTabsSongsChosen(int count);

  /// No description provided for @exportTabsSongCount.
  ///
  /// In en, this message translates to:
  /// **'Number of songs'**
  String get exportTabsSongCount;

  /// No description provided for @exportTabsRecentDesc.
  ///
  /// In en, this message translates to:
  /// **'The most recently played or added songs.'**
  String get exportTabsRecentDesc;

  /// No description provided for @exportTabsUnnamed.
  ///
  /// In en, this message translates to:
  /// **'Unnamed'**
  String get exportTabsUnnamed;

  /// No description provided for @multiSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Manual selection'**
  String get multiSelectTitle;

  /// No description provided for @multiSelectSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get multiSelectSearchHint;

  /// No description provided for @multiSelectCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String multiSelectCount(int count);

  /// No description provided for @multiSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get multiSelectAll;

  /// No description provided for @multiSelectNone.
  ///
  /// In en, this message translates to:
  /// **'Deselect all'**
  String get multiSelectNone;

  /// No description provided for @metadataEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit metadata'**
  String get metadataEditTitle;

  /// No description provided for @metadataTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get metadataTitle;

  /// No description provided for @metadataArtist.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get metadataArtist;

  /// No description provided for @metadataCoverUrl.
  ///
  /// In en, this message translates to:
  /// **'Cover URL'**
  String get metadataCoverUrl;

  /// No description provided for @metadataFetchGenius.
  ///
  /// In en, this message translates to:
  /// **'Fetch from Genius'**
  String get metadataFetchGenius;

  /// No description provided for @editOptionsMetadata.
  ///
  /// In en, this message translates to:
  /// **'Edit metadata'**
  String get editOptionsMetadata;

  /// No description provided for @editOptionsLyrics.
  ///
  /// In en, this message translates to:
  /// **'Edit lyrics and chords'**
  String get editOptionsLyrics;

  /// No description provided for @langChooseTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language\nChoisissez votre langue'**
  String get langChooseTitle;

  /// No description provided for @welcomeFinalGreeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome to '**
  String get welcomeFinalGreeting;

  /// No description provided for @welcomeFinalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your music catalog\n100% free and open-source.'**
  String get welcomeFinalSubtitle;

  /// No description provided for @filterArtists.
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get filterArtists;

  /// No description provided for @filterPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get filterPlaylists;

  /// No description provided for @filterRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get filterRecent;

  /// No description provided for @headerSongs.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 songs} =1{1 song} other{{count} songs}}'**
  String headerSongs(int count);

  /// No description provided for @headerArtistsOldest.
  ///
  /// In en, this message translates to:
  /// **'Least recent artists'**
  String get headerArtistsOldest;

  /// No description provided for @headerArtistsNewest.
  ///
  /// In en, this message translates to:
  /// **'Most recent artists'**
  String get headerArtistsNewest;

  /// No description provided for @headerArtists.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 artists} =1{1 artist} other{{count} artists}}'**
  String headerArtists(int count);

  /// No description provided for @headerOldSongs.
  ///
  /// In en, this message translates to:
  /// **'Old songs'**
  String get headerOldSongs;

  /// No description provided for @headerRecentSongs.
  ///
  /// In en, this message translates to:
  /// **'Recent songs'**
  String get headerRecentSongs;

  /// No description provided for @artistsUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get artistsUnknown;

  /// No description provided for @artistsOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get artistsOther;

  /// No description provided for @recentNoSongsPlayed.
  ///
  /// In en, this message translates to:
  /// **'No songs have been played yet'**
  String get recentNoSongsPlayed;

  /// No description provided for @tagsNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Tag filtering not implemented'**
  String get tagsNotImplemented;

  /// No description provided for @playlistCreateBtn.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get playlistCreateBtn;

  /// No description provided for @playlistRenameBtn.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get playlistRenameBtn;

  /// No description provided for @playlistDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the playlist \"{name}\"?'**
  String playlistDeleteConfirm(String name);

  /// No description provided for @playlistDeleteBtn.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get playlistDeleteBtn;

  /// No description provided for @playlistDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Error deleting the playlist'**
  String get playlistDeleteError;

  /// No description provided for @playlistNone.
  ///
  /// In en, this message translates to:
  /// **'No playlists'**
  String get playlistNone;

  /// No description provided for @playlistCreateNew.
  ///
  /// In en, this message translates to:
  /// **'Create a playlist'**
  String get playlistCreateNew;

  /// No description provided for @playlistSongCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 songs} =1{1 song} other{{count} songs}}'**
  String playlistSongCount(int count);

  /// No description provided for @playlistEditBtn.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get playlistEditBtn;

  /// No description provided for @songListOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get songListOther;

  /// No description provided for @songListNoteSong.
  ///
  /// In en, this message translates to:
  /// **'Write a song'**
  String get songListNoteSong;

  /// No description provided for @songListBlindTest.
  ///
  /// In en, this message translates to:
  /// **'Blind Test'**
  String get songListBlindTest;

  /// No description provided for @songListSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get songListSettings;

  /// No description provided for @updateChangelog.
  ///
  /// In en, this message translates to:
  /// **'What you\'ve missed:'**
  String get updateChangelog;

  /// No description provided for @exportFilterPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Filter by playlist'**
  String get exportFilterPlaylist;

  /// No description provided for @exportFilterPlaylistDesc.
  ///
  /// In en, this message translates to:
  /// **'Include only songs from a playlist.'**
  String get exportFilterPlaylistDesc;

  /// No description provided for @exportFilterPlaylistLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading playlists'**
  String get exportFilterPlaylistLoadError;

  /// No description provided for @exportFilterPlaylistNone.
  ///
  /// In en, this message translates to:
  /// **'No playlists available.'**
  String get exportFilterPlaylistNone;

  /// No description provided for @exportFilterPlaylistSelect.
  ///
  /// In en, this message translates to:
  /// **'Select a playlist'**
  String get exportFilterPlaylistSelect;

  /// No description provided for @exportFilterPlaylistUnnamed.
  ///
  /// In en, this message translates to:
  /// **'Unnamed'**
  String get exportFilterPlaylistUnnamed;

  /// No description provided for @exportFilterPlayCount.
  ///
  /// In en, this message translates to:
  /// **'Filter by play count'**
  String get exportFilterPlayCount;

  /// No description provided for @exportFilterPlayCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Plays'**
  String get exportFilterPlayCountLabel;

  /// No description provided for @exportFilterLastPlayed.
  ///
  /// In en, this message translates to:
  /// **'Filter by last played date'**
  String get exportFilterLastPlayed;

  /// No description provided for @exportFilterSince.
  ///
  /// In en, this message translates to:
  /// **'Since'**
  String get exportFilterSince;

  /// No description provided for @exportFilterBefore.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get exportFilterBefore;

  /// No description provided for @exportFilterChooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose a date'**
  String get exportFilterChooseDate;

  /// No description provided for @exportFilterTags.
  ///
  /// In en, this message translates to:
  /// **'Filter by tags'**
  String get exportFilterTags;

  /// No description provided for @exportFilterTagsSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon!'**
  String get exportFilterTagsSoon;

  /// No description provided for @exportOptDisplayContent.
  ///
  /// In en, this message translates to:
  /// **'Content to display'**
  String get exportOptDisplayContent;

  /// No description provided for @exportOptSongs.
  ///
  /// In en, this message translates to:
  /// **'Songs'**
  String get exportOptSongs;

  /// No description provided for @exportOptAuthors.
  ///
  /// In en, this message translates to:
  /// **'Authors'**
  String get exportOptAuthors;

  /// No description provided for @exportOptBoth.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get exportOptBoth;

  /// No description provided for @exportOptShowSongCount.
  ///
  /// In en, this message translates to:
  /// **'Show song count'**
  String get exportOptShowSongCount;

  /// No description provided for @exportOptShowSongCountDesc.
  ///
  /// In en, this message translates to:
  /// **'Adds the number of songs for each artist.'**
  String get exportOptShowSongCountDesc;

  /// No description provided for @exportOptIncludePlayStats.
  ///
  /// In en, this message translates to:
  /// **'Include play statistics'**
  String get exportOptIncludePlayStats;

  /// No description provided for @exportOptIncludePlayStatsDescArtist.
  ///
  /// In en, this message translates to:
  /// **'Adds the total play count for each artist.'**
  String get exportOptIncludePlayStatsDescArtist;

  /// No description provided for @exportOptArtistSelection.
  ///
  /// In en, this message translates to:
  /// **'Artist selection'**
  String get exportOptArtistSelection;

  /// No description provided for @exportOptAllArtists.
  ///
  /// In en, this message translates to:
  /// **'All artists'**
  String get exportOptAllArtists;

  /// No description provided for @exportOptFilteredArtists.
  ///
  /// In en, this message translates to:
  /// **'Only those meeting certain criteria'**
  String get exportOptFilteredArtists;

  /// No description provided for @exportOptSortOrder.
  ///
  /// In en, this message translates to:
  /// **'Sort order'**
  String get exportOptSortOrder;

  /// No description provided for @exportOptSortAlpha.
  ///
  /// In en, this message translates to:
  /// **'Alphabetical'**
  String get exportOptSortAlpha;

  /// No description provided for @exportOptSortLastPlayed.
  ///
  /// In en, this message translates to:
  /// **'Last played'**
  String get exportOptSortLastPlayed;

  /// No description provided for @exportOptSortAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance order'**
  String get exportOptSortAppearance;

  /// No description provided for @exportOptIncludeStats.
  ///
  /// In en, this message translates to:
  /// **'Include statistics'**
  String get exportOptIncludeStats;

  /// No description provided for @exportOptIncludeStatsDesc.
  ///
  /// In en, this message translates to:
  /// **'Adds play count and last played date.'**
  String get exportOptIncludeStatsDesc;

  /// No description provided for @exportOptSongSelection.
  ///
  /// In en, this message translates to:
  /// **'Song selection'**
  String get exportOptSongSelection;

  /// No description provided for @exportOptAllSongs.
  ///
  /// In en, this message translates to:
  /// **'All songs'**
  String get exportOptAllSongs;

  /// No description provided for @exportOptFilteredSongs.
  ///
  /// In en, this message translates to:
  /// **'Only those meeting certain criteria'**
  String get exportOptFilteredSongs;

  /// No description provided for @exportOptSortChrono.
  ///
  /// In en, this message translates to:
  /// **'Chronological (recent addition)'**
  String get exportOptSortChrono;

  /// No description provided for @exportOptExportFormat.
  ///
  /// In en, this message translates to:
  /// **'Export format'**
  String get exportOptExportFormat;

  /// No description provided for @legalAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'License & Philosophy'**
  String get legalAppBarTitle;

  /// No description provided for @legalPartLicenseHeader.
  ///
  /// In en, this message translates to:
  /// **'Open-source License'**
  String get legalPartLicenseHeader;

  /// No description provided for @legalSection1Title.
  ///
  /// In en, this message translates to:
  /// **'1. License and Source Code'**
  String get legalSection1Title;

  /// No description provided for @legalSection1P1.
  ///
  /// In en, this message translates to:
  /// **'The Chords application is free software distributed under the GNU Affero General Public License v3.0 (AGPL-3.0). The source code is publicly available on the official GitHub repository:'**
  String get legalSection1P1;

  /// No description provided for @legalSection1Link.
  ///
  /// In en, this message translates to:
  /// **'https://github.com/phi-k/chords'**
  String get legalSection1Link;

  /// No description provided for @legalSection1P2.
  ///
  /// In en, this message translates to:
  /// **'Under the AGPL-3.0 license, anyone is free to:'**
  String get legalSection1P2;

  /// No description provided for @legalSection1Bullet1.
  ///
  /// In en, this message translates to:
  /// **'View, copy and fork the source code.'**
  String get legalSection1Bullet1;

  /// No description provided for @legalSection1Bullet2.
  ///
  /// In en, this message translates to:
  /// **'Modify and redistribute the application, provided the same AGPL-3.0 license is retained.'**
  String get legalSection1Bullet2;

  /// No description provided for @legalSection1Bullet3.
  ///
  /// In en, this message translates to:
  /// **'Use the application for any purpose, including commercial use.'**
  String get legalSection1Bullet3;

  /// No description provided for @legalSection1P3.
  ///
  /// In en, this message translates to:
  /// **'Any modified or derived version must be distributed under the same AGPL-3.0 license, include the full license text, and make the source code available. The full license text can be found in the LICENSE file of the repository.'**
  String get legalSection1P3;

  /// No description provided for @legalSection2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Attribution'**
  String get legalSection2Title;

  /// No description provided for @legalSection2P1.
  ///
  /// In en, this message translates to:
  /// **'In accordance with the AGPL-3.0 license, copyright and attribution notices must be retained in any copy or derived version of the software. The original application was created by phi-k.'**
  String get legalSection2P1;

  /// No description provided for @legalSection2P2.
  ///
  /// In en, this message translates to:
  /// **'Contributors are free to add their name to indicate their contributions.'**
  String get legalSection2P2;

  /// No description provided for @legalSection3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Third-Party Services'**
  String get legalSection3Title;

  /// No description provided for @legalSection3P1.
  ///
  /// In en, this message translates to:
  /// **'The website \'chords.ovh\' is an entity independent from the open-source application. It provides optional services (setlist sharing) and its source code is not covered by this license.'**
  String get legalSection3P1;

  /// No description provided for @legalSection3P2.
  ///
  /// In en, this message translates to:
  /// **'Official application updates are published via the GitHub repository. Versions distributed from other sources are not under the responsibility of the original author.'**
  String get legalSection3P2;

  /// No description provided for @legalSection4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Contact'**
  String get legalSection4Title;

  /// No description provided for @legalSection4P1.
  ///
  /// In en, this message translates to:
  /// **'To report a bug, suggest an improvement or for any other inquiry, you can contact the creator:'**
  String get legalSection4P1;

  /// No description provided for @legalPartPhilosophyHeader.
  ///
  /// In en, this message translates to:
  /// **'Project Philosophy'**
  String get legalPartPhilosophyHeader;

  /// No description provided for @legalPhilosophyIntro.
  ///
  /// In en, this message translates to:
  /// **'The following commitments are not legal obligations, but they represent the founding values of the Chords project. They are detailed in the PHILOSOPHY.md file of the repository.'**
  String get legalPhilosophyIntro;

  /// No description provided for @legalPhiloQuote.
  ///
  /// In en, this message translates to:
  /// **'Chords is a free music tool, available to everyone, and we hope it will remain so forever.'**
  String get legalPhiloQuote;

  /// No description provided for @legalPhiloP1.
  ///
  /// In en, this message translates to:
  /// **'The author commits to ensuring that the official version of Chords:'**
  String get legalPhiloP1;

  /// No description provided for @legalPhiloBullet1.
  ///
  /// In en, this message translates to:
  /// **'Remains free and ad-free.'**
  String get legalPhiloBullet1;

  /// No description provided for @legalPhiloBullet2.
  ///
  /// In en, this message translates to:
  /// **'Does not collect any personal data.'**
  String get legalPhiloBullet2;

  /// No description provided for @legalPhiloBullet3.
  ///
  /// In en, this message translates to:
  /// **'Remains a tool for musicians, without commercial compromise.'**
  String get legalPhiloBullet3;

  /// No description provided for @legalPhiloP2.
  ///
  /// In en, this message translates to:
  /// **'We encourage forks and derived versions to share these values, but the AGPL-3.0 license does not impose any restriction on commercial use or interface modification.'**
  String get legalPhiloP2;

  /// No description provided for @legalDonationTitle.
  ///
  /// In en, this message translates to:
  /// **'Contribution & Support'**
  String get legalDonationTitle;

  /// No description provided for @legalDonationContent.
  ///
  /// In en, this message translates to:
  /// **'Chords is and will remain free and ad-free. Development is maintained by the author in their spare time. Donations are possible to support the project but are absolutely optional.'**
  String get legalDonationContent;

  /// No description provided for @legalEmailCopied.
  ///
  /// In en, this message translates to:
  /// **'Email address copied!'**
  String get legalEmailCopied;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

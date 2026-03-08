// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get welcomePass => 'PASSER';

  @override
  String get welcomeStart => 'COMMENCER';

  @override
  String get welcomeNext => 'SUIVANT';

  @override
  String get welcomeSlide1Title => 'L\'Essentiel,\nSublimé.';

  @override
  String get welcomeSlide1Subtitle =>
      'Vos chansons favorites. Vos accords.\nUne interface épurée, pensée pour les musiciens.';

  @override
  String get welcomeSlide2Title => 'Vos Données,\nVos Règles.';

  @override
  String get welcomeSlide2Subtitle =>
      'Connectez n\'importe quelle source de données via API REST.\nChords est un lecteur neutre pour vos bases personnelles.';

  @override
  String get welcomeSlide3Title => 'Outils\nIntelligents.';

  @override
  String get welcomeSlide3Subtitle =>
      'Transposez en un clic, simplifiez\nles accords complexes. Adaptez le morceau à vous.';

  @override
  String get welcomeSlide4Title => 'Maîtrisez\nvotre Art.';

  @override
  String get welcomeSlide4Subtitle =>
      'Statistiques de jeu, historique, playlists.\nSuivez votre progression musicale jour après jour.';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonEdit => 'Modifier';

  @override
  String get commonSearch => 'Rechercher...';

  @override
  String get commonLoading => 'Chargement...';

  @override
  String commonError(String error) {
    return 'Erreur : $error';
  }

  @override
  String get commonUnknownArtist => 'Artiste inconnu';

  @override
  String get commonUntitled => 'Sans titre';

  @override
  String get commonOk => 'OK';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonConfirm => 'Confirmer';

  @override
  String get commonRename => 'Renommer';

  @override
  String get commonCreate => 'Créer';

  @override
  String get commonOther => 'Autres';

  @override
  String get homeArtists => 'Artistes';

  @override
  String get homePlaylists => 'Playlists';

  @override
  String get homeRecent => 'Récents';

  @override
  String get homeTags => 'Tags';

  @override
  String get homeEmptyTitle => 'Votre bibliothèque est vide';

  @override
  String get homeEmptySubtitle =>
      'Pour commencer, connectez une source de données dans les Paramètres ou notez votre premier morceau manuellement.';

  @override
  String get homeEmptyBtnSource => 'Configurer une source';

  @override
  String get homeEmptyBtnSourceDone => 'Source configurée';

  @override
  String get homeEmptySourceDoneSubtitle =>
      'Votre source est prête ! Essayez la recherche pour trouver vos premiers morceaux.';

  @override
  String get homeEmptyBtnWrite => 'Noter un morceau';

  @override
  String get homeNoSongs => 'Aucun morceau sauvegardé.';

  @override
  String homeSongCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count morceaux',
      one: '1 morceau',
      zero: '0 morceau',
    );
    return '$_temp0';
  }

  @override
  String get homeUpdateSuccess => 'Mise à jour réussie !';

  @override
  String homeUpdateSuccessMessage(String version) {
    return 'Chords a bien été mise à jour vers la version $version !';
  }

  @override
  String get homeWhatsNew => 'Nouveautés :';

  @override
  String get homeGreat => 'Super !';

  @override
  String homeSongsOf(String artist) {
    return 'Chansons de $artist';
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
      other: '$count morceaux',
      one: '1 morceau',
      zero: '0 morceau',
    );
    return '$_temp0';
  }

  @override
  String get songDifficulty => 'Difficulté';

  @override
  String get songCapo => 'Capo';

  @override
  String get songTuning => 'Accordage';

  @override
  String get songTranspose => 'Transposer';

  @override
  String get songViewStats => 'Voir les statistiques';

  @override
  String get songOptionsMetadata => 'Modifier les métadonnées';

  @override
  String get songOptionsLyrics => 'Modifier paroles et accords';

  @override
  String get songOptionsDelete => 'Supprimer la chanson';

  @override
  String get songDeleteConfirmTitle => 'Supprimer cette chanson ?';

  @override
  String songDeleteConfirmMessage(String title, String artist) {
    return 'Êtes-vous sûr de vouloir supprimer \"$title\" par $artist ? Cette action est irréversible.';
  }

  @override
  String get songNoCheat => 'Pas de triche ici ! ;)';

  @override
  String get songNoCheatDismiss => 'Snif';

  @override
  String get statsTitle => 'Statistiques';

  @override
  String get statsSavedDate => 'Date d\'enregistrement';

  @override
  String get statsPlayCount => 'Nombre de fois joué';

  @override
  String get statsLastPlayed => 'Dernière lecture';

  @override
  String get statsHistory => 'Historique des lectures';

  @override
  String get statsNoHistory => 'Aucun historique disponible';

  @override
  String get statsTags => 'Tags';

  @override
  String get statsNoTags => 'Aucun tag';

  @override
  String get statsShowList => 'Afficher en liste';

  @override
  String get statsShowGraph => 'Afficher en graphique';

  @override
  String get statsUnknownTitle => 'Titre inconnu';

  @override
  String get toolsTitle => 'Outils';

  @override
  String get toolsUtilities => 'Utilitaires';

  @override
  String get toolsTuner => 'Accordeur';

  @override
  String get toolsTunerDesc => 'Accordez votre guitare via le microphone';

  @override
  String get toolsMetronome => 'Métronome';

  @override
  String get toolsMetronomeDesc => 'Gardez le rythme avec précision';

  @override
  String get toolsExport => 'Export';

  @override
  String get toolsExportList => 'Exporter la liste';

  @override
  String get toolsExportListDesc =>
      'Générer une liste (TXT/PDF) de vos morceaux';

  @override
  String get toolsExportTabs => 'Exporter les tablatures';

  @override
  String get toolsExportTabsDesc => 'Créer un recueil PDF complet (Songbook)';

  @override
  String get toolsMisc => 'Divers';

  @override
  String get toolsVersion => 'Version et mises à jour';

  @override
  String get toolsVersionDesc => 'Voir la version actuelle et l\'historique';

  @override
  String get toolsWelcome => 'Revoir l\'introduction';

  @override
  String get toolsWelcomeDesc => 'Afficher l\'écran de bienvenue';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsSearchHint => 'Rechercher un paramètre...';

  @override
  String get settingsNoResults => 'Aucun résultat trouvé';

  @override
  String get settingsToolsDesc => 'Accordeur, métronome, export...';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsApiKeys => 'Clés API';

  @override
  String get settingsGeniusDesc => 'Utilisé pour les pochettes d\'album';

  @override
  String get settingsGeminiDesc => 'Utilisé pour la recherche intelligente';

  @override
  String get settingsBackups => 'Sauvegardes';

  @override
  String get settingsImportLib => 'Importer une bibliothèque';

  @override
  String get settingsImportLibDesc => 'Importer un fichier JSON de chansons';

  @override
  String get settingsExportLib => 'Exporter la bibliothèque';

  @override
  String get settingsExportLibDesc =>
      'Sauvegarder vos chansons dans un fichier JSON';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get settingsDevBy => 'Développé avec passion par';

  @override
  String get settingsDataSources => 'Sources de données';

  @override
  String get settingsDataSourcesDesc =>
      'Connecter une base de données de tablatures';

  @override
  String get settingsPasteApiKey => 'Collez votre clé API ici';

  @override
  String get settingsConfirmImport => 'Confirmer l\'import';

  @override
  String get settingsReplaceLibrary =>
      'Cela va remplacer la bibliothèque existante. Continuer ?';

  @override
  String get settingsImportSuccess => 'Import réussi. Retour à l\'accueil...';

  @override
  String get settingsInvalidFile => 'Fichier non valide';

  @override
  String settingsImportError(String error) {
    return 'Erreur à l\'import : $error';
  }

  @override
  String settingsExportSuccess(String path) {
    return 'Export réussi dans $path';
  }

  @override
  String get settingsExportCancelled => 'Export annulé';

  @override
  String settingsExportError(String error) {
    return 'Erreur à l\'export : $error';
  }

  @override
  String get settingsDevWith => 'Développé avec';

  @override
  String get settingsDevWithDesc =>
      'Flutter - Merci aux librairies Isar, Riverpod, fl_charts et toutes les autres !';

  @override
  String get settingsAppVersion => 'Version de l\'application';

  @override
  String get settingsLegal => 'Mentions légales & Licence';

  @override
  String get settingsDevSubtitle => 'phi-k - pianiste et développeur';

  @override
  String get dsTitle => 'Sources de données';

  @override
  String get dsNoSource => 'Aucune source configurée';

  @override
  String get dsNoSourceDesc =>
      'Chords ne contient aucune musique par défaut. Connectez votre propre base de données ou une API communautaire pour rechercher des tablatures.';

  @override
  String get dsAddSource => 'Ajouter une source';

  @override
  String get dsScanQr => 'Scanner un QR code';

  @override
  String get dsImportFile => 'Importer un fichier';

  @override
  String get dsManualConfig => 'Configurer manuellement';

  @override
  String get dsHelp => 'Aide';

  @override
  String get dsHelpTitle => 'Sources de données';

  @override
  String get dsHelpContent =>
      'Chords ne contient aucune musique. Vous devez connecter une base de données externe (API REST) pour rechercher des tablatures et des accords.';

  @override
  String get dsHelpBullets =>
      '• Appuyez sur + pour ajouter une source\n• Utilisez le switch pour activer/désactiver\n• Glissez vers la gauche pour supprimer\n• Une seule source peut être active à la fois\n• Partagez vos sources par fichier ou QR code';

  @override
  String get dsUnderstood => 'Compris';

  @override
  String get dsDeleteConfirm => 'Supprimer cette source ?';

  @override
  String dsDeleteMessage(String name) {
    return 'La source « $name » sera définitivement supprimée.';
  }

  @override
  String dsExportError(String error) {
    return 'Erreur lors de l\'export : $error';
  }

  @override
  String get dsImportConfirm => 'Importer cette source ?';

  @override
  String get dsImportName => 'Nom';

  @override
  String get dsImportUrl => 'URL';

  @override
  String get dsImportHeaders => 'Headers';

  @override
  String dsImportSuccess(String name) {
    return 'Source « $name » importée avec succès !';
  }

  @override
  String dsInvalidFile(String error) {
    return 'Fichier invalide : $error';
  }

  @override
  String get dsImport => 'Importer';

  @override
  String get dsShareSource => 'Partager cette source';

  @override
  String get dsShareFile => 'Exporter en fichier';

  @override
  String get dsShareFileDesc => 'Envoyer un fichier JSON partageable';

  @override
  String get dsShareQr => 'QR Code';

  @override
  String get dsShareQrDesc => 'Afficher un QR code scannable';

  @override
  String dsShareTitle(String name) {
    return 'Partager « $name »';
  }

  @override
  String get dsQrScanInfo =>
      'Scannez ce QR code depuis un autre appareil pour importer cette source.';

  @override
  String get dsQrHeadersIncluded => 'Headers inclus dans le QR code';

  @override
  String get dsAddSourceTitle => 'Ajouter une source';

  @override
  String get dsScanSubtitle => 'Importer depuis la caméra d\'un autre appareil';

  @override
  String get dsImportFileSubtitle => 'Charger un fichier JSON de configuration';

  @override
  String get dsManualSubtitle =>
      'Renseigner les informations de connexion à la main';

  @override
  String dsSourceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sources configurées',
      one: '1 source configurée',
    );
    return '$_temp0';
  }

  @override
  String get dsConnected => 'Connectée';

  @override
  String get dsShare => 'Partager';

  @override
  String get editSourceUnsavedTitle => 'Modifications non sauvegardées';

  @override
  String get editSourceUnsavedMessage =>
      'Vous avez des modifications non enregistrées. Que souhaitez-vous faire ?';

  @override
  String get editSourceContinue => 'Continuer l\'édition';

  @override
  String get editSourceDiscard => 'Abandonner';

  @override
  String get editSourceFillRequired =>
      'Remplissez au moins l\'URL de base et le chemin de recherche.';

  @override
  String searchResultsFor(String term) {
    return 'Résultats pour \"$term\"';
  }

  @override
  String get searchNoResults => 'Aucun résultat trouvé pour cette recherche.';

  @override
  String get searchLoadMore => 'Charger plus';

  @override
  String get searchBarHint => 'Find anything.';

  @override
  String get creationTitle => 'Nouveau morceau';

  @override
  String get creationTitleRequired => 'Le titre est obligatoire.';

  @override
  String get creationArtistRequired => 'L\'auteur est obligatoire.';

  @override
  String get creationSongAdded => 'Morceau ajouté à la bibliothèque !';

  @override
  String creationSaveError(String error) {
    return 'Erreur lors de la sauvegarde : $error';
  }

  @override
  String get creationClipboardEmpty => 'Presse-papiers vide.';

  @override
  String get creationTitleHint => 'Titre du morceau';

  @override
  String get creationArtistHint => 'Auteur';

  @override
  String get creationMetadata => 'Métadonnées supplémentaires';

  @override
  String get creationCapo => 'Capo';

  @override
  String get creationTonality => 'Tonalité';

  @override
  String get creationDifficulty => 'Difficulté';

  @override
  String get creationTuning => 'Accordage';

  @override
  String get creationContentHint =>
      '[Intro]\n\nAm           F\nÉcrivez vos accords ici...\nC            G\nAu dessus des paroles.';

  @override
  String get creationPaste => 'Coller';

  @override
  String get creationUndoPaste => 'Annuler le collage';

  @override
  String editLyricsTitle(String title) {
    return 'Éditer \"$title\"';
  }

  @override
  String get editLyricsReset => 'Réinitialiser';

  @override
  String get editLyricsResetTitle => 'Réinitialisation';

  @override
  String get editLyricsResetMessage =>
      'Cette action va restaurer la version originale des paroles et accords, et supprimer toutes vos modifications précédentes. Êtes-vous sûr ?';

  @override
  String get editLyricsHint => 'Entrez les paroles et accords ici...';

  @override
  String get editLyricsResetTooltip => 'Réinitialiser à la version originale';

  @override
  String get blindTestTitle => 'Blind Test';

  @override
  String get blindTestHideTitles => 'Cacher les titres';

  @override
  String get blindTestShowTitles => 'Montrer les titres';

  @override
  String get blindTestShuffle => 'Mélanger à nouveau';

  @override
  String blindTestCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chansons mélangées',
      one: '1 chanson mélangée',
    );
    return '$_temp0';
  }

  @override
  String get blindTestNoSongs => 'Aucune chanson disponible';

  @override
  String get blindTestNoSongsHint =>
      'Sauvegardez quelques chansons pour jouer au blind test !';

  @override
  String get blindTestUnknownTitle => 'Titre inconnu';

  @override
  String get blindTestUnknownArtist => 'Artiste inconnu';

  @override
  String blindTestSongNumber(int number) {
    return 'Chanson $number';
  }

  @override
  String get blindTestTitleHidden => 'Vue du titre désactivée';

  @override
  String get blindTestViewSong => 'Voir la chanson';

  @override
  String get blindTestCancelTooltip => 'Annuler';

  @override
  String get playlistNotFound => 'Playlist non trouvée.';

  @override
  String get playlistNoSongs => 'Aucun morceau dans cette playlist';

  @override
  String get playlistAddSongs => 'Ajouter des morceaux';

  @override
  String get playlistSongLoadError => 'Erreur de chargement des morceaux.';

  @override
  String get playlistSaved => 'Playlist sauvegardée';

  @override
  String playlistSaveError(String error) {
    return 'Erreur lors de la sauvegarde de la playlist: $error';
  }

  @override
  String playlistEditTitle(String name) {
    return 'Modifier $name';
  }

  @override
  String playlistSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count morceaux sélectionnés',
      one: '1 morceau sélectionné',
    );
    return '$_temp0';
  }

  @override
  String get playlistNewTitle => 'Nouvelle Playlist';

  @override
  String get playlistNameHint => 'Nom de la playlist...';

  @override
  String get playlistRenameTitle => 'Renommer la Playlist';

  @override
  String get playlistDeleteTitle => 'Supprimer la Playlist';

  @override
  String playlistDeleteMessage(String name) {
    return 'Voulez-vous vraiment supprimer la playlist \"$name\" ?';
  }

  @override
  String get playlistCreateError => 'Erreur lors de la création de la playlist';

  @override
  String get playlistRenameError => 'Erreur lors du renommage de la playlist';

  @override
  String filterSongsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chansons',
      one: '1 chanson',
      zero: '0 chanson',
    );
    return '$_temp0';
  }

  @override
  String filterArtistsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artistes',
      one: '1 artiste',
      zero: '0 artiste',
    );
    return '$_temp0';
  }

  @override
  String get filterOldestArtists => 'Artistes les moins récents';

  @override
  String get filterNewestArtists => 'Artistes les plus récents';

  @override
  String get filterOldSongs => 'Morceaux anciens';

  @override
  String get filterRecentSongs => 'Morceaux récents';

  @override
  String get filterNoPlayed => 'Aucun morceau n\'a encore été joué';

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
  String get filterTagsNotImplemented => 'Filtrage par tags non implémenté';

  @override
  String get updatePermissionTitle => 'Permission requise';

  @override
  String get updatePermissionMessage =>
      'Pour mettre à jour Chords, vous devez autoriser l\'installation d\'applications inconnues depuis les paramètres.';

  @override
  String get updateOpenSettings => 'Ouvrir les paramètres';

  @override
  String get updateAvailable => 'Mise à jour disponible';

  @override
  String updateVersion(String version) {
    return 'Version $version';
  }

  @override
  String get updateDownloading => 'Téléchargement en cours...';

  @override
  String get updateDownloadFailed =>
      'Échec du téléchargement. Vérifiez votre connexion.';

  @override
  String get updateMissed => 'Ce que vous avez manqué :';

  @override
  String get updateLater => 'Plus tard';

  @override
  String get updateInstall => 'Installer';

  @override
  String get versionTitle => 'Version et mises à jour';

  @override
  String get versionAutoUpdateAndroid =>
      'Les mises à jour automatiques ne sont disponibles que sur Android.';

  @override
  String get versionUpToDate => 'Vous êtes à jour !';

  @override
  String get versionCheckError => 'Erreur lors de la vérification.';

  @override
  String get versionChecking => 'Vérification...';

  @override
  String get versionCheckUpdate => 'Vérifier les mises à jour';

  @override
  String get versionHistory => 'Historique des versions';

  @override
  String get versionHistoryError => 'Impossible de charger l\'historique.';

  @override
  String get tunerTitle => 'Accordeur';

  @override
  String get tunerPlayString => 'Jouez une corde';

  @override
  String get tunerMicPermission =>
      'Permission microphone nécessaire pour l\'accordeur.';

  @override
  String get tunerMicOff => 'Micro coupé';

  @override
  String get tunerTuned => 'Accordé';

  @override
  String get tunerTooLow => 'Trop bas';

  @override
  String get tunerTooHigh => 'Trop haut';

  @override
  String get tunerListening => 'En écoute…';

  @override
  String get tunerMuteBtn => 'Couper le micro';

  @override
  String get tunerActivateBtn => 'Activer le micro';

  @override
  String get metronomeTitle => 'Métronome';

  @override
  String get exportListTitle => 'Exporter la liste';

  @override
  String get exportGenerating => 'Génération...';

  @override
  String get exportExport => 'Exporter';

  @override
  String get exportSongsLoading =>
      'La liste de morceaux est en cours de chargement.';

  @override
  String get exportTabsTitle => 'Générer un Songbook';

  @override
  String get exportTabsSetCount => 'Définir le nombre';

  @override
  String exportTabsCountHint(int max) {
    return 'Entrez un nombre entre 1 et $max :';
  }

  @override
  String get exportTabsContentTitle => '1. Contenu du recueil';

  @override
  String get exportTabsAll => 'Tout';

  @override
  String get exportTabsPlaylist => 'Playlist';

  @override
  String get exportTabsArtist => 'Artiste';

  @override
  String get exportTabsRecent => 'Récents';

  @override
  String get exportTabsManual => 'Manuel';

  @override
  String get exportTabsCustomTitle => '2. Personnalisation';

  @override
  String get exportTabsSongbookTitle => 'Titre du recueil';

  @override
  String get exportTabsCoverPage => 'Inclure la page de couverture';

  @override
  String get exportTabsToc => 'Inclure une table des matières';

  @override
  String get exportTabsGeneratePdf => 'Générer le PDF';

  @override
  String get exportTabsGenerating => 'Génération en cours...';

  @override
  String get exportTabsFooter =>
      'Le document généré contiendra toutes les tablatures sélectionnées mises en page pour l\'impression.';

  @override
  String get exportTabsNoSongs => 'Aucune chanson dans votre bibliothèque.';

  @override
  String get exportTabsNoPlaylist => 'Aucune playlist.';

  @override
  String get exportTabsChoosePlaylist => 'Choisir une playlist';

  @override
  String get exportTabsChooseArtist => 'Choisir un artiste';

  @override
  String get exportTabsManualSelection => 'Sélection manuelle';

  @override
  String get exportTabsClickToChoose => 'Cliquez pour choisir';

  @override
  String exportTabsSongsChosen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count morceaux choisis',
      one: '1 morceau choisi',
    );
    return '$_temp0';
  }

  @override
  String get exportTabsSongCount => 'Nombre de morceaux';

  @override
  String get exportTabsRecentDesc =>
      'Les morceaux les plus récemment joués ou ajoutés.';

  @override
  String get exportTabsUnnamed => 'Sans nom';

  @override
  String get multiSelectTitle => 'Sélection manuelle';

  @override
  String get multiSelectSearchHint => 'Rechercher...';

  @override
  String multiSelectCount(int count) {
    return '$count sélectionné(s)';
  }

  @override
  String get multiSelectAll => 'Tout sélectionner';

  @override
  String get multiSelectNone => 'Tout désélectionner';

  @override
  String get metadataEditTitle => 'Modifier les métadonnées';

  @override
  String get metadataTitle => 'Titre';

  @override
  String get metadataArtist => 'Auteur';

  @override
  String get metadataCoverUrl => 'URL de la cover';

  @override
  String get metadataFetchGenius => 'Récupérer depuis Genius';

  @override
  String get editOptionsMetadata => 'Modifier les métadonnées';

  @override
  String get editOptionsLyrics => 'Modifier les paroles et accords';

  @override
  String get langChooseTitle => 'Choose your language\nChoisissez votre langue';

  @override
  String get welcomeFinalGreeting => 'Bienvenue sur ';

  @override
  String get welcomeFinalSubtitle =>
      'Votre catalogue de musique\n100% gratuit et open-source.';

  @override
  String get filterArtists => 'Artistes';

  @override
  String get filterPlaylists => 'Playlists';

  @override
  String get filterRecent => 'Récents';

  @override
  String headerSongs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chansons',
      one: '1 chanson',
      zero: '0 chansons',
    );
    return '$_temp0';
  }

  @override
  String get headerArtistsOldest => 'Artistes les moins récents';

  @override
  String get headerArtistsNewest => 'Artistes les plus récents';

  @override
  String headerArtists(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artistes',
      one: '1 artiste',
      zero: '0 artistes',
    );
    return '$_temp0';
  }

  @override
  String get headerOldSongs => 'Morceaux anciens';

  @override
  String get headerRecentSongs => 'Morceaux récents';

  @override
  String get artistsUnknown => 'Inconnu';

  @override
  String get artistsOther => 'Autres';

  @override
  String get recentNoSongsPlayed => 'Aucun morceau n\'a encore été joué';

  @override
  String get tagsNotImplemented => 'Filtrage par tags non implémenté';

  @override
  String get playlistCreateBtn => 'Créer';

  @override
  String get playlistRenameBtn => 'Renommer';

  @override
  String playlistDeleteConfirm(String name) {
    return 'Voulez-vous vraiment supprimer la playlist \"$name\" ?';
  }

  @override
  String get playlistDeleteBtn => 'Supprimer';

  @override
  String get playlistDeleteError =>
      'Erreur lors de la suppression de la playlist';

  @override
  String get playlistNone => 'Aucune playlist';

  @override
  String get playlistCreateNew => 'Créer une playlist';

  @override
  String playlistSongCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count morceaux',
      one: '1 morceau',
      zero: '0 morceaux',
    );
    return '$_temp0';
  }

  @override
  String get playlistEditBtn => 'Modifier';

  @override
  String get songListOther => 'Autres';

  @override
  String get songListNoteSong => 'Noter un morceau';

  @override
  String get songListBlindTest => 'Blind Test';

  @override
  String get songListSettings => 'Paramètres';

  @override
  String get updateChangelog => 'Ce que vous avez manqué :';

  @override
  String get exportFilterPlaylist => 'Filtrer par playlist';

  @override
  String get exportFilterPlaylistDesc =>
      'N\'inclure que les morceaux d\'une playlist.';

  @override
  String get exportFilterPlaylistLoadError =>
      'Erreur de chargement des playlists';

  @override
  String get exportFilterPlaylistNone => 'Aucune playlist disponible.';

  @override
  String get exportFilterPlaylistSelect => 'Sélectionner une playlist';

  @override
  String get exportFilterPlaylistUnnamed => 'Sans nom';

  @override
  String get exportFilterPlayCount => 'Filtrer par nombre de lectures';

  @override
  String get exportFilterPlayCountLabel => 'Lectures';

  @override
  String get exportFilterLastPlayed => 'Filtrer par date de dernière lecture';

  @override
  String get exportFilterSince => 'Depuis le';

  @override
  String get exportFilterBefore => 'Avant le';

  @override
  String get exportFilterChooseDate => 'Choisir une date';

  @override
  String get exportFilterTags => 'Filtrer par tags';

  @override
  String get exportFilterTagsSoon => 'Bientôt disponible !';

  @override
  String get exportOptDisplayContent => 'Contenu à afficher';

  @override
  String get exportOptSongs => 'Morceaux';

  @override
  String get exportOptAuthors => 'Auteurs';

  @override
  String get exportOptBoth => 'Les deux';

  @override
  String get exportOptShowSongCount => 'Afficher le nombre de morceaux';

  @override
  String get exportOptShowSongCountDesc =>
      'Ajoute le nombre de morceaux de chaque artiste.';

  @override
  String get exportOptIncludePlayStats => 'Inclure les statistiques de lecture';

  @override
  String get exportOptIncludePlayStatsDescArtist =>
      'Ajoute le nombre total de lectures pour chaque artiste.';

  @override
  String get exportOptArtistSelection => 'Sélection des artistes';

  @override
  String get exportOptAllArtists => 'Tous les artistes';

  @override
  String get exportOptFilteredArtists =>
      'Seulement ceux qui répondent à certains critères';

  @override
  String get exportOptSortOrder => 'Ordre de tri';

  @override
  String get exportOptSortAlpha => 'Alphabétique';

  @override
  String get exportOptSortLastPlayed => 'Dernier joué';

  @override
  String get exportOptSortAppearance => 'Ordre d\'apparition';

  @override
  String get exportOptIncludeStats => 'Inclure les statistiques';

  @override
  String get exportOptIncludeStatsDesc =>
      'Ajoute le nombre de lectures et la date de dernière lecture.';

  @override
  String get exportOptSongSelection => 'Sélection des morceaux';

  @override
  String get exportOptAllSongs => 'Tous les morceaux';

  @override
  String get exportOptFilteredSongs =>
      'Seulement ceux qui répondent à certains critères';

  @override
  String get exportOptSortChrono => 'Chronologique (ajout récent)';

  @override
  String get exportOptExportFormat => 'Format d\'export';

  @override
  String get legalDonationTitle => '8. Contribution & Support';

  @override
  String get legalDonationContent =>
      'Chords est et restera gratuit et sans publicité. Le développement est maintenu par l\'auteur sur son temps libre. Les donations sont possibles pour soutenir le projet mais restent absolument optionnelles.';
}

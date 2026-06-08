// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/tab_source.dart';
import '../../services/source_manager.dart';
import '../../services/song_service.dart';
import '../../utils/chord_format_converter.dart';
import '../../widgets/common/custom_loader.dart';
import '../../l10n/app_localizations.dart';

class EditSourcePage extends StatefulWidget {
  final TabSource? source;
  const EditSourcePage({super.key, this.source});

  @override
  State<EditSourcePage> createState() => _EditSourcePageState();
}

class _EditSourcePageState extends State<EditSourcePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isStaticJson = false;

  late TextEditingController _nameCtrl;
  late TextEditingController _baseUrlCtrl;
  late TextEditingController _searchPathCtrl;
  late TextEditingController _detailsPathCtrl;

  late TextEditingController _listPathCtrl;
  late TextEditingController _titlePathCtrl;
  late TextEditingController _artistPathCtrl;
  late TextEditingController _urlPathCtrl;
  late TextEditingController _typePathCtrl;

  late TextEditingController _votesPathCtrl;
  late TextEditingController _ratingPathCtrl;
  late TextEditingController _albumCoverPathCtrl;
  late TextEditingController _artistCoverPathCtrl;

  late TextEditingController _contentPathCtrl;
  late TextEditingController _capoPathCtrl;
  late TextEditingController _tuningPathCtrl;
  late TextEditingController _difficultyPathCtrl;
  late TextEditingController _tonalityPathCtrl;

  late TextEditingController _chordsDictPathCtrl;
  late TextEditingController _versionsPathCtrl;
  late TextEditingController _artistTopTabsPathCtrl;

  late TextEditingController _header1KeyCtrl;
  late TextEditingController _header1ValCtrl;
  late TextEditingController _header2KeyCtrl;
  late TextEditingController _header2ValCtrl;

  @override
  void initState() {
    super.initState();
    final s = widget.source ?? TabSource(name: '', baseUrl: '');
    _isStaticJson = s.isStaticJson;
    _nameCtrl = TextEditingController(text: s.name);
    _baseUrlCtrl = TextEditingController(text: s.baseUrl);
    _searchPathCtrl = TextEditingController(text: s.searchPath);
    _detailsPathCtrl = TextEditingController(text: s.detailsPath);

    _listPathCtrl = TextEditingController(text: s.listPath);
    _titlePathCtrl = TextEditingController(text: s.titlePath);
    _artistPathCtrl = TextEditingController(text: s.artistPath);
    _urlPathCtrl = TextEditingController(text: s.urlPath);
    _typePathCtrl = TextEditingController(text: s.typePath);

    _votesPathCtrl = TextEditingController(text: s.votesPath);
    _ratingPathCtrl = TextEditingController(text: s.ratingPath);
    _albumCoverPathCtrl = TextEditingController(text: s.albumCoverPath);
    _artistCoverPathCtrl = TextEditingController(text: s.artistCoverPath);

    _contentPathCtrl = TextEditingController(text: s.contentPath);
    _capoPathCtrl = TextEditingController(text: s.capoPath);
    _tuningPathCtrl = TextEditingController(text: s.tuningPath);
    _difficultyPathCtrl = TextEditingController(text: s.difficultyPath);
    _tonalityPathCtrl = TextEditingController(text: s.tonalityPath);

    _chordsDictPathCtrl = TextEditingController(text: s.chordsDictPath);
    _versionsPathCtrl = TextEditingController(text: s.versionsPath);
    _artistTopTabsPathCtrl = TextEditingController(text: s.artistTopTabsPath);

    final keys = s.headers.keys.toList();
    _header1KeyCtrl =
        TextEditingController(text: keys.isNotEmpty ? keys[0] : '');
    _header1ValCtrl =
        TextEditingController(text: keys.isNotEmpty ? s.headers[keys[0]] : '');
    _header2KeyCtrl =
        TextEditingController(text: keys.length > 1 ? keys[1] : '');
    _header2ValCtrl =
        TextEditingController(text: keys.length > 1 ? s.headers[keys[1]] : '');

    _initialSource = _buildSourceFromForm();
  }

  late TabSource _initialSource;

  bool _hasChanges() {
    final current = _buildSourceFromForm();
    return current.toJson() != _initialSource.toJson();
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges()) return true;
    final loc = AppLocalizations.of(context)!;
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              width: 1),
        ),
        title: Text(loc.editSourceUnsavedTitle,
            style: const TextStyle(
                fontFamily: 'Cormorant', fontWeight: FontWeight.bold)),
        content: Text(
          loc.editSourceUnsavedMessage,
          style: const TextStyle(fontFamily: 'Cormorant', fontSize: 16),
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actionsOverflowButtonSpacing: 8.0,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, 'cancel'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Theme.of(context).dividerColor),
              foregroundColor: Theme.of(context).colorScheme.onSurface,
            ),
            child: Text(loc.editSourceContinue,
                style: TextStyle(
                    fontFamily: 'Cormorant',
                    color: Theme.of(context).colorScheme.onSurface)),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, 'discard'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .error
                      .withValues(alpha: 0.5)),
            ),
            child: Text(loc.editSourceDiscard,
                style: TextStyle(
                    fontFamily: 'Cormorant',
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, 'save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: Text(loc.commonSave,
                style: const TextStyle(
                    fontFamily: 'Cormorant',
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (result == 'save') {
      await _save();
      return false;
    }
    return result == 'discard';
  }

  TabSource _buildSourceFromForm() {
    Map<String, String> headers = {};
    if (_header1KeyCtrl.text.isNotEmpty) {
      headers[_header1KeyCtrl.text.trim()] = _header1ValCtrl.text.trim();
    }
    if (_header2KeyCtrl.text.isNotEmpty) {
      headers[_header2KeyCtrl.text.trim()] = _header2ValCtrl.text.trim();
    }

    String finalBaseUrl =
        _baseUrlCtrl.text.trim().replaceAll(RegExp(r'/$'), '');
    if (!finalBaseUrl.startsWith('http://') &&
        !finalBaseUrl.startsWith('https://') &&
        finalBaseUrl.isNotEmpty) {
      finalBaseUrl = 'https://$finalBaseUrl';
    }

    return TabSource(
      id: widget.source?.id,
      name: _nameCtrl.text.trim(),
      baseUrl: finalBaseUrl,
      isStaticJson: _isStaticJson,
      searchPath: _isStaticJson ? '' : _searchPathCtrl.text.trim(),
      detailsPath: _isStaticJson ? '' : _detailsPathCtrl.text.trim(),
      listPath: _listPathCtrl.text.trim(),
      titlePath: _titlePathCtrl.text.trim(),
      artistPath: _artistPathCtrl.text.trim(),
      urlPath: _urlPathCtrl.text.trim(),
      typePath: _typePathCtrl.text.trim(),
      votesPath: _votesPathCtrl.text.trim(),
      ratingPath: _ratingPathCtrl.text.trim(),
      albumCoverPath: _albumCoverPathCtrl.text.trim(),
      artistCoverPath: _artistCoverPathCtrl.text.trim(),
      contentPath: _contentPathCtrl.text.trim(),
      capoPath: _capoPathCtrl.text.trim(),
      tuningPath: _tuningPathCtrl.text.trim(),
      difficultyPath: _difficultyPathCtrl.text.trim(),
      tonalityPath: _tonalityPathCtrl.text.trim(),
      chordsDictPath: _chordsDictPathCtrl.text.trim(),
      versionsPath: _versionsPathCtrl.text.trim(),
      artistTopTabsPath: _artistTopTabsPathCtrl.text.trim(),
      headers: headers,
      isActive: widget.source?.isActive ?? true,
    );
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final newSource = _buildSourceFromForm();
      await SourceManager.saveSource(newSource);
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _deleteSource() async {
    final loc = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(loc.dsDeleteConfirm,
            style: const TextStyle(
                fontFamily: 'Cormorant', fontWeight: FontWeight.bold)),
        content: Text(
          loc.dsDeleteMessage(widget.source!.name),
          style: const TextStyle(fontFamily: 'Cormorant', fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(loc.commonCancel,
                style:
                    TextStyle(fontFamily: 'Cormorant', color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(loc.commonDelete,
                style: TextStyle(
                    fontFamily: 'Cormorant',
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await SourceManager.deleteSource(widget.source!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  void _showSectionHelp(String title, String body) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.help_outline_rounded,
                    color: Theme.of(context).colorScheme.error, size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Text(title,
                      style: TextStyle(
                          fontFamily: 'Cormorant',
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            SizedBox(height: 14),
            Text(body,
                style: TextStyle(
                    fontFamily: 'Cormorant', fontSize: 15, height: 1.5)),
          ],
        ),
      ),
    );
  }

  void _openTestPage() {
    final source = _buildSourceFromForm();
    if (source.baseUrl.isEmpty ||
        (!source.isStaticJson && source.searchPath.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.editSourceFillRequired,
              style: TextStyle(fontFamily: 'Cormorant')),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _TestSourcePage(source: source)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              widget.source == null ? "Nouvelle source" : "Modifier la source",
              style: TextStyle(
                  fontFamily: 'Cormorant',
                  fontWeight: FontWeight.bold,
                  fontSize: 22)),
          elevation: 0,
          actions: [
            if (widget.source != null)
              IconButton(
                icon: Icon(Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error),
                tooltip: "Supprimer",
                onPressed: _deleteSource,
              ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              _buildDocCard(),
              SizedBox(height: 28),
              _buildSectionHeader(
                "1. Connexion serveur",
                Icons.cloud_outlined,
                helpTitle: "Connexion serveur",
                helpBody:
                    "Configurez ici les informations de connexion à votre API REST.\n\n"
                    "• URL de base : l'adresse racine de l'API\n"
                    "• Headers : en-têtes HTTP optionnels pour l'authentification (ex: tokens Cloudflare).",
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  AppLocalizations.of(context)!.dsStaticJsonTitle,
                  style: const TextStyle(
                    fontFamily: 'Cormorant',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  AppLocalizations.of(context)!.dsStaticJsonDesc,
                  style: const TextStyle(fontFamily: 'Cormorant'),
                ),
                value: _isStaticJson,
                onChanged: (value) => setState(() => _isStaticJson = value),
                activeThumbColor  : Theme.of(context).primaryColor,
              ),
              SizedBox(height: 14),
              _buildField("Nom de la source", _nameCtrl, "Ex: Base Locale"),
              SizedBox(height: 12),
              _buildField(
                  "URL de base",
                  _baseUrlCtrl,
                  _isStaticJson
                      ? "Ex: https://.../songs.json"
                      : "Ex: api.monserveur.com"),
              SizedBox(height: 12),
              _buildRowFields("Header 1 (Clé)", _header1KeyCtrl,
                  "Header 1 (Valeur)", _header1ValCtrl,
                  obscure: true),
              SizedBox(height: 10),
              _buildRowFields("Header 2 (Clé)", _header2KeyCtrl,
                  "Header 2 (Valeur)", _header2ValCtrl,
                  obscure: true),
              SizedBox(height: 32),
              _buildDivider(),
              if (!_isStaticJson) ...[
                SizedBox(height: 28),
                _buildSectionHeader(
                  "2. Endpoints",
                  Icons.route_outlined,
                  helpTitle: "Endpoints (Requêtes)",
                  helpBody: "Chemins ajoutés à l'URL de base.\n\n"
                      "• Recherche : utilisez {query} là où le texte cherché doit apparaître.\n"
                      "• Détails : utilisez {url} là où l'identifiant (ID ou URL de la chanson) doit apparaître.",
                ),
                SizedBox(height: 14),
                _buildField("Chemin de recherche", _searchPathCtrl,
                    "Ex: /songs?title=ilike.*{query}*",
                    maxLines: 2),
                SizedBox(height: 12),
                _buildField("Chemin des détails", _detailsPathCtrl,
                    "Ex: /songs?song_url=eq.{url}",
                    maxLines: 2),
                SizedBox(height: 32),
                _buildDivider(),
              ],
              SizedBox(height: 28),
              _buildSectionHeader(
                "3. Infos Générales",
                Icons.account_tree_outlined,
                helpTitle: "Extraction de Base",
                helpBody:
                    "Indiquez comment lire la réponse JSON de votre API en utilisant des points (ex: data.titre).\n\n"
                    "Laissez vide si le champ n'existe pas dans votre base.",
              ),
              SizedBox(height: 14),
              _buildField("Chemin Liste (Recherche)", _listPathCtrl,
                  "Vide si la réponse est un tableau direct [...]"),
              SizedBox(height: 12),
              _buildRowFields(
                  "Clé Titre", _titlePathCtrl, "Clé Artiste", _artistPathCtrl),
              SizedBox(height: 12),
              _buildRowFields("Clé ID/URL", _urlPathCtrl,
                  "Clé Type (Chords, Pro..)", _typePathCtrl),
              SizedBox(height: 32),
              _buildDivider(),
              SizedBox(height: 28),
              _buildSectionHeader(
                "4. Contenu & Musique",
                Icons.music_note_outlined,
                helpTitle: "Contenu Musical (Détails)",
                helpBody:
                    "Où trouver le texte des accords, ainsi que les métadonnées musicales (capo, tuning, etc.) dans l'objet de détails.",
              ),
              SizedBox(height: 14),
              _buildField("Clé Paroles & Accords", _contentPathCtrl,
                  "Le texte brut contenant [ch] ou les accords au-dessus"),
              SizedBox(height: 12),
              _buildRowFields("Clé Capo", _capoPathCtrl,
                  "Clé Accordage (Tuning)", _tuningPathCtrl),
              SizedBox(height: 12),
              _buildRowFields("Clé Difficulté", _difficultyPathCtrl,
                  "Clé Tonalité", _tonalityPathCtrl),
              SizedBox(height: 32),
              _buildDivider(),
              SizedBox(height: 28),
              _buildSectionHeader(
                "5. Médias & Popularité",
                Icons.star_outline_rounded,
                helpTitle: "Statistiques et Images",
                helpBody:
                    "Permet de trier les résultats par popularité et d'afficher les pochettes d'album si l'API les fournit.",
              ),
              SizedBox(height: 14),
              _buildRowFields("Clé Votes (Nombre)", _votesPathCtrl,
                  "Clé Note sur 5", _ratingPathCtrl),
              SizedBox(height: 12),
              _buildRowFields("Cover Album (URL)", _albumCoverPathCtrl,
                  "Cover Artiste (URL)", _artistCoverPathCtrl),
              SizedBox(height: 32),
              _buildDivider(),
              SizedBox(height: 28),
              _buildSectionHeader(
                "6. Données Avancées",
                Icons.explore_outlined,
                helpTitle: "Extraction Complexe",
                helpBody:
                    "Extraction de gros objets JSON pour des fonctionnalités futures (générateur de grilles d'accords in-app, chansons similaires, etc.).",
              ),
              SizedBox(height: 14),
              _buildField("Dictionnaire d'accords", _chordsDictPathCtrl,
                  "Objet JSON contenant le placement des doigts"),
              SizedBox(height: 12),
              _buildRowFields("Versions alternatives", _versionsPathCtrl,
                  "Top de l'Artiste", _artistTopTabsPathCtrl),
              SizedBox(height: 36),
              _buildDivider(),
              SizedBox(height: 28),
              OutlinedButton.icon(
                onPressed: _openTestPage,
                icon: Icon(Icons.science_outlined, size: 20),
                label: Text(loc.dsTestConnection,
                    style: const TextStyle(
                        fontFamily: 'Cormorant',
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue.shade700,
                  side: BorderSide(color: Colors.blue.shade300),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: const Text("Enregistrer la source",
                    style: TextStyle(
                        fontFamily: 'Cormorant',
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon,
      {required String helpTitle, required String helpBody}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        SizedBox(width: 8),
        Expanded(
          child: Text(title,
              style: TextStyle(
                  fontFamily: 'Cormorant',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor)),
        ),
        GestureDetector(
          onTap: () => _showSectionHelp(helpTitle, helpBody),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.help_outline_rounded,
                size: 16,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.4)),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        thickness: 1);
  }

  Widget _buildField(
      String label, TextEditingController controller, String hint,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(fontFamily: 'UbuntuMono', fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
            fontFamily: 'Cormorant',
            color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
            fontSize: 16),
        hintStyle: TextStyle(
            fontFamily: 'UbuntuMono',
            color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
            fontSize: 13),
        filled: true,
        fillColor: Theme.of(context).colorScheme.onSurface.withAlpha(15),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(30))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(30))),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (val) =>
          val!.isEmpty && label.contains("Nom") ? "Requis" : null,
    );
  }

  Widget _buildRowFields(String label1, TextEditingController ctrl1,
      String label2, TextEditingController ctrl2,
      {bool obscure = false}) {
    return Row(
      children: [
        Expanded(child: _buildField(label1, ctrl1, "")),
        SizedBox(width: 10),
        Expanded(
            child: TextFormField(
          controller: ctrl2,
          obscureText: obscure,
          style: TextStyle(fontFamily: 'UbuntuMono', fontSize: 14),
          decoration: InputDecoration(
            labelText: label2,
            labelStyle: TextStyle(
                fontFamily: 'Cormorant',
                color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                fontSize: 16),
            filled: true,
            fillColor: Theme.of(context).colorScheme.onSurface.withAlpha(15),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color:
                        Theme.of(context).colorScheme.onSurface.withAlpha(30))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color:
                        Theme.of(context).colorScheme.onSurface.withAlpha(30))),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        )),
      ],
    );
  }

  Widget _buildDocCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.blue.withAlpha(25),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.blue.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.info_outline, color: Colors.blue, size: 20),
            SizedBox(width: 8),
            Text("API Agnostique",
                style: TextStyle(
                    fontFamily: 'Cormorant',
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.blue))
          ]),
          SizedBox(height: 10),
          Text(
              "Seuls les champs obligatoires (Nom et URL) sont nécessaires. Les autres champs étendent les capacités de l'application si l'API les supporte.",
              style: TextStyle(
                  fontFamily: 'Cormorant', fontSize: 14, height: 1.4)),
        ],
      ),
    );
  }
}

class _TestSourcePage extends StatefulWidget {
  final TabSource source;
  const _TestSourcePage({required this.source});

  @override
  State<_TestSourcePage> createState() => _TestSourcePageState();
}

enum _TestStep { idle, searching, searchDone, loadingDetails, done, error }

class _TestSourcePageState extends State<_TestSourcePage> {
  final _queryCtrl = TextEditingController();
  _TestStep _step = _TestStep.idle;
  String? _error;

  List<Map<String, dynamic>> _results = [];
  int _totalRawResults = 0;

  Map<String, String> _detailFields = {};
  String _previewLyrics = '';

  Duration _searchDuration = Duration.zero;
  Duration _detailsDuration = Duration.zero;
  bool get _isSearchSlow => _searchDuration.inMilliseconds > 1500;
  bool get _isDetailsSlow => _detailsDuration.inMilliseconds > 1500;
  bool get _isAnySlow => _isSearchSlow || _isDetailsSlow;

  Map<String, String> _extraFields = {};

  int get _configuredExtraCount {
    int count = 0;
    final s = widget.source;
    if (s.votesPath.isNotEmpty) count++;
    if (s.ratingPath.isNotEmpty) count++;
    if (s.albumCoverPath.isNotEmpty) count++;
    if (s.artistCoverPath.isNotEmpty) count++;
    if (s.tuningPath.isNotEmpty) count++;
    if (s.difficultyPath.isNotEmpty) count++;
    if (s.versionsPath.isNotEmpty) count++;
    if (s.artistTopTabsPath.isNotEmpty) count++;
    return count;
  }

  bool get _hasExtraFieldsConfigured => _configuredExtraCount > 0;

  int get _extraFieldsFoundCount {
    return _extraFields.values
        .where((v) => v.isNotEmpty && v != '—' && v != 'Non')
        .length;
  }

  dynamic _extractNestedValue(dynamic json, String path) {
    if (path.isEmpty || json == null) return json;
    List<String> keys = path.split('.');
    dynamic current = json;
    for (String key in keys) {
      if (current is Map && current.containsKey(key)) {
        current = current[key];
      } else {
        return null;
      }
    }
    return current;
  }

  Future<void> _runTest() async {
    final query = _queryCtrl.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _step = _TestStep.searching;
      _error = null;
      _results = [];
      _detailFields = {};
      _extraFields = {};
      _previewLyrics = '';
      _searchDuration = Duration.zero;
      _detailsDuration = Duration.zero;
    });

    try {
      final source = widget.source;

      if (source.isStaticJson) {
        final searchStopwatch = Stopwatch()..start();
        final results = await SongService.searchStaticSource(source, query);
        searchStopwatch.stop();
        _searchDuration = searchStopwatch.elapsed;

        _totalRawResults = results.length;

        final mapped = results.take(3).map((r) {
          return <String, dynamic>{
            "title": r['title'] ?? "Sans titre",
            "artist": r['artist'] ?? "Inconnu",
            "url": r['song_url'] ?? "",
            "type": r['type'] ?? "Chords",
            "votes": r['votes'] ?? "",
            "rating": r['rating'] ?? "",
          };
        }).toList();

        final Map<String, String> searchExtras = {};
        if (mapped.isNotEmpty) {
          searchExtras['Votes'] = mapped[0]['votes']?.toString() ?? '';
          searchExtras['Rating'] = mapped[0]['rating']?.toString() ?? '';
        }

        setState(() {
          _results = mapped;
          _step = _TestStep.searchDone;
        });

        await Future.delayed(const Duration(milliseconds: 400));

        if (mapped.isEmpty) {
          setState(() {
            _extraFields = searchExtras;
            _step = _TestStep.done;
          });
          return;
        }

        setState(() => _step = _TestStep.loadingDetails);

        final detailsStopwatch = Stopwatch()..start();
        final detailResult = await SongService.fetchStaticSourceDetails(
          source,
          mapped.first['url']?.toString() ?? '',
        );
        detailsStopwatch.stop();
        _detailsDuration = detailsStopwatch.elapsed;

        if (detailResult == null) {
          setState(() {
            _extraFields = searchExtras;
            _step = _TestStep.done;
          });
          return;
        }

        final content = (detailResult['lyrics_with_chords'] ?? '').toString();
        final converted = ChordFormatConverter.convertOnlineToOffline(content);
        final lines = converted.split('\n');

        final dynamic chordsDict =
            json.decode(detailResult['chords_dict'] ?? '{}');
        final String chordsDictStatus =
            chordsDict == null || (chordsDict is Map && chordsDict.isEmpty)
                ? 'Non'
                : 'Oui';

        setState(() {
          _detailFields = {
            'Titre': detailResult['title']?.toString() ?? '—',
            'Artiste': detailResult['artist']?.toString() ?? '—',
            'Tonalité': detailResult['tonality']?.toString() ?? '—',
            'Capo': detailResult['capo']?.toString() ?? '—',
            'Dico Accords ?': chordsDictStatus,
          };
          _previewLyrics = lines.take(16).join('\n');
          _extraFields = {...searchExtras};
          _step = _TestStep.done;
        });
        return;
      }

      final cleanQuery = Uri.encodeComponent(query.replaceAll(' ', '*'));
      final rawUrl = '${source.baseUrl}${source.searchPath}';
      final url = rawUrl.replaceAll('{query}', cleanQuery);

      final searchStopwatch = Stopwatch()..start();
      final searchResponse =
          await http.get(Uri.parse(url), headers: source.headers);
      searchStopwatch.stop();
      _searchDuration = searchStopwatch.elapsed;

      if (searchResponse.statusCode != 200) {
        setState(() {
          _step = _TestStep.error;
          _error = "Recherche : erreur HTTP ${searchResponse.statusCode}";
        });
        return;
      }

      final dynamic decoded = json.decode(searchResponse.body);
      final List<dynamic> rawResults = source.listPath.isEmpty
          ? (decoded is List ? decoded : [decoded])
          : _extractNestedValue(decoded, source.listPath) ?? [];

      _totalRawResults = rawResults.length;

      final mapped = rawResults.take(3).map((r) {
        return <String, dynamic>{
          "title": _extractNestedValue(r, source.titlePath)?.toString() ??
              "Sans titre",
          "artist": _extractNestedValue(r, source.artistPath)?.toString() ??
              "Inconnu",
          "url": _extractNestedValue(r, source.urlPath)?.toString() ?? "",
          "type":
              _extractNestedValue(r, source.typePath)?.toString() ?? "Chords",
          "votes": _extractNestedValue(r, source.votesPath)?.toString() ?? "",
          "rating": _extractNestedValue(r, source.ratingPath)?.toString() ?? "",
        };
      }).toList();

      final Map<String, String> searchExtras = {};
      if (source.votesPath.isNotEmpty && mapped.isNotEmpty) {
        searchExtras['Votes'] = mapped[0]['votes']?.toString() ?? '';
      }
      if (source.ratingPath.isNotEmpty && mapped.isNotEmpty) {
        searchExtras['Rating'] = mapped[0]['rating']?.toString() ?? '';
      }

      setState(() {
        _results = mapped;
        _step = _TestStep.searchDone;
      });

      await Future.delayed(const Duration(milliseconds: 400));

      if (mapped.isEmpty || source.detailsPath.isEmpty) {
        setState(() {
          _extraFields = searchExtras;
          _step = _TestStep.done;
        });
        return;
      }

      final firstUrl = mapped[0]['url']?.toString() ?? '';
      if (firstUrl.isEmpty) {
        setState(() {
          _extraFields = searchExtras;
          _step = _TestStep.done;
        });
        return;
      }

      setState(() => _step = _TestStep.loadingDetails);

      final encodedUrl = Uri.encodeComponent(firstUrl);
      final detailRawUrl = '${source.baseUrl}${source.detailsPath}';
      final detailUrl = detailRawUrl.replaceAll('{url}', encodedUrl);

      final detailsStopwatch = Stopwatch()..start();
      final detailResponse =
          await http.get(Uri.parse(detailUrl), headers: source.headers);
      detailsStopwatch.stop();
      _detailsDuration = detailsStopwatch.elapsed;

      if (detailResponse.statusCode != 200) {
        setState(() {
          _step = _TestStep.error;
          _error = "Détails : erreur HTTP ${detailResponse.statusCode}";
        });
        return;
      }

      final dynamic detailDecoded = json.decode(detailResponse.body);
      final item = (detailDecoded is List && detailDecoded.isNotEmpty)
          ? detailDecoded[0]
          : detailDecoded;

      String content =
          _extractNestedValue(item, source.contentPath)?.toString() ?? '';
      content = content.replaceAll(RegExp(r'\[/?tab\]'), '').trim();

      final converted = ChordFormatConverter.convertOnlineToOffline(content);
      final lines = converted.split('\n');

      final dynamic chordsDict =
          _extractNestedValue(item, source.chordsDictPath);
      final String chordsDictStatus =
          chordsDict == null || (chordsDict is Map && chordsDict.isEmpty)
              ? 'Non'
              : 'Oui';

      final Map<String, String> detailExtras = {};
      if (source.albumCoverPath.isNotEmpty) {
        detailExtras['Couverture album'] =
            _extractNestedValue(item, source.albumCoverPath)?.toString() ?? '';
      }
      if (source.artistCoverPath.isNotEmpty) {
        detailExtras['Photo artiste'] =
            _extractNestedValue(item, source.artistCoverPath)?.toString() ?? '';
      }
      if (source.tuningPath.isNotEmpty) {
        detailExtras['Accordage'] =
            _extractNestedValue(item, source.tuningPath)?.toString() ?? '';
      }
      if (source.difficultyPath.isNotEmpty) {
        detailExtras['Difficulté'] =
            _extractNestedValue(item, source.difficultyPath)?.toString() ?? '';
      }
      if (source.versionsPath.isNotEmpty) {
        final val = _extractNestedValue(item, source.versionsPath);
        if (val is List) {
          detailExtras['Versions'] = '${val.length} version(s)';
        } else {
          detailExtras['Versions'] = val?.toString() ?? '';
        }
      }
      if (source.artistTopTabsPath.isNotEmpty) {
        final val = _extractNestedValue(item, source.artistTopTabsPath);
        if (val is List) {
          detailExtras['Top tabs artiste'] = '${val.length} tab(s)';
        } else {
          detailExtras['Top tabs artiste'] = val?.toString() ?? '';
        }
      }

      setState(() {
        _detailFields = {
          'Titre':
              _extractNestedValue(item, source.titlePath)?.toString() ?? '—',
          'Artiste':
              _extractNestedValue(item, source.artistPath)?.toString() ?? '—',
          'Tonalité':
              _extractNestedValue(item, source.tonalityPath)?.toString() ?? '—',
          'Capo': _extractNestedValue(item, source.capoPath)?.toString() ?? '—',
          'Dico Accords ?': chordsDictStatus,
        };
        _previewLyrics = lines.take(16).join('\n');
        _extraFields = {...searchExtras, ...detailExtras};
        _step = _TestStep.done;
      });
    } catch (e) {
      setState(() {
        _step = _TestStep.error;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.dsTestConnection,
            style: const TextStyle(
                fontFamily: 'Cormorant',
                fontWeight: FontWeight.bold,
                fontSize: 22)),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(24, 8, 24, 40),
        children: [
          Text(
              widget.source.name.isNotEmpty
                  ? widget.source.name
                  : loc.dsUnnamedSource,
              style: TextStyle(
                  fontFamily: 'Cormorant',
                  fontSize: 15,
                  color:
                      Theme.of(context).colorScheme.onSurface.withAlpha(150))),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _queryCtrl,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _runTest(),
                  style: TextStyle(fontFamily: 'Cormorant', fontSize: 16),
                  decoration: InputDecoration(
                    hintText: "Ex: Imagine, Yesterday...",
                    hintStyle: TextStyle(
                        fontFamily: 'Cormorant',
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha(100),
                        fontSize: 15),
                    filled: true,
                    fillColor:
                        Theme.of(context).colorScheme.onSurface.withAlpha(15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha(100),
                        size: 20),
                  ),
                ),
              ),
              SizedBox(width: 10),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _step == _TestStep.searching ||
                          _step == _TestStep.loadingDetails
                      ? null
                      : _runTest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    disabledBackgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: Text(loc.dsTestBtn,
                      style: TextStyle(
                          fontFamily: 'Cormorant',
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          SizedBox(height: 28),
          if (_step != _TestStep.idle) ...[
            _buildStepIndicator(),
            SizedBox(height: 24),
          ],
          if (_step == _TestStep.error && _error != null) ...[
            _buildErrorCard(),
            SizedBox(height: 20),
          ],
          if (_step == _TestStep.done && _isAnySlow) ...[
            _buildSlowWarningCard(),
            SizedBox(height: 20),
          ],
          if (_results.isNotEmpty) ...[
            _buildSectionTitle(loc.dsTestSearchResults,
                loc.dsTestResultsSummary(_totalRawResults, _results.length)),
            SizedBox(height: 10),
            _buildResultsCard(),
            SizedBox(height: 24),
          ],
          if (_detailFields.isNotEmpty) ...[
            _buildSectionTitle(loc.dsTestExtractedInfo,
                loc.dsTestAutoReadFirst),
            SizedBox(height: 10),
            _buildDetailCard(),
            SizedBox(height: 24),
          ],
          if (_previewLyrics.isNotEmpty) ...[
            _buildSectionTitle(loc.dsTestTabPreview, loc.dsTestFirstLines),
            SizedBox(height: 10),
            _buildLyricsCard(),
            SizedBox(height: 24),
          ],
          if (_step == _TestStep.done && _extraFields.isNotEmpty) ...[
            _buildSectionTitle(loc.dsTestExtraFields,
                loc.dsTestExtraFieldsSummary(_extraFieldsFoundCount, _extraFields.length)),
            SizedBox(height: 10),
            _buildExtraFieldsCard(),
          ],
          if (_step == _TestStep.idle) _buildIdleHint(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final loc = AppLocalizations.of(context)!;
    final searchDone = _step == _TestStep.searchDone ||
        _step == _TestStep.loadingDetails ||
        _step == _TestStep.done;
    final detailsDone = _step == _TestStep.done && _detailFields.isNotEmpty;
    final isSearching = _step == _TestStep.searching;
    final isLoadingDetails = _step == _TestStep.loadingDetails;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStepDot(
            label: loc.dsTestStepSearch,
            isDone: searchDone,
            isActive: isSearching,
            isError: _step == _TestStep.error && !searchDone,
            isSlow: searchDone && _isSearchSlow,
            duration: _searchDuration,
          ),
          Expanded(
            child: Container(
              height: 2,
              color: searchDone
                  ? (_isSearchSlow
                      ? Colors.orange.shade300
                      : Colors.green.shade300)
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.1),
            ),
          ),
          _buildStepDot(
            label: loc.dsTestStepDetails,
            isDone: detailsDone,
            isActive: isLoadingDetails,
            isError: _step == _TestStep.error && searchDone,
            isSlow: detailsDone && _isDetailsSlow,
            duration: _detailsDuration,
          ),
          if (_hasExtraFieldsConfigured) ...[
            Expanded(
              child: Container(
                height: 2,
                color: detailsDone
                    ? (_extraFieldsFoundCount == _extraFields.length
                        ? Colors.green.shade300
                        : _extraFieldsFoundCount == 0
                            ? Theme.of(context).primaryColor
                            : Colors.orange.shade300)
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.1),
              ),
            ),
            _buildStepDot(
              label: loc.dsTestStepExtras,
              isDone: detailsDone && _extraFields.isNotEmpty,
              isActive: isLoadingDetails,
              isError: detailsDone &&
                  _extraFields.isNotEmpty &&
                  _extraFieldsFoundCount == 0,
              isSlow: detailsDone &&
                  _extraFields.isNotEmpty &&
                  _extraFieldsFoundCount > 0 &&
                  _extraFieldsFoundCount < _extraFields.length,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSlowWarningCard() {
    final loc = AppLocalizations.of(context)!;
    final searchMs = _searchDuration.inMilliseconds;
    final detailsMs = _detailsDuration.inMilliseconds;
    String timing = '';
    if (_isSearchSlow && _isDetailsSlow) {
      timing =
          '${loc.dsTestStepSearch} : ${(searchMs / 1000).toStringAsFixed(1)}s · ${loc.dsTestStepDetails} : ${(detailsMs / 1000).toStringAsFixed(1)}s';
    } else if (_isSearchSlow) {
      timing = '${loc.dsTestStepSearch} : ${(searchMs / 1000).toStringAsFixed(1)}s';
    } else {
      timing = '${loc.dsTestStepDetails} : ${(detailsMs / 1000).toStringAsFixed(1)}s';
    }

    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha(25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.speed_rounded, color: Colors.orange.shade700, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loc.dsTestSlowWarningTitle,
                    style: TextStyle(
                        fontFamily: 'Cormorant',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800)),
                SizedBox(height: 4),
                Text(
                    loc.dsTestSlowWarningBody,
                    style: TextStyle(
                        fontFamily: 'Cormorant',
                        fontSize: 13,
                        color: Colors.orange.shade900,
                        height: 1.4)),
                SizedBox(height: 6),
                Text(timing,
                    style: TextStyle(
                        fontFamily: 'UbuntuMono',
                        fontSize: 12,
                        color: Colors.orange.shade700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDot({
    required String label,
    required bool isDone,
    required bool isActive,
    required bool isError,
    bool isSlow = false,
    Duration duration = Duration.zero,
  }) {
    Color dotColor;
    Widget dotChild;

    if (isError) {
      dotColor = Theme.of(context).primaryColor;
      dotChild = Icon(Icons.close_rounded,
          size: 14, color: Theme.of(context).colorScheme.onPrimary);
    } else if (isDone && isSlow) {
      dotColor = Colors.orange;
      dotChild = Icon(Icons.check_rounded,
          size: 14, color: Theme.of(context).colorScheme.onPrimary);
    } else if (isDone) {
      dotColor = Colors.green;
      dotChild = Icon(Icons.check_rounded,
          size: 14, color: Theme.of(context).colorScheme.onPrimary);
    } else if (isActive) {
      dotColor = Theme.of(context).primaryColor;
      dotChild =
          CustomLoader(size: 18, color: Theme.of(context).colorScheme.error);
    } else {
      dotColor = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1);
      dotChild = SizedBox.shrink();
    }

    final durationText = duration.inMilliseconds > 0
        ? '${(duration.inMilliseconds / 1000).toStringAsFixed(1)}s'
        : '';

    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
          child: Center(child: dotChild),
        ),
        SizedBox(height: 6),
        Text(label,
            style: TextStyle(
                fontFamily: 'Cormorant',
                fontSize: 12,
                color: isDone
                    ? (isSlow ? Colors.orange.shade700 : Colors.green.shade700)
                    : isError
                        ? Theme.of(context).primaryColor
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.4),
                fontWeight: FontWeight.bold)),
        if (durationText.isNotEmpty)
          Text(durationText,
              style: TextStyle(
                  fontFamily: 'UbuntuMono',
                  fontSize: 10,
                  color:
                      isSlow ? Colors.orange.shade600 : Colors.green.shade500)),
      ],
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.error),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded,
              color: Theme.of(context).colorScheme.error, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(_error!,
                style: TextStyle(
                    fontFamily: 'Cormorant',
                    fontSize: 14,
                    color: Theme.of(context).primaryColor,
                    height: 1.4),
                maxLines: 5,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontFamily: 'Cormorant',
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        SizedBox(height: 2),
        Text(subtitle,
            style: TextStyle(
                fontFamily: 'Cormorant',
                fontSize: 13,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.4))),
      ],
    );
  }

  Widget _buildResultsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: _results.asMap().entries.map((entry) {
          final i = entry.key;
          final r = entry.value;
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text("${i + 1}",
                            style: TextStyle(
                                fontFamily: 'Cormorant',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor)),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r['title'] ?? '',
                              style: TextStyle(
                                  fontFamily: 'Cormorant',
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          SizedBox(height: 2),
                          Text(r['artist'] ?? '',
                              style: TextStyle(
                                  fontFamily: 'Cormorant',
                                  fontSize: 13,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.5)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(r['type'] ?? '',
                          style: TextStyle(
                              fontFamily: 'Cormorant',
                              fontSize: 11,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.5))),
                    ),
                  ],
                ),
              ),
              if (i < _results.length - 1)
                Divider(
                    height: 1,
                    indent: 60,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.05)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDetailCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: _detailFields.entries.map((entry) {
          final isFound = entry.value != '—' &&
              entry.value != 'Non' &&
              entry.value.isNotEmpty;
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(entry.key,
                      style: TextStyle(
                          fontFamily: 'Cormorant',
                          fontSize: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.4))),
                ),
                Expanded(
                  child: Text(
                    entry.value.isNotEmpty ? entry.value : '—',
                    style: TextStyle(
                        fontFamily: 'Cormorant',
                        fontSize: 15,
                        fontWeight:
                            isFound ? FontWeight.bold : FontWeight.normal,
                        color: isFound
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.25),
                        fontStyle:
                            isFound ? FontStyle.normal : FontStyle.italic),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  isFound
                      ? Icons.check_circle_rounded
                      : Icons.remove_circle_outline,
                  size: 16,
                  color: isFound
                      ? Colors.green.shade400
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.15),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLyricsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withAlpha(10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_previewLyrics,
              style: TextStyle(
                  fontFamily: 'UbuntuMono', fontSize: 12, height: 1.5)),
          SizedBox(height: 8),
          Center(
            child: Text("···",
                style: TextStyle(
                    fontFamily: 'Cormorant',
                    fontSize: 20,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.25),
                    letterSpacing: 4)),
          ),
        ],
      ),
    );
  }

  Widget _buildExtraFieldsCard() {
    final found = _extraFieldsFoundCount;
    final total = _extraFields.length;
    final Color headerColor;
    final IconData headerIcon;
    final String headerText;

    if (found == total) {
      headerColor = Colors.green;
      headerIcon = Icons.check_circle_rounded;
      headerText = 'Tous les champs supplémentaires sont détectés';
    } else if (found == 0) {
      headerColor = Theme.of(context).primaryColor;
      headerIcon = Icons.cancel_rounded;
      headerText = 'Aucun champ supplémentaire détecté';
    } else {
      headerColor = Colors.orange;
      headerIcon = Icons.warning_rounded;
      headerText =
          '$found / $total champ${total > 1 ? 's' : ''} détecté${found > 1 ? 's' : ''}';
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: headerColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: headerColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: Row(
              children: [
                Icon(headerIcon, size: 18, color: headerColor),
                SizedBox(width: 10),
                Expanded(
                  child: Text(headerText,
                      style: TextStyle(
                          fontFamily: 'Cormorant',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: headerColor)),
                ),
              ],
            ),
          ),
          ..._extraFields.entries.map((entry) {
            final isFound = entry.value.isNotEmpty &&
                entry.value != '—' &&
                entry.value != 'Non';
            final displayValue = entry.value.isNotEmpty ? entry.value : '—';
            final truncated = displayValue.length > 60
                ? '${displayValue.substring(0, 57)}...'
                : displayValue;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(entry.key,
                        style: TextStyle(
                            fontFamily: 'Cormorant',
                            fontSize: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.4))),
                  ),
                  Expanded(
                    child: Text(
                      truncated,
                      style: TextStyle(
                          fontFamily: 'Cormorant',
                          fontSize: 14,
                          fontWeight:
                              isFound ? FontWeight.bold : FontWeight.normal,
                          color: isFound
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.25),
                          fontStyle:
                              isFound ? FontStyle.normal : FontStyle.italic),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    isFound
                        ? Icons.check_circle_rounded
                        : Icons.remove_circle_outline,
                    size: 16,
                    color: isFound
                        ? Colors.green.shade400
                        : Theme.of(context).primaryColor,
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildIdleHint() {
    final loc = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Icon(Icons.electric_bolt_outlined,
              size: 48,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.1)),
          SizedBox(height: 16),
          Text(
            loc.dsTestIdleHint1,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Cormorant',
                fontSize: 15,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.25),
                height: 1.4),
          ),
          SizedBox(height: 8),
          Text(
            loc.dsTestIdleHint2,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Cormorant',
                fontSize: 13,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.25),
                height: 1.4),
          ),
        ],
      ),
    );
  }
}

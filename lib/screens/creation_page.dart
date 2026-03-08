import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../data/collections/song.dart';
import '../l10n/app_localizations.dart';
import '../models/bottom_bar_model.dart';
import '../providers/song_provider.dart';

class CreationPage extends ConsumerStatefulWidget {
  const CreationPage({super.key});

  @override
  ConsumerState<CreationPage> createState() => _CreationPageState();
}

class _CreationPageState extends ConsumerState<CreationPage> {
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _contentController = TextEditingController();
  final _capoController = TextEditingController();
  final _tonalityController = TextEditingController();
  final _difficultyController = TextEditingController();
  final _tuningController = TextEditingController();

  bool _isSaving = false;
  bool _showUndoPaste = false;
  String? _pasteUndoContent;
  Timer? _pasteUndoTimer;

  @override
  void dispose() {
    _pasteUndoTimer?.cancel();
    _titleController.dispose();
    _artistController.dispose();
    _contentController.dispose();
    _capoController.dispose();
    _tonalityController.dispose();
    _difficultyController.dispose();
    _tuningController.dispose();
    super.dispose();
  }

  Future<void> _saveSong() async {
    final title = _titleController.text.trim();
    final artist = _artistController.text.trim();
    final content = _contentController.text;
    final capo = _capoController.text.trim();
    final tonality = _tonalityController.text.trim();
    final difficulty = _difficultyController.text.trim();
    final tuning = _tuningController.text.trim();

    final loc = AppLocalizations.of(context)!;

    if (title.isEmpty) {
      BottomBarModel.showBottomBar(message: loc.creationTitleRequired);
      return;
    }

    if (artist.isEmpty) {
      BottomBarModel.showBottomBar(message: loc.creationArtistRequired);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final now = DateTime.now();
      final String uniqueId = const Uuid().v4();
      final String manualUrl = "manual_$uniqueId";

      final tags = <String>["Manuel"];
      if (tonality.isNotEmpty) {
        tags.add("Tonalité: $tonality");
      }

      final newSong = Song(
        songUrl: manualUrl,
        title: title,
        artist: artist,
        difficulty: difficulty.isEmpty ? null : difficulty,
        capo: capo.isEmpty ? null : capo,
        tuning: tuning.isEmpty ? null : tuning,
        lyricsWithChords: content,
        originalLyricsWithChords: content,
        addedDate: now,
        savedDate: now,
        playCount: 0,
        playHistory: const [],
        tags: tags,
      );

      await ref.read(databaseServiceProvider).updateSong(newSong);

      if (!mounted) return;

      BottomBarModel.showBottomBar(
        message: loc.creationSongAdded,
      );
      Navigator.pop(context);
      ref.invalidate(allSongsProvider);
    } catch (e) {
      if (!mounted) return;
      BottomBarModel.showBottomBar(
        message: loc.creationSaveError(e.toString()),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    final text = data?.text ?? '';

    if (!mounted) return;

    if (text.trim().isEmpty) {
      BottomBarModel.showBottomBar(
          message: AppLocalizations.of(context)!.creationClipboardEmpty);
      return;
    }
    _pasteUndoTimer?.cancel();
    _pasteUndoContent = _contentController.text;
    setState(() {
      _showUndoPaste = true;
    });

    _contentController.text = text;
    _contentController.selection = TextSelection.collapsed(
      offset: text.length,
    );

    _pasteUndoTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _showUndoPaste = false;
      });
    });
  }

  void _undoPaste() {
    final previous = _pasteUndoContent;
    if (previous == null) return;
    _pasteUndoTimer?.cancel();
    _contentController.text = previous;
    _contentController.selection = TextSelection.collapsed(
      offset: previous.length,
    );
    setState(() {
      _showUndoPaste = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          AppLocalizations.of(context)!.creationTitle,
          style: const TextStyle(
            fontFamily: 'Cormorant',
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _isSaving
                ? const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.red,
                      ),
                    ),
                  )
                : TextButton.icon(
                    onPressed: _saveSong,
                    icon: const Icon(Icons.check, color: Colors.red),
                    label: Text(
                      AppLocalizations.of(context)!.commonSave,
                      style: const TextStyle(
                        fontFamily: 'Cormorant',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.red,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  style: const TextStyle(
                    fontFamily: 'Cormorant',
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.creationTitleHint,
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                TextField(
                  controller: _artistController,
                  style: TextStyle(
                    fontFamily: 'Cormorant',
                    fontSize: 18,
                    color: Colors.grey.shade800,
                  ),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.creationArtistHint,
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.only(top: 2, bottom: 0),
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      size: 18,
                      color: Colors.grey,
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 25),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.only(top: 0, bottom: 2),
                childrenPadding: const EdgeInsets.only(bottom: 8),
                title: Text(
                  AppLocalizations.of(context)!.creationMetadata,
                  style: const TextStyle(
                    fontFamily: 'Cormorant',
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                children: [
                  TextField(
                    controller: _capoController,
                    style: const TextStyle(
                      fontFamily: 'Cormorant',
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.creationCapo,
                      labelStyle: const TextStyle(
                        fontFamily: 'Cormorant',
                        color: Colors.black,
                      ),
                    ),
                  ),
                  TextField(
                    controller: _tonalityController,
                    style: const TextStyle(
                      fontFamily: 'Cormorant',
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.creationTonality,
                      labelStyle: const TextStyle(
                        fontFamily: 'Cormorant',
                        color: Colors.black,
                      ),
                    ),
                  ),
                  TextField(
                    controller: _difficultyController,
                    style: const TextStyle(
                      fontFamily: 'Cormorant',
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText:
                          AppLocalizations.of(context)!.creationDifficulty,
                      labelStyle: const TextStyle(
                        fontFamily: 'Cormorant',
                        color: Colors.black,
                      ),
                    ),
                  ),
                  TextField(
                    controller: _tuningController,
                    style: const TextStyle(
                      fontFamily: 'Cormorant',
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.creationTuning,
                      labelStyle: const TextStyle(
                        fontFamily: 'Cormorant',
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Stack(
                children: [
                  TextField(
                    controller: _contentController,
                    maxLines: null,
                    expands: true,
                    style: const TextStyle(
                      fontFamily: 'UbuntuMono',
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          AppLocalizations.of(context)!.creationContentHint,
                      hintStyle: TextStyle(
                        fontFamily: 'UbuntuMono',
                        color: Colors.grey.shade400,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.only(
                        top: 28,
                        right: 32,
                      ),
                    ),
                    keyboardType: TextInputType.multiline,
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      tooltip: _showUndoPaste
                          ? AppLocalizations.of(context)!.creationUndoPaste
                          : AppLocalizations.of(context)!.creationPaste,
                      onPressed:
                          _showUndoPaste ? _undoPaste : _pasteFromClipboard,
                      icon: Icon(
                        _showUndoPaste ? Icons.undo : Icons.content_paste,
                        size: 18,
                        color: Colors.black.withValues(alpha: 0.6),
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.04),
                        padding: const EdgeInsets.all(6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

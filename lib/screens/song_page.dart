// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../data/collections/song.dart';
import '../main.dart';
import '../providers/song_provider.dart';
import '../services/pdf_export_service.dart';
import '../utils/chord_transposer.dart';
import '../utils/chord_simplifier.dart';
import '../utils/auto_scroller.dart';
import '../utils/clipboard_utils.dart';
import '../utils/string_normalization.dart';
import '../widgets/chords_lyrics_display.dart';
import '../widgets/common/app_image.dart';
import '../widgets/song_options_popup.dart';
import '../widgets/song_edit_options_popup.dart';
import 'edit_lyrics_page.dart';
import 'song_statistics_page.dart';
import '../l10n/app_localizations.dart';

class SongPage extends ConsumerStatefulWidget {
  final Song songData;
  const SongPage({super.key, required this.songData});

  @override
  ConsumerState<SongPage> createState() => _SongPageState();
}

class _SongPageState extends ConsumerState<SongPage> {
  late Song songData;
  late String displayedLyrics;
  bool isTransposing = false;
  double _scale = 1.0;
  double _baseScale = 1.0;
  final ScrollController _scrollController = ScrollController();
  late final AutoScroller autoScroller;

  Timer? _timeOnPageTimer;
  bool _playMarked = false;

  final GlobalKey _statisticsDividerKey = GlobalKey();

  bool _isFromOnlineSearch = false;
  bool _songIsSavedInDb = false;

  String _cleanTitle(String? title) {
    return (title ?? "").replaceAll(RegExp(r'\(version \d+\)'), '').trim();
  }

  @override
  void initState() {
    super.initState();
    songData = widget.songData;
    _isFromOnlineSearch = songData.savedDate == null;
    _checkIfSaved();

    autoScroller = AutoScroller(scrollController: _scrollController);
    _applyAllTransformations();

    _scrollController.addListener(_onScroll);
    _timeOnPageTimer = Timer(const Duration(seconds: 15), () {
      if (mounted && _songIsSavedInDb) {
        _checkPlayConditions();
      }
    });
  }

  void _checkIfSaved() async {
    final saved =
        await ref.read(databaseServiceProvider).isSongSaved(songData.songUrl);
    if (mounted) {
      setState(() {
        _songIsSavedInDb = saved;
      });
    }
  }

  Future<void> _toggleSave() async {
    final isNowSaved =
        await ref.read(databaseServiceProvider).toggleSong(songData.toMap());
    if (mounted) {
      setState(() {
        _songIsSavedInDb = isNowSaved;
      });
      if (isNowSaved) {
        final isar = ref.read(isarProvider);
        final freshSong = await isar.songs.getBySongUrl(songData.songUrl);
        if (freshSong != null) {
          setState(() {
            songData = freshSong;
          });
        }
      }
    }
  }

  void _onScroll() {
    if (_isStatisticsDividerVisible() && _songIsSavedInDb) {
      _checkPlayConditions();
    }
  }

  bool _isStatisticsDividerVisible() {
    final context = _statisticsDividerKey.currentContext;
    if (context == null) return false;
    final RenderObject? object = context.findRenderObject();
    if (object == null || !object.attached) return false;
    final RenderBox box = object as RenderBox;
    final Offset position = box.localToGlobal(Offset.zero);
    return position.dy < MediaQuery.of(context).size.height;
  }

  void _checkPlayConditions() {
    if (!_playMarked) {
      _markAsPlayed();
      if (mounted) {
        setState(() {
          _playMarked = true;
        });
      }
    }
  }

  Future<void> _markAsPlayed() async {
    await ref
        .read(databaseServiceProvider)
        .incrementPlayCount(songData.songUrl);
    if (mounted) {
      setState(() {
        songData.playCount++;
        songData.lastPlayed = DateTime.now();
      });
    }
  }

  @override
  void dispose() {
    _timeOnPageTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    autoScroller.stop();
    _scrollController.dispose();
    super.dispose();
  }

  void _applyAllTransformations() {
    String processedLyrics = songData.lyricsWithChords ?? "";
    if (songData.transpose != 0) {
      processedLyrics = ChordTransposer.transposeLyricsWithChords(
          processedLyrics, songData.transpose);
    }
    if (songData.simplified) {
      processedLyrics = simplifyChordsInText(processedLyrics);
    }
    if (mounted) {
      setState(() {
        displayedLyrics = processedLyrics;
      });
    }
  }

  void transposeChords(int semitones) {
    setState(() {
      songData.transpose += semitones;
      if (songData.transpose >= 12 || songData.transpose <= -12) {
        songData.transpose = 0;
      }
    });

    _applyAllTransformations();
    if (_songIsSavedInDb) {
      ref.read(databaseServiceProvider).updateSong(songData);
    }
  }

  void resetTranspose() {
    setState(() {
      songData.transpose = 0;
    });
    _applyAllTransformations();
    if (_songIsSavedInDb) {
      ref.read(databaseServiceProvider).updateSong(songData);
    }
  }

  void toggleSimplify() {
    setState(() {
      songData.simplified = !songData.simplified;
    });
    _applyAllTransformations();
    if (_songIsSavedInDb) {
      ref.read(databaseServiceProvider).updateSong(songData);
    }
  }

  void _handleLyricsUpdated(Song updatedSong) {
    setState(() {
      songData = updatedSong;
      _applyAllTransformations();
    });
    ref.read(databaseServiceProvider).updateSong(updatedSong);
  }

  Future<void> _handleEditButtonPress() async {
    final option = await showSongEditOptionsPopup(context);
    if (!mounted) return;
    if (option == 'metadata') {
      await showEditMetadataDialog(context, ref, songData);
    } else if (option == 'lyrics') {
      final result = await Navigator.push<Song>(
        context,
        MaterialPageRoute(
          builder: (context) => EditLyricsPage(
            songData: songData,
            onLyricsUpdated: _handleLyricsUpdated,
          ),
        ),
      );
      if (result != null) {
        _handleLyricsUpdated(result);
      }
    }
  }

  Widget _buildToolButtons() {
    List<Widget> buttons = [
      IconButton(
        icon: const Icon(Icons.download, color: Colors.black, size: 20),
        onPressed: () async {
          await PdfExportService.exportSongToPdf(
            title:
                songData.title ?? AppLocalizations.of(context)!.commonUntitled,
            artist: songData.artist ??
                AppLocalizations.of(context)!.commonUnknownArtist,
            difficulty: songData.difficulty ?? "",
            capo: songData.capo ?? "",
            tuning: songData.tuning ?? "",
            lyricsWithChords: displayedLyrics,
          );
        },
      ),
      IconButton(
        icon: const Icon(Icons.link, color: Colors.black, size: 20),
        onPressed: () {
          ClipboardUtils.copyLinkToClipboard(songData.songUrl);
        },
      ),
      IconButton(
        icon: Icon(
          Icons.elderly,
          color: songData.simplified ? Colors.red : Colors.black,
          size: 20,
        ),
        onPressed: toggleSimplify,
      ),
    ];

    if (!_isFromOnlineSearch || (_isFromOnlineSearch && _songIsSavedInDb)) {
      buttons.insert(
        1,
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.black, size: 20),
          onPressed: _handleEditButtonPress,
        ),
      );
    }

    return Row(children: buttons);
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle =
        GoogleFonts.cormorant(fontSize: 24, fontWeight: FontWeight.bold);
    final artistStyle = GoogleFonts.cormorant(fontSize: 20);
    final dynamicTitleStyle =
        getDynamicTextStyle(_cleanTitle(songData.title), titleStyle);
    final dynamicArtistStyle =
        getDynamicTextStyle(songData.artist ?? "", artistStyle);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (autoScroller.isScrolling &&
                notification is UserScrollNotification) {
              autoScroller.stop();
            }
            return false;
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _cleanTitle(songData.title),
                            style: dynamicTitleStyle,
                          ),
                          Text(songData.artist ?? "",
                              style: dynamicArtistStyle),
                        ],
                      ),
                    ),
                    if (_isFromOnlineSearch)
                      IconButton(
                        icon: Icon(
                          _songIsSavedInDb
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.red,
                        ),
                        onPressed: _toggleSave,
                      ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  "${AppLocalizations.of(context)!.songDifficulty}: ${songData.difficulty ?? ""}",
                  style: GoogleFonts.cormorant(fontSize: 14),
                ),
                Text(
                  "${AppLocalizations.of(context)!.songCapo}: ${songData.capo ?? ""}",
                  style: GoogleFonts.cormorant(fontSize: 14),
                ),
                Text(
                  "${AppLocalizations.of(context)!.songTuning}: ${songData.tuning ?? ""}",
                  style: GoogleFonts.cormorant(fontSize: 14),
                ),
                const SizedBox(height: 20),
                const Divider(),
                GestureDetector(
                  onDoubleTap: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (!isTransposing)
                        _buildToolButtons()
                      else
                        Row(
                          children: [
                            _TransposeHoldButton(
                              icon: Icons.remove,
                              onPressStart: () => autoScroller.stop(),
                              onStep: () => transposeChords(-1),
                            ),
                            Text('${songData.transpose}',
                                style: const TextStyle(fontSize: 15)),
                            _TransposeHoldButton(
                              icon: Icons.add,
                              onPressStart: () => autoScroller.stop(),
                              onStep: () => transposeChords(1),
                            ),
                            IconButton(
                              icon: const Icon(Icons.restart_alt,
                                  color: Colors.black, size: 20),
                              onPressed: resetTranspose,
                            ),
                            IconButton(
                              icon: const Icon(Icons.close,
                                  color: Colors.black, size: 20),
                              onPressed: () =>
                                  setState(() => isTransposing = false),
                            ),
                          ],
                        ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                        ),
                        onPressed: () {
                          setState(() {
                            isTransposing = !isTransposing;
                          });
                        },
                        child: Text(
                          AppLocalizations.of(context)!.songTranspose,
                          style: GoogleFonts.cormorant(
                            fontSize: 16,
                            color: songData.transpose != 0
                                ? Colors.red
                                : Colors.black,
                            fontWeight: songData.transpose != 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onDoubleTap: () => autoScroller.toggle(),
                  onScaleStart: (details) {
                    _baseScale = _scale;
                  },
                  onScaleUpdate: (details) {
                    setState(() {
                      _scale = (_baseScale * details.scale).clamp(0.5, 3.0);
                    });
                  },
                  child: ChordLyricsDisplay(
                    key: ValueKey(songData.transpose),
                    text: displayedLyrics,
                    chordStyle: TextStyle(
                      fontFamily: 'UbuntuMono',
                      fontSize: 16 * _scale,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    lyricStyle: TextStyle(
                      fontFamily: 'UbuntuMono',
                      fontSize: 16 * _scale,
                      color: Colors.black,
                    ),
                  ),
                ),
                if (_songIsSavedInDb) ...[
                  const SizedBox(height: 40),
                  Divider(key: _statisticsDividerKey, thickness: 2),
                  const SizedBox(height: 20),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SongStatisticsPage(songData: songData),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          AppImage(
                            url: songData.coverUrl,
                            width: 50,
                            height: 50,
                            borderRadius: 10,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.songViewStats,
                              style: GoogleFonts.cormorant(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: Colors.black, size: 24),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TransposeHoldButton extends StatefulWidget {
  const _TransposeHoldButton({
    required this.icon,
    required this.onStep,
    this.onPressStart,
  });

  final IconData icon;
  final VoidCallback onStep;
  final VoidCallback? onPressStart;

  static const Duration _holdDelay = Duration(milliseconds: 220);
  static const Duration _repeatInterval = Duration(milliseconds: 130);

  @override
  State<_TransposeHoldButton> createState() => _TransposeHoldButtonState();
}

class _TransposeHoldButtonState extends State<_TransposeHoldButton> {
  Timer? _holdDelayTimer;
  Timer? _repeatTimer;
  bool _holdTriggered = false;

  @override
  void dispose() {
    _clearTimers();
    super.dispose();
  }

  void _handleTap() {
    if (_holdTriggered) {
      _holdTriggered = false;
      return;
    }
    widget.onPressStart?.call();
    widget.onStep();
  }

  void _handleTapDown(TapDownDetails details) {
    _holdDelayTimer?.cancel();
    _repeatTimer?.cancel();
    widget.onPressStart?.call();
    _holdDelayTimer = Timer(_TransposeHoldButton._holdDelay, () {
      _holdTriggered = true;
      widget.onStep();
      _repeatTimer = Timer.periodic(_TransposeHoldButton._repeatInterval, (_) {
        widget.onStep();
      });
    });
  }

  void _handleTapUp(TapUpDetails details) {
    _clearTimers(preserveHoldFlag: true);
  }

  void _handleTapCancel() {
    _clearTimers();
    _holdTriggered = false;
  }

  void _clearTimers({bool preserveHoldFlag = false}) {
    _holdDelayTimer?.cancel();
    _repeatTimer?.cancel();
    _holdDelayTimer = null;
    _repeatTimer = null;
    if (!preserveHoldFlag) {
      _holdTriggered = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _handleTap,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            widget.icon,
            color: Colors.black,
            size: 20,
          ),
        ),
      ),
    );
  }
}

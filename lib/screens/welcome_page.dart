// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../l10n/app_localizations.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _showContent = false;
  bool _isExiting = false;

  static const String coverJeff =
      "https://upload.wikimedia.org/wikipedia/en/3/30/Jeff_Buckley_-_Grace.jpg";
  static const String coverQueen =
      "https://upload.wikimedia.org/wikipedia/en/4/4d/Queen_A_Night_At_The_Opera.png";
  static const String coverOasis =
      "https://upload.wikimedia.org/wikipedia/en/b/b1/Oasis_-_(What's_the_Story)_Morning_Glory_album_cover.jpg";
  static const String coverCabrel =
      "https://upload.wikimedia.org/wikipedia/en/5/5e/Francis_Cabrel_-_Samedi_Soir_Sur_La_Terre_-_album_cover.jpg";
  static const String coverBeatles =
      "https://upload.wikimedia.org/wikipedia/en/2/25/LetItBe.jpg";

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showContent = true;
        });
      }
    });
  }

  Future<void> _completeWelcome() async {
    if (mounted) {
      setState(() {
        _isExiting = true;
      });
    }

    await Future.delayed(const Duration(milliseconds: 800));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_welcome', true);

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _skipToLastPage() {
    _pageController.animateToPage(
      4,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLastPage = _currentPage == 4;
    final Color backgroundColor = isLastPage ? Colors.black : Colors.white;

    final bool isVisible = _showContent && !_isExiting;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: backgroundColor,
        child: SafeArea(
          bottom: false,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutQuad,
            opacity: isVisible ? 1.0 : 0.0,
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutQuad,
              padding: isVisible
                  ? EdgeInsets.zero
                  : (_isExiting
                      ? const EdgeInsets.only(bottom: 20)
                      : const EdgeInsets.only(top: 20)),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (!isLastPage)
                          TextButton(
                            onPressed: _skipToLastPage,
                            child: Text(
                              AppLocalizations.of(context)!.welcomePass,
                              style: GoogleFonts.ubuntuMono(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) =>
                          setState(() => _currentPage = index),
                      children: [
                        _buildSlide(
                          index: 0,
                          title:
                              AppLocalizations.of(context)!.welcomeSlide1Title,
                          subtitle: AppLocalizations.of(context)!
                              .welcomeSlide1Subtitle,
                          content: MockHomeScreen(
                            covers: const [
                              coverJeff,
                              coverCabrel,
                              coverOasis,
                              coverBeatles
                            ],
                          ),
                        ),
                        _buildSlide(
                          index: 1,
                          title:
                              AppLocalizations.of(context)!.welcomeSlide2Title,
                          subtitle: AppLocalizations.of(context)!
                              .welcomeSlide2Subtitle,
                          content: const MockSearchScreen(coverUrl: coverQueen),
                        ),
                        _buildSlide(
                          index: 2,
                          title:
                              AppLocalizations.of(context)!.welcomeSlide3Title,
                          subtitle: AppLocalizations.of(context)!
                              .welcomeSlide3Subtitle,
                          content: const MockSongScreen(),
                        ),
                        _buildSlide(
                          index: 3,
                          title:
                              AppLocalizations.of(context)!.welcomeSlide4Title,
                          subtitle: AppLocalizations.of(context)!
                              .welcomeSlide4Subtitle,
                          content: const MockStatsScreen(coverUrl: coverJeff),
                        ),
                        _buildFinalSlide(),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(30, 20, 30, 50),
                    color: backgroundColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(right: 8),
                              height: 6,
                              width: _currentPage == index ? 24 : 6,
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? Colors.red
                                    : (isLastPage
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          }),
                        ),
                        InkWell(
                          onTap: () {
                            if (isLastPage) {
                              _completeWelcome();
                            } else {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeOutQuart,
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(30),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: isLastPage
                                  ? [
                                      BoxShadow(
                                          color:
                                              Colors.red.withValues(alpha: 0.4),
                                          blurRadius: 15)
                                    ]
                                  : [],
                            ),
                            child: Row(
                              children: [
                                Text(
                                  isLastPage
                                      ? AppLocalizations.of(context)!
                                          .welcomeStart
                                      : AppLocalizations.of(context)!
                                          .welcomeNext,
                                  style: GoogleFonts.ubuntuMono(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  isLastPage
                                      ? Icons.rocket_launch
                                      : Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlide({
    required int index,
    required String title,
    required String subtitle,
    required Widget content,
  }) {
    final bool isActive = _currentPage == index && _showContent && !_isExiting;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedOpacity(
                opacity: isActive ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                child: Text(
                  title,
                  style: GoogleFonts.cormorant(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AnimatedOpacity(
                opacity: isActive ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
                child: Text(
                  subtitle,
                  style: GoogleFonts.ubuntuMono(
                    fontSize: 15,
                    height: 1.4,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Expanded(
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutQuart,
            padding: isActive
                ? const EdgeInsets.symmetric(horizontal: 40)
                : const EdgeInsets.only(left: 40, right: 40, top: 50),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade200, width: 4),
              ),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: content,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinalSlide() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(AppLocalizations.of(context)!.welcomeFinalGreeting,
                    style: GoogleFonts.cormorant(
                        fontSize: 30, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text("C",
                    style: GoogleFonts.cormorant(
                        fontSize: 60,
                        color: Colors.red,
                        fontWeight: FontWeight.bold)),
                Text("hords",
                    style: GoogleFonts.cormorant(
                        fontSize: 60,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 30),
            Container(height: 1, width: 60, color: Colors.red),
            const SizedBox(height: 30),
            Text(
              AppLocalizations.of(context)!.welcomeFinalSubtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.ubuntuMono(
                fontSize: 16,
                color: Colors.grey.shade400,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MockHomeScreen extends StatefulWidget {
  final List<String> covers;
  const MockHomeScreen({super.key, required this.covers});

  @override
  State<MockHomeScreen> createState() => _MockHomeScreenState();
}

class _MockHomeScreenState extends State<MockHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Map<String, String>> songs;

  @override
  void initState() {
    super.initState();
    songs = [
      {"t": "Hallelujah", "a": "Jeff Buckley", "img": widget.covers[0]},
      {
        "t": "Je l'aime à mourir",
        "a": "Francis Cabrel",
        "img": widget.covers[1]
      },
      {"t": "Wonderwall", "a": "Oasis", "img": widget.covers[2]},
      {"t": "Let It Be", "a": "The Beatles", "img": widget.covers[3]},
      {"t": "Perfect", "a": "Ed Sheeran", "img": ""},
    ];

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text("C",
                  style:
                      GoogleFonts.cormorant(fontSize: 40, color: Colors.red)),
              Text("hords",
                  style:
                      GoogleFonts.cormorant(fontSize: 40, color: Colors.black)),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Divider(color: Colors.black, height: 1),
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _buildPill("Artistes", true),
              const SizedBox(width: 8),
              _buildPill("Playlists", false),
              const SizedBox(width: 8),
              _buildPill("Récents", false),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            physics: const BouncingScrollPhysics(),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _controller,
                  curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
                )),
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                          parent: _controller,
                          curve: Interval(index * 0.1, 1.0,
                              curve: Curves.easeOut))),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: songs[index]["img"]!.isNotEmpty
                              ? Image.network(
                                  songs[index]["img"]!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey.shade300,
                                      child: const Icon(Icons.music_note,
                                          color: Colors.grey)),
                                )
                              : Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.music_note,
                                      color: Colors.grey)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(songs[index]["t"]!,
                                  style: GoogleFonts.cormorant(
                                      fontSize: 20,
                                      color: Colors.red,
                                      fontWeight: FontWeight.normal),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1),
                              Text(songs[index]["a"]!,
                                  style: GoogleFonts.cormorant(
                                      fontSize: 16, color: Colors.black)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPill(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFFEE0E0) : Colors.white,
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: GoogleFonts.cormorant(
              fontSize: 12,
              color: Colors.black,
              fontWeight: active ? FontWeight.bold : FontWeight.normal)),
    );
  }
}

class MockSearchScreen extends StatelessWidget {
  final String coverUrl;
  const MockSearchScreen({super.key, required this.coverUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: Text('Résultats pour "Queen"',
              style: GoogleFonts.cormorant(
                  color: Colors.black, fontWeight: FontWeight.normal)),
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          automaticallyImplyLeading: false,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
            physics: const BouncingScrollPhysics(),
            children: [
              _buildExpandedGroup("Bohemian Rhapsody", "Queen", coverUrl),
              _buildCollapsedGroup("Don't Stop Me Now", "Queen", 1),
              _buildCollapsedGroup("Love of My Life", "Queen", 2),
              _buildCollapsedGroup("We Will Rock You", "Queen", 3),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildExpandedGroup(String title, String artist, String imgUrl) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    imgUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                        width: 50, height: 50, color: Colors.grey.shade200),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontFamily: 'Cormorant',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red)),
                      Text(artist,
                          style: TextStyle(
                              fontFamily: 'Cormorant',
                              fontSize: 16,
                              color: Colors.grey.shade700)),
                    ],
                  ),
                ),
                const Icon(Icons.expand_less, color: Colors.black),
              ],
            ),
          ),
          _buildVersionRow("Version 1 - Chords", "4.9 (5214 avis)", true),
          _buildVersionRow("Version 2 - Chords", "4.5 (800 avis)", false),
          _buildVersionRow("Version 3 - Tab", "4.2 (120 avis)", false),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildVersionRow(String title, String note, bool isBest) {
    return Material(
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(title,
                  style:
                      const TextStyle(fontFamily: 'Cormorant', fontSize: 16)),
            ),
            Row(
              children: [
                if (isBest)
                  const Icon(Icons.emoji_events,
                      color: Color(0xFFD4AF37), size: 16),
                if (isBest) const SizedBox(width: 8),
                Text(note,
                    style: TextStyle(
                        fontFamily: 'Cormorant',
                        fontSize: 14,
                        color: Colors.grey.shade800)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsedGroup(String title, String artist, int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (delay * 200)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)), child: child),
        );
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8),
        color: Colors.white,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.music_note, color: Colors.grey),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontFamily: 'Cormorant',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red)),
                    Text(artist,
                        style: TextStyle(
                            fontFamily: 'Cormorant',
                            fontSize: 16,
                            color: Colors.grey.shade700)),
                  ],
                ),
              ),
              const Icon(Icons.expand_more, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }
}

class MockSongScreen extends StatelessWidget {
  const MockSongScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hallelujah",
                    style: GoogleFonts.cormorant(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                Text("Jeff Buckley",
                    style: GoogleFonts.cormorant(
                        fontSize: 22, color: Colors.black)),
              ],
            ),
            const Icon(Icons.favorite, color: Colors.red),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text("Difficulté: Novice",
                style: GoogleFonts.cormorant(fontSize: 14)),
            const SizedBox(width: 15),
            Text("Capo: 5", style: GoogleFonts.cormorant(fontSize: 14)),
          ],
        ),
        const SizedBox(height: 15),
        const Divider(thickness: 1),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.download, size: 20),
                SizedBox(width: 15),
                Icon(Icons.link, size: 20),
                SizedBox(width: 15),
                Icon(Icons.elderly, size: 20),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  const Icon(Icons.remove, size: 16),
                  const SizedBox(width: 8),
                  const Text("+0",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  const Icon(Icons.add, size: 16),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        RichText(
          text: TextSpan(
            style: GoogleFonts.ubuntuMono(
                fontSize: 16, color: Colors.black, height: 1.5),
            children: const [
              TextSpan(
                  text: "G               Em\n",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black)),
              TextSpan(text: "I heard there was a secret chord\n"),
              TextSpan(
                  text: "G                   Em\n",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black)),
              TextSpan(text: "That David played and it pleased the Lord\n"),
              TextSpan(
                  text: "    C                D             G        D\n",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black)),
              TextSpan(
                  text: "But you don't really care for music, do you?\n\n"),
              TextSpan(
                  text: "[Chorus]\n",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              TextSpan(
                  text: "C           D           Em\n",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black)),
              TextSpan(text: "Hallelujah, Hallelujah\n"),
            ],
          ),
        ),
        const SizedBox(height: 50),
      ],
    );
  }
}

class MockStatsScreen extends StatelessWidget {
  final String coverUrl;
  const MockStatsScreen({super.key, required this.coverUrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5))
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                coverUrl,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.music_note, size: 50)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text("Hallelujah",
              style: GoogleFonts.cormorant(
                  fontSize: 26, fontWeight: FontWeight.bold)),
          Text("Jeff Buckley",
              style: GoogleFonts.cormorant(
                  fontSize: 18, color: Colors.grey.shade700)),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _stat("Joué", "84", "fois"),
              _stat("Dernier", "Auj.", "10:24"),
            ],
          ),
          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 10),
          Align(
              alignment: Alignment.centerLeft,
              child: Text("Activité",
                  style: GoogleFonts.cormorant(
                      fontSize: 20, fontWeight: FontWeight.bold))),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                double targetHeight =
                    [20.0, 35.0, 15.0, 45.0, 25.0, 50.0, 10.0][index];
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: targetHeight),
                  duration: Duration(milliseconds: 800 + (index * 100)),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 20,
                          height: value,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF0000), Color(0xFFFF8C00)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(["L", "M", "M", "J", "V", "S", "D"][index],
                            style: const TextStyle(fontSize: 10)),
                      ],
                    );
                  },
                );
              }),
            ),
          )
        ],
      ),
    );
  }

  Widget _stat(String label, String val, String sub) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.cormorant(fontSize: 16)),
        Text(val,
            style: GoogleFonts.ubuntuMono(
                fontSize: 32, fontWeight: FontWeight.bold, color: Colors.red)),
        Text(sub, style: GoogleFonts.cormorant(fontSize: 14)),
      ],
    );
  }
}

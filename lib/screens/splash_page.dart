// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class SplashPage extends StatefulWidget {
  final Widget nextScreen;

  const SplashPage({super.key, required this.nextScreen});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _lineWidth;
  late Animation<double> _subtitleOpacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );

    _textSlide =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic),
      ),
    );

    _lineWidth = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.7, curve: Curves.easeInOutQuart),
      ),
    );

    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    widget.nextScreen,
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 700),
              ),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isFr = loc?.localeName == 'fr';
    final subtitleText = isFr ? "par φ" : "by φ";

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FadeTransition(
                opacity: _textOpacity,
                child: SlideTransition(
                  position: _textSlide,
                  child: AnimatedBuilder(
                    animation: _lineWidth,
                    builder: (context, child) {
                      return CustomPaint(
                        foregroundPainter: _ChordsLogoPainter(_lineWidth.value),
                        child: child,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: const [
                          Text(
                            "C",
                            style: TextStyle(
                              fontFamily: 'Cormorant',
                              fontSize: 50,
                              color: Colors.red,
                              height: 1.0,
                            ),
                          ),
                          Text(
                            "hords",
                            style: TextStyle(
                              fontFamily: 'Cormorant',
                              fontSize: 50,
                              color: Colors.black,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              FadeTransition(
                opacity: _subtitleOpacity,
                child: Text(
                  subtitleText,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'LibertinusSerif',
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade500,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChordsLogoPainter extends CustomPainter {
  final double lineProgress;

  _ChordsLogoPainter(this.lineProgress);

  @override
  void paint(Canvas canvas, Size size) {
    if (lineProgress > 0) {
      final paint = Paint()
        ..color = Colors.black
        ..strokeWidth = 1.0;

      final double y = size.height - 0.5;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width * lineProgress, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ChordsLogoPainter oldDelegate) {
    return oldDelegate.lineProgress != lineProgress;
  }
}

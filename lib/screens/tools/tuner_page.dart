// Copyright (C) 2026 phi-k
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';

import '../../models/bottom_bar_model.dart';
import '../../l10n/app_localizations.dart';

class TunerPage extends StatefulWidget {
  const TunerPage({super.key});

  @override
  State<TunerPage> createState() => _TunerPageState();
}

class _TunerPageState extends State<TunerPage>
    with SingleTickerProviderStateMixin {
  FlutterAudioCapture _audioCapture = FlutterAudioCapture();
  PitchDetector? _pitchDetector;
  int _detectorBufferSize = 0;
  bool _initialized = false;

  final List<String> _noteStrings = const [
    'C',
    'C#',
    'D',
    'D#',
    'E',
    'F',
    'F#',
    'G',
    'G#',
    'A',
    'A#',
    'B',
  ];

  bool _isListening = false;
  String _note = '-';
  String _status = 'play_string';
  double _frequency = 0.0;
  double _targetDiff = 0.0;

  late AnimationController _needleController;
  double _animatedDiff = 0.0;

  @override
  void initState() {
    super.initState();
    _needleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() {
        setState(() {
          _animatedDiff = _needleTween.evaluate(_needleController);
        });
      });
    _checkPermissionAndStart();
  }

  Tween<double> _needleTween = Tween(begin: 0.0, end: 0.0);

  void _animateNeedleTo(double target) {
    _needleTween = Tween(begin: _animatedDiff, end: target);
    _needleController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _needleController.dispose();
    _stopCapture();
    super.dispose();
  }

  Future<void> _checkPermissionAndStart() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      await _startCapture();
    } else if (mounted) {
      BottomBarModel.showBottomBar(
        message: AppLocalizations.of(context)!.tunerMicPermission,
      );
    }
  }

  Future<void> _startCapture() async {
    try {
      if (!_initialized) {
        await _audioCapture.init();
        _initialized = true;
      }
      await _audioCapture.start(
        _listener,
        _onError,
        sampleRate: 44100,
        bufferSize: 3000,
      );
      if (!mounted) return;
      setState(() => _isListening = true);
    } catch (e) {
      debugPrint("Erreur accordeur start: $e");
    }
  }

  Future<void> _stopCapture() async {
    try {
      await _audioCapture.stop();
      _audioCapture = FlutterAudioCapture();
      _initialized = false;
      if (!mounted) return;
      setState(() {
        _isListening = false;
        _frequency = 0.0;
        _note = '-';
        _status = 'mic_off';
        _targetDiff = 0.0;
      });
      _animateNeedleTo(0.0);
    } catch (e) {
      debugPrint("Erreur accordeur stop: $e");
    }
  }

  Future<void> _toggleMic() async {
    if (_isListening) {
      await _stopCapture();
    } else {
      await _checkPermissionAndStart();
    }
  }

  void _listener(Float32List obj) async {
    final List<double> audioSample = obj.map((e) => e.toDouble()).toList();
    if (audioSample.length < 256) return;

    if (_pitchDetector == null || _detectorBufferSize != audioSample.length) {
      _detectorBufferSize = audioSample.length;
      _pitchDetector = PitchDetector(
        audioSampleRate: 44100,
        bufferSize: _detectorBufferSize,
      );
    }

    final result = await _pitchDetector!.getPitchFromFloatBuffer(audioSample);

    if (!result.pitched || result.pitch <= 60 || result.pitch >= 1000) return;

    final double pitch = result.pitch;
    final double noteNum = 12 * (math.log(pitch / 440) / math.log(2)) + 69;
    final int nearestNote = noteNum.round();
    final double diff = noteNum - nearestNote;
    final int noteIndex = nearestNote % 12;
    final String noteName = _noteStrings[noteIndex];

    String status;
    if (diff.abs() < 0.1) {
      status = 'tuned';
    } else if (diff < 0) {
      status = 'too_low';
    } else {
      status = 'too_high';
    }

    if (!mounted) return;

    final double clampedDiff = diff.clamp(-1.0, 1.0);
    _animateNeedleTo(clampedDiff);

    setState(() {
      _note = noteName;
      _frequency = pitch;
      _targetDiff = clampedDiff;
      _status = status;
    });
  }

  void _onError(Object e) {
    debugPrint("Erreur audio capture: $e");
  }

  String _localizedStatus(AppLocalizations loc) {
    switch (_status) {
      case 'tuned':
        return loc.tunerTuned;
      case 'too_low':
        return loc.tunerTooLow;
      case 'too_high':
        return loc.tunerTooHigh;
      case 'mic_off':
        return loc.tunerMicOff;
      case 'play_string':
        return loc.tunerPlayString;
      default:
        return _status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final bool isPerfect = _targetDiff.abs() < 0.1 && _frequency > 0;
    final Color activeColor = isPerfect ? const Color(0xFF4CAF50) : Colors.red;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          loc.tunerTitle,
          style: const TextStyle(
            fontFamily: 'Cormorant',
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                !_isListening
                    ? loc.tunerMicOff
                    : _frequency > 0
                        ? _localizedStatus(loc)
                        : loc.tunerListening,
                key: ValueKey(_isListening
                    ? (_frequency > 0 ? _status : 'listening')
                    : 'off'),
                style: TextStyle(
                  fontFamily: 'Cormorant',
                  fontSize: 20,
                  color: isPerfect
                      ? const Color(0xFF4CAF50)
                      : Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 40),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                _note,
                key: ValueKey(_note),
                style: TextStyle(
                  fontFamily: 'Cormorant',
                  fontSize: 120,
                  fontWeight: FontWeight.bold,
                  color: _frequency > 0 ? Colors.black : Colors.grey.shade300,
                  height: 1.0,
                ),
              ),
            ),
            Text(
              _frequency > 0 ? '${_frequency.toStringAsFixed(1)} Hz' : '—',
              style: TextStyle(
                fontFamily: 'UbuntuMono',
                fontSize: 18,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50),
            SizedBox(
              height: 130,
              width: 280,
              child: CustomPaint(
                painter: TunerGaugePainter(
                  diff: _animatedDiff,
                  isActive: _frequency > 0 && _isListening,
                  activeColor: activeColor,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _toggleMic,
                borderRadius: BorderRadius.circular(40),
                splashColor: _isListening
                    ? Colors.red.withValues(alpha: 0.15)
                    : Colors.green.withValues(alpha: 0.15),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: _isListening
                        ? Colors.red.withValues(alpha: 0.08)
                        : Colors.grey.withValues(alpha: 0.08),
                    border: Border.all(
                      color: _isListening
                          ? Colors.red.withValues(alpha: 0.3)
                          : Colors.grey.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          _isListening ? Icons.mic : Icons.mic_off,
                          key: ValueKey(_isListening),
                          color: _isListening ? Colors.red : Colors.grey,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 10),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          _isListening
                              ? loc.tunerMuteBtn
                              : loc.tunerActivateBtn,
                          key: ValueKey(_isListening),
                          style: TextStyle(
                            fontFamily: 'Cormorant',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _isListening
                                ? Colors.red
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TunerGaugePainter extends CustomPainter {
  final double diff;
  final bool isActive;
  final Color activeColor;

  TunerGaugePainter({
    required this.diff,
    required this.isActive,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height);
    final double radius = size.width / 2;

    final Paint paintArc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = Colors.grey.shade300;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      paintArc,
    );

    _drawTick(
      canvas,
      center,
      radius,
      -math.pi / 2,
      15,
      4,
      Colors.black,
    );
    _drawTick(
      canvas,
      center,
      radius,
      -math.pi / 2 - 0.5,
      10,
      2,
      Colors.grey.shade400,
    );
    _drawTick(
      canvas,
      center,
      radius,
      -math.pi / 2 + 0.5,
      10,
      2,
      Colors.grey.shade400,
    );

    if (!isActive) return;

    final double needleAngle = -math.pi / 2 + (diff * 0.8);

    final Paint paintNeedle = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = activeColor
      ..strokeCap = StrokeCap.round;

    final Offset needleEnd = Offset(
      center.dx + (radius - 10) * math.cos(needleAngle),
      center.dy + (radius - 10) * math.sin(needleAngle),
    );
    canvas.drawLine(center, needleEnd, paintNeedle);

    canvas.drawCircle(center, 8, Paint()..color = activeColor);
  }

  void _drawTick(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
    double length,
    double width,
    Color color,
  ) {
    final Offset outer = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
    final Offset inner = Offset(
      center.dx + (radius - length) * math.cos(angle),
      center.dy + (radius - length) * math.sin(angle),
    );
    canvas.drawLine(
      inner,
      outer,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..color = color
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant TunerGaugePainter oldDelegate) {
    return oldDelegate.diff != diff ||
        oldDelegate.isActive != isActive ||
        oldDelegate.activeColor != activeColor;
  }
}

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';

class MetronomePage extends StatefulWidget {
  const MetronomePage({super.key});

  @override
  State<MetronomePage> createState() => _MetronomePageState();
}

class _MetronomePageState extends State<MetronomePage>
    with SingleTickerProviderStateMixin {
  int _bpm = 100;
  int _beatsPerBar = 4;
  bool _isPlaying = false;

  int _currentBeat = 0;
  Timer? _timer;

  final AudioPlayer _player = AudioPlayer();
  final String _highClickPath = 'sounds/click_high.wav';
  final String _lowClickPath = 'sounds/click_low.wav';

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _player.setPlayerMode(PlayerMode.lowLatency);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _stop();
    _player.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_isPlaying) {
      _stop();
    } else {
      _start();
    }
  }

  void _start() {
    setState(() {
      _isPlaying = true;
      _currentBeat = 0;
    });
    _tick();

    final interval = Duration(milliseconds: (60000 / _bpm).round());

    _timer = Timer.periodic(interval, (timer) {
      _tick();
    });
  }

  void _stop() {
    _timer?.cancel();
    setState(() {
      _isPlaying = false;
      _currentBeat = 0;
    });
  }

  Future<void> _tick() async {
    final bool isFirstBeat = _currentBeat == 0;
    try {
      await _player.stop();
      await _player
          .play(AssetSource(isFirstBeat ? _highClickPath : _lowClickPath));
    } catch (e) {
      debugPrint("Erreur audio (vérifiez les assets) : $e");
    }

    HapticFeedback.lightImpact();

    _animationController.forward(from: 0.0);

    setState(() {
      _currentBeat = (_currentBeat + 1) % _beatsPerBar;
    });
  }

  void _changeBpm(int delta) {
    int newBpm = (_bpm + delta).clamp(30, 300);
    if (newBpm != _bpm) {
      setState(() => _bpm = newBpm);
      if (_isPlaying) {
        _stop();
        _start();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.metronomeTitle,
          style: const TextStyle(
            fontFamily: 'Cormorant',
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_beatsPerBar, (index) {
              int activeIndex = (_currentBeat - 1);
              if (activeIndex < 0) activeIndex = _beatsPerBar - 1;
              if (!_isPlaying) activeIndex = -1;

              final bool isActive = index == activeIndex;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? (index == 0 ? Colors.red : Colors.black)
                      : Colors.grey.shade300,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: (index == 0 ? Colors.red : Colors.black)
                                .withValues(alpha: 0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ]
                      : [],
                ),
              );
            }),
          ),
          const SizedBox(height: 50),
          Text(
            "$_bpm",
            style: const TextStyle(
              fontFamily: 'Cormorant',
              fontSize: 120,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 1.0,
            ),
          ),
          const Text(
            "BPM",
            style: TextStyle(
              fontFamily: 'UbuntuMono',
              fontSize: 20,
              color: Colors.grey,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.red,
                inactiveTrackColor: Colors.grey.shade200,
                thumbColor: Colors.white,
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 12, elevation: 3),
                overlayColor: Colors.red.withValues(alpha: 0.1),
              ),
              child: Slider(
                value: _bpm.toDouble(),
                min: 30,
                max: 300,
                onChanged: (val) {
                  setState(() => _bpm = val.round());
                },
                onChangeEnd: (val) {
                  if (_isPlaying) {
                    _stop();
                    _start();
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAdjustButton(Icons.remove, () => _changeBpm(-1)),
              const SizedBox(width: 30),
              _buildAdjustButton(Icons.add, () => _changeBpm(1)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [2, 3, 4, 6].map((sig) {
                final isSelected = _beatsPerBar == sig;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _beatsPerBar = sig;
                      if (_isPlaying) {
                        _stop();
                        _start();
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? Colors.white : Colors.transparent,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                              )
                            ]
                          : [],
                    ),
                    child: Text(
                      "$sig",
                      style: TextStyle(
                        fontFamily: 'UbuntuMono',
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: _togglePlay,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isPlaying ? Colors.grey.shade100 : Colors.red,
                boxShadow: [
                  BoxShadow(
                    color: (_isPlaying ? Colors.grey : Colors.red)
                        .withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
                border: _isPlaying
                    ? Border.all(color: Colors.grey.shade300, width: 2)
                    : null,
              ),
              child: Icon(
                _isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                color: _isPlaying ? Colors.black : Colors.white,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildAdjustButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, color: Colors.black),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vibration/vibration.dart';

import '../../models/note.dart';
import '../../storage/note_repo.dart';
import '../../theme/motion.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';
import '../../utils/lunar.dart';
import '../note/note_page.dart';
import 'pin.dart';
import 'realm_painter.dart';
import 'sky.dart';
import 'weather.dart';

/// The home screen. A living kingdom of mountains and seas.
class RealmPage extends StatefulWidget {
  final NoteRepo repo;
  const RealmPage({super.key, required this.repo});

  @override
  State<RealmPage> createState() => _RealmPageState();
}

class _RealmPageState extends State<RealmPage> {
  StreamSubscription<AccelerometerEvent>? _accelSub;
  double _tiltX = 0;
  double _tiltY = 0;
  Timer? _clockTick;
  DateTime _now = DateTime.now();
  String? _focusedId;

  /// Particle/shader fidelity knob — currently fixed; expose in settings later.
  final double _quality = 1.0;

  @override
  void initState() {
    super.initState();
    _accelSub = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 33),
    ).listen((e) {
      setState(() {
        _tiltX = (_tiltX * 0.85) + (-e.x / 9.81) * 0.15;
        _tiltY = (_tiltY * 0.85) + (e.y / 9.81) * 0.15;
      });
    });

    _clockTick = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    _clockTick?.cancel();
    super.dispose();
  }

  Future<void> _openNote(Note? note) async {
    setState(() => _focusedId = note?.id);
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 8, amplitude: 80);
    }
    if (!mounted) return;
    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        transitionDuration: Motion.med,
        pageBuilder: (_, __, ___) =>
            NotePage(repo: widget.repo, initial: note),
        transitionsBuilder: (_, anim, __, child) {
          final t = CurvedAnimation(parent: anim, curve: Motion.unfurl);
          return FadeTransition(
            opacity: t,
            child: ScaleTransition(
              scale: Tween(begin: 0.92, end: 1.0).animate(t),
              child: child,
            ),
          );
        },
      ),
    );
    if (mounted) setState(() => _focusedId = null);
  }

  Future<void> _archive(Note n) async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [0, 12, 40, 18], intensities: [0, 70, 0, 90]);
    }
    await widget.repo.archive(n.id);
  }

  @override
  Widget build(BuildContext context) {
    final notes = widget.repo.all;
    return Scaffold(
      backgroundColor: Palette.xuanZhi,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Sky
          Sky(now: _now),
          // 2. Clouds, petals, koi, fireflies
          Weather(now: _now, quality: _quality),
          // 3. Mountains + sea + reeds
          CustomPaint(
            painter: RealmPainter(
              parallaxX: _tiltX,
              parallaxY: _tiltY,
            ),
            size: Size.infinite,
          ),
          // 4. Pins
          LayoutBuilder(builder: (_, c) {
            return Stack(
              children: [
                for (final n in notes)
                  Positioned(
                    left: n.mapX * c.maxWidth - 65,
                    top: n.mapY * c.maxHeight - 75,
                    child: RealmPin(
                      note: n,
                      focused: _focusedId == n.id,
                      onTap: () => _openNote(n),
                      onLongPress: () => _archive(n),
                    ),
                  ),
              ],
            );
          }),
          // 5. Top chrome — realm name + lore for focused pin
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  children: [
                    Text(widget.repo.realmName,
                        style: AppType.brush(
                            size: 44, color: Palette.moHei, letter: 8)),
                    const SizedBox(height: 4),
                    Text(_subtitle(),
                        style: AppType.sans(
                            size: 12, color: Palette.danMo.withOpacity(0.8))),
                  ],
                ),
              ),
            ),
          ),
          // 6. Brush button to compose
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: _BrushButton(onTap: () => _openNote(null)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _subtitle() {
    final n = widget.repo.all.length;
    final band = SkyBand.now(_now).band;
    final timeWord = switch (band) {
      0 => '黎明 · dawn',
      1 => '白昼 · day',
      2 => '黄昏 · dusk',
      _ => '夜 · night',
    };
    return '$n notes · $timeWord';
  }
}

class _BrushButton extends StatefulWidget {
  final VoidCallback onTap;
  const _BrushButton({required this.onTap});

  @override
  State<_BrushButton> createState() => _BrushButtonState();
}

class _BrushButtonState extends State<_BrushButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl =
      AnimationController(vsync: this, duration: Motion.fast);

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctl.forward(),
      onTapUp: (_) {
        _ctl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctl.reverse(),
      child: AnimatedBuilder(
        animation: _ctl,
        builder: (_, __) => Transform.scale(
          scale: 1 - _ctl.value * 0.12,
          child: Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Palette.zhuSha,
              boxShadow: [
                BoxShadow(
                  color: Palette.zhuSha.withOpacity(0.5),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
                BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 6)),
              ],
            ),
            child: Center(
              child: Text('笔',
                  style: AppType.brush(
                      size: 32, color: Palette.yueBai, letter: 0)),
            ),
          ),
        ),
      ),
    );
  }
}


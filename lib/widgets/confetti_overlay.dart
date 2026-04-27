import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../core/constants/app_colors.dart';

/// Full-screen confetti overlay for celebration moments
class ConfettiOverlay extends StatefulWidget {
  final Widget child;
  final bool isPlaying;

  const ConfettiOverlay({
    super.key,
    required this.child,
    this.isPlaying = false,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> {
  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 4));
    if (widget.isPlaying) _controller.play();
  }

  @override
  void didUpdateWidget(ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _controller.play();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Center confetti burst
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _controller,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              AppColors.kidPrimary,
              AppColors.kidSecondary,
              AppColors.kidAccent,
              AppColors.kidCoral,
              AppColors.kidGreen,
              AppColors.kidPink,
            ],
            numberOfParticles: 40,
            gravity: 0.3,
            emissionFrequency: 0.08,
            maxBlastForce: 25,
            minBlastForce: 15,
          ),
        ),
      ],
    );
  }
}

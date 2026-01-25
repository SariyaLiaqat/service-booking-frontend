import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class BubbleTap extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const BubbleTap({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  State<BubbleTap> createState() => _BubbleTapState();
}

class _BubbleTapState extends State<BubbleTap> {
  double _scale = 1.0;
  final AudioPlayer _player = AudioPlayer();

  Future<void> _handleTap() async {
    // 🔊 Soft bubble sound
    _player.play(AssetSource('sounds/bubble.mp3'));

    // 🫧 Bubble animation
    setState(() => _scale = 1.08);
    await Future.delayed(const Duration(milliseconds: 120));
    if (mounted) setState(() => _scale = 1.0);

    widget.onTap();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutBack, // premium bubbly curve
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: widget.child,
      ),
    );
  }
}




// 🌟 OPTIONAL NEXT UPGRADES

// If you want later:

// ✨ Glow ring on tap

// 🍏 Haptic feedback (iOS feel)

// 🔕 Sound ON/OFF toggle in settings

// 🎨 Gradient cards on active state
import 'package:flutter/material.dart';
//import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../helpers/coolors.dart';

class AnimatedAIChatButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Color buttonColor;

  const AnimatedAIChatButton({
    Key? key,
    required this.onPressed,
    this.buttonColor = kPrimaryColor,
  }) : super(key: key);

  @override
  _AnimatedAIChatButtonState createState() => _AnimatedAIChatButtonState();
}

class _AnimatedAIChatButtonState extends State<AnimatedAIChatButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FloatingActionButton(
        onPressed: widget.onPressed,
        backgroundColor: widget.buttonColor,
        elevation: 8,
        highlightElevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
  Icons.auto_awesome,  
  size: 30,
  color: buttonText,
),

      ),
    );
  }
}

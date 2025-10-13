import 'package:flutter/material.dart';
import 'dart:async';
import '../helpers/my_colors.dart';
import 'package:servicebookingapp/screens/signup.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Animation controller for pulsing circle
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Navigate to SignupScreen after 3 seconds with smooth slide + fade
   Timer(Duration(seconds: 6), () {
  Navigator.of(context).pushReplacement(PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SignupScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Smooth curve
      var curve = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
      
      // Slide from bottom
      final slideTween = Tween<Offset>(begin: Offset(0, 0.2), end: Offset.zero);
      
      return FadeTransition(
        opacity: curve,
        child: SlideTransition(
          position: slideTween.animate(curve),
          child: child,
        ),
      );
    },
    transitionDuration: Duration(milliseconds: 700), // thoda lamba smooth effect
  ));
});

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background,
      body: Stack(
        children: [
          // Animated glowing circle at bottom-left
          Positioned(
            bottom: -100,
            left: -100,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  width: 250 * _animation.value,
                  height: 250 * _animation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        MyColors.secondary.withOpacity(0.6 * _animation.value),
                        Colors.transparent
                      ],
                      radius: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: MyColors.secondary.withOpacity(0.6 * _animation.value),
                        blurRadius: 100,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Logo and texts at top
          Padding(
            padding: const EdgeInsets.only(top: 100), // top padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/bglogo.png',
                    width: 160,
                    height: 160,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Connect Pro',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: MyColors.primary,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Your service simplified',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

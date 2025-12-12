


// import 'dart:async';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'dart:ui';

// class ClockAndDayBox extends StatefulWidget {
//   const ClockAndDayBox({super.key});

//   @override
//   State<ClockAndDayBox> createState() => _ClockAndDayBoxState();
// }

// class _ClockAndDayBoxState extends State<ClockAndDayBox> {
//   late Timer _timer;
//   late Timer _quoteTimer;
//   DateTime _currentTime = DateTime.now();
//   bool _showQuote = false;
//   final Random _random = Random();

//   final List<String> _quotes = [
//     "Service with a smile 😄",
//     "We fix, you chill 🛠️",
//     "Task done, stress gone ✨",
//     "Help is just a click away 🖱️",
//     "Your wish, our job 📝",
//     "We hustle, you relax 🛋️",
//     "Done and dusted ✅",
//     "Call us, we got this 📞",
//     "Your problem, our solution 🔧",
//     "Fast service, zero drama ⚡",
//   ];

//   String _currentQuote = "";

//   @override
//   void initState() {
//     super.initState();

//     _timer = Timer.periodic(const Duration(seconds: 1), (_) {
//       if (mounted) {
//         setState(() {
//           _currentTime = DateTime.now();
//         });
//       }
//     });

//     _quoteTimer = Timer.periodic(const Duration(seconds: 5), (_) {
//       if (mounted) {
//         setState(() {
//           _showQuote = !_showQuote;
//           if (_showQuote) {
//             _currentQuote = _quotes[_random.nextInt(_quotes.length)];
//           }
//         });
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     _quoteTimer.cancel();
//     super.dispose();
//   }

//  Widget _glassContainer({
//   required Widget child,
//   required Color backgroundColor,
//   double radius = 16,
// }) {
//   return ClipRRect(
//     borderRadius: BorderRadius.circular(radius),
//     child: BackdropFilter(
//       filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//       child: Container(
//         decoration: BoxDecoration(
//           color: backgroundColor.withOpacity(0.6), // slightly more opaque
//           borderRadius: BorderRadius.circular(radius),
//           border: Border.all(
//             color: Colors.black.withOpacity(0.2), // stronger border
//             width: 1.5,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.15),
//               blurRadius: 6,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: child,
//       ),
//     ),
//   );
// }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: Row(
//         children: [
//           // --- Clock Box (Pastel Purple) ---
//           _glassContainer(
//             backgroundColor: Color(0xFFF8D7DA),
//             radius: 16,
//             child: Container(
//               width: 100,
//               height: 100,
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.access_time, color: Colors.black, size: 28),
//                   const SizedBox(height: 6),
//                   FittedBox(
//                     fit: BoxFit.scaleDown,
//                     child: Text(
//   "${_currentTime.hour.toString().padLeft(2,'0')}:${_currentTime.minute.toString().padLeft(2,'0')}:${_currentTime.second.toString().padLeft(2,'0')}",
//   style: const TextStyle(
//     fontWeight: FontWeight.bold,
//     fontSize: 18,
//     color: Colors.black, // strong color
//     shadows: [
//       Shadow(
//         color: Colors.black12, // subtle shadow for readability
//         blurRadius: 2,
//         offset: Offset(0, 1),
//       ),
//     ],
//   ),
// ),

//                   ),
//                 ],
//               ),
//             ),
//           ),

//           const SizedBox(width: 12),

//           // --- Day / Quote Box (Pastel Yellow) ---
//           Expanded(
//             child: _glassContainer(
//               backgroundColor: Color(0xFFCCE5FF),
//               radius: 16,
//               child: Container(
//                 height: 100,
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Icon(Icons.today, color: Colors.black, size: 28),
//                     const SizedBox(height: 6),
//                     AnimatedSwitcher(
//                       duration: const Duration(milliseconds: 700),
//                       transitionBuilder: (child, animation) {
//                         final offsetAnimation = Tween<Offset>(
//                           begin: const Offset(0, 0.3),
//                           end: Offset.zero,
//                         ).animate(animation);
//                         return SlideTransition(
//                           position: offsetAnimation,
//                           child: FadeTransition(opacity: animation, child: child),
//                         );
//                       },
//                       child: FittedBox(
//                         key: ValueKey<bool>(_showQuote),
//                         fit: BoxFit.scaleDown,
//                         child: Text(
//                           _showQuote
//                               ? _currentQuote
//                               : [
//                                   "Sunday",
//                                   "Monday",
//                                   "Tuesday",
//                                   "Wednesday",
//                                   "Thursday",
//                                   "Friday",
//                                   "Saturday"
//                                 ][DateTime.now().weekday % 7],
//                           textAlign: TextAlign.center,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                             color: Colors.black,
//                             shadows: [
//                               Shadow(
//                                 color: Colors.black26,
//                                 blurRadius: 2,
//                                 offset: Offset(0, 1),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }












import 'dart:async';
import 'dart:math';
import '../helpers/coolors.dart';
import 'package:flutter/material.dart';

class ClockAndDayBox extends StatefulWidget {
  const ClockAndDayBox({super.key});

  @override
  State<ClockAndDayBox> createState() => _ClockAndDayBoxState();
}

class _ClockAndDayBoxState extends State<ClockAndDayBox> {
  late Timer _timer;
  late Timer _quoteTimer;
  DateTime _currentTime = DateTime.now();
  bool _showQuote = false;
  final Random _random = Random();

  final List<String> _quotes = [
    "Service with a smile 😄",
    "We fix, you chill 🛠️",
    "Task done, stress gone ✨",
    "Help is just a click away 🖱️",
    "Your wish, our job 📝",
    "We hustle, you relax 🛋️",
    "Done and dusted ✅",
    "Call us, we got this 📞",
    "Your problem, our solution 🔧",
    "Fast service, zero drama ⚡",
  ];

  String _currentQuote = "";

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });

    _quoteTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        setState(() {
          _showQuote = !_showQuote;
          if (_showQuote) {
            _currentQuote = _quotes[_random.nextInt(_quotes.length)];
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _quoteTimer.cancel();
    super.dispose();
  }

  // --- Card Container with TaskCards style shadow ---
  Widget _cardContainer({required Widget child, double radius = 20}) {
    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // --- Clock Box ---
          _cardContainer(
            radius: 16,
            child: SizedBox(
              width: 100,
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.access_time, color: kPrimaryColor, size: 28),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "${_currentTime.hour.toString().padLeft(2,'0')}:${_currentTime.minute.toString().padLeft(2,'0')}:${_currentTime.second.toString().padLeft(2,'0')}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: kSecondaryColor,
                        shadows: [
                          Shadow(
                            color: Colors.black12,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // --- Day / Quote Box ---
          Expanded(
            child: _cardContainer(
              radius: 16,
              child: SizedBox(
                height: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.today, color: kPrimaryColor, size: 28),
                    const SizedBox(height: 6),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 700),
                      transitionBuilder: (child, animation) {
                        final offsetAnimation = Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(animation);
                        return SlideTransition(
                          position: offsetAnimation,
                          child: FadeTransition(opacity: animation, child: child),
                        );
                      },
                      child: FittedBox(
                        key: ValueKey<bool>(_showQuote),
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _showQuote
                              ? _currentQuote
                              : [
                                  "Sunday",
                                  "Monday",
                                  "Tuesday",
                                  "Wednesday",
                                  "Thursday",
                                  "Friday",
                                  "Saturday"
                                ][DateTime.now().weekday % 7],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: kSecondaryColor,
                          ),
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
    );
  }
}

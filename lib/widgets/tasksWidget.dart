// import 'dart:async';
// import 'dart:math';
// import '../helpers/coolors.dart';
// import 'package:flutter/material.dart';

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
//       if (mounted) setState(() => _currentTime = DateTime.now());
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

//   // --- Card Container with TaskCards style shadow ---
//   Widget _cardContainer({required Widget child, double radius = 20}) {
//     return Container(
//       decoration: BoxDecoration(
//         color: kCardColor,
//         borderRadius: BorderRadius.circular(radius),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: Row(
//         children: [
//           // --- Clock Box ---
//           _cardContainer(
//             radius: 16,
//             child: SizedBox(
//               width: 100,
//               height: 100,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.access_time, color: kPrimaryColor, size: 28),
//                   const SizedBox(height: 6),
//                   FittedBox(
//                     fit: BoxFit.scaleDown,
//                     child: Text(
//                       "${_currentTime.hour.toString().padLeft(2,'0')}:${_currentTime.minute.toString().padLeft(2,'0')}:${_currentTime.second.toString().padLeft(2,'0')}",
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 12,
//                         color: kSecondaryColor,
//                         shadows: [
//                           Shadow(
//                             color: Colors.black12,
//                             blurRadius: 2,
//                             offset: Offset(0, 1),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           const SizedBox(width: 12),

//           // --- Day / Quote Box ---
//           Expanded(
//             child: _cardContainer(
//               radius: 16,
//               child: SizedBox(
//                 height: 100,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Icon(Icons.today, color: kPrimaryColor, size: 28),
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
//                             fontSize: 12,
//                             color: kSecondaryColor,
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
import 'package:intl/intl.dart';

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
    "Relax, we're on it! ☕",
    "Problem? What problem? 🪄",
    "Consider it done.🎤",
    "Stress less, we do the rest 💆‍♂️",
    "Your hero has arrived 🦸‍♀️",
    "Making magic ✨",
    "We work, you nap. 😴",
    "Solving lives 🖱️🔥",
    "Zero drama, fast service ⚡️",
    "Task killed. Dance! 💃",
    "Now go be awesome 🚀",
    "Poof! Task gone 🎩✨",
    "We fix it, you flex it 💪",
    "Helping like a pro 💼"
  ];

  String _currentQuote = "";

  @override
  void initState() {
    super.initState();
    _currentQuote = _quotes[_random.nextInt(_quotes.length)];
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: IntrinsicHeight( // Ensures both boxes are exactly the same height
        child: Row(
          children: [
            // --- Clock Box (The Data Side) ---
            Expanded(
              flex: 4,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryColor.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox( // Prevents Overflow
                      child: Text(
                        DateFormat('hh:mm a').format(_currentTime),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22, // Reduced from 28 to look cleaner
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat('EEE, MMM d').format(_currentTime),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 10),

            // --- Quote/Day Box (The Personality Side) ---
            Expanded(
              flex: 6,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kCardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kDividerColor.withOpacity(0.5)),
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Column(
                      key: ValueKey<bool>(_showQuote),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _showQuote ? Icons.tips_and_updates_rounded : Icons.wb_sunny_rounded,
                          color: kSecondaryColor,
                          size: 18,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _showQuote 
                              ? _currentQuote 
                              : "Happy ${DateFormat('EEEE').format(_currentTime)}!",
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: kTextPrimary,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
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
// import 'dart:async';
// import 'package:flutter/material.dart';

// class ConfirmedTasksSection extends StatefulWidget {
//   const ConfirmedTasksSection({super.key});

//   @override
//   State<ConfirmedTasksSection> createState() => _ConfirmedTasksSectionState();
// }

// class _ConfirmedTasksSectionState extends State<ConfirmedTasksSection> {
//   int _currentIndex = 0;
//   late PageController _pageController;
//   Timer? _timer;

//   final List<String> images = [
//     "one",
//     "two",
//     "three",
//     "four",
//     "five",
//     "six",
//     "seven",
//     "eight",
//     "nine",
//     "ten",
//     "eleven",
//     "twelve",
//     "thirteen",
//     "fourteen",
//     "fifteen",
//     "sixteen",
//     "seventeen",
//     "eighteen",
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();

//     _timer = Timer.periodic(const Duration(seconds: 5), (_) {
//       if (_pageController.hasClients) {
//         _currentIndex = (_currentIndex + 1) % images.length;
//         _pageController.animateToPage(
//           _currentIndex,
//           duration: const Duration(milliseconds: 600),
//           curve: Curves.easeInOut,
//         );
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       height: 200, // Box ki height, adjust as needed
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       decoration: BoxDecoration(
//         color: Colors.purple.shade600, // Box ka background
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.15),
//             offset: const Offset(0, 4),
//             blurRadius: 8,
//           ),
//         ],
//       ),
//       clipBehavior: Clip.hardEdge, // Images ko border ke bahar na jaane de
//       child: PageView(
//         controller: _pageController,
//         physics: const NeverScrollableScrollPhysics(),
//         children: images
//             .map(
//               (img) => Image.asset(
//                 "assets/images/$img.png",
//                 fit: BoxFit.cover, // Box ke andar poori tarah fill kare
//                 width: double.infinity,
//                 height: double.infinity,
//               ),
//             )
//             .toList(),
//       ),
//     );
//   }
// }


/////////////////////////////

// import 'dart:async';
// import 'package:flutter/material.dart';

// class ConfirmedTasksSection extends StatefulWidget {
  
//   const ConfirmedTasksSection({super.key});

//   @override
//   State<ConfirmedTasksSection> createState() => _ConfirmedTasksSectionState();
// }

// class _ConfirmedTasksSectionState extends State<ConfirmedTasksSection>
//     with SingleTickerProviderStateMixin {
//   int _currentIndex = 0;
//   late PageController _pageController;
//   Timer? _timer;

//   bool showWelcome = true;

//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

//   final List<String> images = [
//     "one",
//     "two",
//     "three",
//     "four",
//     "five",
//     "six",
//     "seven",
//     "eight",
//     "nine",
//     "ten",
//     "eleven",
//     "twelve",
//     "thirteen",
//     "fourteen",
//     "fifteen",
//     "sixteen",
//     "seventeen",
//     "eighteen",
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();

//     _animationController =
//         AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
//     _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
//         CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
//     _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
//         .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

//     // 4 sec welcome delay
//     Timer(const Duration(seconds: 4), () {
//       setState(() {
//         showWelcome = false;
//       });
//       _animationController.forward();
//     });

//     // Carousel timer
//     _timer = Timer.periodic(const Duration(seconds: 5), (_) {
//       if (_pageController.hasClients) {
//         _currentIndex = (_currentIndex + 1) % images.length;
//         _pageController.animateToPage(
//           _currentIndex,
//           duration: const Duration(milliseconds: 600),
//           curve: Curves.easeInOut,
//         );
//       }
//     });
//   }

//   String getGreeting() {
//     final hour = DateTime.now().hour;
//     if (hour < 12) return "Good Morning ☀️";
//     if (hour < 17) return "Good Noon 🌤️";
//     return "Good Night 🌙";
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _pageController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       height: 220,
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       decoration: BoxDecoration(
//         color: showWelcome ? const Color(0xFFFFF3CD) : Color(0xFFFFF3CD),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.15),
//             offset: const Offset(0, 4),
//             blurRadius: 8,
//           ),
//         ],
//       ),
//       clipBehavior: Clip.hardEdge,
//       child: Stack(
//         children: [
//           // Carousel with animation
//           if (!showWelcome)
//             FadeTransition(
//               opacity: _fadeAnimation,
//               child: SlideTransition(
//                 position: _slideAnimation,
//                 child: PageView(
//                   controller: _pageController,
//                   physics: const NeverScrollableScrollPhysics(),
//                   children: images
//                       .map(
//                         (img) => Image.asset(
//                           "assets/images/$img.png",
//                           fit: BoxFit.cover, // poora card fill ho
//                           width: double.infinity,
//                           height: double.infinity,
//                         ),
//                       )
//                       .toList(),
//                 ),
//               ),
//             ),

//           // Welcome section
//           if (showWelcome)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: Row(
//                 children: [
//                   // Bigger profile picture
//                   CircleAvatar(
//                     radius: 40,
//                     backgroundColor: Colors.grey.shade300,
//                     child: const Icon(Icons.person, size: 40, color: Colors.white),
//                   ),
//                   const SizedBox(width: 16),
//                   // Welcome text
//                   Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Welcome, Username",
//                         style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       Text(
//                         getGreeting(),
//                         style: const TextStyle(
//                           fontSize: 18,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }














import 'dart:async';
import 'package:flutter/material.dart';
import '../helpers/coolors.dart';
import '../helpers/backend.dart';
class ConfirmedTasksSection extends StatefulWidget {
    final Map<String, dynamic> currentUser;
  const ConfirmedTasksSection({super.key, required this.currentUser});

  @override
  State<ConfirmedTasksSection> createState() => _ConfirmedTasksSectionState();
}

class _ConfirmedTasksSectionState extends State<ConfirmedTasksSection>
    with SingleTickerProviderStateMixin {
       late final user = widget.currentUser;
  int _currentIndex = 0;
  late PageController _pageController;
  Timer? _timer;

  bool showWelcome = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> images = [
    "one",
    "two",
    "three",
    "four",
    "five",
    "six",
    "seven",
    "eight",
    "nine",
    "ten",
    "eleven",
    "twelve",
    "thirteen",
    "fourteen",
    "fifteen",
    "sixteen",
    "seventeen",
    "eighteen",
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    // 4 sec welcome delay
    Timer(const Duration(seconds: 4), () {
      setState(() {
        showWelcome = false;
      });
      _animationController.forward();
    });

    // Carousel timer
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_pageController.hasClients) {
        _currentIndex = (_currentIndex + 1) % images.length;
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning ☀️";
    if (hour < 17) return "Good Noon 🌤️";
    return "Good Night 🌙";
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: showWelcome ?  kCardColor : kCardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Carousel with animation
          if (!showWelcome)
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: images
                      .map(
                        (img) => Image.asset(
                          "assets/images/$img.png",
                          fit: BoxFit.cover, // poora card fill ho
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),

          // Welcome section
          if (showWelcome)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  // Bigger profile picture
                 CircleAvatar(
  radius: 40,
  backgroundColor: Colors.grey.shade300,
  backgroundImage: user['profile_image'] != null
      ? NetworkImage("${Backend.baseUrl}/${user['profile_image']}")
      : null,
  child: user['profile_image'] == null
      ? Icon(Icons.person, size: 40, color: Colors.white)
      : null,
),

                  const SizedBox(width: 16),
                  // Welcome text
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                     Text(
  "Welcome, ${user['username']}",
  style: const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  ),
),

                      const SizedBox(height: 6),
                      Text(
                        getGreeting(),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}



// import '../helpers/coolors.dart';
// import 'package:flutter/material.dart';
// import '../widgets/bubble_tap.dart'; // 👈 import

// class TaskCardsWidget extends StatefulWidget {
//   final int toDo;
//   final int inProgress;
//   final int inReview;
//   final int completed;

//   const TaskCardsWidget({
//     super.key,
//     required this.toDo,
//     required this.inProgress,
//     required this.inReview,
//     required this.completed,
//   });

//   @override
//   State<TaskCardsWidget> createState() => _TaskCardsWidgetState();
// }

// class _TaskCardsWidgetState extends State<TaskCardsWidget> {
//   int? _pressedIndex;

//   BoxDecoration _cardDecoration() {
//     return BoxDecoration(
//       color: kCardColor,
//       borderRadius: BorderRadius.circular(20),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.05),
//           blurRadius: 8,
//           offset: const Offset(0, 4),
//         ),
//       ],
//     );
//   }

// Widget _buildTaskCard({
//   required int index,
//   required IconData icon,
//   required String title,
//   required int value,
//   required VoidCallback onTap,
// }) {
//   final bool isPressed = _pressedIndex == index;

//   return GestureDetector(
//     behavior: HitTestBehavior.translucent,
//     onTapDown: (_) => setState(() => _pressedIndex = index),
//     onTapUp: (_) => setState(() => _pressedIndex = null),
//     onTapCancel: () => setState(() => _pressedIndex = null),
//     child: BubbleTap(
//       onTap: onTap, // 🔊 sound still works
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 150),
//         width: 80,
//         height: 120,
//         padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//         decoration: _cardDecoration().copyWith(
//           boxShadow: [
//             BoxShadow(
//               color: isPressed
//                   ? kPrimaryColor.withValues(alpha: 0.6)
//                   : Colors.black.withValues(alpha: 0.05),
//               blurRadius: isPressed ? 14 : 8,
//               spreadRadius: isPressed ? 2 : 1,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Icon(icon, size: 28, color: kPrimaryColor),
//             Text(
//               title,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black.withValues(alpha: 0.75),
//               ),
//             ),
//             Column(
//               children: [
//                 Text(
//                   "$value",
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w900,
//                     color: kSecondaryColor,
//                   ),
//                 ),
//                 const Text(
//                   "tasks",
//                   style: TextStyle(
//                     fontSize: 8,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.black54,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }



//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         physics: const BouncingScrollPhysics(), // 👈 premium scroll feel
//         child: Row(
//           children: [
//             _buildTaskCard(
//                index: 0,
//               icon: Icons.assignment_outlined,
//               title: 'Total',
//               value: widget.toDo,
//               onTap: () {},
//             ),
//             const SizedBox(width: 12),
//             _buildTaskCard(
//                index: 1,
//               icon: Icons.hourglass_empty,
//               title: 'In Progress',
//               value: widget.inProgress,
//               onTap: () {},
//             ),
//             const SizedBox(width: 12),
//             _buildTaskCard(
//                index: 2,
//               icon: Icons.cancel_outlined,
//               title: 'Rejected',
//               value: widget.inReview,
//               onTap: () {},
//             ),
//             const SizedBox(width: 12),
//             _buildTaskCard(
//                index: 3,
//               icon: Icons.check_circle_outline,
//               title: 'Completed',
//               value: widget.completed,
//               onTap: () {},
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }










import '../helpers/coolors.dart';
import 'package:flutter/material.dart';
import '../widgets/bubble_tap.dart'; // 👈 import

class TaskCardsWidget extends StatefulWidget {
  final int toDo;
  final int inProgress;
  final int inReview;
  final int completed;

  const TaskCardsWidget({
    super.key,
    required this.toDo,
    required this.inProgress,
    required this.inReview,
    required this.completed,
  });

  @override
  State<TaskCardsWidget> createState() => _TaskCardsWidgetState();
}

class _TaskCardsWidgetState extends State<TaskCardsWidget> {
  int? _pressedIndex;

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: kCardColor,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

Widget _buildTaskCard({
  required int index,
  required IconData icon,
  required String title,
  required int value,
  required VoidCallback onTap,
 required Color bgColor,
}) {
  final bool isPressed = _pressedIndex == index;

  return GestureDetector(
    behavior: HitTestBehavior.translucent,
    onTapDown: (_) => setState(() => _pressedIndex = index),
    onTapUp: (_) => setState(() => _pressedIndex = null),
    onTapCancel: () => setState(() => _pressedIndex = null),
    child: BubbleTap(
      onTap: onTap, // 🔊 sound still works
     child: AnimatedContainer(
  duration: const Duration(milliseconds: 150),
  width: 80,
  height: 120,
  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
  decoration: _cardDecoration().copyWith(
    color: bgColor, // ✅ yahan bg color
    boxShadow: [
      BoxShadow(
        color: isPressed
            ? kPrimaryColor.withValues(alpha: 0.6)
            : Colors.black.withValues(alpha: 0.05),
        blurRadius: isPressed ? 14 : 8,
        spreadRadius: isPressed ? 2 : 1,
        offset: const Offset(0, 4),
      ),
    ],
  ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 28, color:  navbarTextColor),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color:  navbarTextColor,
              ),
            ),
            Column(
              children: [
                Text(
                  "$value",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color:  navbarTextColor,
                  ),
                ),
                const Text(
                  "tasks",
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                    color:  navbarTextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(), // 👈 premium scroll feel
        child: Row(
          children: [
            _buildTaskCard(
               index: 0,
              icon: Icons.assignment_outlined,
              title: 'Total',
              value: widget.toDo,
              bgColor: const Color(0xFF4CAF50),
              onTap: () {},
            ),
            const SizedBox(width: 12),
            _buildTaskCard(
               index: 1,
              icon: Icons.hourglass_empty,
              title: 'In Progress',
              value: widget.inProgress,
              bgColor: const Color(0xFF42A5F5),
              onTap: () {},
            ),
            const SizedBox(width: 12),
            _buildTaskCard(
               index: 2,
              icon: Icons.cancel_outlined,
              title: 'Rejected',
              value: widget.inReview,
              bgColor: const Color(0xFFFFA726),
              onTap: () {},
            ),
            const SizedBox(width: 12),
            _buildTaskCard(
               index: 3,
              icon: Icons.check_circle_outline,
              title: 'Completed',
              value: widget.completed,
              bgColor: const Color(0xFF9575CD),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

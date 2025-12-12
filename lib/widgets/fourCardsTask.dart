
// import 'package:flutter/material.dart';

// class TaskCardsWidget extends StatelessWidget {
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

//   // --- Card Colors (Rao Sahb friendly soft palette) ---
//   static const Color softPurple = Color(0xFFD6C1F7); // Total / Rejected
//   static const Color softYellow = Color(0xFFF9E6A3); // In Progress
//   static const Color softPink = Color(0xFFF7C1E3); // Rejected / In Review
//   static const Color softGreen = Color(0xFF8FE9A1); // Complete

//   Widget _buildImageStyleTaskCard({
//     required String title,
//     required int value,
//     required Color cardColor,
//     required IconData icon,
//   }) {
//     final Color contentColor = Colors.black.withOpacity(0.75); // Softer text

//     return Expanded(
//       child: Container(
//         height: 120,
//         decoration: BoxDecoration(
//           color: cardColor,
//           borderRadius: BorderRadius.circular(30),
//         ),
//         padding: const EdgeInsets.all(16),
//         child: Stack(
//           children: [
//             Align(
//               alignment: Alignment.topLeft,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 8,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.5),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(icon, size: 18, color: contentColor),
//                     const SizedBox(width: 6),
//                     Text(
//                       title,
//                       style: TextStyle(
//                         color: contentColor,
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Align(
//               alignment: Alignment.bottomLeft,
//               child: Text(
//                 "$value tasks",
//                 style: const TextStyle(
//                   color: Colors.black,
//                   fontSize: 22,
//                   fontWeight: FontWeight.w900,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             child: Column(
//               children: [
//                 _buildImageStyleTaskCard(
//                   title: 'Total',
//                   value: toDo,
//                   cardColor: softPurple,
//                   icon: Icons.assignment_outlined,
//                 ),
//                 const SizedBox(height: 16),
//                 _buildImageStyleTaskCard(
//                   title: 'Rejected',
//                   value: inReview,
//                   cardColor: softPink,
//                   icon: Icons.search_outlined,
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               children: [
//                 _buildImageStyleTaskCard(
//                   title: 'In progress',
//                   value: inProgress,
//                   cardColor: softYellow,
//                   icon: Icons.hourglass_empty,
//                 ),
//                 const SizedBox(height: 16),
//                 _buildImageStyleTaskCard(
//                   title: 'Complete',
//                   value: completed,
//                   cardColor: softGreen,
//                   icon: Icons.check_circle_outline,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }












// import 'package:flutter/material.dart';

// class TaskCardsWidget extends StatelessWidget {
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

//   // Card colors
//   Color getCardColor(String status) {
//     switch (status) {
//       case "confirmed":
//         return const Color(0xFFD1E7DD); // Soft green
//       case "completed":
//         return const Color(0xFFCCE5FF); // Light blue
//       case "rejected":
//         return const Color(0xFFF8D7DA); // Soft pink
//       default:
//         return const Color(0xFFFFF3CD); // Soft yellow
//     }
//   }

//   Widget _buildTaskCard({
//     required IconData icon,
//     required String title,
//     required int value,
//     required Color cardColor,
//   }) {
//     return Container(
//       width: 80,
//       height: 120,
//       decoration: BoxDecoration(
//         color: cardColor,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Icon(icon, size: 28, color: Colors.black.withOpacity(0.75)),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 12, // smaller to fit
//               fontWeight: FontWeight.w600,
//               color: Colors.black.withOpacity(0.75),
//             ),
//             textAlign: TextAlign.center,
//           ),
//           Column(
//             children: [
//               Text(
//                 "$value",
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w900,
//                   color: Colors.black,
//                 ),
//               ),
//               const Text(
//                 "tasks",
//                 style: TextStyle(
//                   fontSize: 8, // tiny label
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black54,
//                 ),
//               )
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           children: [
//             _buildTaskCard(
//               icon: Icons.assignment_outlined,
//               title: 'Total',
//               value: toDo,
//               cardColor: getCardColor('pending'),
//             ),
//             const SizedBox(width: 12),
//             _buildTaskCard(
//               icon: Icons.hourglass_empty,
//               title: 'In Progress',
//               value: inProgress,
//               cardColor: getCardColor('confirmed'),
//             ),
//             const SizedBox(width: 12),
//             _buildTaskCard(
//               icon: Icons.cancel_outlined,
//               title: 'Rejected',
//               value: inReview,
//               cardColor: getCardColor('rejected'),
//             ),
//             const SizedBox(width: 12),
//             _buildTaskCard(
//               icon: Icons.check_circle_outline,
//               title: 'Complete',
//               value: completed,
//               cardColor: getCardColor('completed'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




import '../helpers/coolors.dart';
import 'package:flutter/material.dart';

class TaskCardsWidget extends StatelessWidget {
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
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: kCardColor,
      borderRadius: BorderRadius.circular(20),
      // border: Border.all(
      //   color: kPrimaryColor,
      //   width: 2,
      // ),
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
    required IconData icon,
    required String title,
    required int value,
  }) {
    return Container(
      width: 80,          // SAME SIZE as your original
      height: 120,        // SAME SIZE
      decoration: _cardDecoration(),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8), // SAME PADDING
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 28, color: kPrimaryColor),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.75),
            ),
            textAlign: TextAlign.center,
          ),
          Column(
            children: [
              Text(
                "$value",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: kSecondaryColor,
                ),
              ),
              const Text(
                "tasks",
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildTaskCard(
              icon: Icons.assignment_outlined,
              title: 'Total',
              value: toDo,
            ),
            const SizedBox(width: 12),
            _buildTaskCard(
              icon: Icons.hourglass_empty,
              title: 'In Progress',
              value: inProgress,
            ),
            const SizedBox(width: 12),
            _buildTaskCard(
              icon: Icons.cancel_outlined,
              title: 'Rejected',
              value: inReview,
            ),
            const SizedBox(width: 12),
            _buildTaskCard(
              icon: Icons.check_circle_outline,
              title: 'Completed',
              value: completed,
            ),
          ],
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import '../helpers/backend.dart';
// import '../models/action_buttons.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';

// import '../helpers/my_colors.dart';
// class ExternalProfileWidget extends StatefulWidget {
//   final Map<String, dynamic> userData;
//   final int currentUserId;

//   const ExternalProfileWidget({
//     super.key,
//     required this.userData,
//     required this.currentUserId,
//   });

//   @override
//   State<ExternalProfileWidget> createState() => _ExternalProfileWidgetState();
// }

// class _ExternalProfileWidgetState extends State<ExternalProfileWidget> {
//   double _userRating = 0;
//   double _averageRating = 0;
//   int _totalRatings = 0;
//   List<Map<String, dynamic>> _recentComments = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchRatings();
//   }

//   // Fetch provider ratings from backend
//   Future<void> fetchRatings() async {
//     final providerId = widget.userData['id'];
//     try {
//       final response = await Backend.get('/provider/$providerId/ratings');
//       if (response != null) {
//         setState(() {
//           _averageRating = (response['average_rating'] != null)
//               ? double.tryParse(response['average_rating'].toString()) ?? 0
//               : 0;

//           _totalRatings = response['total_ratings'] ?? 0;
//           _recentComments = List<Map<String, dynamic>>.from(
//             response['ratings'] ?? [],
//           );

//           // Sirf latest 2 reviews lo
//           if (_recentComments.length > 2) {
//             _recentComments = _recentComments.take(2).toList();
//           }

//           _isLoading = false;
//         });
//       } else {
//         setState(() => _isLoading = false);
//       }
//     } catch (e) {
//       // keep the error handling minimal (you can expand later)
//       debugPrint('Fetch ratings error: $e');
//       setState(() => _isLoading = false);
//     }
//   }

//   // Submit rating to backend (no comment field anymore)
//   Future<void> submitRating() async {
//     final providerId = widget.userData['id'];
//     final userId = widget.currentUserId;

//     if (_userRating == 0) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Please select a rating')));
//       return;
//     }

//     try {
//       final response = await Backend.post('/provider/$providerId/rate', {
//         'user_id': userId,
//         'rating': _userRating.toInt(),
//         // comment removed per request
//       });

//       if (response != null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Rating submitted successfully')),
//         );

//         // Reset local input
//         setState(() {
//           _userRating = 0;
//         });

//         // Refresh ratings from backend
//         await fetchRatings();
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to submit rating')),
//         );
//       }
//     } catch (e) {
//       debugPrint('Submit rating error: $e');
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Failed to submit rating')));
//     }
//   }

//   // --- Profile header (name, username, bio + actions row) ---
//   Widget _buildProfileHeader() {
//     final user = widget.userData;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           user['name'] ?? 'Unknown',
//           style: const TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             color: MyColors.textPrimary, // keep parent theme color for consistency
//           ),
//         ),
//         if (user['username'] != null)
//           Padding(
//             padding: const EdgeInsets.only(top: 4.0),
//             child: Text(
//               '@${user['username']}',
//               style: const TextStyle(fontSize: 14, color: MyColors.textSecondary,),
//             ),
//           ),
//         if (user['bio'] != null && (user['bio'] as String).isNotEmpty)
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 6.0),
//             child: Text(
//               user['bio'],
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontStyle: FontStyle.italic,
//                color: MyColors.textSecondary,
//               ),
//             ),
//           ),

//         // Actions row (buttons) right under the bio - using your ActionButtonsWidget
//         const SizedBox(height: 10),
//         _buildActionButtonsRow(),
//       ],
//     );
//   }

  
//   Widget _buildActionButtonsRow() {
//     final user = widget.userData;
//     // If ActionButtonsWidget itself contains multiple buttons (likely),
//     // just return it. Otherwise you can wrap multiple button widgets in a Row.
//     return Row(
//       children: [
//         // Expand to use available width and keep a clean row layout
//         Expanded(
//           child: ActionButtonsWidget(
//             providerId: user['id'] ?? 0,
//             providerName: user['name'] ?? 'Unknown',
//             phone: user['phone'] ?? '',
//             currentUserId: widget.currentUserId,
            
//             serviceData:
//                 (user['services'] != null &&
//                     (user['services'] as List).isNotEmpty)
//                 ? (user['services'][0] as Map<String, dynamic>)
//                 : null,
//           ),
//         ),
//       ],
//     );
//   }

//   // --- Ratings UI (no comment input) ---
//   // --- Replace your _buildRatingSection method with this ---
//   Widget _buildRatingSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Average rating row
//         Row(
//           children: [
//             RatingBarIndicator(
//               rating: _averageRating,
//               itemBuilder: (context, index) =>
//                   const Icon(Icons.star, color: Colors.amber),
//               itemCount: 5,
//               itemSize: 18,
//             ),
//             const SizedBox(width: 8),
//             Text(
//               '${_averageRating.toStringAsFixed(1)} ($_totalRatings)',
//               style: const TextStyle(fontSize: 13, color: MyColors.textPrimary),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),

//         const Text(
//           'Rate this provider',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.bold,
//            color: MyColors.textPrimary,
//           ),
//         ),
//         const SizedBox(height: 8),

//         // rating selector
//         RatingBar.builder(
//           initialRating: _userRating,
//           minRating: 1,
//           maxRating: 5,
//           allowHalfRating: false,
//           itemBuilder: (context, index) =>
//               const Icon(Icons.star, color: Colors.amber),
//               unratedColor: MyColors.textPrimary,
//           itemSize: 20,
//           onRatingUpdate: (rating) => setState(() => _userRating = rating),
//         ),
//         const SizedBox(height: 12),


//         // Submit Rating button
//         SizedBox(
//           width: double.infinity,
//           child: ElevatedButton(
//             onPressed: submitRating,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: MyColors.primary,
//               padding: const EdgeInsets.symmetric(vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: const Text(
//               'Submit Rating',
//               style: TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.bold,
//                 color:MyColors.textPrimary,
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 12),

//         // Add Comment Button
//         SizedBox(
//           width: double.infinity,
//           child: OutlinedButton(
//             onPressed: _showAddCommentDialog,
//             style: OutlinedButton.styleFrom(
//               side: const BorderSide(color:  MyColors.primary),
//               padding: const EdgeInsets.symmetric(vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: const Text(
//               'Add Comment',
//               style: TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.bold,
//                 color: MyColors.textPrimary,
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 18),
//       ],
//     );
//   }

//   // --- Recent reviews (keeps comments if backend returns them) ---
//   Future<void> _submitComment(String comment) async {
//   if (_userRating == 0 && comment.isEmpty) {
//   ScaffoldMessenger.of(context).showSnackBar(
//     const SnackBar(content: Text('Please provide a rating or comment')),
//   );
//   return;
// }
//   final providerId = widget.userData['id'];

//   try {
//     final response = await Backend.post('/provider/$providerId/rate', {
//       'user_id': widget.currentUserId,
//       'rating': _userRating > 0 ? _userRating.toInt() : null,
//       'comment': comment.isNotEmpty ? comment : null,
//     });
// debugPrint('POST response: $response');
// debugPrint('POST payload: userId=${widget.currentUserId}, rating=$_userRating, comment=$comment');

//     if (response != null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Comment submitted successfully')),
//       );
//       await fetchRatings(); // refresh recent comments
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to submit comment')),
//       );
//     }
//   } catch (e) {
//     debugPrint('Submit comment error: $e');
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Failed to submit comment')),
//     );
//   }
// }





//   // --- Modify _buildRecentComments method to make comment scrollable if long ---
//   Widget _buildRecentComments() {
//     if (_recentComments.isEmpty) return const SizedBox.shrink();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Recent Reviews',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: MyColors.textPrimary,
//           ),
//         ),
//         const SizedBox(height: 8),
//         ..._recentComments.map(
//           (r) => Card(
//             margin: const EdgeInsets.symmetric(vertical: 6),
//             color: MyColors.surface,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: ListTile(
//               title: Text(
//                 r['user_name'] ?? 'Anonymous',
//                 style: const TextStyle(fontWeight: FontWeight.bold,color: MyColors.textPrimary,),
//               ),
//               subtitle: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 6),
//                   RatingBarIndicator(
//                     rating: (r['rating'] ?? 0).toDouble(),
//                     itemBuilder: (context, index) =>
//                         const Icon(Icons.star, color: Colors.amber),
//                     itemCount: 5,
//                     itemSize: 14,
//                   ),
//                   if (r['comment'] != null &&
//                       (r['comment'] as String).isNotEmpty)
//                     Container(
//                       constraints: const BoxConstraints(maxHeight: 70),
//                       padding: const EdgeInsets.only(top: 6),
//                       child: SingleChildScrollView(
//                         child: Text(
//                           r['comment'],
//                           style: const TextStyle(
//                             fontSize: 13,
//                             color: MyColors.textSecondary,
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//               dense: true,
//             ),
//           ),
//         ),
//         const SizedBox(height: 12),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = widget.userData;

//     return _isLoading
//         ? const Center(
//             child: CircularProgressIndicator(color: MyColors.primary),
//           )
//         : SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildProfileHeader(),
//                 const SizedBox(height: 16),
//                 // Ratings and reviews only for provider role
//                 if (user['role'] == 'provider') _buildRatingSection(),
//                 if (user['role'] == 'provider') _buildRecentComments(),
//               ],
//             ),
//           );
//   }

//   // --- Add this method in your State class ---
//   void _showAddCommentDialog() {
//     final TextEditingController _commentController = TextEditingController();

//    showDialog(
//   context: context,
//   builder: (context) => Dialog(
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(20),
//     ),
//     elevation: 8,
//    backgroundColor: MyColors.surface,
//     child: Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Title
//           Text(
//             'Add Comment',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//                color: MyColors.primary,
//             ),
//           ),
//           const SizedBox(height: 12),

//           // Comment input
//           ConstrainedBox(
//             constraints: const BoxConstraints(maxHeight: 150),
//             child: TextField(
//               controller: _commentController,
//               maxLines: 5,
//               style: const TextStyle(
//     color: MyColors.textPrimary, // ye text ko white/dark theme color dega
//     fontSize: 16,
//   ),
//   cursorColor: MyColors.primary,
//               decoration: InputDecoration(
//                 hintText: 'Write your comment...',
//                 hintStyle: TextStyle(
//       color: MyColors.textSecondary, // hint ka color
//       fontSize: 15,
//     ),
//                 contentPadding: const EdgeInsets.symmetric(
//                     vertical: 12, horizontal: 16),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: MyColors.inputBorder),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: MyColors.inputFocusedBorder, width: 2),
//                 ),
//                 fillColor: MyColors.inputFill,
//                 filled: true,
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),

//           // Buttons
//           Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text(
//                   'Cancel',
//                   style: TextStyle(fontSize: 15, color: MyColors.textSecondary),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               ElevatedButton(
//                 onPressed: () async {
//                   final comment = _commentController.text.trim();
//                   if (comment.isEmpty) return;

//                   Navigator.pop(context); // close dialog
//                   await _submitComment(comment);
//                 },
//                 style: ElevatedButton.styleFrom(
//                  backgroundColor: MyColors.primary,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   elevation: 4,
//                 ),
//                 child: const Text(
//                   'Submit',
//                   style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,color: MyColors.textPrimary),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     ),
//   ),
// );


//   }
// }















import 'package:flutter/material.dart';
import '../helpers/backend.dart';
import '../models/action_buttons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../helpers/coolors.dart';
class ExternalProfileWidget extends StatefulWidget {
  final Map<String, dynamic> userData;
  final int currentUserId;

  const ExternalProfileWidget({
    super.key,
    required this.userData,
    required this.currentUserId,
  });

  @override
  State<ExternalProfileWidget> createState() => _ExternalProfileWidgetState();
}

class _ExternalProfileWidgetState extends State<ExternalProfileWidget> {
  double _userRating = 0;
  double _averageRating = 0;
  int _totalRatings = 0;
  List<Map<String, dynamic>> _recentComments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRatings();
  }

  // Fetch provider ratings from backend
  Future<void> fetchRatings() async {
    final providerId = widget.userData['id'];
    try {
      final response = await Backend.get('/provider/$providerId/ratings');
      if (response != null) {
        setState(() {
          _averageRating = (response['average_rating'] != null)
              ? double.tryParse(response['average_rating'].toString()) ?? 0
              : 0;

          _totalRatings = response['total_ratings'] ?? 0;
          _recentComments = List<Map<String, dynamic>>.from(
            response['ratings'] ?? [],
          );

          // Sirf latest 2 reviews lo
          if (_recentComments.length > 2) {
            _recentComments = _recentComments.take(2).toList();
          }

          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      // keep the error handling minimal (you can expand later)
      debugPrint('Fetch ratings error: $e');
      setState(() => _isLoading = false);
    }
  }

  // Submit rating to backend (no comment field anymore)
  Future<void> submitRating() async {
    final providerId = widget.userData['id'];
    final userId = widget.currentUserId;

    if (_userRating == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a rating')));
      return;
    }

    try {
      final response = await Backend.post('/provider/$providerId/rate', {
        'user_id': userId,
        'rating': _userRating.toInt(),
        // comment removed per request
      });

      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rating submitted successfully')),
        );

        // Reset local input
        setState(() {
          _userRating = 0;
        });

        // Refresh ratings from backend
        await fetchRatings();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit rating')),
        );
      }
    } catch (e) {
      debugPrint('Submit rating error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to submit rating')));
    }
  }

  // --- Profile header (name, username, bio + actions row) ---
  Widget _buildProfileHeader() {
    final user = widget.userData;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user['name'] ?? 'Unknown',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: kTextPrimary, // keep parent theme color for consistency
          ),
        ),
        if (user['username'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              '@${user['username']}',
              style: const TextStyle(fontSize: 14, color: kTextSecondary,),
            ),
          ),
        if (user['bio'] != null && (user['bio'] as String).isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Text(
              user['bio'],
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
               color: kTextSecondary,
              ),
            ),
          ),

        // Actions row (buttons) right under the bio - using your ActionButtonsWidget
        const SizedBox(height: 10),
        _buildActionButtonsRow(),
      ],
    );
  }

  
  Widget _buildActionButtonsRow() {
    final user = widget.userData;
    // If ActionButtonsWidget itself contains multiple buttons (likely),
    // just return it. Otherwise you can wrap multiple button widgets in a Row.
    return Row(
      children: [
        // Expand to use available width and keep a clean row layout
        Expanded(
          child: ActionButtonsWidget(
            providerId: user['id'] ?? 0,
            providerName: user['name'] ?? 'Unknown',
            phone: user['phone'] ?? '',
            currentUserId: widget.currentUserId,
            
            serviceData:
                (user['services'] != null &&
                    (user['services'] as List).isNotEmpty)
                ? (user['services'][0] as Map<String, dynamic>)
                : null,
          ),
        ),
      ],
    );
  }

  // --- Ratings UI (no comment input) ---
  // --- Replace your _buildRatingSection method with this ---
  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Average rating row
        Row(
          children: [
            RatingBarIndicator(
              rating: _averageRating,
              itemBuilder: (context, index) =>
                  const Icon(Icons.star, color: Colors.amber),
              itemCount: 5,
              itemSize: 18,
            ),
            const SizedBox(width: 8),
            Text(
              '${_averageRating.toStringAsFixed(1)} ($_totalRatings)',
              style: const TextStyle(fontSize: 13, color: kTextPrimary),
            ),
          ],
        ),
        const SizedBox(height: 12),

        const Text(
          'Rate this provider',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
           color: kTextPrimary,
          ),
        ),
        const SizedBox(height: 8),

        // rating selector
        RatingBar.builder(
          initialRating: _userRating,
          minRating: 1,
          maxRating: 5,
          allowHalfRating: false,
          itemBuilder: (context, index) =>
              const Icon(Icons.star, color: Colors.amber),
              unratedColor: kTextPrimary,
          itemSize: 20,
          onRatingUpdate: (rating) => setState(() => _userRating = rating),
        ),
        const SizedBox(height: 12),


        // Submit Rating button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: submitRating,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Submit Rating',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color:kTextPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Add Comment Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _showAddCommentDialog,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color:  kPrimaryColor),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Add Comment',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: kTextPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  // --- Recent reviews (keeps comments if backend returns them) ---
  Future<void> _submitComment(String comment) async {
  if (_userRating == 0 && comment.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Please provide a rating or comment')),
  );
  return;
}
  final providerId = widget.userData['id'];

  try {
    final response = await Backend.post('/provider/$providerId/rate', {
      'user_id': widget.currentUserId,
      'rating': _userRating > 0 ? _userRating.toInt() : null,
      'comment': comment.isNotEmpty ? comment : null,
    });
debugPrint('POST response: $response');
debugPrint('POST payload: userId=${widget.currentUserId}, rating=$_userRating, comment=$comment');

    if (response != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment submitted successfully')),
      );
      await fetchRatings(); // refresh recent comments
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit comment')),
      );
    }
  } catch (e) {
    debugPrint('Submit comment error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to submit comment')),
    );
  }
}





  // --- Modify _buildRecentComments method to make comment scrollable if long ---
  Widget _buildRecentComments() {
    if (_recentComments.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Reviews',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: kTextPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ..._recentComments.map(
          (r) => Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            color: kBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              title: Text(
                r['user_name'] ?? 'Anonymous',
                style: const TextStyle(fontWeight: FontWeight.bold,color: kTextPrimary,),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  RatingBarIndicator(
                    rating: (r['rating'] ?? 0).toDouble(),
                    itemBuilder: (context, index) =>
                        const Icon(Icons.star, color: Colors.amber),
                    itemCount: 5,
                    itemSize: 14,
                  ),
                  if (r['comment'] != null &&
                      (r['comment'] as String).isNotEmpty)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 70),
                      padding: const EdgeInsets.only(top: 6),
                      child: SingleChildScrollView(
                        child: Text(
                          r['comment'],
                          style: const TextStyle(
                            fontSize: 13,
                            color: kTextSecondary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              dense: true,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.userData;

    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(color: kTextPrimary),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 16),
                // Ratings and reviews only for provider role
                if (user['role'] == 'provider') _buildRatingSection(),
                if (user['role'] == 'provider') _buildRecentComments(),
              ],
            ),
          );
  }

  // --- Add this method in your State class ---
  void _showAddCommentDialog() {
    final TextEditingController _commentController = TextEditingController();

   showDialog(
  context: context,
  builder: (context) => Dialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    elevation: 8,
   backgroundColor: kBackgroundColor,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            'Add Comment',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
               color: kPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),

          // Comment input
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 150),
            child: TextField(
              controller: _commentController,
              maxLines: 5,
              style: const TextStyle(
    color: kTextPrimary, // ye text ko white/dark theme color dega
    fontSize: 16,
  ),
  cursorColor: kTextPrimary,
              decoration: InputDecoration(
                hintText: 'Write your comment...',
                hintStyle: TextStyle(
      color: kTextSecondary, // hint ka color
      fontSize: 15,
    ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: kTextPrimary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: kTextPrimary, width: 2),
                ),
                fillColor: kTextPrimary,
                filled: true,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 15, color: kTextSecondary),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  final comment = _commentController.text.trim();
                  if (comment.isEmpty) return;

                  Navigator.pop(context); // close dialog
                  await _submitComment(comment);
                },
                style: ElevatedButton.styleFrom(
                 backgroundColor:kPrimaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,color: kTextPrimary),
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
}

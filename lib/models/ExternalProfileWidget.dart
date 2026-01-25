// import 'package:flutter/material.dart';
// import '../helpers/backend.dart';
// import '../models/action_buttons.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import '../helpers/coolors.dart';

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
//   int? _taskId;
//   double _userRating = 0;
//   double _averageRating = 0;
//   int _totalRatings = 0;
//   List<Map<String, dynamic>> _recentComments = [];
//   bool _isLoading = true;
//   bool _hasRated = false;
//   bool showRatingSection = false;

//   @override
//   void initState() {
//     super.initState();
//     fetchRatings();
//     checkIfCanRate();
//   }

//   Future<void> checkIfCanRate() async {
//     final providerId = widget.userData['id'];
//     final userId = widget.currentUserId;

//     final response = await Backend.get(
//       '/tasks?user_id=$userId&provider_id=$providerId',
//     );
//     if (response != null) {
//       final tasks = List<Map<String, dynamic>>.from(response['tasks'] ?? []);
//       final canRateTasks = tasks
//           .where((t) => t['status'] == 'completed' && t['can_rate'] == true)
//           .toList();

//       setState(() {
//         showRatingSection = canRateTasks.isNotEmpty && userId != providerId;
//         _taskId = canRateTasks.isNotEmpty ? canRateTasks[0]['id'] : null;
//       });
//     }
//   }

//   Future<void> fetchRatings() async {
//     final providerId = widget.userData['id'];
//     try {
//       final response = await Backend.get('/provider/$providerId/ratings');
//       debugPrint('Fetch ratings response: $response');
//       if (response != null) {
//         setState(() {
//           _averageRating = (response['average_rating'] != null)
//               ? double.tryParse(response['average_rating'].toString()) ?? 0
//               : 0;
//           _totalRatings = response['total_ratings'] ?? 0;

//           final allRatings = List<Map<String, dynamic>>.from(
//             response['ratings'] ?? [],
//           );
//           _recentComments = allRatings.length > 2
//               ? allRatings.take(2).toList()
//               : allRatings;
//           _hasRated = allRatings.any(
//             (r) => r['user_id'] == widget.currentUserId,
//           );
//           _isLoading = false;
//         });
//       } else {
//         setState(() => _isLoading = false);
//       }
//     } catch (e, s) {
//       debugPrint('Stack trace: $s');
//       debugPrint('Fetch ratings error: $e');
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _submitRatingComment(double rating, String comment) async {
//     final providerId = widget.userData['id'];
//     final userId = widget.currentUserId;

//     try {
//       final response = await Backend.post('/provider/$providerId/rate', {
//         'user_id': userId,
//         if (rating > 0) 'rating': rating.toInt(),
//         if (comment.isNotEmpty) 'comment': comment,
//         'task_id': _taskId,
//       });

//       debugPrint('Submit rating/comment response: $response');

//       if (response != null) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('Submitted successfully')));
//         setState(() {
//           _hasRated = true;
//           showRatingSection = false; // force hide after rating
//         });
//         await fetchRatings();
//       } else {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('Failed to submit')));
//       }
//     } catch (e, s) {
//       debugPrint('Stack trace: $s');
//       debugPrint('Submit error: $e');
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Failed to submit')));
//     }
//   }

//   void _showAddRatingDialog() {
//     if (_hasRated ||
//         widget.currentUserId == widget.userData['id'] ||
//         !showRatingSection)
//       return;

//     final TextEditingController _commentController = TextEditingController();
//     double tempRating = _userRating;

//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         backgroundColor: kBackgroundColor,
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 'Rate & Comment',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: kPrimaryColor,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               RatingBar.builder(
//                 initialRating: tempRating,
//                 minRating: 1,
//                 maxRating: 5,
//                 allowHalfRating: false,
//                 itemBuilder: (context, _) =>
//                     const Icon(Icons.star, color: Colors.amber),
//                 onRatingUpdate: (rating) => tempRating = rating,
//               ),
//               const SizedBox(height: 12),
//               ConstrainedBox(
//                 constraints: const BoxConstraints(maxHeight: 150),
//                 child: TextField(
//                   controller: _commentController,
//                   maxLines: 5,
//                   style: const TextStyle(color: kTextPrimary, fontSize: 16),
//                   cursorColor: kTextPrimary,
//                   decoration: InputDecoration(
//                     hintText: 'Write your comment...',
//                     hintStyle: TextStyle(color: kTextSecondary, fontSize: 15),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: const Text(
//                       'Cancel',
//                       style: TextStyle(color: kTextSecondary),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   ElevatedButton(
//                     onPressed: () async {
//                       final comment = _commentController.text.trim();
//                       if (tempRating == 0 && comment.isEmpty) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Please provide a rating or comment'),
//                           ),
//                         );
//                         return;
//                       }
//                       Navigator.pop(context);
//                       _userRating = tempRating;
//                       await _submitRatingComment(tempRating, comment);
//                     },
//                     child: const Text(
//                       'Submit',
//                       style: TextStyle(color: kTextPrimary),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

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
//             color: kTextPrimary,
//           ),
//         ),
//         if (user['username'] != null)
//           Padding(
//             padding: const EdgeInsets.only(top: 4.0),
//             child: Text(
//               '@${user['username']}',
//               style: const TextStyle(fontSize: 14, color: kTextSecondary),
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
//                 color: kTextSecondary,
//               ),
//             ),
//           ),
//         const SizedBox(height: 10),
//         _buildActionButtonsRow(),
//       ],
//     );
//   }

//   Widget _buildActionButtonsRow() {
//     final user = widget.userData;
//     return Row(
//       children: [
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

//  Widget _buildRatingSection() {
//   // 1. User already rated → hide permanently
//   if (_hasRated) return const SizedBox.shrink();

//   // 2. User is rating themselves → hide
//   if (widget.currentUserId == widget.userData['id']) {
//     return const SizedBox.shrink();
//   }

//   // 3. Backend says rating allowed nahi (task completed + paid nahi)
//   if (!showRatingSection) return const SizedBox.shrink();

//   // 4. Otherwise show button
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Row(
//         children: [
//           RatingBarIndicator(
//             rating: _averageRating,
//             itemBuilder: (context, index) =>
//                 const Icon(Icons.star, color: Colors.amber),
//             itemCount: 5,
//             itemSize: 18,
//           ),
//           const SizedBox(width: 8),
//           Text(
//             '${_averageRating.toStringAsFixed(1)} ($_totalRatings)',
//             style: const TextStyle(fontSize: 13, color: kTextPrimary),
//           ),
//         ],
//       ),
//       const SizedBox(height: 12),
//       SizedBox(
//         width: double.infinity,
//         child: ElevatedButton(
//           onPressed: _showAddRatingDialog,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: kPrimaryColor,
//             padding: const EdgeInsets.symmetric(vertical: 12),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(8),
//             ),
//           ),
//           child: const Text(
//             'Rate & Comment',
//             style: TextStyle(
//               fontSize: 15,
//               fontWeight: FontWeight.bold,
//               color: kTextPrimary,
//             ),
//           ),
//         ),
//       ),
//       const SizedBox(height: 18),
//     ],
//   );
// }

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
//             color: kTextPrimary,
//           ),
//         ),
//         const SizedBox(height: 8),
//         ..._recentComments.map(
//           (r) => Card(
//             margin: const EdgeInsets.symmetric(vertical: 6),
//             color: kBackgroundColor,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: ListTile(
//               title: Text(
//                 r['user_name'] ?? 'Anonymous',
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: kTextPrimary,
//                 ),
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
//                             color: kTextSecondary,
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
//         ? const Center(child: CircularProgressIndicator(color: kTextPrimary))
//         : SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildProfileHeader(),
//                 const SizedBox(height: 16),
//                 if (user['role'] == 'provider') _buildRatingSection(),
//                 if (user['role'] == 'provider') _buildRecentComments(),
//               ],
//             ),
//           );
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
  int? _taskId;
  double _userRating = 0;
  double _averageRating = 0;
  int _totalRatings = 0;
  List<Map<String, dynamic>> _recentComments = [];
  bool _isLoading = true;
  bool _hasRated = false;
  bool showRatingSection = false;

  @override
  void initState() {
    super.initState();
    fetchRatings();
    checkIfCanRate();
  }

  Future<void> checkIfCanRate() async {
    final providerId = widget.userData['id'];
    final userId = widget.currentUserId;

    final response = await Backend.get(
      '/tasks?user_id=$userId&provider_id=$providerId',
    );

    if (response != null) {
      final tasks = List<Map<String, dynamic>>.from(response['tasks'] ?? []);

      // ✅ Filter tasks: completed, can_rate true, payment done
      final canRateTasks = tasks
          .where(
            (t) =>
                t['status'] == 'completed' &&
                t['can_rate'] == true &&
                t['payment_status'] == 'paid',
          )
          .toList();

      setState(() {
        // Show rating section only if there is at least 1 paid, completed task
        showRatingSection = canRateTasks.isNotEmpty && userId != providerId;

        // Store the first eligible task id for rating
        _taskId = canRateTasks.isNotEmpty ? canRateTasks[0]['id'] : null;
      });
    }
  }

  Future<void> fetchRatings() async {
    final providerId = widget.userData['id'];
    try {
      final response = await Backend.get('/provider/$providerId/ratings');
      debugPrint('Fetch ratings response: $response');
      if (response != null) {
        setState(() {
          _averageRating = (response['average_rating'] != null)
              ? double.tryParse(response['average_rating'].toString()) ?? 0
              : 0;
          _totalRatings = response['total_ratings'] ?? 0;

          final allRatings = List<Map<String, dynamic>>.from(
            response['ratings'] ?? [],
          );
          _recentComments = allRatings.length > 2
              ? allRatings.take(2).toList()
              : allRatings;
          _hasRated = allRatings.any(
            (r) => r['user_id'] == widget.currentUserId,
          );
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e, s) {
      debugPrint('Stack trace: $s');
      debugPrint('Fetch ratings error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitRatingComment(double rating, String comment) async {
    final providerId = widget.userData['id'];
    final userId = widget.currentUserId;

    try {
      final response = await Backend.post('/provider/$providerId/rate', {
        'user_id': userId,
        if (rating > 0) 'rating': rating.toInt(),
        if (comment.isNotEmpty) 'comment': comment,
        'task_id': _taskId,
      });

      debugPrint('Submit rating/comment response: $response');

      if (response != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Submitted successfully')));
        setState(() {
          _hasRated = true;
          showRatingSection = false; // force hide after rating
        });
        await fetchRatings();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to submit')));
      }
    } catch (e, s) {
      debugPrint('Stack trace: $s');
      debugPrint('Submit error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to submit')));
    }
  }

  void _showAddRatingDialog() {
    if (_hasRated ||
        widget.currentUserId == widget.userData['id'] ||
        !showRatingSection)
      return;

    final TextEditingController _commentController = TextEditingController();
    double tempRating = _userRating;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: kBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Rate & Comment',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
              const SizedBox(height: 12),
              RatingBar.builder(
                initialRating: tempRating,
                minRating: 1,
                maxRating: 5,
                allowHalfRating: false,
                itemBuilder: (context, _) =>
                    const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (rating) => tempRating = rating,
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 150),
                child: TextField(
                  controller: _commentController,
                  maxLines: 5,
                  style: const TextStyle(color: kTextPrimary, fontSize: 16),
                  cursorColor: kTextPrimary,
                  decoration: InputDecoration(
                    hintText: 'Write your comment...',
                    hintStyle: TextStyle(color: kTextSecondary, fontSize: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: kTextSecondary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final comment = _commentController.text.trim();
                      if (tempRating == 0 && comment.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please provide a rating or comment'),
                          ),
                        );
                        return;
                      }
                      Navigator.pop(context);
                      _userRating = tempRating;
                      await _submitRatingComment(tempRating, comment);
                    },
                    child: const Text(
                      'Submit',
                      style: TextStyle(color: kTextPrimary),
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
            color: kTextPrimary,
          ),
        ),
        if (user['username'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              '@${user['username']}',
              style: const TextStyle(fontSize: 14, color: kTextSecondary),
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
        const SizedBox(height: 10),
        _buildActionButtonsRow(),
      ],
    );
  }

  Widget _buildActionButtonsRow() {
    final user = widget.userData;
    return Row(
      children: [
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

  Widget _buildRatingSection() {
    // 1. User already rated → hide permanently
    if (_hasRated) return const SizedBox.shrink();

    // 2. User is rating themselves → hide
    if (widget.currentUserId == widget.userData['id']) {
      return const SizedBox.shrink();
    }

    // 3. Backend says rating allowed nahi (task completed + paid nahi)
    if (!showRatingSection) return const SizedBox.shrink();

    // 4. Otherwise show button
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _showAddRatingDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Rate & Comment',
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
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: kTextPrimary,
                ),
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
        ? const Center(child: CircularProgressIndicator(color: kTextPrimary))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 16),
                if (user['role'] == 'provider') _buildRatingSection(),
                if (user['role'] == 'provider') _buildRecentComments(),
              ],
            ),
          );
  }
}

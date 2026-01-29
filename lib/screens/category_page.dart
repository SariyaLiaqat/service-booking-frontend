// import 'package:flutter/material.dart';
// import 'MyProfileScreen.dart';
// import '../helpers/backend.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:geolocator/geolocator.dart';
// import 'dart:async';
// import '../widgets/categories_pages_widgets.dart';
// // Your NEW Color Scheme
// import 'package:lottie/lottie.dart';

// import '../helpers/coolors.dart';

// //

// class CategoryPage extends StatefulWidget {
//   final int categoryId;
//   final String categoryName;
//   final int currentUserId;

//   const CategoryPage({
//     Key? key,
//     required this.categoryId,
//     required this.categoryName,
//     required this.currentUserId,
//   }) : super(key: key);

//   @override
//   State<CategoryPage> createState() => _CategoryPageState();
// }

// class _CategoryPageState extends State<CategoryPage> {
//   List<dynamic> providers = [];
//   bool isLoading = true;
//   TextEditingController searchController = TextEditingController();

//   Timer? _locationTimer;
//   List<dynamic> filteredRelatedProviders = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchCategoryProviders();
//     _updateProviderLocation();
//     startPeriodicLocationUpdates(widget.currentUserId);

//     searchController.addListener(() {
//       final query = searchController.text.toLowerCase();
//       setState(() {
//         filteredRelatedProviders = providers.where((p) {
//           final name = p['name']?.toLowerCase() ?? '';
//           final skills = (p['skills'] ?? []).join(', ').toLowerCase();
//           final services = (p['services'] ?? [])
//               .map((s) => s['title'].toString().toLowerCase())
//               .join(' ');
//           return name.contains(query) ||
//               skills.contains(query) ||
//               services.contains(query);
//         }).toList();
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _locationTimer?.cancel();
//     searchController.dispose(); // Dispose controller
//     super.dispose();
//   }

//   //----------------------timer helpers (Logic Maintained) ----------------------
//   void startPeriodicLocationUpdates(int providerId) {
//     _locationTimer?.cancel();
//     _locationTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
//       updateProviderLocation(providerId);
//     });
//   }

//   void stopPeriodicLocationUpdates() {
//     _locationTimer?.cancel();
//   }

//   //------------------update location (Logic Maintained) ----------------------
//   Future<void> _updateProviderLocation() async {
//     await updateProviderLocation(widget.currentUserId);
//   }

//   Future<void> updateProviderLocation(int providerId) async {
//     try {
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied ||
//           permission == LocationPermission.deniedForever)
//         return;

//       Position? position = await getCurrentLocation();
//       if (position == null) return;

//       final url = Uri.parse('${Backend.baseUrl}/provider/$providerId/location');
//       final response = await http.put(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "latitude": position.latitude,
//           "longitude": position.longitude,
//         }),
//       );

//       if (response.statusCode == 200) {
//         debugPrint(
//           '✅ Location updated successfully: ${position.latitude}, ${position.longitude}',
//         );
//       } else {
//         debugPrint('❌ Failed to update location: ${response.statusCode}');
//       }
//     } catch (e) {
//       debugPrint('❌ Error updating location: $e');
//     }
//   }

//   //------------------get current location (Logic Maintained) ------------------
//   Future<Position?> getCurrentLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) return null;

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) return null;
//     }
//     if (permission == LocationPermission.deniedForever) return null;

//     return await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//   }

//   //------------------fetch providers (Logic Maintained) ----------------------
//   Future<void> fetchCategoryProviders() async {
//     try {
//       final url = Uri.parse(
//         '${Backend.baseUrl}/services?category_id=${widget.categoryId}',
//       );
//       final response = await http.get(url);
//       print('API Response: ${response.body}');

//       if (response.statusCode == 200) {
//         final List fetchedServices = jsonDecode(response.body);

//         Map<int, dynamic> uniqueProviders = {};
//         for (var service in fetchedServices) {
//           final pid = service['provider_id'];
//           if (!uniqueProviders.containsKey(pid)) {
//             double avgRating = 0.0;
//             int totalRatings = 0;

//             try {
//               final ratingUrl = Uri.parse(
//                 '${Backend.baseUrl}/provider/$pid/ratings',
//               );
//               final ratingResp = await http.get(ratingUrl);
//               if (ratingResp.statusCode == 200) {
//                 final ratingData = jsonDecode(ratingResp.body);
//                 avgRating =
//                     double.tryParse(
//                       ratingData['average_rating']?.toString() ?? '0',
//                     ) ??
//                     0.0;
//                 totalRatings = ratingData['total_ratings'] ?? 0;
//               }
//             } catch (e) {
//               print('Error fetching rating for provider $pid: $e');
//             }
//             uniqueProviders[pid] = {
//               'provider_id': pid,
//               'name': service['provider_name'],
//               'profile_image': service['provider_image'],
//               'skills': service['provider_skills'],
//               'average_rating': avgRating,
//               'total_ratings': totalRatings,
//               'services': [],
//             };
//           }
//           uniqueProviders[pid]['services'].add(service);
//         }

//         if (!mounted) return;
//         providers = uniqueProviders.values.toList();
//         filteredRelatedProviders = providers;
//         setState(() => isLoading = false);
//       } else {
//         if (!mounted) return;
//         setState(() => isLoading = false);
//         print('Failed: ${response.statusCode}');
//       }
//     } catch (e) {
//       if (!mounted) return;
//       setState(() => isLoading = false);
//       print('Error: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kBackgroundColor,

//       // ✨ New AppBar Design: Clean, single color, no gradient for a modern look
//       appBar: AppBar(
//         title: Text(
//           widget.categoryName,
//           style: const TextStyle(
//             color: buttonText, // White text on primary background
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: kPrimaryColor,
//       ),

//       body: Column(
//         children: [
//           // ✨ Redesigned Search Bar: Floating card effect for prominence
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               controller: searchController,
//               style: const TextStyle(
//                 color: kTextPrimary,
//                 fontWeight: FontWeight.w500,
//               ),
//               decoration: InputDecoration(
//                 hintText: 'Search Providers or Services...',
//                 hintStyle: const TextStyle(
//                   color: kTextHint,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w400,
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none,
//                 ),
//                 filled: true,
//                 fillColor: kCardColor, // White fill color
//                 contentPadding: const EdgeInsets.symmetric(
//                   vertical: 14,
//                   horizontal: 16,
//                 ),
//                 prefixIcon: const Icon(Icons.search, color: kPrimaryColor),
//                 // Add a subtle elevation/shadow to the search field
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(color: kDividerColor),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(color: kPrimaryColor, width: 2),
//                 ),
//               ),
//             ),
//           ),

//           // ✅ Rest of the body
//           Expanded(
//             child: isLoading
//                 ? const Center(
//                     child: CircularProgressIndicator(color: kPrimaryColor),
//                   )
//                 : SingleChildScrollView(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // 1️⃣ Nearby Providers (hamesha show)
//                         NearbyProvidersWithRatingsWidget(
//                           currentUserId: widget.currentUserId,
//                         ),

//                         const SizedBox(height: 20),

//                         // 2️⃣ High Rated Providers (hamesha show)
//                         HighRatedProvidersWidget(providers: providers),

//                         const SizedBox(height: 20),

//                         // 3️⃣ All Related Providers Section
//                         const Padding(
//                           padding: EdgeInsets.symmetric(vertical: 8.0),
//                           child: Text(
//                             'All Related Providers',
//                             style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               color: kTextPrimary,
//                             ),
//                           ),
//                         ),

//                         filteredRelatedProviders.isEmpty
//                             ? Center(
//                                 child: Column(
//                                   children: [
//                                     SizedBox(
//                                       height: 150,
//                                       child: Lottie.asset(
//                                         'assets/lottie/Lovely cats.json',
//                                         frameRate: FrameRate.max,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 8),
//                                     const Text(
//                                       'No providers found in this category.',
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         color: kTextHint,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               )
//                             : ListView.builder(
//                                 shrinkWrap: true,
//                                 physics: const NeverScrollableScrollPhysics(),
//                                 itemCount: filteredRelatedProviders.length,
//                                 itemBuilder: (context, index) {
//                                   final provider =
//                                       filteredRelatedProviders[index];
//                                   return buildProviderCard(provider);
//                                 },
//                               ),
//                       ],
//                     ),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildProviderCard(dynamic provider) {
//     String? imageUrl;

//     if (provider['profile_image'] != null && provider['profile_image'] != '') {
//       imageUrl = provider['profile_image'].startsWith('http')
//           ? provider['profile_image']
//           : '${Backend.baseUrl}/${provider['profile_image']}';
//     } else if (provider['provider_image'] != null &&
//         provider['provider_image'] != '') {
//       imageUrl = provider['provider_image'].startsWith('http')
//           ? provider['provider_image']
//           : '${Backend.baseUrl}/${provider['provider_image']}';
//     }

//     String displayName =
//         provider['name'] ?? provider['provider_name'] ?? 'Unknown';

//     double avgRating =
//         double.tryParse(provider['average_rating']?.toString() ?? '0') ?? 0.0;
//     int totalRatings =
//         int.tryParse(provider['total_ratings']?.toString() ?? '0') ?? 0;

//     final providerId = provider['provider_id'] ?? provider['id'];

//     return GestureDetector(
//       onTap: () async {
//         dynamic providerDetails;
//         try {
//           final url = Uri.parse(
//             '${Backend.baseUrl}/provider/services/providers/$providerId',
//           );
//           final response = await http.get(url);
//           if (response.statusCode == 200) {
//             providerDetails = jsonDecode(response.body)['provider'];
//           } else {
//             providerDetails = provider;
//           }
//         } catch (_) {
//           providerDetails = provider;
//         }

//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => MyProfileScreen(
//               userData: providerDetails,
//               readOnly: widget.currentUserId != providerId,
//               currentUserId: widget.currentUserId,
//             ),
//           ),
//         );
//       },

//       child: Container(
//         height: 95,
//         margin: const EdgeInsets.symmetric(vertical: 6),
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: kCardColor,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: heaidng.withOpacity(0.05),
//               blurRadius: 8,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),

//         child: Row(
//           children: [
//             /// IMAGE - FACE FOCUSED PROFILE STYLE
//             ClipRRect(
//               borderRadius: BorderRadius.circular(10),
//               child: Container(
//                 width: 60,
//                 height: 75,
//                 color: kDividerColor,
//                 child: imageUrl != null
//                     ? Image.network(
//                         imageUrl,
//                         fit: BoxFit.cover, // 👉 Shows only face nicely
//                       )
//                     : const Icon(Icons.person, size: 35, color: kTextHint),
//               ),
//             ),

//             const SizedBox(width: 12),

//             /// MAIN CONTENT (NO OVERFLOW)
//             Expanded(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // SERVICE TITLE
//                   Text(
//                     provider['services'] != null &&
//                             provider['services'] is List &&
//                             provider['services'].isNotEmpty
//                         ? provider['services'][0]['title']
//                         : 'Service',
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       color: kTextPrimary,
//                     ),
//                   ),

//                   const SizedBox(height: 4),

//                   // NAME
//                   Text(
//                     displayName,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(fontSize: 12, color: kTextSecondary),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(width: 10),

//             /// RATING (SHRINKS, NO OVERFLOW)
//             Flexible(
//               flex: 0,
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Icon(Icons.star, color: kWarningColor, size: 16),
//                   const SizedBox(width: 3),
//                   Text(
//                     avgRating.toStringAsFixed(1),
//                     style: const TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                       color: kTextPrimary,
//                     ),
//                   ),
//                   if (totalRatings > 0) ...[
//                     const SizedBox(width: 3),
//                     Text(
//                       '($totalRatings)',
//                       style: const TextStyle(
//                         fontSize: 11,
//                         color: kTextSecondary,
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// ----------------------------------------------------------------------------
// /// Nearby Providers with Ratings Widget
// /// ----------------------------------------------------------------------------
// class NearbyProvidersWithRatingsWidget extends StatefulWidget {
//   final int currentUserId;
//   const NearbyProvidersWithRatingsWidget({
//     Key? key,
//     required this.currentUserId,
//   }) : super(key: key);

//   @override
//   _NearbyProvidersWithRatingsWidgetState createState() =>
//       _NearbyProvidersWithRatingsWidgetState();
// }

// class _NearbyProvidersWithRatingsWidgetState
//     extends State<NearbyProvidersWithRatingsWidget> {
//   List<dynamic> nearbyProviders = [];
//   double? userLat;
//   double? userLng;
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _getUserLocation();
//   }

//   // --- Logic for fetching location and nearby providers ---
//   Future<void> _getUserLocation() async {
//     try {
//       final position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       setState(() {
//         userLat = position.latitude;
//         userLng = position.longitude;
//       });
//       await _fetchNearbyProviders();
//     } catch (e) {
//       setState(() => isLoading = false);
//       debugPrint('Location error: $e');
//     }
//   }

//   Future<void> _fetchNearbyProviders() async {
//     if (userLat == null || userLng == null) return;

//     try {
//       final url = Uri.parse(
//         '${Backend.baseUrl}/provider/nearest?lat=$userLat&lng=$userLng&limit=10',
//       );
//       final response = await http.get(url);

//       nearbyProviders = [];

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List rawProviders = data['providers'] ?? [];

//         for (var p in rawProviders) {
//           double avgRating = 0.0;
//           int totalRatings = 0;

//           try {
//             final ratingUrl = Uri.parse(
//               '${Backend.baseUrl}/provider/${p['id']}/ratings',
//             );
//             final ratingResp = await http.get(ratingUrl);
//             if (ratingResp.statusCode == 200) {
//               final ratingData = jsonDecode(ratingResp.body);
//               avgRating =
//                   double.tryParse(
//                     ratingData['average_rating']?.toString() ?? '0',
//                   ) ??
//                   0.0;
//               totalRatings = ratingData['total_ratings'] ?? 0;
//             }
//           } catch (e) {
//             debugPrint('Error fetching rating for provider ${p['id']}: $e');
//           }

//           nearbyProviders.add({
//             'provider_id': p['id'],
//             'name': p['name'] ?? 'Unknown',
//             'profile_image': p['profile_image'],
//             'skills': p['skills'] ?? [],
//             'average_rating': avgRating,
//             'total_ratings': totalRatings,
//           });
//         }
//       } else {
//         debugPrint('Failed to fetch nearby providers: ${response.statusCode}');
//       }
//     } catch (e) {
//       debugPrint('Error fetching nearby providers: $e');
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // --- Section Title (always visible) ---
//         const Padding(
//           padding: EdgeInsets.symmetric(vertical: 12.0),
//           child: Text(
//             'Providers Near You',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: kTextPrimary,
//             ),
//           ),
//         ),

//         // --- Body ---
//         if (isLoading)
//           const Center(
//             child: Padding(
//               padding: EdgeInsets.symmetric(vertical: 24.0),
//               child: CircularProgressIndicator(color: kPrimaryColor),
//             ),
//           )
//         else if (nearbyProviders.isEmpty)
//   Center(
//     child: Column(
//       children: [
//         SizedBox(
//           height: 150,
//           child: Lottie.asset('assets/lottie/empty ghost.json'),
//         ),
//         const SizedBox(height: 8),
//         const Text(
//           'No nearby providers found.',
//           style: TextStyle(color: kTextHint, fontSize: 16),
//         ),
//       ],
//     ),
//   )

//         else
//           SizedBox(
//             height: 140, // Horizontal card height
//             child: ListView.separated(
//               scrollDirection: Axis.horizontal,
//               itemCount: nearbyProviders.length,
//               separatorBuilder: (_, __) => const SizedBox(width: 12),
//               itemBuilder: (context, index) {
//                 final provider = nearbyProviders[index];

//                 String? imageUrl;
//                 if (provider['profile_image'] != null &&
//                     provider['profile_image'] != '') {
//                   imageUrl = provider['profile_image'].startsWith('http')
//                       ? provider['profile_image']
//                       : '${Backend.baseUrl}/${provider['profile_image']}';
//                 }
//                 double avgRating = provider['average_rating'] ?? 0.0;
//                 int totalRatings = provider['total_ratings'] ?? 0;

//                 return GestureDetector(
//                   onTap: () async {
//                     dynamic providerDetails;
//                     try {
//                       final url = Uri.parse(
//                         '${Backend.baseUrl}/provider/services/providers/${provider['provider_id']}',
//                       );
//                       final response = await http.get(url);
//                       if (response.statusCode == 200) {
//                         providerDetails = jsonDecode(response.body)['provider'];
//                       } else {
//                         providerDetails = provider;
//                       }
//                     } catch (_) {
//                       providerDetails = provider;
//                     }

//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => MyProfileScreen(
//                           userData: providerDetails,
//                           readOnly:
//                               widget.currentUserId != provider['provider_id'],
//                           currentUserId: widget.currentUserId,
//                         ),
//                       ),
//                     );
//                   },
//                   child: Container(
//                     width: 100,
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: kCardColor,
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: [
//                         BoxShadow(
//                           color: heaidng.withOpacity(0.05),
//                           blurRadius: 5,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         CircleAvatar(
//                           radius: 30,
//                           backgroundImage: imageUrl != null
//                               ? NetworkImage(imageUrl)
//                               : null,
//                           backgroundColor: kDividerColor,
//                           child: imageUrl == null
//                               ? const Icon(
//                                   Icons.person,
//                                   size: 30,
//                                   color: kTextHint,
//                                 )
//                               : null,
//                         ),
//                         const SizedBox(height: 6),
//                         Text(
//                           provider['name'] ?? 'Unknown',
//                           textAlign: TextAlign.center,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: kTextPrimary,
//                             fontSize: 14,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Icon(
//                               Icons.star,
//                               color: kWarningColor,
//                               size: 12,
//                             ),
//                             const SizedBox(width: 2),
//                             Text(
//                               avgRating.toStringAsFixed(1),
//                               style: const TextStyle(
//                                 color: kTextSecondary,
//                                 fontSize: 10,
//                               ),
//                             ),
//                             if (totalRatings > 0) ...[
//                               const SizedBox(width: 2),
//                               Text(
//                                 '($totalRatings)',
//                                 style: const TextStyle(
//                                   color: kTextHint,
//                                   fontSize: 8,
//                                 ),
//                               ),
//                             ],
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         const SizedBox(height: 20),
//       ],
//     );
//   }
// }

//  // Nearby Providers Section

import 'package:flutter/material.dart';
import 'MyProfileScreen.dart';
import '../helpers/backend.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../widgets/categories_pages_widgets.dart';
// Your NEW Color Scheme
import 'package:lottie/lottie.dart';

import '../helpers/coolors.dart';

//

class CategoryPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  final int currentUserId;

  const CategoryPage({
    Key? key,
    required this.categoryId,
    required this.categoryName,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<dynamic> providers = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  Timer? _locationTimer;
  List<dynamic> filteredRelatedProviders = [];

  @override
  void initState() {
    super.initState();
    fetchCategoryProviders();
    _updateProviderLocation();
    startPeriodicLocationUpdates(widget.currentUserId);

    searchController.addListener(() {
      final query = searchController.text.toLowerCase();
      setState(() {
        filteredRelatedProviders = providers.where((p) {
          final name = p['name']?.toLowerCase() ?? '';
          final skills = (p['skills'] ?? []).join(', ').toLowerCase();
          final services = (p['services'] ?? [])
              .map((s) => s['title'].toString().toLowerCase())
              .join(' ');
          return name.contains(query) ||
              skills.contains(query) ||
              services.contains(query);
        }).toList();
      });
    });
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    searchController.dispose(); // Dispose controller
    super.dispose();
  }

  //----------------------timer helpers (Logic Maintained) ----------------------
  void startPeriodicLocationUpdates(int providerId) {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      updateProviderLocation(providerId);
    });
  }

  void stopPeriodicLocationUpdates() {
    _locationTimer?.cancel();
  }

  //------------------update location (Logic Maintained) ----------------------
  Future<void> _updateProviderLocation() async {
    await updateProviderLocation(widget.currentUserId);
  }

  Future<void> updateProviderLocation(int providerId) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever)
        return;

      Position? position = await getCurrentLocation();
      if (position == null) return;

      final url = Uri.parse('${Backend.baseUrl}/provider/$providerId/location');
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "latitude": position.latitude,
          "longitude": position.longitude,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint(
          '✅ Location updated successfully: ${position.latitude}, ${position.longitude}',
        );
      } else {
        debugPrint('❌ Failed to update location: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error updating location: $e');
    }
  }

  //------------------get current location (Logic Maintained) ------------------
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  //------------------fetch providers (Logic Maintained) ----------------------
  Future<void> fetchCategoryProviders() async {
    try {
      final url = Uri.parse(
        '${Backend.baseUrl}/services?category_id=${widget.categoryId}',
      );
      final response = await http.get(url);
      print('API Response: ${response.body}');

      if (response.statusCode == 200) {
        final List fetchedServices = jsonDecode(response.body);

        Map<int, dynamic> uniqueProviders = {};
        for (var service in fetchedServices) {
          final pid = service['provider_id'];
          if (!uniqueProviders.containsKey(pid)) {
            double avgRating = 0.0;
            int totalRatings = 0;

            try {
              final ratingUrl = Uri.parse(
                '${Backend.baseUrl}/provider/$pid/ratings',
              );
              final ratingResp = await http.get(ratingUrl);
              if (ratingResp.statusCode == 200) {
                final ratingData = jsonDecode(ratingResp.body);
                avgRating =
                    double.tryParse(
                      ratingData['average_rating']?.toString() ?? '0',
                    ) ??
                    0.0;
                totalRatings = ratingData['total_ratings'] ?? 0;
              }
            } catch (e) {
              print('Error fetching rating for provider $pid: $e');
            }
            uniqueProviders[pid] = {
              'provider_id': pid,
              'name': service['provider_name'],
              'profile_image': service['provider_image'],
              'skills': service['provider_skills'],
              'average_rating': avgRating,
              'total_ratings': totalRatings,
              'services': [],
            };
          }
          uniqueProviders[pid]['services'].add(service);
        }

        if (!mounted) return;
        providers = uniqueProviders.values.toList();
        filteredRelatedProviders = providers;
        setState(() => isLoading = false);
      } else {
        if (!mounted) return;
        setState(() => isLoading = false);
        print('Failed: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
     appBar: AppBar(
  backgroundColor: kBackgroundColor,
  elevation: 0,
  centerTitle: true,
  // Modern Back Button
  leading: Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: kTextPrimary),
        onPressed: () => Navigator.pop(context),
      ),
    ),
  ),
  title: Text(
    widget.categoryName,
    style: const TextStyle(
      color: kTextPrimary, // Clean dark text
      fontSize: 20,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
    ),
  ),
  // Added a dummy action to perfectly balance the centered title
  actions: [
    const SizedBox(width: 56), 
  ],
),

      body: Column(
        children: [
          // ✨ Redesigned Search Bar: Floating card effect for prominence
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: kCardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                style: const TextStyle(
                  color: kTextPrimary,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Search Providers or Services...',
                  hintStyle: const TextStyle(
                    color: kTextHint,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: kCardColor,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.black),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.black),
                          onPressed: () {
                            searchController.clear();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  (context as Element).markNeedsBuild();
                },
              ),
            ),
          ),

          // ✅ Rest of the body
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: kPrimaryColor),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1️⃣ Nearby Providers (hamesha show)
                        NearbyProvidersWithRatingsWidget(
                          currentUserId: widget.currentUserId,
                        ),

                        const SizedBox(height: 20),

                        // 2️⃣ High Rated Providers (hamesha show)
                        HighRatedProvidersWidget(providers: providers),

                        const SizedBox(height: 20),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'All Related Providers',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: kTextPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Container(
                              width: 60,
                              height: 4,
                              decoration: BoxDecoration(
                                color: kSecondaryColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),

                        filteredRelatedProviders.isEmpty
                            ? Center(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 150,
                                      child: Lottie.asset(
                                        'assets/lottie/Lovely cats.json',
                                        frameRate: FrameRate.max,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'No providers found in this category.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: kTextHint,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredRelatedProviders.length,
                                itemBuilder: (context, index) {
                                  final provider =
                                      filteredRelatedProviders[index];
                                  return buildProviderCard(provider);
                                },
                              ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget buildProviderCard(dynamic provider) {
    String? imageUrl;

    if (provider['profile_image'] != null && provider['profile_image'] != '') {
      imageUrl = provider['profile_image'].startsWith('http')
          ? provider['profile_image']
          : '${Backend.baseUrl}/${provider['profile_image']}';
    } else if (provider['provider_image'] != null &&
        provider['provider_image'] != '') {
      imageUrl = provider['provider_image'].startsWith('http')
          ? provider['provider_image']
          : '${Backend.baseUrl}/${provider['provider_image']}';
    }

    String displayName =
        provider['name'] ?? provider['provider_name'] ?? 'Unknown';

    double avgRating =
        double.tryParse(provider['average_rating']?.toString() ?? '0') ?? 0.0;
    int totalRatings =
        int.tryParse(provider['total_ratings']?.toString() ?? '0') ?? 0;

    final providerId = provider['provider_id'] ?? provider['id'];

    return GestureDetector(
      onTap: () async {
        dynamic providerDetails;
        try {
          final url = Uri.parse(
            '${Backend.baseUrl}/provider/services/providers/$providerId',
          );
          final response = await http.get(url);
          if (response.statusCode == 200) {
            providerDetails = jsonDecode(response.body)['provider'];
          } else {
            providerDetails = provider;
          }
        } catch (_) {
          providerDetails = provider;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MyProfileScreen(
              userData: providerDetails,
              readOnly: widget.currentUserId != providerId,
              currentUserId: widget.currentUserId,
            ),
          ),
        );
      },

      child: Container(
        height: 95,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: heaidng.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: Row(
          children: [
            /// IMAGE - FACE FOCUSED PROFILE STYLE
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 60,
                height: 75,
                color: kDividerColor,
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover, // 👉 Shows only face nicely
                      )
                    : const Icon(Icons.person, size: 35, color: kTextHint),
              ),
            ),

            const SizedBox(width: 12),

            /// MAIN CONTENT (NO OVERFLOW)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SERVICE TITLE
                  Text(
                    provider['services'] != null &&
                            provider['services'] is List &&
                            provider['services'].isNotEmpty
                        ? provider['services'][0]['title']
                        : 'Service',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kTextPrimary,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // NAME
                  Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: kTextSecondary),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            /// RATING (SHRINKS, NO OVERFLOW)
            Flexible(
              flex: 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: kWarningColor, size: 16),
                  const SizedBox(width: 3),
                  Text(
                    avgRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kTextPrimary,
                    ),
                  ),
                  if (totalRatings > 0) ...[
                    const SizedBox(width: 3),
                    Text(
                      '($totalRatings)',
                      style: const TextStyle(
                        fontSize: 11,
                        color: kTextSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ----------------------------------------------------------------------------
/// Nearby Providers with Ratings Widget
/// ----------------------------------------------------------------------------
class NearbyProvidersWithRatingsWidget extends StatefulWidget {
  final int currentUserId;
  const NearbyProvidersWithRatingsWidget({
    Key? key,
    required this.currentUserId,
  }) : super(key: key);

  @override
  _NearbyProvidersWithRatingsWidgetState createState() =>
      _NearbyProvidersWithRatingsWidgetState();
}

class _NearbyProvidersWithRatingsWidgetState
    extends State<NearbyProvidersWithRatingsWidget> {
  List<dynamic> nearbyProviders = [];
  double? userLat;
  double? userLng;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  // --- Logic for fetching location and nearby providers ---
  Future<void> _getUserLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        userLat = position.latitude;
        userLng = position.longitude;
      });
      await _fetchNearbyProviders();
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Location error: $e');
    }
  }

  Future<void> _fetchNearbyProviders() async {
    if (userLat == null || userLng == null) return;

    try {
      final url = Uri.parse(
        '${Backend.baseUrl}/provider/nearest?lat=$userLat&lng=$userLng&limit=10',
      );
      final response = await http.get(url);

      nearbyProviders = [];

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List rawProviders = data['providers'] ?? [];

        for (var p in rawProviders) {
          double avgRating = 0.0;
          int totalRatings = 0;

          try {
            final ratingUrl = Uri.parse(
              '${Backend.baseUrl}/provider/${p['id']}/ratings',
            );
            final ratingResp = await http.get(ratingUrl);
            if (ratingResp.statusCode == 200) {
              final ratingData = jsonDecode(ratingResp.body);
              avgRating =
                  double.tryParse(
                    ratingData['average_rating']?.toString() ?? '0',
                  ) ??
                  0.0;
              totalRatings = ratingData['total_ratings'] ?? 0;
            }
          } catch (e) {
            debugPrint('Error fetching rating for provider ${p['id']}: $e');
          }

          nearbyProviders.add({
            'provider_id': p['id'],
            'name': p['name'] ?? 'Unknown',
            'profile_image': p['profile_image'],
            'skills': p['skills'] ?? [],
            'average_rating': avgRating,
            'total_ratings': totalRatings,
          });
        }
      } else {
        debugPrint('Failed to fetch nearby providers: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching nearby providers: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Section Title (always visible) ---
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Providers Near You',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: kTextPrimary,
              ),
            ),
            SizedBox(height: 4),
            Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                color: kSecondaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),

        // --- Body ---
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: CircularProgressIndicator(color: kPrimaryColor),
            ),
          )
        else if (nearbyProviders.isEmpty)
          Center(
            child: Column(
              children: [
                SizedBox(
                  height: 150,
                  child: Lottie.asset('assets/lottie/empty ghost.json'),
                ),
                const SizedBox(height: 8),
                const Text(
                  'No nearby providers found.',
                  style: TextStyle(color: kTextHint, fontSize: 16),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 140, // Horizontal card height
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: nearbyProviders.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final provider = nearbyProviders[index];

                String? imageUrl;
                if (provider['profile_image'] != null &&
                    provider['profile_image'] != '') {
                  imageUrl = provider['profile_image'].startsWith('http')
                      ? provider['profile_image']
                      : '${Backend.baseUrl}/${provider['profile_image']}';
                }
                double avgRating = provider['average_rating'] ?? 0.0;
                int totalRatings = provider['total_ratings'] ?? 0;

                return GestureDetector(
                  onTap: () async {
                    dynamic providerDetails;
                    try {
                      final url = Uri.parse(
                        '${Backend.baseUrl}/provider/services/providers/${provider['provider_id']}',
                      );
                      final response = await http.get(url);
                      if (response.statusCode == 200) {
                        providerDetails = jsonDecode(response.body)['provider'];
                      } else {
                        providerDetails = provider;
                      }
                    } catch (_) {
                      providerDetails = provider;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MyProfileScreen(
                          userData: providerDetails,
                          readOnly:
                              widget.currentUserId != provider['provider_id'],
                          currentUserId: widget.currentUserId,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 100,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kCardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: heaidng.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: imageUrl != null
                              ? NetworkImage(imageUrl)
                              : null,
                          backgroundColor: kDividerColor,
                          child: imageUrl == null
                              ? const Icon(
                                  Icons.person,
                                  size: 30,
                                  color: kTextHint,
                                )
                              : null,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          provider['name'] ?? 'Unknown',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: kTextPrimary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.star,
                              color: kWarningColor,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              avgRating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: kTextSecondary,
                                fontSize: 10,
                              ),
                            ),
                            if (totalRatings > 0) ...[
                              const SizedBox(width: 2),
                              Text(
                                '($totalRatings)',
                                style: const TextStyle(
                                  color: kTextHint,
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 20),
      ],
    );
  }
}

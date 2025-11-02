// import 'package:flutter/material.dart';
// import 'MyProfileScreen.dart';
// import '../helpers/backend.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:geolocator/geolocator.dart';
// import 'dart:async';
// import 'package:flutter_background/flutter_background.dart';
// import '../helpers/my_colors.dart';

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

//   Timer? _locationTimer; // ✅ Timer variable

//   @override
//   void initState() {
//     super.initState();
//     initBackground();
//     fetchCategoryProviders();
//     _updateProviderLocation();
//     startPeriodicLocationUpdates(widget.currentUserId); // ✅ Start timer
//   }

//   @override
//   void dispose() {
//     _locationTimer?.cancel(); // ✅ Proper cleanup
//     super.dispose();
//   }

//   //--------------------background update----------
//   Future<void> initBackground() async {
//     final androidConfig = FlutterBackgroundAndroidConfig(
//       notificationTitle: "App is running in background",
//       notificationText: "Your location will be updated periodically",
//       notificationImportance: AndroidNotificationImportance.normal,
//       enableWifiLock: true,
//     );

//     bool hasPermissions = await FlutterBackground.hasPermissions;
//     if (!hasPermissions) {
//       await FlutterBackground.initialize(androidConfig: androidConfig);
//     }

//     await FlutterBackground.enableBackgroundExecution();
//   }

//   //----------------------timer helpers----------
//   void startPeriodicLocationUpdates(int providerId) {
//     _locationTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
//       updateProviderLocation(providerId);
//     });
//   }

//   void stopPeriodicLocationUpdates() {
//     _locationTimer?.cancel();
//   }

//   //------------------update location------------
//   Future<void> _updateProviderLocation() async {
//     await updateProviderLocation(widget.currentUserId);
//   }

//   Future<void> updateProviderLocation(int providerId) async {
//     try {
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

//   //------------------get current location-------
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

//   //final url = Uri.parse('${Backend.baseUrl}/category_providers?category_id=${widget.categoryId}');
//   Future<void> fetchCategoryProviders() async {
//     try {
//       final url = Uri.parse(
//         '${Backend.baseUrl}/services?category_id=${widget.categoryId}',
//       );
//       final response = await http.get(url);
//       print('API Response: ${response.body}');

//       if (response.statusCode == 200) {
//         final List fetchedServices = jsonDecode(response.body);

//         // Group services by provider_id
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

//         providers = uniqueProviders.values.toList();
//         setState(() => isLoading = false);
//       } else {
//         setState(() => isLoading = false);
//         print('Failed: ${response.statusCode}');
//       }
//     } catch (e) {
//       setState(() => isLoading = false);
//       print('Error: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: MyColors.background,

//       appBar: AppBar(
//         title: Text(widget.categoryName, style: TextStyle(color: Colors.white)),
//         centerTitle: true,
//         elevation: 0,
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xFF2A2A40), Color(0xFF3D3A8B)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
//         ),
//       ),

//       body: Column(
//         children: [
//           // ✅ Beautiful Search Bar below AppBar
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: searchController,
//                     style: const TextStyle(
//                       color: Colors.white, // textDark equivalent
//                       fontWeight: FontWeight.w500,
//                       fontSize: 16,
//                     ),

//                     decoration: InputDecoration(
//                       hintText: 'Search for a category',
//                       hintStyle: const TextStyle(
//                         color: MyColors.hintText,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w400,
//                       ),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(25),
//                         borderSide: BorderSide.none,
//                       ),
//                       filled: true,
//                       fillColor: const Color(0xFF232334),
//                       contentPadding: const EdgeInsets.symmetric(
//                         vertical: 14,
//                         horizontal: 16,
//                       ),
//                       prefixIcon: Icon(Icons.search, color: MyColors.primary),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // ✅ Rest of the body
//           Expanded(
//             child: isLoading
//                 ? const Center(
//                     child: CircularProgressIndicator(color: MyColors.primary),
//                   )
//                 : SingleChildScrollView(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         NearbyProvidersWithRatingsWidget(
//                           currentUserId: widget.currentUserId,
//                         ),
//                         const SizedBox(height: 24),
//                         GridView.builder(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           gridDelegate:
//                               const SliverGridDelegateWithFixedCrossAxisCount(
//                                 crossAxisCount: 2,
//                                 childAspectRatio: 0.78,
//                                 mainAxisSpacing: 16,
//                                 crossAxisSpacing: 16,
//                               ),
//                           itemCount: providers.length,
//                           itemBuilder: (context, index) {
//                             final provider = providers[index];
//                             return buildProviderCard(provider);
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildProviderCard(dynamic provider) {
//     // ✅ Correct image mapping
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

//     // ✅ Correct name mapping
//     String displayName =
//         provider['name'] ?? provider['provider_name'] ?? 'Unknown';

//     // ✅ Correct skills mapping
//     String skills = '';
//     if (provider['skills'] != null && provider['skills'] is List) {
//       skills = (provider['skills'] as List).join(', ');
//     } else if (provider['provider_skills'] != null &&
//         provider['provider_skills'] is List) {
//       skills = (provider['provider_skills'] as List).join(', ');
//     }

//     // ✅ Rating
//     double avgRating =
//         double.tryParse(provider['average_rating']?.toString() ?? '0') ?? 0.0;
//     int totalRatings =
//         int.tryParse(provider['total_ratings']?.toString() ?? '0') ?? 0;

//     // ✅ Provider ID
//     final providerId = provider['provider_id'] ?? provider['id'];

//     return GestureDetector(
//       onTap: () async {
//         dynamic providerDetails;
//         try {
//           final url = Uri.parse(
//             '${Backend.baseUrl}/provider/services/providers/${provider['provider_id']}',
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

//       // ✅ Safe layout container
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           return ConstrainedBox(
//             constraints: const BoxConstraints(
//               minWidth: 150,
//               maxWidth: 250, // responsive safe width
//             ),
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [MyColors.surface, Colors.white],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 6,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),

//               // ✅ ScrollView added to avoid overflow
//               child: SingleChildScrollView(
//                 physics: const NeverScrollableScrollPhysics(),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     CircleAvatar(
//                       radius: 38,
//                       backgroundColor: MyColors.primary.withOpacity(0.3),
//                       child: CircleAvatar(
//                         radius: 35,
//                         backgroundImage: imageUrl != null
//                             ? NetworkImage(imageUrl)
//                             : null,
//                         backgroundColor: const Color(0xFF2C2C3A),
//                         child: imageUrl == null
//                             ? const Icon(
//                                 Icons.person,
//                                 color: Colors.white,
//                                 size: 32,
//                               )
//                             : null,
//                       ),
//                     ),

//                     const SizedBox(height: 8),
//                     Text(
//                       displayName,
//                       textAlign: TextAlign.center,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     if (skills.isNotEmpty)
//                       Text(
//                         skills,
//                         textAlign: TextAlign.center,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(
//                           color: Color(0xFF5C74B1),
//                           fontSize: 12,
//                         ),
//                       ),
//                     const SizedBox(height: 6),

//                     // 🔹 Services list (read-only, no delete)
//                     if (provider['services'] != null &&
//                         provider['services'] is List)
//                       ...List.generate(provider['services'].length, (i) {
//                         final service = provider['services'][i];
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 2),
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               vertical: 4,
//                               horizontal: 6,
//                             ),
//                             decoration: BoxDecoration(
//                               color: MyColors.secondary.withOpacity(0.05),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Text(
//                               '- ${service['title']}',
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: const TextStyle(
//                                 color: MyColors.surface,

//                                 fontSize: 12,
//                               ),
//                             ),
//                           ),
//                         );
//                       }),

//                     const SizedBox(height: 6),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Icon(Icons.star, color: Colors.amber, size: 16),
//                         const SizedBox(width: 4),
//                         Text(
//                           avgRating.toStringAsFixed(1),
//                           style: const TextStyle(color: Color(0xFF2A3A69)),
//                         ),
//                         if (totalRatings > 0) ...[
//                           const SizedBox(width: 4),
//                           Text(
//                             '($totalRatings)',
//                             style: const TextStyle(
//                               fontSize: 12,
//                               color: Color(0xFF5C74B1),
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// /// ✅ Nearby Providers with Ratings Widget
// /// ✅ Nearby Providers with Ratings Widget
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

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List rawProviders = data['providers'] ?? [];

//         nearbyProviders = [];

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

//         setState(() => isLoading = false);
//       } else {
//         setState(() => isLoading = false);
//         debugPrint('Failed to fetch nearby providers: ${response.statusCode}');
//       }
//     } catch (e) {
//       setState(() => isLoading = false);
//       debugPrint('Error fetching nearby providers: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (nearbyProviders.isEmpty) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         child: Center(
//           child: Text(
//             'No nearby providers found.',
//             style: TextStyle(color: Color(0xFFA1A1A1), fontSize: 16),
//           ),
//         ),
//       );
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Section Title
//         const Padding(
//           padding: EdgeInsets.symmetric(vertical: 12.0),
//           child: Text(
//             'Nearby Providers',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: MyColors.textPrimary,
//             ),
//           ),
//         ),

//         // Horizontal Scroll List
//         SizedBox(
//           height: 160,
//           child: ListView.separated(
//             scrollDirection: Axis.horizontal,
//             itemCount: nearbyProviders.length,
//             separatorBuilder: (_, __) => const SizedBox(width: 12),
//             itemBuilder: (context, index) {
//               final provider = nearbyProviders[index];

//               String? imageUrl;
//               if (provider['profile_image'] != null &&
//                   provider['profile_image'] != '') {
//                 imageUrl = provider['profile_image'].startsWith('http')
//                     ? provider['profile_image']
//                     : '${Backend.baseUrl}/${provider['profile_image']}';
//               }

//               double avgRating = provider['average_rating'] ?? 0.0;
//               int totalRatings = provider['total_ratings'] ?? 0;

//               return GestureDetector(
//                 onTap: () async {
//                   dynamic providerDetails;
//                   try {
//                     final url = Uri.parse(
//                       '${Backend.baseUrl}/provider/services/providers/${provider['provider_id']}',
//                     );
//                     final response = await http.get(url);
//                     if (response.statusCode == 200) {
//                       providerDetails = jsonDecode(response.body)['provider'];
//                     } else {
//                       providerDetails = provider;
//                     }
//                   } catch (_) {
//                     providerDetails = provider;
//                   }

//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => MyProfileScreen(
//                         userData: providerDetails,
//                         readOnly:
//                             widget.currentUserId != provider['provider_id'],
//                         currentUserId: widget.currentUserId,
//                       ),
//                     ),
//                   );
//                 },
//                 child: Container(
//                   width: 110,
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF1E1E28),
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: MyColors.primary.withOpacity(0.15),
//                         blurRadius: 10,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),

//                   child: Column(
//                     children: [
//                       CircleAvatar(
//                         radius: 35,
//                         backgroundColor: MyColors.primary.withOpacity(0.2),
//                         child: CircleAvatar(
//                           radius: 33,
//                           backgroundImage: imageUrl != null
//                               ? NetworkImage(imageUrl)
//                               : null,
//                           child: imageUrl == null
//                               ? Icon(
//                                   Icons.person,
//                                   size: 35,
//                                   color: MyColors.primary,
//                                 )
//                               : null,
//                           backgroundColor: Colors.white,
//                         ),
//                       ),

//                       const SizedBox(height: 6),
//                       SizedBox(
//                         width: 90,
//                         child: Text(
//                           provider['name'] ?? 'Unknown',
//                           textAlign: TextAlign.center,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFFA1A1A1),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Icon(Icons.star, color: Colors.amber, size: 14),
//                           const SizedBox(width: 2),
//                           Text(
//                             avgRating.toStringAsFixed(1),
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 12,
//                             ),
//                           ),
//                           if (totalRatings > 0) ...[
//                             const SizedBox(width: 2),
//                             Text(
//                               '($totalRatings)',
//                               style: const TextStyle(
//                                 color: Color(0xFF5C74B1),
//                                 fontSize: 10,
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//         SizedBox(height: 20),
//         // Divider / All Providers Section Label
//         const Padding(
//           padding: EdgeInsets.symmetric(vertical: 12.0),
//           child: Text(
//             'Related Services For You',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }










// import 'package:flutter/material.dart';
// import 'MyProfileScreen.dart';
// import '../helpers/backend.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:geolocator/geolocator.dart';
// import 'dart:async';

// import '../helpers/my_colors.dart';

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

//   Timer? _locationTimer; // ✅ Timer variable
//   List<dynamic> filteredRelatedProviders = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchCategoryProviders();
//     _updateProviderLocation();
//     startPeriodicLocationUpdates(widget.currentUserId); // ✅ Start timer

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
//     _locationTimer?.cancel(); // ✅ Proper cleanup
//     super.dispose();
//   }

//   //----------------------timer helpers----------
//   void startPeriodicLocationUpdates(int providerId) {
//     _locationTimer?.cancel(); // ✅ cancel existing timer if any
//     _locationTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
//       updateProviderLocation(providerId);
//     });
//   }

//   void stopPeriodicLocationUpdates() {
//     _locationTimer?.cancel();
//   }

//   //------------------update location------------
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

//   //------------------get current location-------
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

//   //final url = Uri.parse('${Backend.baseUrl}/category_providers?category_id=${widget.categoryId}');
//  Future<void> fetchCategoryProviders() async {
//   try {
//     final url = Uri.parse(
//       '${Backend.baseUrl}/services?category_id=${widget.categoryId}',
//     );
//     final response = await http.get(url);
//     print('API Response: ${response.body}');

//     if (response.statusCode == 200) {
//       final List fetchedServices = jsonDecode(response.body);

//       // Group services by provider_id
//       Map<int, dynamic> uniqueProviders = {};
//       for (var service in fetchedServices) {
//         final pid = service['provider_id'];
//         if (!uniqueProviders.containsKey(pid)) {
//           double avgRating = 0.0;
//           int totalRatings = 0;

//           try {
//             final ratingUrl = Uri.parse(
//               '${Backend.baseUrl}/provider/$pid/ratings',
//             );
//             final ratingResp = await http.get(ratingUrl);
//             if (ratingResp.statusCode == 200) {
//               final ratingData = jsonDecode(ratingResp.body);
//               avgRating =
//                   double.tryParse(
//                         ratingData['average_rating']?.toString() ?? '0',
//                       ) ??
//                       0.0;
//               totalRatings = ratingData['total_ratings'] ?? 0;
//             }
//           } catch (e) {
//             print('Error fetching rating for provider $pid: $e');
//           }
//           uniqueProviders[pid] = {
//             'provider_id': pid,
//             'name': service['provider_name'],
//             'profile_image': service['provider_image'],
//             'skills': service['provider_skills'],
//             'average_rating': avgRating,
//             'total_ratings': totalRatings,
//             'services': [],
//           };
//         }
//         uniqueProviders[pid]['services'].add(service);
//       }

//       if (!mounted) return;
//       providers = uniqueProviders.values.toList();
//       filteredRelatedProviders = providers;
//       setState(() => isLoading = false);
//     } else {
//       if (!mounted) return;
//       setState(() => isLoading = false);
//       print('Failed: ${response.statusCode}');
//     }
//   } catch (e) {
//     if (!mounted) return;
//     setState(() => isLoading = false);
//     print('Error: $e');
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: MyColors.background,

//       appBar: AppBar(
//         title: Text(widget.categoryName, style: TextStyle(color: Colors.white)),
//         centerTitle: true,
//         elevation: 0,
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xFF2A2A40), Color(0xFF3D3A8B)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
//         ),
//       ),

//       body: Column(
//         children: [
//           // ✅ Beautiful Search Bar below AppBar
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: searchController,
//                     style: const TextStyle(
//                       color: Colors.white, // textDark equivalent
//                       fontWeight: FontWeight.w500,
//                       fontSize: 16,
//                     ),

//                     decoration: InputDecoration(
//                       hintText: 'Search for a category',
//                       hintStyle: const TextStyle(
//                         color: MyColors.hintText,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w400,
//                       ),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(25),
//                         borderSide: BorderSide.none,
//                       ),
//                       filled: true,
//                       fillColor: const Color(0xFF232334),
//                       contentPadding: const EdgeInsets.symmetric(
//                         vertical: 14,
//                         horizontal: 16,
//                       ),
//                       prefixIcon: Icon(Icons.search, color: MyColors.primary),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // ✅ Rest of the body
//           Expanded(
//             child: isLoading
//                 ? const Center(
//                     child: CircularProgressIndicator(color: MyColors.primary),
//                   )
//                 : SingleChildScrollView(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         NearbyProvidersWithRatingsWidget(
//                           currentUserId: widget.currentUserId,
//                         ),
//                         const SizedBox(height: 24),
//                         GridView.builder(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           gridDelegate:
//                               const SliverGridDelegateWithFixedCrossAxisCount(
//                                 crossAxisCount: 2,
//                                 childAspectRatio: 0.78,
//                                 mainAxisSpacing: 16,
//                                 crossAxisSpacing: 16,
//                               ),
//                           itemCount: filteredRelatedProviders.length,
//                           itemBuilder: (context, index) {
//                             final provider = filteredRelatedProviders[index];
//                             return buildProviderCard(provider);
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildProviderCard(dynamic provider) {
//     // ✅ Correct image mapping
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

//     // ✅ Correct name mapping
//     String displayName =
//         provider['name'] ?? provider['provider_name'] ?? 'Unknown';

//     // ✅ Correct skills mapping
//     String skills = '';
//     if (provider['skills'] != null && provider['skills'] is List) {
//       skills = (provider['skills'] as List).join(', ');
//     } else if (provider['provider_skills'] != null &&
//         provider['provider_skills'] is List) {
//       skills = (provider['provider_skills'] as List).join(', ');
//     }

//     // ✅ Rating
//     double avgRating =
//         double.tryParse(provider['average_rating']?.toString() ?? '0') ?? 0.0;
//     int totalRatings =
//         int.tryParse(provider['total_ratings']?.toString() ?? '0') ?? 0;

//     // ✅ Provider ID
//     final providerId = provider['provider_id'] ?? provider['id'];

//     return GestureDetector(
//       onTap: () async {
//         dynamic providerDetails;
//         try {
//           final url = Uri.parse(
//             '${Backend.baseUrl}/provider/services/providers/${provider['provider_id']}',
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

//       // ✅ Safe layout container
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           return ConstrainedBox(
//             constraints: const BoxConstraints(
//               minWidth: 150,
//               maxWidth: 250, // responsive safe width
//             ),
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [MyColors.surface, Colors.white],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 6,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),

//               // ✅ ScrollView added to avoid overflow
//               child: SingleChildScrollView(
//                 physics: const NeverScrollableScrollPhysics(),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     CircleAvatar(
//                       radius: 38,
//                       backgroundColor: MyColors.primary.withOpacity(0.3),
//                       child: CircleAvatar(
//                         radius: 35,
//                         backgroundImage: imageUrl != null
//                             ? NetworkImage(imageUrl)
//                             : null,
//                         backgroundColor: const Color(0xFF2C2C3A),
//                         child: imageUrl == null
//                             ? const Icon(
//                                 Icons.person,
//                                 color: Colors.white,
//                                 size: 32,
//                               )
//                             : null,
//                       ),
//                     ),

//                     const SizedBox(height: 8),
//                     Text(
//                       displayName,
//                       textAlign: TextAlign.center,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     if (skills.isNotEmpty)
//                       Text(
//                         skills,
//                         textAlign: TextAlign.center,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(
//                           color: Color(0xFF5C74B1),
//                           fontSize: 12,
//                         ),
//                       ),
//                     const SizedBox(height: 6),

//                     // 🔹 Services list (read-only, no delete)
//                     if (provider['services'] != null &&
//                         provider['services'] is List)
//                       ...List.generate(provider['services'].length, (i) {
//                         final service = provider['services'][i];
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 2),
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               vertical: 4,
//                               horizontal: 6,
//                             ),
//                             decoration: BoxDecoration(
//                               color: MyColors.secondary.withOpacity(0.05),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Text(
//                               '- ${service['title']}',
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: const TextStyle(
//                                 color: MyColors.surface,

//                                 fontSize: 12,
//                               ),
//                             ),
//                           ),
//                         );
//                       }),

//                     const SizedBox(height: 6),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Icon(Icons.star, color: Colors.amber, size: 16),
//                         const SizedBox(width: 4),
//                         Text(
//                           avgRating.toStringAsFixed(1),
//                           style: const TextStyle(color: Color(0xFF2A3A69)),
//                         ),
//                         if (totalRatings > 0) ...[
//                           const SizedBox(width: 4),
//                           Text(
//                             '($totalRatings)',
//                             style: const TextStyle(
//                               fontSize: 12,
//                               color: Color(0xFF5C74B1),
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// /// ✅ Nearby Providers with Ratings Widget
// /// ✅ Nearby Providers with Ratings Widget
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

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List rawProviders = data['providers'] ?? [];

//         nearbyProviders = [];

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

//         setState(() => isLoading = false);
//       } else {
//         setState(() => isLoading = false);
//         debugPrint('Failed to fetch nearby providers: ${response.statusCode}');
//       }
//     } catch (e) {
//       setState(() => isLoading = false);
//       debugPrint('Error fetching nearby providers: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (nearbyProviders.isEmpty) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         child: Center(
//           child: Text(
//             'No nearby providers found.',
//             style: TextStyle(color: Color(0xFFA1A1A1), fontSize: 16),
//           ),
//         ),
//       );
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Section Title
//         const Padding(
//           padding: EdgeInsets.symmetric(vertical: 12.0),
//           child: Text(
//             'Nearby Providers',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: MyColors.textPrimary,
//             ),
//           ),
//         ),

//         // Horizontal Scroll List
//         SizedBox(
//           height: 160,
//           child: ListView.separated(
//             scrollDirection: Axis.horizontal,
//             itemCount: nearbyProviders.length,
//             separatorBuilder: (_, __) => const SizedBox(width: 12),
//             itemBuilder: (context, index) {
//               final provider = nearbyProviders[index];

//               String? imageUrl;
//               if (provider['profile_image'] != null &&
//                   provider['profile_image'] != '') {
//                 imageUrl = provider['profile_image'].startsWith('http')
//                     ? provider['profile_image']
//                     : '${Backend.baseUrl}/${provider['profile_image']}';
//               }

//               double avgRating = provider['average_rating'] ?? 0.0;
//               int totalRatings = provider['total_ratings'] ?? 0;

//               return GestureDetector(
//                 onTap: () async {
//                   dynamic providerDetails;
//                   try {
//                     final url = Uri.parse(
//                       '${Backend.baseUrl}/provider/services/providers/${provider['provider_id']}',
//                     );
//                     final response = await http.get(url);
//                     if (response.statusCode == 200) {
//                       providerDetails = jsonDecode(response.body)['provider'];
//                     } else {
//                       providerDetails = provider;
//                     }
//                   } catch (_) {
//                     providerDetails = provider;
//                   }

//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => MyProfileScreen(
//                         userData: providerDetails,
//                         readOnly:
//                             widget.currentUserId != provider['provider_id'],
//                         currentUserId: widget.currentUserId,
//                       ),
//                     ),
//                   );
//                 },
//                 child: Container(
//                   width: 110,
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF1E1E28),
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: MyColors.primary.withOpacity(0.15),
//                         blurRadius: 10,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),

//                   child: Column(
//                     children: [
//                       CircleAvatar(
//                         radius: 35,
//                         backgroundColor: MyColors.primary.withOpacity(0.2),
//                         child: CircleAvatar(
//                           radius: 33,
//                           backgroundImage: imageUrl != null
//                               ? NetworkImage(imageUrl)
//                               : null,
//                           child: imageUrl == null
//                               ? Icon(
//                                   Icons.person,
//                                   size: 35,
//                                   color: MyColors.primary,
//                                 )
//                               : null,
//                           backgroundColor: Colors.white,
//                         ),
//                       ),

//                       const SizedBox(height: 6),
//                       SizedBox(
//                         width: 90,
//                         child: Text(
//                           provider['name'] ?? 'Unknown',
//                           textAlign: TextAlign.center,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFFA1A1A1),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Icon(Icons.star, color: Colors.amber, size: 14),
//                           const SizedBox(width: 2),
//                           Text(
//                             avgRating.toStringAsFixed(1),
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 12,
//                             ),
//                           ),
//                           if (totalRatings > 0) ...[
//                             const SizedBox(width: 2),
//                             Text(
//                               '($totalRatings)',
//                               style: const TextStyle(
//                                 color: Color(0xFF5C74B1),
//                                 fontSize: 10,
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//         SizedBox(height: 20),
//         // Divider / All Providers Section Label
//         const Padding(
//           padding: EdgeInsets.symmetric(vertical: 12.0),
//           child: Text(
//             'Related Services For You',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }









import 'package:flutter/material.dart';
import 'MyProfileScreen.dart';
import '../helpers/backend.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

// Your NEW Color Scheme
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
      
      // ✨ New AppBar Design: Clean, single color, no gradient for a modern look
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            color: buttonText, // White text on primary background
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: kPrimaryColor,
      ),

      body: Column(
        children: [
          // ✨ Redesigned Search Bar: Floating card effect for prominence
          Padding(
            padding: const EdgeInsets.all(16.0),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: kCardColor, // White fill color
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: kPrimaryColor,
                ),
                // Add a subtle elevation/shadow to the search field
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kDividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kPrimaryColor, width: 2),
                ),
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
                        // Nearby Providers Section
                        NearbyProvidersWithRatingsWidget(
                          currentUserId: widget.currentUserId,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // All Related Providers Section Title
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'All Related Providers',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: kTextPrimary,
                            ),
                          ),
                        ),
                        
                        // Grid of Providers
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.70, // Adjusted for new card height
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                              ),
                          itemCount: filteredRelatedProviders.length,
                          itemBuilder: (context, index) {
                            final provider = filteredRelatedProviders[index];
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



  // ✨ Redesigned Provider Card: Elevated, cleaner look
  Widget buildProviderCard(dynamic provider) {
    // --- Logic for data mapping (Maintained) ---
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

    String skills = '';
    if (provider['skills'] != null && provider['skills'] is List) {
      skills = (provider['skills'] as List).join(', ');
    } else if (provider['provider_skills'] != null &&
        provider['provider_skills'] is List) {
      skills = (provider['provider_skills'] as List).join(', ');
    }

    double avgRating =
        double.tryParse(provider['average_rating']?.toString() ?? '0') ?? 0.0;
    int totalRatings =
        int.tryParse(provider['total_ratings']?.toString() ?? '0') ?? 0;

    final providerId = provider['provider_id'] ?? provider['id'];
    // ---------------------------------------------

    return GestureDetector(
      onTap: () async {
        // --- Navigation Logic (Maintained) ---
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
              readOnly: widget.currentUserId != providerId,
              currentUserId: widget.currentUserId,
            ),
          ),
        );
        // -------------------------------------
      },

      // ✨ Card UI: White background, subtle shadow, and clean layout
      child: Container(
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:heaidng.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Avatar
            Center(
              child: CircleAvatar(
                radius: 38,
                backgroundColor: kPrimaryColor.withOpacity(0.1),
                child: CircleAvatar(
                  radius: 35,
                  backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                  backgroundColor:kDividerColor,
                  child: imageUrl == null
                      ? const Icon(
                          Icons.person,
                          color: kTextHint,
                          size: 38,
                        )
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 10),
            
            // Name
            Text(
              displayName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: kTextPrimary,
                fontSize: 16,
              ),
            ),
            
            // Skills
            if (skills.isNotEmpty)
              Text(
                skills,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: kTextSecondary,
                  fontSize: 12,
                ),
              ),
            const SizedBox(height: 6),

            // Rating Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: kWarningColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  avgRating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: kTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (totalRatings > 0) ...[
                  const SizedBox(width: 4),
                  Text(
                    '($totalRatings)',
                    style: const TextStyle(
                      fontSize: 12,
                      color: kTextSecondary,
                    ),
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 8),

            // Services List - Scrollable list in the card for better space use
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                physics: const ClampingScrollPhysics(), // Allow scrolling for many services
                itemCount: provider['services'] != null && provider['services'] is List
                    ? (provider['services'] as List).length
                    : 0,
                itemBuilder: (context, i) {
                  final service = provider['services'][i];
                  return Center(
                    child: IntrinsicWidth(
                 child:Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '• ${service['title']}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: kTextSecondary,
                        fontSize: 12,
                        
                      ),
                   
                    ),
                  ),
                    )
                  );
                },
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

  // --- Logic for fetching location and nearby providers (Maintained) ---
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List rawProviders = data['providers'] ?? [];

        nearbyProviders = [];

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

        setState(() => isLoading = false);
      } else {
        setState(() => isLoading = false);
        debugPrint('Failed to fetch nearby providers: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error fetching nearby providers: $e');
    }
  }
  // ----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.0),
          child: CircularProgressIndicator(color: kPrimaryColor),
        ),
      );
    }

    if (nearbyProviders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No nearby providers found.',
            style: TextStyle(color:kTextHint, fontSize: 16),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            'Providers Near You',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kTextPrimary,
            ),
          ),
        ),

        // ✨ Horizontal Scroll List Design
        SizedBox(
          height: 140, // Reduced height for cleaner look
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: nearbyProviders.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final provider = nearbyProviders[index];

              // --- Data Mapping (Maintained) ---
              String? imageUrl;
              if (provider['profile_image'] != null &&
                  provider['profile_image'] != '') {
                imageUrl = provider['profile_image'].startsWith('http')
                    ? provider['profile_image']
                    : '${Backend.baseUrl}/${provider['profile_image']}';
              }
              double avgRating = provider['average_rating'] ?? 0.0;
              int totalRatings = provider['total_ratings'] ?? 0;
              // ---------------------------------

              return GestureDetector(
                onTap: () async {
                  // --- Navigation Logic (Maintained) ---
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
                  // ---------------------------------
                },
                
                // ✨ Card UI: Clean white card for nearby providers
                child: Container(
                  width: 100, // Reduced width
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
                      // Avatar
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
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
                      
                      // Name
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
                      
                      // Rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color:kWarningColor, size: 12),
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
        
        // This label is moved up to the main CategoryPage build method for better structure
      ],
    );
  }
}
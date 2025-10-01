

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:geolocator/geolocator.dart';
// import '../helpers/backend.dart';
// import 'MyProfileScreen.dart';
// import 'side_menu.dart';
// import 'category_page.dart'; // Make sure you have this page

// class ServicesScreen extends StatefulWidget {
//   final int currentUserId;
//   const ServicesScreen({Key? key, required this.currentUserId})
//       : super(key: key);

//   @override
//   ServicesScreenState createState() => ServicesScreenState();
// }

// class ServicesScreenState extends State<ServicesScreen> {
//   bool isLoading = true;
//   List<dynamic> providers = [];
//   List<dynamic> filteredProviders = [];
//   List<dynamic> nearbyProviders = [];
//   TextEditingController searchController = TextEditingController();
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   double? userLat;
//   double? userLng;
// List<dynamic> categories = [];

//   Future<void> fetchCategories() async {
//   try {
//     final url = Uri.parse('${Backend.baseUrl}/categories');
//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       setState(() {
//         // Check if data is a List directly or inside 'categories'
//         categories = data is List ? data : data['categories'] ?? [];
//       });
//       print("Fetched categories: $categories"); // Debug
//     } else {
//       showSnack('Failed to load categories ❌');
//     }
//   } catch (e) {
//     showSnack('Error fetching categories: $e');
//   }
// }



//   @override
//   void initState() {
//     super.initState();
//     getUserLocation();
//     fetchCategories();
//     searchController.addListener(_onSearchChanged);
//   }

//   @override
//   void dispose() {
//     searchController.dispose();
//     super.dispose();
//   }

//   void _onSearchChanged() {
//     String query = searchController.text.toLowerCase();
//     setState(() {
//       filteredProviders = providers.where((provider) {
//         String name = provider['name']?.toLowerCase() ?? '';
//         String skills = provider['skills'] != null
//             ? (provider['skills'] as List).join(', ').toLowerCase()
//             : '';
//         return name.contains(query) || skills.contains(query);
//       }).toList();
//     });
//   }

//   Future<void> getUserLocation() async {
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         showSnack('Please enable location services');
//         fetchProviders();
//         return;
//       }

//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           showSnack('Location permission denied');
//           fetchProviders();
//           return;
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         showSnack('Location permissions are permanently denied');
//         fetchProviders();
//         return;
//       }

//       final position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       setState(() {
//         userLat = position.latitude;
//         userLng = position.longitude;
//       });

//       fetchNearbyProviders();
//       fetchProviders();
//     } catch (e) {
//       showSnack('Location error: $e');
//       fetchProviders();
//     }
//   }

//   Future<void> fetchProviders() async {
//     setState(() => isLoading = true);
//     try {
//       final url = Uri.parse('${Backend.baseUrl}/provider');
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> tempProviders = data['providers'] ?? [];

//         // Fetch ratings
//         for (var provider in tempProviders) {
//           try {
//             final ratingUrl = Uri.parse(
//                 '${Backend.baseUrl}/provider/${provider['id']}/ratings');
//             final ratingResp = await http.get(ratingUrl);
//             if (ratingResp.statusCode == 200) {
//               final ratingData = jsonDecode(ratingResp.body);
//               provider['average_rating'] =
//                   double.tryParse(ratingData['average_rating']?.toString() ?? '0') ??
//                       0.0;
//               provider['total_ratings'] =
//                   int.tryParse(ratingData['total_ratings']?.toString() ?? '0') ??
//                       0;
//             } else {
//               provider['average_rating'] = 0.0;
//               provider['total_ratings'] = 0;
//             }
//           } catch (_) {
//             provider['average_rating'] = 0.0;
//             provider['total_ratings'] = 0;
//           }
//         }

//         setState(() {
//           providers = tempProviders;
//           filteredProviders = providers;
//         });
//       } else {
//         showSnack('Failed to load providers ❌');
//       }
//     } catch (e) {
//       showSnack('Error fetching providers: $e');
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> fetchNearbyProviders() async {
//     if (userLat == null || userLng == null) return;
//     try {
//       final url = Uri.parse(
//         '${Backend.baseUrl}/provider/nearest?lat=$userLat&lng=$userLng&limit=10',
//       );
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           nearbyProviders = data['providers'] ?? [];
//         });
//       } else {
//         showSnack('Failed to load nearby providers ❌');
//       }
//     } catch (e) {
//       showSnack('Error fetching nearby providers: $e');
//     }
//   }

//   void showSnack(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   Widget buildNearbyCard(dynamic provider) {
//     String? imageUrl;
//     if (provider['profile_image'] != null && provider['profile_image'] != '') {
//       imageUrl = provider['profile_image'].startsWith('http')
//           ? provider['profile_image']
//           : '${Backend.baseUrl}/${provider['profile_image']}';
//     }

//     return GestureDetector(
//       onTap: () async {
//         dynamic providerDetails;
//         try {
//           final url = Uri.parse(
//               '${Backend.baseUrl}/provider/services/providers/${provider['id']}');
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
//               readOnly: widget.currentUserId != provider['id'],
//               currentUserId: widget.currentUserId,
//             ),
//           ),
//         );
//       },
//       child: Column(
//         children: [
//           CircleAvatar(
//             radius: 40,
//             backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
//             child: imageUrl == null
//                 ? const Icon(Icons.person, size: 40, color: Color(0xFF2A3A69))
//                 : null,
//             backgroundColor: Colors.white,
//           ),
//           const SizedBox(height: 6),
//           SizedBox(
//             width: 80,
//             child: Text(
//               provider['name'] ?? 'Unknown',
//               textAlign: TextAlign.center,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(
//                   fontWeight: FontWeight.bold, color: Color(0xFF2A3A69)),
//             ),
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
//     }

//     String skills = '';
//     if (provider['skills'] != null && provider['skills'] is List) {
//       skills = (provider['skills'] as List).join(', ');
//     }

//     double avgRating = provider['average_rating']?.toDouble() ?? 0.0;
//     int totalRatings = provider['total_ratings'] ?? 0;

//     return GestureDetector(
//       onTap: () async {
//         dynamic providerDetails;
//         try {
//           final url = Uri.parse(
//               '${Backend.baseUrl}/provider/services/providers/${provider['id']}');
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
//               readOnly: widget.currentUserId != provider['id'],
//               currentUserId: widget.currentUserId,
//             ),
//           ),
//         );
//       },
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: const Color(0xFFD9E1F0),
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black26,
//               blurRadius: 6,
//               offset: Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircleAvatar(
//               radius: 35,
//               backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
//               child: imageUrl == null
//                   ? const Icon(Icons.person, size: 35, color: Color(0xFF2A3A69))
//                   : null,
//               backgroundColor: Colors.white,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               provider['name'] ?? 'Unknown',
//               textAlign: TextAlign.center,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(
//                   fontWeight: FontWeight.bold, color: Color(0xFF2A3A69)),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               skills.isNotEmpty ? skills : 'No skills',
//               textAlign: TextAlign.center,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(color: Color(0xFF5C74B1), fontSize: 12),
//             ),
//             const SizedBox(height: 6),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.star, color: Colors.amber, size: 16),
//                 SizedBox(width: 4),
//                 Text(avgRating.toStringAsFixed(1),
//                     style: TextStyle(color: Color(0xFF2A3A69))),
//                 if (totalRatings > 0) ...[
//                   SizedBox(width: 4),
//                   Text('($totalRatings)',
//                       style: TextStyle(fontSize: 12, color: Color(0xFF5C74B1))),
//                 ],
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       resizeToAvoidBottomInset: true,
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF0A66C2),
//         elevation: 4,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(
//             bottom: Radius.circular(16),
//           ),
//         ),
//         toolbarHeight: 60,
//         titleSpacing: 16,
//         leading: IconButton(
//           icon: const Icon(Icons.menu, color: Colors.white),
//           onPressed: () => _scaffoldKey.currentState?.openDrawer(),
//         ),
//         title: const Text(
//           'Services',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       drawer: SideMenu(
//         logoPath: "assets/images/logo.png",
//         primaryColor: const Color(0xFF0A66C2),
//         secondaryColor: const Color(0xFFD9E1F0),
//         highlightColor: const Color(0xFF2A3A69),
//         selectedMenu: "About Us",
//         onMenuSelected: (menu) {
//           Navigator.pop(context);
//         },
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           reverse: true,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Tagline
//               Padding(
//                 padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
//                 child: Text(
//                   'Your Trusted Service, Just a Tap Away',
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF0A66C2),
//                     height: 1.5,
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//               ),

//               // Search Bar
//               TextField(
//                 controller: searchController,
//                 style: const TextStyle(
//                   color: Color(0xFF2A3A69),
//                   fontWeight: FontWeight.w500,
//                   fontSize: 16,
//                 ),
//                 decoration: InputDecoration(
//                   hintText: 'Search for a service',
//                   hintStyle: const TextStyle(
//                     color: Color(0xFF5C74B1),
//                     fontSize: 16,
//                     fontWeight: FontWeight.w400,
//                   ),
//                   prefixIcon: const Icon(Icons.search, color: Color(0xFF0A66C2)),
//                   filled: true,
//                   fillColor: const Color(0xFFE6F0FA),
//                   contentPadding:
//                       const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(18),
//                     borderSide: BorderSide.none,
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(18),
//                     borderSide:
//                         const BorderSide(color: Color(0xFF0A66C2), width: 2),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // Nearby Providers
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 12.0),
//                 child: Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFE6F0FA),
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black12,
//                         blurRadius: 6,
//                         offset: Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: const Text(
//                     'Your Nearby Providers',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF0A66C2),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               SizedBox(
//                 height: 130,
//                 child: nearbyProviders.isNotEmpty
//                     ? ListView.separated(
//                         scrollDirection: Axis.horizontal,
//                         itemCount: nearbyProviders.length,
//                         separatorBuilder: (_, __) => const SizedBox(width: 12),
//                         itemBuilder: (context, index) =>
//                             buildNearbyCard(nearbyProviders[index]),
//                       )
//                     : Center(
//                         child: Text(
//                           'No nearby providers available',
//                           style: TextStyle(
//                             color: Color(0xFF5C74B1),
//                             fontSize: 14,
//                             fontStyle: FontStyle.italic,
//                           ),
//                         ),
//                       ),
//               ),

//               const SizedBox(height: 16),
// buildCategorySection(),





//               // Categories & Explore All Services
//              // Section-wise Categories
// ...[

// ],

//               const SizedBox(height: 16),

           



//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildCategorySection() {
//   if (categories.isEmpty) {
//     return const Center(child: CircularProgressIndicator());
//   }

//   // Group categories by section
//   Map<String, List<dynamic>> groupedCategories = {};
//   for (var cat in categories) {
//     String section = cat.containsKey('section') ? cat['section'] : 'Other';
//     if (!groupedCategories.containsKey(section)) {
//       groupedCategories[section] = [];
//     }
//     groupedCategories[section]!.add(cat);
//   }

//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: groupedCategories.entries.map((entry) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8.0),
//             child: Text(
//               entry.key, // section heading
//               style: const TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//           ),
//           GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: entry.value.length,
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 3,
//               mainAxisSpacing: 12,
//               crossAxisSpacing: 12,
//               childAspectRatio: 0.8,
//             ),
//             itemBuilder: (context, index) {
//               final category = entry.value[index];
//               String? imagePath = category['image_url'];

//               Widget imageWidget;

//               if (imagePath != null && imagePath.isNotEmpty) {
//                 if (imagePath.startsWith('http')) {
//                   // Load network image with fallback
//                   imageWidget = Image.network(
//                     imagePath,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) {
//                       return const CircleAvatar(
//                         radius: 30,
//                         backgroundColor: Colors.grey,
//                         child: Icon(Icons.image, color: Colors.white, size: 30),
//                       );
//                     },
//                   );
//                 } else if (imagePath.startsWith('assets/')) {
//                   // Load asset image
//                   imageWidget = Image.asset(
//                     imagePath,
//                     fit: BoxFit.cover,
//                   );
//                 } else {
//                   // Unknown format → fallback
//                   imageWidget = const CircleAvatar(
//                     radius: 30,
//                     backgroundColor: Colors.grey,
//                     child: Icon(Icons.image, color: Colors.white, size: 30),
//                   );
//                 }
//               } else {
//                 // No image provided → fallback
//                 imageWidget = const CircleAvatar(
//                   radius: 30,
//                   backgroundColor: Colors.grey,
//                   child: Icon(Icons.image, color: Colors.white, size: 30),
//                 );
//               }

//               return GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => CategoryPage(
//                         categoryId: category['id'],
//                         categoryName: category['name'],
//                         currentUserId: widget.currentUserId,
//                       ),
//                     ),
//                   );
//                 },
//                 child: Column(
//                   children: [
//                     Expanded(
//                       child: Container(
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           color: Colors.grey[200],
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         clipBehavior: Clip.antiAlias,
//                         child: imageWidget,
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       category['name'] ?? 'Unknown',
//                       textAlign: TextAlign.center,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(
//                         color: Color(0xFF0A66C2),
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//           const SizedBox(height: 16),
//         ],
//       );
//     }).toList(),
//   );
// }

// }






// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:geolocator/geolocator.dart';
// import '../helpers/backend.dart';
// import 'MyProfileScreen.dart';
// import 'side_menu.dart';
// import 'category_page.dart'; // Make sure you have this page

// class ServicesScreen extends StatefulWidget {
//   final int currentUserId;
//   const ServicesScreen({Key? key, required this.currentUserId})
//       : super(key: key);

//   @override
//   ServicesScreenState createState() => ServicesScreenState();
// }

// class ServicesScreenState extends State<ServicesScreen> {
//   bool isLoading = true;
//   List<dynamic> providers = [];
//   List<dynamic> filteredProviders = [];
//   List<dynamic> nearbyProviders = [];
//   TextEditingController searchController = TextEditingController();
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   double? userLat;
//   double? userLng;
// List<dynamic> categories = [];

//   Future<void> fetchCategories() async {
//   try {
//     final url = Uri.parse('${Backend.baseUrl}/categories');
//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       setState(() {
//         // Check if data is a List directly or inside 'categories'
//         categories = data is List ? data : data['categories'] ?? [];
//       });
//       print("Fetched categories: $categories"); // Debug
//     } else {
//       showSnack('Failed to load categories ❌');
//     }
//   } catch (e) {
//     showSnack('Error fetching categories: $e');
//   }
// }



//   @override
//   void initState() {
//     super.initState();
//     getUserLocation();
//     fetchCategories();
//     searchController.addListener(_onSearchChanged);
//   }

//   @override
//   void dispose() {
//     searchController.dispose();
//     super.dispose();
//   }

//   void _onSearchChanged() {
//     String query = searchController.text.toLowerCase();
//     setState(() {
//       filteredProviders = providers.where((provider) {
//         String name = provider['name']?.toLowerCase() ?? '';
//         String skills = provider['skills'] != null
//             ? (provider['skills'] as List).join(', ').toLowerCase()
//             : '';
//         return name.contains(query) || skills.contains(query);
//       }).toList();
//     });
//   }

//   Future<void> getUserLocation() async {
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         showSnack('Please enable location services');
//         fetchProviders();
//         return;
//       }

//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           showSnack('Location permission denied');
//           fetchProviders();
//           return;
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         showSnack('Location permissions are permanently denied');
//         fetchProviders();
//         return;
//       }

//       final position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       setState(() {
//         userLat = position.latitude;
//         userLng = position.longitude;
//       });

//       fetchNearbyProviders();
//       fetchProviders();
//     } catch (e) {
//       showSnack('Location error: $e');
//       fetchProviders();
//     }
//   }

//   Future<void> fetchProviders() async {
//     setState(() => isLoading = true);
//     try {
//       final url = Uri.parse('${Backend.baseUrl}/provider');
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> tempProviders = data['providers'] ?? [];

//         // Fetch ratings
//         for (var provider in tempProviders) {
//           try {
//             final ratingUrl = Uri.parse(
//                 '${Backend.baseUrl}/provider/${provider['id']}/ratings');
//             final ratingResp = await http.get(ratingUrl);
//             if (ratingResp.statusCode == 200) {
//               final ratingData = jsonDecode(ratingResp.body);
//               provider['average_rating'] =
//                   double.tryParse(ratingData['average_rating']?.toString() ?? '0') ??
//                       0.0;
//               provider['total_ratings'] =
//                   int.tryParse(ratingData['total_ratings']?.toString() ?? '0') ??
//                       0;
//             } else {
//               provider['average_rating'] = 0.0;
//               provider['total_ratings'] = 0;
//             }
//           } catch (_) {
//             provider['average_rating'] = 0.0;
//             provider['total_ratings'] = 0;
//           }
//         }

//         setState(() {
//           providers = tempProviders;
//           filteredProviders = providers;
//         });
//       } else {
//         showSnack('Failed to load providers ❌');
//       }
//     } catch (e) {
//       showSnack('Error fetching providers: $e');
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> fetchNearbyProviders() async {
//     if (userLat == null || userLng == null) return;
//     try {
//       final url = Uri.parse(
//         '${Backend.baseUrl}/provider/nearest?lat=$userLat&lng=$userLng&limit=10',
//       );
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           nearbyProviders = data['providers'] ?? [];
//         });
//       } else {
//         showSnack('Failed to load nearby providers ❌');
//       }
//     } catch (e) {
//       showSnack('Error fetching nearby providers: $e');
//     }
//   }

//   void showSnack(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   Widget buildNearbyCard(dynamic provider) {
//     String? imageUrl;
//     if (provider['profile_image'] != null && provider['profile_image'] != '') {
//       imageUrl = provider['profile_image'].startsWith('http')
//           ? provider['profile_image']
//           : '${Backend.baseUrl}/${provider['profile_image']}';
//     }

//     return GestureDetector(
//       onTap: () async {
//         dynamic providerDetails;
//         try {
//           final url = Uri.parse(
//               '${Backend.baseUrl}/provider/services/providers/${provider['id']}');
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
//               readOnly: widget.currentUserId != provider['id'],
//               currentUserId: widget.currentUserId,
//             ),
//           ),
//         );
//       },
//       child: Column(
//         children: [
//           CircleAvatar(
//             radius: 40,
//             backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
//             child: imageUrl == null
//                 ? const Icon(Icons.person, size: 40, color: Color(0xFF2A3A69))
//                 : null,
//             backgroundColor: Colors.white,
//           ),
//           const SizedBox(height: 6),
//           SizedBox(
//             width: 80,
//             child: Text(
//               provider['name'] ?? 'Unknown',
//               textAlign: TextAlign.center,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(
//                   fontWeight: FontWeight.bold, color: Color(0xFF2A3A69)),
//             ),
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
//     }

//     String skills = '';
//     if (provider['skills'] != null && provider['skills'] is List) {
//       skills = (provider['skills'] as List).join(', ');
//     }

//     double avgRating = provider['average_rating']?.toDouble() ?? 0.0;
//     int totalRatings = provider['total_ratings'] ?? 0;

//     return GestureDetector(
//       onTap: () async {
//         dynamic providerDetails;
//         try {
//           final url = Uri.parse(
//               '${Backend.baseUrl}/provider/services/providers/${provider['id']}');
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
//               readOnly: widget.currentUserId != provider['id'],
//               currentUserId: widget.currentUserId,
//             ),
//           ),
//         );
//       },
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: const Color(0xFFD9E1F0),
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black26,
//               blurRadius: 6,
//               offset: Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircleAvatar(
//               radius: 35,
//               backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
//               child: imageUrl == null
//                   ? const Icon(Icons.person, size: 35, color: Color(0xFF2A3A69))
//                   : null,
//               backgroundColor: Colors.white,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               provider['name'] ?? 'Unknown',
//               textAlign: TextAlign.center,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(
//                   fontWeight: FontWeight.bold, color: Color(0xFF2A3A69)),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               skills.isNotEmpty ? skills : 'No skills',
//               textAlign: TextAlign.center,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(color: Color(0xFF5C74B1), fontSize: 12),
//             ),
//             const SizedBox(height: 6),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.star, color: Colors.amber, size: 16),
//                 SizedBox(width: 4),
//                 Text(avgRating.toStringAsFixed(1),
//                     style: TextStyle(color: Color(0xFF2A3A69))),
//                 if (totalRatings > 0) ...[
//                   SizedBox(width: 4),
//                   Text('($totalRatings)',
//                       style: TextStyle(fontSize: 12, color: Color(0xFF5C74B1))),
//                 ],
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       resizeToAvoidBottomInset: true,
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF0A66C2),
//         elevation: 4,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(
//             bottom: Radius.circular(16),
//           ),
//         ),
//         toolbarHeight: 60,
//         titleSpacing: 16,
//         leading: IconButton(
//           icon: const Icon(Icons.menu, color: Colors.white),
//           onPressed: () => _scaffoldKey.currentState?.openDrawer(),
//         ),
//         title: const Text(
//           'Services',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       drawer: SideMenu(
//         logoPath: "assets/images/logo.png",
//         primaryColor: const Color(0xFF0A66C2),
//         secondaryColor: const Color(0xFFD9E1F0),
//         highlightColor: const Color(0xFF2A3A69),
//         selectedMenu: "About Us",
//         onMenuSelected: (menu) {
//           Navigator.pop(context);
//         },
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           reverse: true,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Tagline
//               Padding(
//                 padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
//                 child: Text(
//                   'Your Trusted Service, Just a Tap Away',
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF0A66C2),
//                     height: 1.5,
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//               ),

//               // Search Bar
//               TextField(
//                 controller: searchController,
//                 style: const TextStyle(
//                   color: Color(0xFF2A3A69),
//                   fontWeight: FontWeight.w500,
//                   fontSize: 16,
//                 ),
//                 decoration: InputDecoration(
//                   hintText: 'Search for a service',
//                   hintStyle: const TextStyle(
//                     color: Color(0xFF5C74B1),
//                     fontSize: 16,
//                     fontWeight: FontWeight.w400,
//                   ),
//                   prefixIcon: const Icon(Icons.search, color: Color(0xFF0A66C2)),
//                   filled: true,
//                   fillColor: const Color(0xFFE6F0FA),
//                   contentPadding:
//                       const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(18),
//                     borderSide: BorderSide.none,
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(18),
//                     borderSide:
//                         const BorderSide(color: Color(0xFF0A66C2), width: 2),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // Nearby Providers
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 12.0),
//                 child: Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFE6F0FA),
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black12,
//                         blurRadius: 6,
//                         offset: Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: const Text(
//                     'Your Nearby Providers',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF0A66C2),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               SizedBox(
//                 height: 130,
//                 child: nearbyProviders.isNotEmpty
//                     ? ListView.separated(
//                         scrollDirection: Axis.horizontal,
//                         itemCount: nearbyProviders.length,
//                         separatorBuilder: (_, __) => const SizedBox(width: 12),
//                         itemBuilder: (context, index) =>
//                             buildNearbyCard(nearbyProviders[index]),
//                       )
//                     : Center(
//                         child: Text(
//                           'No nearby providers available',
//                           style: TextStyle(
//                             color: Color(0xFF5C74B1),
//                             fontSize: 14,
//                             fontStyle: FontStyle.italic,
//                           ),
//                         ),
//                       ),
//               ),

//               const SizedBox(height: 16),
// buildCategorySection(),
//               // Categories & Explore All Services
//              // Section-wise Categories
// ...[

// ],

//               const SizedBox(height: 16),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//  Widget buildCategorySection() {
//   if (categories.isEmpty) {
//     return const Center(child: CircularProgressIndicator());
//   }

//   // Group categories by section
//   Map<String, List<dynamic>> groupedCategories = {};
//   for (var cat in categories) {
//     String section = cat.containsKey('section') ? cat['section'] : 'Other';
//     if (!groupedCategories.containsKey(section)) {
//       groupedCategories[section] = [];
//     }
//     groupedCategories[section]!.add(cat);
//   }

//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: groupedCategories.entries.map((entry) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0), // Added padding for the heading
//             child: Text(
//               entry.key, // section heading
//               style: const TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//           ),
//           // --- Design changes applied here ---
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0), // Horizontal padding for the grid
//             child: GridView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: entry.value.length,
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 // The image shows 3 items per row and has very little spacing
//                 crossAxisCount: 3, 
//                 mainAxisSpacing: 0,     // Reduced vertical spacing
//                 crossAxisSpacing: 0,    // Reduced horizontal spacing
//                 childAspectRatio: 0.9, // Adjusted to make items more square/taller for the name
//               ),
//               itemBuilder: (context, index) {
//                 final category = entry.value[index];
//                 String? imagePath = category['image_url'];

//                 Widget imageWidget;

//                 // Existing image logic (kept as is)
//                 if (imagePath != null && imagePath.isNotEmpty) {
//                   if (imagePath.startsWith('http')) {
//                     imageWidget = Image.network(
//                       imagePath,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) {
//                         return const Icon(Icons.image, color: Colors.grey, size: 30); // Changed fallback to just icon
//                       },
//                     );
//                   } else if (imagePath.startsWith('assets/')) {
//                     imageWidget = Image.asset(
//                       imagePath,
//                       fit: BoxFit.cover,
//                     );
//                   } else {
//                     imageWidget = const Icon(Icons.image, color: Colors.grey, size: 30); // Changed fallback
//                   }
//                 } else {
//                   imageWidget = const Icon(Icons.image, color: Colors.grey, size: 30); // Changed fallback
//                 }

//                 // --- Design changes applied here ---
//                 return GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => CategoryPage(
//                           categoryId: category['id'],
//                           categoryName: category['name'],
//                           currentUserId: widget.currentUserId,
//                         ),
//                       ),
//                     );
//                   },
//                   // Removed Padding/SizedBox for category name to tighten spacing
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start, // Align to top
//                     children: [
//                       // The icons in the image are smaller and do not fill a colored background block
//                       SizedBox(
//                         width: 50, // Fixed icon width for consistent size
//                         height: 50, // Fixed icon height
//                         child: imageWidget, // Assuming your image assets are the required icon silhouettes
//                       ),
//                       const SizedBox(height: 4), // Reduced space between icon and text
//                       Text(
//                         category['name'] ?? 'Unknown',
//                         textAlign: TextAlign.center,
//                         maxLines: 2, // Allow max two lines for longer names
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(
//                           color: Colors.black54, // Changed text color to a soft, dark gray
//                           fontWeight: FontWeight.normal, // Changed font weight to normal
//                           fontSize: 11, // Reduced font size for category name
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//           // --- Ensure consistent space between sections ---
//           const SizedBox(height: 16), 
//         ],
//       );
//     }).toList(),
//   );
// }

// }




// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../helpers/backend.dart';
// import 'MyProfileScreen.dart';
// import 'side_menu.dart';
// import 'category_page.dart';

// class ServicesScreen extends StatefulWidget {
//   final int currentUserId;
//   const ServicesScreen({Key? key, required this.currentUserId})
//       : super(key: key);

//   @override
//   ServicesScreenState createState() => ServicesScreenState();
// }

// class ServicesScreenState extends State<ServicesScreen> {
//   bool isLoading = true;
//   List<dynamic> providers = [];
//   List<dynamic> filteredProviders = [];
//   List<dynamic> categories = [];
//   TextEditingController searchController = TextEditingController();
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   @override
//   void initState() {
//     super.initState();
//     fetchProviders();
//     fetchCategories();
//     searchController.addListener(_onSearchChanged);
//   }

//   @override
//   void dispose() {
//     searchController.dispose();
//     super.dispose();
//   }

//   void _onSearchChanged() {
//     String query = searchController.text.toLowerCase();
//     setState(() {
//       filteredProviders = providers.where((provider) {
//         String name = provider['name']?.toLowerCase() ?? '';
//         String skills = provider['skills'] != null
//             ? (provider['skills'] as List).join(', ').toLowerCase()
//             : '';
//         return name.contains(query) || skills.contains(query);
//       }).toList();
//     });
//   }

//   Future<void> fetchCategories() async {
//     try {
//       final url = Uri.parse('${Backend.baseUrl}/categories');
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           categories = data is List ? data : data['categories'] ?? [];
//         });
//         print("Fetched categories: $categories");
//       } else {
//         showSnack('Failed to load categories ❌');
//       }
//     } catch (e) {
//       showSnack('Error fetching categories: $e');
//     }
//   }

//   Future<void> fetchProviders() async {
//     setState(() => isLoading = true);
//     try {
//       final url = Uri.parse('${Backend.baseUrl}/provider');
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> tempProviders = data['providers'] ?? [];

//         // Fetch ratings
//         for (var provider in tempProviders) {
//           try {
//             final ratingUrl = Uri.parse(
//                 '${Backend.baseUrl}/provider/${provider['id']}/ratings');
//             final ratingResp = await http.get(ratingUrl);
//             if (ratingResp.statusCode == 200) {
//               final ratingData = jsonDecode(ratingResp.body);
//               provider['average_rating'] =
//                   double.tryParse(ratingData['average_rating']?.toString() ?? '0') ?? 0.0;
//               provider['total_ratings'] =
//                   int.tryParse(ratingData['total_ratings']?.toString() ?? '0') ?? 0;
//             } else {
//               provider['average_rating'] = 0.0;
//               provider['total_ratings'] = 0;
//             }
//           } catch (_) {
//             provider['average_rating'] = 0.0;
//             provider['total_ratings'] = 0;
//           }
//         }

//         setState(() {
//           providers = tempProviders;
//           filteredProviders = providers;
//         });
//       } else {
//         showSnack('Failed to load providers ❌');
//       }
//     } catch (e) {
//       showSnack('Error fetching providers: $e');
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   void showSnack(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   Widget buildProviderCard(dynamic provider) {
//     String? imageUrl;
//     if (provider['profile_image'] != null && provider['profile_image'] != '') {
//       imageUrl = provider['profile_image'].startsWith('http')
//           ? provider['profile_image']
//           : '${Backend.baseUrl}/${provider['profile_image']}';
//     }

//     String skills = '';
//     if (provider['skills'] != null && provider['skills'] is List) {
//       skills = (provider['skills'] as List).join(', ');
//     }

//     double avgRating = provider['average_rating']?.toDouble() ?? 0.0;
//     int totalRatings = provider['total_ratings'] ?? 0;

//     return GestureDetector(
//       onTap: () async {
//         dynamic providerDetails;
//         try {
//           final url = Uri.parse(
//               '${Backend.baseUrl}/provider/services/providers/${provider['id']}');
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
//               readOnly: widget.currentUserId != provider['id'],
//               currentUserId: widget.currentUserId,
//             ),
//           ),
//         );
//       },
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: const Color(0xFFD9E1F0),
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black26,
//               blurRadius: 6,
//               offset: Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircleAvatar(
//               radius: 35,
//               backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
//               child: imageUrl == null
//                   ? const Icon(Icons.person, size: 35, color: Color(0xFF2A3A69))
//                   : null,
//               backgroundColor: Colors.white,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               provider['name'] ?? 'Unknown',
//               textAlign: TextAlign.center,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(
//                   fontWeight: FontWeight.bold, color: Color(0xFF2A3A69)),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               skills.isNotEmpty ? skills : 'No skills',
//               textAlign: TextAlign.center,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(color: Color(0xFF5C74B1), fontSize: 12),
//             ),
//             const SizedBox(height: 6),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.star, color: Colors.amber, size: 16),
//                 SizedBox(width: 4),
//                 Text(avgRating.toStringAsFixed(1),
//                     style: TextStyle(color: Color(0xFF2A3A69))),
//                 if (totalRatings > 0) ...[
//                   SizedBox(width: 4),
//                   Text('($totalRatings)',
//                       style: TextStyle(fontSize: 12, color: Color(0xFF5C74B1))),
//                 ],
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildCategorySection() {
//     if (categories.isEmpty) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     Map<String, List<dynamic>> groupedCategories = {};
//     for (var cat in categories) {
//       String section = cat.containsKey('section') ? cat['section'] : 'Other';
//       if (!groupedCategories.containsKey(section)) {
//         groupedCategories[section] = [];
//       }
//       groupedCategories[section]!.add(cat);
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: groupedCategories.entries.map((entry) {
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
//               child: Text(
//                 entry.key,
//                 style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: GridView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: entry.value.length,
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 3,
//                   mainAxisSpacing: 0,
//                   crossAxisSpacing: 0,
//                   childAspectRatio: 0.9,
//                 ),
//                 itemBuilder: (context, index) {
//                   final category = entry.value[index];
//                   String? imagePath = category['image_url'];
//                   Widget imageWidget;

//                   if (imagePath != null && imagePath.isNotEmpty) {
//                     if (imagePath.startsWith('http')) {
//                       imageWidget = Image.network(
//                         imagePath,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) {
//                           return const Icon(Icons.image, color: Colors.grey, size: 30);
//                         },
//                       );
//                     } else if (imagePath.startsWith('assets/')) {
//                       imageWidget = Image.asset(
//                         imagePath,
//                         fit: BoxFit.cover,
//                       );
//                     } else {
//                       imageWidget = const Icon(Icons.image, color: Colors.grey, size: 30);
//                     }
//                   } else {
//                     imageWidget = const Icon(Icons.image, color: Colors.grey, size: 30);
//                   }

//                   return GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => CategoryPage(
//                             categoryId: category['id'],
//                             categoryName: category['name'],
//                             currentUserId: widget.currentUserId,
//                           ),
//                         ),
//                       );
//                     },
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                           width: 50,
//                           height: 50,
//                           child: imageWidget,
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           category['name'] ?? 'Unknown',
//                           textAlign: TextAlign.center,
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(
//                             color: Colors.black54,
//                             fontWeight: FontWeight.normal,
//                             fontSize: 11,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: 16),
//           ],
//         );
//       }).toList(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF0A66C2),
//         elevation: 4,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
//         ),
//         toolbarHeight: 60,
//         titleSpacing: 16,
//         leading: IconButton(
//           icon: const Icon(Icons.menu, color: Colors.white),
//           onPressed: () => _scaffoldKey.currentState?.openDrawer(),
//         ),
//         title: const Text(
//           'Services',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       drawer: SideMenu(
//         logoPath: "assets/images/logo.png",
//         primaryColor: const Color(0xFF0A66C2),
//         secondaryColor: const Color(0xFFD9E1F0),
//         highlightColor: const Color(0xFF2A3A69),
//         selectedMenu: "About Us",
//         onMenuSelected: (menu) {
//           Navigator.pop(context);
//         },
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Tagline
//               Padding(
//                 padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
//                 child: Text(
//                   'Your Trusted Service, Just a Tap Away',
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF0A66C2),
//                     height: 1.5,
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//               ),
//               // Search Bar
//               TextField(
//                 controller: searchController,
//                 style: const TextStyle(
//                   color: Color(0xFF2A3A69),
//                   fontWeight: FontWeight.w500,
//                   fontSize: 16,
//                 ),
//                 decoration: InputDecoration(
//                   hintText: 'Search for a service',
//                   hintStyle: const TextStyle(
//                     color: Color(0xFF5C74B1),
//                     fontSize: 16,
//                     fontWeight: FontWeight.w400,
//                   ),
//                   prefixIcon: const Icon(Icons.search, color: Color(0xFF0A66C2)),
//                   filled: true,
//                   fillColor: const Color(0xFFE6F0FA),
//                   contentPadding:
//                       const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(18),
//                     borderSide: BorderSide.none,
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(18),
//                     borderSide: const BorderSide(color: Color(0xFF0A66C2), width: 2),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               buildCategorySection(),
//               const SizedBox(height: 16),
//               // Providers list
//               isLoading
//                   ? const Center(child: CircularProgressIndicator())
//                   : GridView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: filteredProviders.length,
//                       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2,
//                         mainAxisSpacing: 12,
//                         crossAxisSpacing: 12,
//                         childAspectRatio: 0.8,
//                       ),
//                       itemBuilder: (context, index) =>
//                           buildProviderCard(filteredProviders[index]),
//                     ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../helpers/backend.dart';
import 'category_page.dart';
import 'side_menu.dart';

class ServicesScreen extends StatefulWidget {
  final int currentUserId;
  const ServicesScreen({Key? key, required this.currentUserId})
      : super(key: key);

  @override
  ServicesScreenState createState() => ServicesScreenState();
}

class ServicesScreenState extends State<ServicesScreen> {
  bool isLoading = true;
  List<dynamic> categories = [];
  List<dynamic> filteredCategories = [];
  TextEditingController searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    fetchCategories();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredCategories = categories.where((category) {
        String name = category['name']?.toLowerCase() ?? '';
        return name.contains(query);
      }).toList();
    });
  }

  Future<void> fetchCategories() async {
    try {
      final url = Uri.parse('${Backend.baseUrl}/categories');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          categories = data is List ? data : data['categories'] ?? [];
          filteredCategories = categories;
        });
      } else {
        showSnack('Failed to load categories ❌');
      }
    } catch (e) {
      showSnack('Error fetching categories: $e');
    }
  }

  void showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget buildCategorySection() {
    if (filteredCategories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    Map<String, List<dynamic>> groupedCategories = {};
    for (var cat in filteredCategories) {
      String section = cat.containsKey('section') ? cat['section'] : 'Other';
      if (!groupedCategories.containsKey(section)) {
        groupedCategories[section] = [];
      }
      groupedCategories[section]!.add(cat);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groupedCategories.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
              child: Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: entry.value.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  final category = entry.value[index];
                  String? imagePath = category['image_url'];
                  Widget imageWidget;

                  if (imagePath != null && imagePath.isNotEmpty) {
                    if (imagePath.startsWith('http')) {
                      imageWidget = Image.network(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image, color: Colors.grey, size: 30);
                        },
                      );
                    } else if (imagePath.startsWith('assets/')) {
                      imageWidget = Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                      );
                    } else {
                      imageWidget = const Icon(Icons.image, color: Colors.grey, size: 30);
                    }
                  } else {
                    imageWidget = const Icon(Icons.image, color: Colors.grey, size: 30);
                  }

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CategoryPage(
                            categoryId: category['id'],
                            categoryName: category['name'],
                            currentUserId: widget.currentUserId,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: imageWidget,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category['name'] ?? 'Unknown',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.normal,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A66C2),
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        toolbarHeight: 60,
        titleSpacing: 16,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text(
          'Services',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: SideMenu(
        logoPath: "assets/images/logo.png",
        primaryColor: const Color(0xFF0A66C2),
        secondaryColor: const Color(0xFFD9E1F0),
        highlightColor: const Color(0xFF2A3A69),
        selectedMenu: "About Us",
        onMenuSelected: (menu) {
          Navigator.pop(context);
    //        if (menu == "Settings") {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (_) => SettingsScreen(
    //         userId: widget.currentUserId.toString(),
    //         currentRole: "user", // yahaan backend se ya local state se current role bhej sakte ho
    //       ),
    //     ),
    //   );
    // }
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tagline
              Padding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
                child: Text(
                  'Your Trusted Service, Just a Tap Away',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0A66C2),
                    height: 1.5,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              // Search Bar
              TextField(
                controller: searchController,
                style: const TextStyle(
                  color: Color(0xFF2A3A69),
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Search for a category',
                  hintStyle: const TextStyle(
                    color: Color(0xFF5C74B1),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF0A66C2)),
                  filled: true,
                  fillColor: const Color(0xFFE6F0FA),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFF0A66C2), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              buildCategorySection(),
            ],
          ),
        ),
      ),
    );
  }
}




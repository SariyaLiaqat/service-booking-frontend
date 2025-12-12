// // services_screen.dart
// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'package:http/http.dart' as http;
// import '../widgets/confirmedSection.dart';
// import '../helpers/coolors.dart';
// import 'dart:convert';
// import '../helpers/backend.dart';
// import 'category_page.dart';
// import 'side_menu.dart';
// import 'dashboard.dart';
// import '../widgets/settings.dart';
// import '../widgets/Contact.dart';

// class ServicesScreen extends StatefulWidget {

//   final int currentUserId;
//   final Map<String, dynamic> currentUser;
//   const ServicesScreen({Key? key, required this.currentUserId,  required this.currentUser,})
//     : super(key: key);

//   @override
//   ServicesScreenState createState() => ServicesScreenState();
// }

// class ServicesScreenState extends State<ServicesScreen> {
//     late Map<String, dynamic> currentUser;
//   bool isLoading = true;
//   bool showAllCategories = false;
//   bool showAllPopular = false;

//   List<dynamic> categories = [];
//   List<dynamic> filteredCategories = [];
//   List<dynamic> popularCategories = [];
//   List<dynamic> recentlyViewed = [];
//   List<dynamic> allServices = [];

//   TextEditingController searchController = TextEditingController();
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   // small helpers to avoid magic numbers
//   static const double kNavbarHeight = 60.0;
//   static const double kSearchHeight = 48.0;

//   @override
//   void initState() {
//     super.initState();
//      // ✅ Use widget.currentUser directly
//     currentUser = widget.currentUser;
//     print("Profile Image URL: ${currentUser['profile_image']}");
//     searchController.addListener(_onSearchChanged);
//     _initialLoad();
//   }

//   Future<void> _initialLoad() async {
//     await Future.wait([
//       fetchCategories(),
//       fetchRecentlyViewed(),
//       fetchAllServices(),
//       fetchPopularCategories(), // <-- yaha add karo
//     ]);
//     setState(() {
//       isLoading = false;
//     });
//   }

//   @override
//   void dispose() {
//     searchController.dispose();
//     super.dispose();
//   }

//   void _onSearchChanged() {
//     String query = searchController.text.toLowerCase().trim();
//     setState(() {
//       if (query.isEmpty) {
//         filteredCategories = List.from(categories);
//       } else {
//         filteredCategories = categories.where((category) {
//           String name = (category['name'] ?? '').toString().toLowerCase();
//           return name.contains(query);
//         }).toList();
//       }
//     });
//   }

//   Future<void> fetchCategories() async {
//     try {
//       final url = Uri.parse('${Backend.baseUrl}/categories');
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final List<dynamic> cats = data is List
//             ? data
//             : (data['categories'] ?? []);
//         setState(() {
//           categories = cats;
//           filteredCategories = List.from(categories);
//         });
//       } else {
//         showSnack('Failed to load categories ❌');
//       }
//     } catch (e) {
//       showSnack('Error fetching categories: $e');
//     }
//   }

//   Future<void> fetchPopularCategories() async {
//     try {
//       final url = Uri.parse('${Backend.baseUrl}/categories/popular');
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final List<dynamic> cats = data is List
//             ? data
//             : (data['popularCategories'] ?? []);
//         setState(() {
//           popularCategories = cats;
//         });
//       } else {
//         showSnack('Failed to load popular categories ❌');
//       }
//     } catch (e) {
//       showSnack('Error fetching popular categories: $e');
//     }
//   }

//   Future<void> fetchRecentlyViewed() async {
//     try {
//       // Assumes backend endpoint that returns recently viewed items for user
//       final url = Uri.parse(
//         '${Backend.baseUrl}/recently-viewed/${widget.currentUserId}',
//       );
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final List<dynamic> list = data is List
//             ? data
//             : (data['recentlyViewed'] ?? data['items'] ?? []);
//         setState(() {
//           recentlyViewed = list;
//         });
//       } else {
//         // do not block UI; show empty recently viewed
//         setState(() {
//           recentlyViewed = [];
//         });
//       }
//     } catch (e) {
//       // keep empty list on error
//       setState(() {
//         recentlyViewed = [];
//       });
//     }
//   }

//   Future<void> fetchAllServices() async {
//     try {
//       final url = Uri.parse('${Backend.baseUrl}/services');
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final List<dynamic> list = data is List
//             ? data
//             : (data['services'] ?? []);
//         setState(() {
//           allServices = list;
//         });
//       } else {
//         setState(() {
//           allServices = [];
//         });
//       }
//     } catch (e) {
//       setState(() {
//         allServices = [];
//       });
//     }
//   }

//   void showSnack(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   // ---------------- UI BUILDERS ----------------

//   Widget buildNavbar() {
//     return Container(
//       height: kNavbarHeight,
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       color: kBackgroundColor,
//       child: Row(
//         children: [
//           // App name left
//           Text(
//             'Servyx',
//             style: TextStyle(
//               color: kTextPrimary,
//               fontSize: 20,
//               fontWeight: FontWeight.w700,
//               letterSpacing: 0.3,
//             ),
//           ),
//           const Spacer(),
//           // Menu icon right
//           IconButton(
//             icon: Icon(Icons.menu, color: kTextPrimary),
//             onPressed: () {
//               _scaffoldKey.currentState?.openDrawer();
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildSearchBar() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: Container(
//         height: kSearchHeight,
//         decoration: BoxDecoration(
//           color: kCardColor,
//           borderRadius: BorderRadius
//               .zero, // you wanted NOT rounded — 0 radius as requested
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.06),
//               blurRadius: 8,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             const SizedBox(width: 12),
//             const Icon(Icons.search, size: 22),
//             const SizedBox(width: 8),
//             Expanded(
//               child: TextField(
//                 controller: searchController,
//                 style: TextStyle(
//                   color: kTextPrimary,
//                   fontSize: 15,
//                   fontWeight: FontWeight.w500,
//                 ),
//                 decoration: InputDecoration(
//                   hintText: 'Search for a category or service',
//                   hintStyle: TextStyle(color: kTextSecondary, fontSize: 15),
//                   border: InputBorder.none,
//                 ),
//                 textInputAction: TextInputAction.search,
//                 onSubmitted: (_) {
//                   // keep current filter behavior
//                   _onSearchChanged();
//                 },
//               ),
//             ),
//             if (searchController.text.isNotEmpty)
//               IconButton(
//                 icon: Icon(Icons.clear, color: kTextSecondary),
//                 onPressed: () {
//                   searchController.clear();
//                 },
//               ),
//             const SizedBox(width: 8),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildSectionTitle(String title, {Widget? action}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
//       child: Row(
//         children: [
//           Text(
//             title,
//             style: TextStyle(
//               color: kTextPrimary,
//               fontSize: 18,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           const Spacer(),
//           if (action != null) action,
//         ],
//       ),
//     );
//   }

//   Widget buildPopularCategories() {
//     if (popularCategories.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     // Show only 6 unless View All pressed
//     final int itemCount = showAllPopular
//         ? popularCategories.length
//         : (popularCategories.length >= 6 ? 6 : popularCategories.length);

//     final List<String> localImages = [
//       'assets/images/popular/one.png',
//       'assets/images/popular/three.png',
//       'assets/images/popular/seven.png',
//       'assets/images/popular/ten.png',
//       'assets/images/popular/four.png',
//       'assets/images/popular/five.png',
//       'assets/images/popular/three.png',
//       'assets/images/popular/eight.png',
//       'assets/images/popular/nine.png',
//       'assets/images/popular/six.png',
//       'assets/images/popular/two.png',
//     ];

//     return SizedBox(
//       height: 140,
//       child: ListView.separated(
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         scrollDirection: Axis.horizontal,
//         itemCount: itemCount,
//         separatorBuilder: (_, __) => const SizedBox(width: 12),
//         itemBuilder: (context, index) {
//           final item = popularCategories[index];
//           final String name = item['name'] ?? 'Unknown';

//           final String image = index < localImages.length
//               ? localImages[index]
//               : 'assets/images/popular/placeholder.png';

//           return GestureDetector(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => CategoryPage(
//                     categoryId: item['id'],
//                     categoryName: item['name'],
//                     currentUserId: widget.currentUserId,
//                   ),
//                 ),
//               );
//             },
//             child: Container(
//               width: 120,
//               decoration: BoxDecoration(
//                 color: const Color(
//                   0xFFB799F2,
//                 ).withOpacity(0.30), // Soft glassy purple
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 6,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   // Image with cute glassy bg
//                   Container(
//                     height: 80,
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFB799F2).withOpacity(0.55),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: Image.asset(image, fit: BoxFit.cover),
//                     ),
//                   ),

//                   const SizedBox(height: 8),

//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 4.0),
//                     child: Text(
//                       name,
//                       style: TextStyle(
//                         color: kTextPrimary,
//                         fontSize: 13,
//                         fontWeight: FontWeight.w600,
//                       ),
//                       textAlign: TextAlign.center,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget buildRecentlyViewed() {
//     // Limit to max 10 categories
//     final List limitedList = recentlyViewed.length > 10
//         ? recentlyViewed.sublist(0, 10)
//         : recentlyViewed;

//     if (limitedList.isEmpty) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//         child: Text(
//           'No recently viewed categories.',
//           style: TextStyle(color: kTextSecondary),
//         ),
//       );
//     }

//     return SizedBox(
//       height: 130,
//       child: ListView.separated(
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         scrollDirection: Axis.horizontal,
//         itemCount: limitedList.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 16),
//         itemBuilder: (context, index) {
//           final item = limitedList[index];
//           final String title = item['category_name'] ?? "Category";
//           final String? cover = item['category_image'];
//           final int categoryId = item['category_id'];

//           return GestureDetector(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => CategoryPage(
//                     categoryId: categoryId,
//                     categoryName: title,
//                     currentUserId: widget.currentUserId,
//                   ),
//                 ),
//               );
//             },
//             child: Column(
//               children: [
//                 // 🔥 Cute Small Box Around Image
//                 Container(
//                   width: 75,
//                   height: 75,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF8D7DA), // Light cute pink
//                     borderRadius: BorderRadius.circular(16), // Soft cute box
//                   ),
//                   padding: const EdgeInsets.all(6), // Inner spacing
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: imageWidgetFor(cover, fit: BoxFit.cover),
//                   ),
//                 ),

//                 const SizedBox(height: 6),

//                 // Category Name
//                 SizedBox(
//                   width: 75,
//                   child: Text(
//                     title,
//                     style: TextStyle(
//                       color: kTextPrimary,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget buildAllServicesGrid() {
//     if (filteredCategories.isEmpty) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
//         child: Text(
//           'No categories found.',
//           style: TextStyle(color: kTextSecondary),
//         ),
//       );
//     }

//     // show only first 6 unless user taps "View All"
//     final displayList = showAllCategories
//         ? filteredCategories
//         : filteredCategories.take(6).toList();

//     final crossAxis = MediaQuery.of(context).size.width > 700 ? 3 : 2;

//     return Column(
//       children: [
//         GridView.builder(
//           physics: const NeverScrollableScrollPhysics(),
//           shrinkWrap: true,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           itemCount: displayList.length,
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: crossAxis,
//             mainAxisSpacing: 16,
//             crossAxisSpacing: 16,
//             childAspectRatio: 0.90,
//           ),
//           itemBuilder: (context, index) {
//             final category = displayList[index];
//             final String title = category['name'] ?? 'Category';
//             final String? cover = category['image_url'];

//             return GestureDetector(
//               onTap: () async {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => CategoryPage(
//                       categoryId: category['id'],
//                       categoryName: category['name'],
//                       currentUserId: widget.currentUserId,
//                     ),
//                   ),
//                 );
//                 // 2️⃣ Send POST request to backend for recently viewed
//                 try {
//                   final url = Uri.parse('${Backend.baseUrl}/recently-viewed');
//                   final response = await http.post(
//                     url,
//                     headers: {'Content-Type': 'application/json'},
//                     body: jsonEncode({
//                       'userId': widget.currentUserId,
//                       'categoryId': category['id'],
//                       'serviceId': null,
//                     }),
//                   );

//                   print("POST response status: ${response.statusCode}");
//                   print("POST response body: ${response.body}");

//                   // Refresh recently viewed list
//                   await fetchRecentlyViewed();
//                   print(
//                     "Recently viewed list updated: ${recentlyViewed.length} items",
//                   );
//                 } catch (e) {
//                   print("Error adding to recently viewed: $e");
//                 }
//               },
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Color(0xFFD1E7DD),
//                   borderRadius: BorderRadius.circular(14),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.06),
//                       blurRadius: 8,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // Rounded small image using ClipRRect (fixed)
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: SizedBox(
//                         height: 75,
//                         width: 75,
//                         child: imageWidgetFor(cover, fit: BoxFit.cover),
//                       ),
//                     ),

//                     const SizedBox(height: 10),

//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                       child: Text(
//                         title,
//                         style: TextStyle(
//                           color: kTextPrimary,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w700,
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),

//         // SHOW VIEW ALL (only if categories > 6 and not already showing all)
//         // Bottom toggle
//         if (filteredCategories.length > 6)
//           GestureDetector(
//             onTap: () {
//               setState(() {
//                 showAllCategories = !showAllCategories;
//               });
//             },
//             child: Padding(
//               padding: const EdgeInsets.only(top: 8, bottom: 20),
//               child: Text(
//                 showAllCategories ? "Show Less" : "View All Categories",
//                 style: TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.bold,
//                   color: kPrimaryColor,
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   // small helper to create image widget from url or asset or fallback icon
//   Widget imageWidgetFor(
//     String? imageUrl, {
//     BoxFit fit = BoxFit.contain,
//     double radius = 0,
//   }) {
//     if (imageUrl == null || imageUrl.isEmpty) {
//       return Container(
//         color: Colors.transparent,
//         child: const Center(child: Icon(Icons.image, size: 28)),
//       );
//     }

//     if (imageUrl.startsWith('http')) {
//       return Image.network(
//         imageUrl,
//         fit: fit,
//         errorBuilder: (context, error, stackTrace) {
//           return const Center(child: Icon(Icons.broken_image));
//         },
//       );
//     }

//     if (imageUrl.startsWith('assets/')) {
//       return Image.asset(imageUrl, fit: fit);
//     }

//     // fallback
//     return Container(
//       color: Colors.transparent,
//       child: const Center(child: Icon(Icons.image, size: 28)),
//     );
//   }

//   // ---------------- MAIN BUILD ----------------

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       backgroundColor: kBackgroundColor,
//       drawer: SideMenu(
//         logoPath: "assets/images/bglogo.png",
//         primaryColor: kPrimaryColor,
//         secondaryColor: kCardColor,
//         highlightColor: kSecondaryColor,
//         selectedMenu: "Dashboard",
//         onMenuSelected: (menu) {
//           // preserve behavior — open provider screen OR settings/contact
//           if (menu == "Dashboard") {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) =>
//                     ProviderDashboardScreen(providerId: widget.currentUserId),
//               ),
//             );
//             return;
//           }
//           if (menu == "Settings") {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) =>
//                     SettingsScreen(currentUserId: widget.currentUserId),
//               ),
//             );
//             return;
//           } else if (menu == "Contact Us") {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => ContactUsPage()),
//             );
//             return;
//           }
//         },
//       ),

//       body: SafeArea(
//         child: Column(
//           children: [
//             // Navbar
//             buildNavbar(),

//             // Search bar
//             buildSearchBar(),

//             // main content scrollable
//             Expanded(
//               child: isLoading
//                   ? const Center(child: CircularProgressIndicator())
//                   : SingleChildScrollView(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [

//                           ConfirmedTasksSection(currentUser: currentUser),

//  const SizedBox(height: 12),

//                           // Popular categories
//                           buildSectionTitle(
//                             'Popular categories',
//                             action: GestureDetector(
//                               onTap: () {
//                                 setState(() {
//                                   showAllPopular = !showAllPopular;
//                                 });
//                               },
//                               child: Text(
//                                 showAllPopular ? 'Show less' : 'View all',
//                                 style: const TextStyle(
//                                   color: Color(0xFF6A1B9A), // dark purple
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                               ),
//                             ),
//                           ),

//                           buildPopularCategories(),
//                           const SizedBox(height: 12),

//                           // Recently viewed
//                           buildSectionTitle('Recently viewed'),
//                           buildRecentlyViewed(),
//                           const SizedBox(height: 12),

//                           // All services grid
//                           buildSectionTitle('All services'),
//                           buildAllServicesGrid(),

//                           const SizedBox(height: 24),
//                         ],
//                       ),
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// services_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../widgets/confirmedSection.dart';
import '../helpers/coolors.dart';
import 'dart:convert';
import '../helpers/backend.dart';
import 'category_page.dart';
import 'side_menu.dart';
import 'dashboard.dart';
import '../widgets/settings.dart';
import '../widgets/Contact.dart';

class ServicesScreen extends StatefulWidget {
  final int currentUserId;
  final String currentUserRole;
  final Map<String, dynamic> currentUser;
  const ServicesScreen({
    Key? key,
    required this.currentUserId,
    required this.currentUser,
    required this.currentUserRole,
  }) : super(key: key);

  @override
  ServicesScreenState createState() => ServicesScreenState();
}

class ServicesScreenState extends State<ServicesScreen> {
  late Map<String, dynamic> currentUser;
  bool isLoading = true;
  bool showAllCategories = false;
  bool showAllPopular = false;

  List<dynamic> categories = [];
  List<dynamic> filteredCategories = [];
  List<dynamic> popularCategories = [];
  List<dynamic> recentlyViewed = [];
  List<dynamic> allServices = [];

  TextEditingController searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // small helpers to avoid magic numbers
  static const double kNavbarHeight = 60.0;
  static const double kSearchHeight = 48.0;

  @override
  void initState() {
    super.initState();
    // ✅ Use widget.currentUser directly
    currentUser = widget.currentUser;
    print("Profile Image URL: ${currentUser['profile_image']}");
    searchController.addListener(_onSearchChanged);
    _initialLoad();
  }

  Future<void> _initialLoad() async {
    await Future.wait([
      fetchCategories(),
      fetchRecentlyViewed(),
      fetchAllServices(),
      fetchPopularCategories(), // <-- yaha add karo
    ]);
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    String query = searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        filteredCategories = List.from(categories);
      } else {
        filteredCategories = categories.where((category) {
          String name = (category['name'] ?? '').toString().toLowerCase();
          return name.contains(query);
        }).toList();
      }
    });
  }

  Future<void> fetchCategories() async {
    try {
      final url = Uri.parse('${Backend.baseUrl}/categories');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> cats = data is List
            ? data
            : (data['categories'] ?? []);
        setState(() {
          categories = cats;
          filteredCategories = List.from(categories);
        });
      } else {
        showSnack('Failed to load categories ❌');
      }
    } catch (e) {
      showSnack('Error fetching categories: $e');
    }
  }

  Future<void> fetchPopularCategories() async {
    try {
      final url = Uri.parse('${Backend.baseUrl}/categories/popular');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> cats = data is List
            ? data
            : (data['popularCategories'] ?? []);
        setState(() {
          popularCategories = cats;
        });
      } else {
        showSnack('Failed to load popular categories ❌');
      }
    } catch (e) {
      showSnack('Error fetching popular categories: $e');
    }
  }

  Future<void> fetchRecentlyViewed() async {
    try {
      // Assumes backend endpoint that returns recently viewed items for user
      final url = Uri.parse(
        '${Backend.baseUrl}/recently-viewed/${widget.currentUserId}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data is List
            ? data
            : (data['recentlyViewed'] ?? data['items'] ?? []);
        setState(() {
          recentlyViewed = list;
        });
      } else {
        // do not block UI; show empty recently viewed
        setState(() {
          recentlyViewed = [];
        });
      }
    } catch (e) {
      // keep empty list on error
      setState(() {
        recentlyViewed = [];
      });
    }
  }

  Future<void> fetchAllServices() async {
    try {
      final url = Uri.parse('${Backend.baseUrl}/services');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data is List
            ? data
            : (data['services'] ?? []);
        setState(() {
          allServices = list;
        });
      } else {
        setState(() {
          allServices = [];
        });
      }
    } catch (e) {
      setState(() {
        allServices = [];
      });
    }
  }

  void showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ---------------- UI BUILDERS ----------------

  Widget buildNavbar() {
    return Container(
      height: kNavbarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: kBackgroundColor,
      child: Row(
        children: [
          // App name left
          Text(
            'Servyx',
            style: TextStyle(
              color: kTextPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const Spacer(),
          // Menu icon right
          IconButton(
            icon: Icon(Icons.menu, color: kTextPrimary),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ],
      ),
    );
  }

  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        height: kSearchHeight,
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius
              .zero, // you wanted NOT rounded — 0 radius as requested
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(Icons.search, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: searchController,
                style: TextStyle(
                  color: kTextPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Search for a category',
                  hintStyle: TextStyle(color: kTextSecondary, fontSize: 15),
                  border: InputBorder.none,
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (_) {
                  // keep current filter behavior
                  _onSearchChanged();
                },
              ),
            ),
            if (searchController.text.isNotEmpty)
              IconButton(
                icon: Icon(Icons.clear, color: kTextSecondary),
                onPressed: () {
                  searchController.clear();
                },
              ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget buildSectionTitle(String title, {Widget? action}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: kTextPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          if (action != null) action,
        ],
      ),
    );
  }

  Widget buildPopularCategories() {
    if (popularCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    // Show only 6 unless View All pressed
    final int itemCount = showAllPopular
        ? popularCategories.length
        : (popularCategories.length >= 6 ? 6 : popularCategories.length);

    final List<String> localImages = [
      'assets/images/popular/one.png',
      'assets/images/popular/three.png',
      'assets/images/popular/seven.png',
      'assets/images/popular/ten.png',
      'assets/images/popular/four.png',
      'assets/images/popular/five.png',
      'assets/images/popular/three.png',
      'assets/images/popular/eight.png',
      'assets/images/popular/nine.png',
      'assets/images/popular/six.png',
      'assets/images/popular/two.png',
    ];

    return SizedBox(
      height: 140,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = popularCategories[index];
          final String name = item['name'] ?? 'Unknown';

          final String image = index < localImages.length
              ? localImages[index]
              : 'assets/images/popular/placeholder.png';

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryPage(
                    categoryId: item['id'],
                    categoryName: item['name'],
                    currentUserId: widget.currentUserId,
                  ),
                ),
              );
            },
            child: Container(
              width: 120,
              decoration: BoxDecoration(
                color:kCardColor, // Soft glassy purple
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Image with cute glassy bg
                  Container(
                    height: 80,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: kCardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(image, fit: BoxFit.cover),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      name,
                      style: TextStyle(
                        color: kTextPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildRecentlyViewed() {
    // Limit to max 10 categories
    final List limitedList = recentlyViewed.length > 10
        ? recentlyViewed.sublist(0, 10)
        : recentlyViewed;

    if (limitedList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          'No recently viewed categories.',
          style: TextStyle(color: kTextSecondary),
        ),
      );
    }

    return SizedBox(
      height: 130,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: limitedList.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final item = limitedList[index];
          final String title = item['category_name'] ?? "Category";
          final String? cover = item['category_image'];
          final int categoryId = item['category_id'];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryPage(
                    categoryId: categoryId,
                    categoryName: title,
                    currentUserId: widget.currentUserId,
                  ),
                ),
              );
            },
            child: Column(
              children: [
                // 🔥 Cute Small Box Around Image
                Container(
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    color: kCardColor, // Light cute pink
                    borderRadius: BorderRadius.circular(16), // Soft cute box
                  ),
                  padding: const EdgeInsets.all(6), // Inner spacing
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: imageWidgetFor(cover, fit: BoxFit.cover),
                  ),
                ),

                const SizedBox(height: 6),

                // Category Name
                SizedBox(
                  width: 75,
                  child: Text(
                    title,
                    style: TextStyle(
                      color: kTextPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildAllServicesGrid() {
    if (filteredCategories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: Text(
          'No categories found.',
          style: TextStyle(color: kTextSecondary),
        ),
      );
    }

    // show only first 6 unless user taps "View All"
    final displayList = showAllCategories
        ? filteredCategories
        : filteredCategories.take(6).toList();

    final crossAxis = MediaQuery.of(context).size.width > 700 ? 3 : 2;

    return Column(
      children: [
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: displayList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxis,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.90,
          ),
          itemBuilder: (context, index) {
            final category = displayList[index];
            final String title = category['name'] ?? 'Category';
            final String? cover = category['image_url'];

            return GestureDetector(
              onTap: () async {
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
                // 2️⃣ Send POST request to backend for recently viewed
                try {
                  final url = Uri.parse('${Backend.baseUrl}/recently-viewed');
                  final response = await http.post(
                    url,
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'userId': widget.currentUserId,
                      'categoryId': category['id'],
                      'serviceId': null,
                    }),
                  );

                  print("POST response status: ${response.statusCode}");
                  print("POST response body: ${response.body}");

                  // Refresh recently viewed list
                  await fetchRecentlyViewed();
                  print(
                    "Recently viewed list updated: ${recentlyViewed.length} items",
                  );
                } catch (e) {
                  print("Error adding to recently viewed: $e");
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: kCardColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Rounded small image using ClipRRect (fixed)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 75,
                        width: 75,
                        child: imageWidgetFor(cover, fit: BoxFit.cover),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        title,
                        style: TextStyle(
                          color: kTextPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // SHOW VIEW ALL (only if categories > 6 and not already showing all)
        // Bottom toggle
        if (filteredCategories.length > 6)
          GestureDetector(
            onTap: () {
              setState(() {
                showAllCategories = !showAllCategories;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 20),
              child: Text(
                showAllCategories ? "Show Less" : "View All Categories",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: kSecondaryColor,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // small helper to create image widget from url or asset or fallback icon
  Widget imageWidgetFor(
    String? imageUrl, {
    BoxFit fit = BoxFit.contain,
    double radius = 0,
  }) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        color: Colors.transparent,
        child: const Center(child: Icon(Icons.image, size: 28)),
      );
    }

    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Icon(Icons.broken_image));
        },
      );
    }

    if (imageUrl.startsWith('assets/')) {
      return Image.asset(imageUrl, fit: fit);
    }

    // fallback
    return Container(
      color: Colors.transparent,
      child: const Center(child: Icon(Icons.image, size: 28)),
    );
  }

  // ---------------- MAIN BUILD ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: kBackgroundColor,
      drawer: SideMenu(
        logoPath: "assets/images/bglogo.png",
        primaryColor: kPrimaryColor,
        secondaryColor: kCardColor,
        highlightColor: kSecondaryColor,
        selectedMenu: "Dashboard",
        onMenuSelected: (menu) {
          // preserve behavior — open provider screen OR settings/contact
          if (menu == "Dashboard") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DashboardScreen(
                  userId: widget.currentUserId,
                  role: widget.currentUserRole,
                ),
              ),
            );
            return;
          }
          if (menu == "Settings") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    SettingsScreen(currentUserId: widget.currentUserId),
              ),
            );
            return;
          } else if (menu == "Contact Us") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ContactUsPage()),
            );
            return;
          }
        },
      ),

      body: SafeArea(
        child: Column(
          children: [
            // Navbar
            buildNavbar(),

            // Search bar
            buildSearchBar(),

            // main content scrollable
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ConfirmedTasksSection(currentUser: currentUser),

                          const SizedBox(height: 12),

                          // Popular categories
                          buildSectionTitle(
                            'Popular categories',
                            action: GestureDetector(
                              onTap: () {
                                setState(() {
                                  showAllPopular = !showAllPopular;
                                });
                              },
                              child: Text(
                                showAllPopular ? 'Show less' : 'View all',
                                style: const TextStyle(
                                  color: kSecondaryColor, // dark purple
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                          buildPopularCategories(),
                          const SizedBox(height: 12),

                          // Recently viewed
                          buildSectionTitle('Recently viewed'),
                          buildRecentlyViewed(),
                          const SizedBox(height: 12),

                          // All services grid
                          buildSectionTitle('All services'),
                          buildAllServicesGrid(),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

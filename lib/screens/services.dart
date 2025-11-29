// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'package:http/http.dart' as http;

// import '../helpers/coolors.dart';
// import 'dart:convert';
// import '../helpers/backend.dart';
// import 'category_page.dart';
// import 'side_menu.dart';
// import 'provider_status_screen.dart';
// import '../widgets/settings.dart';
// import '../widgets/Contact.dart';

// class ServicesScreen extends StatefulWidget {
//   final int currentUserId;
//   const ServicesScreen({Key? key, required this.currentUserId})
//     : super(key: key);

//   @override
//   ServicesScreenState createState() => ServicesScreenState();
// }

// class ServicesScreenState extends State<ServicesScreen> {
//   bool isLoading = true;
//   List<dynamic> categories = [];
//   List<dynamic> filteredCategories = [];
//   TextEditingController searchController = TextEditingController();
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   @override
//   void initState() {
//     super.initState();
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
//       filteredCategories = categories.where((category) {
//         String name = category['name']?.toLowerCase() ?? '';
//         return name.contains(query);
//       }).toList();
//     });
//   }

//   Future<void> fetchCategories() async {
//     // ... existing logic preserved ...
//     try {
//       final url = Uri.parse('${Backend.baseUrl}/categories');
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           categories = data is List ? data : data['categories'] ?? [];
//           filteredCategories = categories;
//         });
//       } else {
//         showSnack('Failed to load categories ❌');
//       }
//     } catch (e) {
//       showSnack('Error fetching categories: $e');
//     }
//   }

//   void showSnack(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   Widget buildCategorySection() {
//     if (filteredCategories.isEmpty) {
//       // Color updated: MyColors.primary -> kPrimaryColor
//       return const Center(
//         child: CircularProgressIndicator(color: kPrimaryColor),
//       );
//     }

//     Map<String, List<dynamic>> groupedCategories = {};
//     for (var cat in filteredCategories) {
//       String section = cat.containsKey('section') ? cat['section'] : 'Other';
//       if (!groupedCategories.containsKey(section)) {
//         groupedCategories[section] = [];
//       }
//       groupedCategories[section]!.add(cat);
//     }

//     return SafeArea(
//       child: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.only(bottom: 16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: groupedCategories.entries.map((entry) {
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.only(
//                       left: 16.0,
//                       top: 16.0,
//                       bottom: 8.0,
//                     ),
//                     child: Text(
//                       entry.key,
//                       style: const TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         // Color updated: MyColors.textPrimary -> kTextPrimary (Best fit for bold heading)
//                         color: kTextPrimary,
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                     child: LayoutBuilder(
//                       builder: (context, constraints) {
//                         return GridView.builder(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           itemCount: entry.value.length,
//                           gridDelegate:
//                               const SliverGridDelegateWithFixedCrossAxisCount(
//                                 crossAxisCount: 3,
//                                 mainAxisSpacing: 15,
//                                 crossAxisSpacing: 15,
//                                 childAspectRatio:
//                                     0.75, // existing ratio preserved
//                               ),
//                           itemBuilder: (context, index) {
//                             final category = entry.value[index];
//                             String? imagePath = category['image_url'];
//                             Widget imageWidget;

//                             // Image logic preserved (network, asset, or fallback icon)
//                             if (imagePath != null && imagePath.isNotEmpty) {
//                               if (imagePath.startsWith('http')) {
//                                 imageWidget = Image.network(
//                                   imagePath,
//                                   fit: BoxFit.contain,
//                                   errorBuilder: (context, error, stackTrace) {
//                                     return const Icon(
//                                       Icons.image,
//                                       color: Colors.grey,
//                                       size: 30,
//                                     );
//                                   },
//                                 );
//                               } else if (imagePath.startsWith('assets/')) {
//                                 imageWidget = Image.asset(
//                                   imagePath,
//                                   fit: BoxFit.contain,
//                                 );
//                               } else {
//                                 imageWidget = const Icon(
//                                   Icons.image,
//                                   color: Colors.grey,
//                                   size: 30,
//                                 );
//                               }
//                             } else {
//                               imageWidget = const Icon(
//                                 Icons.image,
//                                 color: Colors.grey,
//                                 size: 30,
//                               );
//                             }

//                             return GestureDetector(
//                               onTap: () {
//                                 // Existing navigation logic preserved
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (_) => CategoryPage(
//                                       categoryId: category['id'],
//                                       categoryName: category['name'],
//                                       currentUserId: widget.currentUserId,
//                                     ),
//                                   ),
//                                 );
//                               },
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   // Color updated: MyColors.surface -> kCardColor
//                                   color: kCardColor,
//                                   borderRadius: BorderRadius.circular(20),
//                                   // Box Shadow preserved
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.4),
//                                       blurRadius: 8,
//                                       offset: const Offset(0, 4),
//                                     ),
//                                   ],
//                                 ),
//                                 padding: const EdgeInsets.all(10),
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     SizedBox(
//                                       width: 55,
//                                       height: 55,
//                                       child: Center(child: imageWidget),
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Text(
//                                       category['name'] ?? 'Unknown',
//                                       textAlign: TextAlign.center,
//                                       maxLines: 2,
//                                       overflow: TextOverflow.ellipsis,
//                                       style: const TextStyle(
//                                         // Color updated: MyColors.textPrimary -> kTextPrimary
//                                         color: kTextPrimary,
//                                         fontWeight: FontWeight.w600,
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                 ],
//               );
//             }).toList(),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       // Color updated: MyColors.background -> kBackgroundColor
//       backgroundColor: kBackgroundColor,
//       drawer: SideMenu(
//         // Colors updated for drawer:
//         logoPath: "assets/images/bglogo.png",
//         primaryColor: kPrimaryColor, // MyColors.primary -> kPrimaryColor
//         secondaryColor: kCardColor, // MyColors.surface -> kCardColor
//         highlightColor: kSecondaryColor, // MyColors.secondary -> kSecondaryColor

//         selectedMenu: "Dashboard",
//         onMenuSelected: (menu) {
//           // ... existing drawer navigation logic preserved ...
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) =>
//                   ProviderStatusScreen(providerId: widget.currentUserId),
//             ),
//           );

//           // close the drawer first

//           if (menu == "Settings") {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) =>
//                     SettingsScreen(currentUserId: widget.currentUserId),
//               ),
//             );
//           }
//           else if (menu == "Contact Us") {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => ContactUsPage()),
//             );
//           }
//         },
//       ),

//       body: SafeArea(
//         child: Column(
//           children: [
//             // Top Image + Search Bar
//             Stack(
//               clipBehavior: Clip.none,
//               children: [
//                 // Image with rounded top corners
//                 ClipRRect(
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(24),
//                     topRight: Radius.circular(24),
//                   ),
//                   child: Image.asset(
//                     'assets/images/newmain.png',
//                     width: double.infinity,
//                     height: 240,
//                     fit: BoxFit.cover,
//                   ),
//                 ),

//                 // Search bar + menu icon
//                 Positioned(
//                   bottom: -25, // Overlapping effect preserved
//                   left: 16,
//                   right: 16,
//                   child: Container(
//                     height: 50,
//                     decoration: BoxDecoration(
//                       // Color updated: MyColors.surface -> kCardColor
//                       color: kCardColor,
//                       borderRadius: BorderRadius.circular(25),
//                       // Box Shadow preserved
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.4),
//                           blurRadius: 8,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 50,
//                           height: 50,
//                           decoration: BoxDecoration(
//                             // Color updated: MyColors.primary -> kPrimaryColor
//                             color: kPrimaryColor,
//                             borderRadius: BorderRadius.circular(25),
//                           ),
//                           child: Builder(
//                             builder: (context) {
//                               return IconButton(
//                                 icon: const Icon(
//                                   // Icon is for opening the drawer based on logic
//                                   Icons.arrow_back_ios_new,
//                                   color: buttonText, // Using your white buttonText color
//                                 ),
//                                 onPressed: () {
//                                   // Existing drawer open logic preserved
//                                   Scaffold.of(
//                                     context,
//                                   ).openDrawer();
//                                 },
//                               );
//                             },
//                           ),
//                         ),

//                         const SizedBox(width: 12),

//                         // Search input
//                         Expanded(
//                           child: TextField(
//                             controller: searchController,
//                             style: const TextStyle(
//                               // Color updated: MyColors.textPrimary -> kTextPrimary
//                               color: kTextPrimary,
//                               fontWeight: FontWeight.w500,
//                               fontSize: 16,
//                             ),
//                             decoration: InputDecoration(
//                               hintText: 'Search for a category',
//                               hintStyle: const TextStyle(
//                                 // Color updated: MyColors.textSecondary -> kTextSecondary
//                                 color: kTextSecondary,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w400,
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(25),
//                                 borderSide: BorderSide.none,
//                               ),
//                               filled: true,
//                               // Color updated: MyColors.surface -> kCardColor
//                               fillColor: kCardColor,
//                               contentPadding: const EdgeInsets.symmetric(
//                                 vertical: 14,
//                                 horizontal: 16,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 35), // Space below search bar preserved
//             // Main content
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 24),
//                     buildCategorySection(),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

/////////////////////////

// // services_screen.dart
// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'package:http/http.dart' as http;

// import '../helpers/coolors.dart';
// import 'dart:convert';
// import '../helpers/backend.dart';
// import 'category_page.dart';
// import 'side_menu.dart';
// import 'provider_status_screen.dart';
// import '../widgets/settings.dart';
// import '../widgets/Contact.dart';

// class ServicesScreen extends StatefulWidget {
//   final int currentUserId;
//   const ServicesScreen({Key? key, required this.currentUserId})
//       : super(key: key);

//   @override
//   ServicesScreenState createState() => ServicesScreenState();
// }

// class ServicesScreenState extends State<ServicesScreen> {
//   bool isLoading = true;
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
//     searchController.addListener(_onSearchChanged);
//     _initialLoad();
//   }

//   Future<void> _initialLoad() async {
//     await Future.wait([
//       fetchCategories(),
//       fetchRecentlyViewed(),
//       fetchAllServices(),
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
//         final List<dynamic> cats =
//             data is List ? data : (data['categories'] ?? []);
//         setState(() {
//           categories = cats;
//           filteredCategories = List.from(categories);
//           // Simple heuristic: mark first 6 as popular (or use `is_popular` flag)
//           popularCategories = cats.length <= 6 ? List.from(cats) : cats.sublist(0, 6);
//         });
//       } else {
//         showSnack('Failed to load categories ❌');
//       }
//     } catch (e) {
//       showSnack('Error fetching categories: $e');
//     }
//   }

//   Future<void> fetchRecentlyViewed() async {
//     try {
//       // Assumes backend endpoint that returns recently viewed items for user
//       final url = Uri.parse(
//           '${Backend.baseUrl}/recently-viewed?userId=${widget.currentUserId}');
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final List<dynamic> list =
//             data is List ? data : (data['recentlyViewed'] ?? data['items'] ?? []);
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
//         final List<dynamic> list =
//             data is List ? data : (data['services'] ?? []);
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
//           borderRadius:
//               BorderRadius.zero, // you wanted NOT rounded — 0 radius as requested
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
//                   hintStyle: TextStyle(
//                     color: kTextSecondary,
//                     fontSize: 15,
//                   ),
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

//   Widget buildSectionTitle(String title, {VoidCallback? onViewAll}) {
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
//           if (onViewAll != null)
//             GestureDetector(
//               onTap: onViewAll,
//               child: Text(
//                 'View all',
//                 style: TextStyle(
//                   color: kSecondaryColor,
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget buildPopularCategories() {
//     if (popularCategories.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     return SizedBox(
//       height: 110,
//       child: ListView.separated(
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         scrollDirection: Axis.horizontal,
//         itemCount: popularCategories.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 12),
//         itemBuilder: (context, index) {
//           final item = popularCategories[index];
//           final String name = item['name'] ?? 'Unknown';
//           final String? image = item['image_url'];

//           return GestureDetector(
//             onTap: () {
//               // open category page (keeps same behavior)
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
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: kCardColor,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.06),
//                     blurRadius: 8,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   SizedBox(
//                     height: 44,
//                     width: 44,
//                     child: imageWidgetFor(image, radius: 8),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     name,
//                     style: TextStyle(
//                       color: kTextPrimary,
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                     ),
//                     textAlign: TextAlign.center,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
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
//     if (recentlyViewed.isEmpty) {
//       // show placeholder empty state
//       return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//         child: Text(
//           'No recently viewed items.',
//           style: TextStyle(color: kTextSecondary),
//         ),
//       );
//     }

//     return SizedBox(
//       height: 160,
//       child: ListView.separated(
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         scrollDirection: Axis.horizontal,
//         itemCount: recentlyViewed.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 12),
//         itemBuilder: (context, index) {
//           final item = recentlyViewed[index];
//           // Expect item to include service or category details and provider/user image
//           final String title = item['title'] ?? item['name'] ?? 'Service';
//           final String? cover = item['cover_image'] ?? item['image_url'];
//           final String? avatar = item['provider']?['avatar_url'] ?? item['avatar_url'];

//           return GestureDetector(
//             onTap: () {
//               // if item has category id, open CategoryPage, otherwise show snackbar
//               final dynamic categoryId = item['category_id'] ?? item['category']?['id'];
//               if (categoryId != null) {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => CategoryPage(
//                       categoryId: categoryId,
//                       categoryName: item['name'] ?? '',
//                       currentUserId: widget.currentUserId,
//                     ),
//                   ),
//                 );
//               } else {
//                 showSnack('Open item: ${item['id'] ?? title}');
//               }
//             },
//             child: Container(
//               width: 300,
//               decoration: BoxDecoration(
//                 color: kCardColor,
//                 borderRadius: BorderRadius.circular(14),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.06),
//                     blurRadius: 10,
//                     offset: const Offset(0, 6),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   // left: cover image
//                   Container(
//                     width: 110,
//                     height: double.infinity,
//                     decoration: BoxDecoration(
//                       borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(14),
//                         bottomLeft: Radius.circular(14),
//                       ),
//                       color: kBackgroundColor,
//                     ),
//                     child: ClipRRect(
//                       borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(14),
//                         bottomLeft: Radius.circular(14),
//                       ),
//                       child: imageWidgetFor(cover, fit: BoxFit.cover),
//                     ),
//                   ),

//                   // right: text + avatar
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             title,
//                             style: TextStyle(
//                                 color: kTextPrimary,
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.w700),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             item['short_description'] ?? item['subtitle'] ?? '',
//                             style: TextStyle(
//                               color: kTextSecondary,
//                               fontSize: 13,
//                             ),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           const Spacer(),
//                           Row(
//                             children: [
//                               // large profile image
//                               CircleAvatar(
//                                 radius: 20,
//                                 backgroundColor: Colors.grey[200],
//                                 backgroundImage:
//                                     avatar != null && avatar.isNotEmpty && avatar.startsWith('http')
//                                         ? NetworkImage(avatar)
//                                         : null,
//                                 child: (avatar == null || avatar.isEmpty)
//                                     ? const Icon(Icons.person, size: 20)
//                                     : null,
//                               ),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: Text(
//                                   item['provider']?['name'] ??
//                                       item['seller_name'] ??
//                                       'Provider',
//                                   style: TextStyle(
//                                     color: kTextPrimary,
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget buildAllServicesGrid() {
//     if (allServices.isEmpty) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
//         child: Text(
//           'No services found.',
//           style: TextStyle(color: kTextSecondary),
//         ),
//       );
//     }

//     // two columns on small screens, three on wider screens
//     final crossAxis = MediaQuery.of(context).size.width > 700 ? 3 : 2;

//     return GridView.builder(
//       physics: const NeverScrollableScrollPhysics(),
//       shrinkWrap: true,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       itemCount: allServices.length,
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: crossAxis,
//         mainAxisSpacing: 12,
//         crossAxisSpacing: 12,
//         childAspectRatio: 0.78,
//       ),
//       itemBuilder: (context, index) {
//         final item = allServices[index];
//         final String title = item['title'] ?? item['name'] ?? 'Service';
//         final String? cover = item['cover_image'] ?? item['image_url'];
//         final double price = (item['price'] != null)
//             ? double.tryParse(item['price'].toString()) ?? 0
//             : 0;

//         return GestureDetector(
//           onTap: () {
//             // best-effort navigation: if service has category id, open CategoryPage or show snackbar
//             final dynamic categoryId = item['category_id'] ?? item['category']?['id'];
//             if (categoryId != null) {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => CategoryPage(
//                     categoryId: categoryId,
//                     categoryName: item['name'] ?? '',
//                     currentUserId: widget.currentUserId,
//                   ),
//                 ),
//               );
//             } else {
//               showSnack('Open service: ${item['id'] ?? title}');
//             }
//           },
//           child: Container(
//             decoration: BoxDecoration(
//               color: kCardColor,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 8,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 // image
//                 ClipRRect(
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(12),
//                     topRight: Radius.circular(12),
//                   ),
//                   child: SizedBox(
//                     height: 120,
//                     width: double.infinity,
//                     child: imageWidgetFor(cover, fit: BoxFit.cover),
//                   ),
//                 ),

//                 // text
//                 Padding(
//                   padding: const EdgeInsets.all(10.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         title,
//                         style: TextStyle(
//                           color: kTextPrimary,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w700,
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 6),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             item['provider']?['name'] ??
//                                 item['seller_name'] ??
//                                 'Provider',
//                             style: TextStyle(
//                               color: kTextSecondary,
//                               fontSize: 12,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           Text(
//                             price > 0 ? 'PKR ${price.toStringAsFixed(0)}' : '',
//                             style: TextStyle(
//                               color: kPrimaryColor,
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // small helper to create image widget from url or asset or fallback icon
//   Widget imageWidgetFor(String? imageUrl, {BoxFit fit = BoxFit.contain, double radius = 0}) {
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
//                     ProviderStatusScreen(providerId: widget.currentUserId),
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
//                           // Popular categories
//                           buildSectionTitle('Popular categories', onViewAll: () {
//                             showSnack('View all categories');
//                           }),
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

import '../helpers/coolors.dart';
import 'dart:convert';
import '../helpers/backend.dart';
import 'category_page.dart';
import 'side_menu.dart';
import 'provider_status_screen.dart';
import '../widgets/settings.dart';
import '../widgets/Contact.dart';

class ServicesScreen extends StatefulWidget {
  final int currentUserId;
  const ServicesScreen({Key? key, required this.currentUserId})
    : super(key: key);

  @override
  ServicesScreenState createState() => ServicesScreenState();
}

class ServicesScreenState extends State<ServicesScreen> {
  bool isLoading = true;
  bool showAllCategories = false;

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
                  hintText: 'Search for a category or service',
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

  Widget buildSectionTitle(String title, {VoidCallback? onViewAll}) {
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
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                'View all',
                style: TextStyle(
                  color: kSecondaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
Widget buildPopularCategories() {
  if (popularCategories.isEmpty) {
    return const SizedBox.shrink();
  }

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
    height: 140, // thoda bada box for image + text
    child: ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      itemCount: popularCategories.length,
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
              color: kCardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Image at top, fits the container
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 80,
                    width: double.infinity,
                    child: Image.asset(
                      image,
                      fit: BoxFit.cover, // image covers entire box
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Name below image
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
    if (recentlyViewed.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          'No recently viewed categories.',
          style: TextStyle(color: kTextSecondary),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: recentlyViewed.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final item = recentlyViewed[index];
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
                // Circle Image (same function as grid)
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: SizedBox(
                    width: 70,
                    height: 70,
                    child: imageWidgetFor(cover, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 6),

                // Category Name
                SizedBox(
                  width: 70,
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
                  color: kPrimaryColor,
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
                builder: (_) =>
                    ProviderStatusScreen(providerId: widget.currentUserId),
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
                          // Popular categories
                          buildSectionTitle(
                            'Popular categories',
                            onViewAll: () {
                              showSnack('View all categories');
                            },
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











////////////////////////////////
///

  // Widget buildPopularCategories() {
  //   if (popularCategories.isEmpty) {
  //     return const SizedBox.shrink();
  //   }

  //   return SizedBox(
  //     height: 110,
  //     child: ListView.separated(
  //       padding: const EdgeInsets.symmetric(horizontal: 16),
  //       scrollDirection: Axis.horizontal,
  //       itemCount: popularCategories.length,
  //       separatorBuilder: (_, __) => const SizedBox(width: 12),
  //       itemBuilder: (context, index) {
  //         final item = popularCategories[index];
  //         final String name = item['name'] ?? 'Unknown';
  //         final String? image = item['image_url'];

  //         return GestureDetector(
  //           onTap: () {
  //             // open category page (keeps same behavior)
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute(
  //                 builder: (_) => CategoryPage(
  //                   categoryId: item['id'],
  //                   categoryName: item['name'],
  //                   currentUserId: widget.currentUserId,
  //                 ),
  //               ),
  //             );
  //           },
  //           child: Container(
  //             width: 120,
  //             padding: const EdgeInsets.all(12),
  //             decoration: BoxDecoration(
  //               color: kCardColor,
  //               borderRadius: BorderRadius.circular(12),
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: Colors.black.withOpacity(0.06),
  //                   blurRadius: 8,
  //                   offset: const Offset(0, 4),
  //                 ),
  //               ],
  //             ),
  //             child: Column(
  //               children: [
  //                 SizedBox(
  //                   height: 44,
  //                   width: 44,
  //                   child: imageWidgetFor(image, radius: 8),
  //                 ),
  //                 const SizedBox(height: 8),
  //                 Text(
  //                   name,
  //                   style: TextStyle(
  //                     color: kTextPrimary,
  //                     fontSize: 13,
  //                     fontWeight: FontWeight.w600,
  //                   ),
  //                   textAlign: TextAlign.center,
  //                   maxLines: 2,
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }


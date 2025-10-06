// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../helpers/backend.dart';
// import 'category_page.dart';
// import 'side_menu.dart';

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
//       return const Center(child: CircularProgressIndicator());
//     }

//     Map<String, List<dynamic>> groupedCategories = {};
//     for (var cat in filteredCategories) {
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
//                   mainAxisSpacing: 8,
//                   crossAxisSpacing: 8,
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
//                   hintText: 'Search for a category',
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
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../helpers/backend.dart';
// import 'category_page.dart';
// import 'side_menu.dart';
// import '../helpers/colors.dart';
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
//       return const Center(child: CircularProgressIndicator());
//     }

//     Map<String, List<dynamic>> groupedCategories = {};
//     for (var cat in filteredCategories) {
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
//                   mainAxisSpacing: 8,
//                   crossAxisSpacing: 8,
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
// Widget build(BuildContext context) {
//   return Scaffold(
//     key: _scaffoldKey,
//     backgroundColor: Colors.white,
//     body: SafeArea(
//       child: Column(
//         children: [
//           // Top Image + Search Bar Section
//           Stack(
//             children: [
//               // Image with rounded top corners
//               ClipRRect(
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(24),
//                   topRight: Radius.circular(24),
//                 ),
//                 child: Image.asset(
//                   'assets/images/mainImg.png', // Replace with your image
//                   width: double.infinity,
//                   height: 180, // normal height
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               // Search bar & menu icon overlay
//               Positioned(
//                 bottom: 16,
//                 left: 16,
//                 right: 16,
//                 child: Row(
//                   children: [
//                     // Menu Icon
//                     Container(
//                       decoration: BoxDecoration(
//                         color: AppColors.primaryBlue,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: IconButton(
//                         icon: const Icon(Icons.menu, color: Colors.white),
//                         onPressed: () => _scaffoldKey.currentState?.openDrawer(),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     // Search Field
//                     Expanded(
//                       child: TextField(
//                         controller: searchController,
//                         style: const TextStyle(
//                           color: AppColors.textDark,
//                           fontWeight: FontWeight.w500,
//                           fontSize: 16,
//                         ),
//                         decoration: InputDecoration(
//                           hintText: 'Search for a category',
//                           hintStyle: const TextStyle(
//                             color: Color(0xFF5C74B1),
//                             fontSize: 16,
//                             fontWeight: FontWeight.w400,
//                           ),
//                           filled: true,
//                           fillColor: const Color(0xFFE6F0FA),
//                           contentPadding: const EdgeInsets.symmetric(
//                               vertical: 14, horizontal: 16),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(18),
//                             borderSide: BorderSide.none,
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(18),
//                             borderSide: const BorderSide(
//                                 color: Color(0xFF0A66C2), width: 2),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),

//           // Rest of your content
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   buildCategorySection(),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//     drawer: SideMenu(
//       logoPath: "assets/images/logo.png",
//       primaryColor: const Color(0xFF0A66C2),
//       secondaryColor: const Color(0xFFD9E1F0),
//       highlightColor: const Color(0xFF2A3A69),
//       selectedMenu: "About Us",
//       onMenuSelected: (menu) {
//         Navigator.pop(context);
//       },
//     ),
//   );
// }

// }

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../helpers/backend.dart';
import 'category_page.dart';
import 'side_menu.dart';
import '../helpers/colors.dart';
import '../widgets/settings.dart';
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

  return SafeArea(
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: groupedCategories.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    top: 16.0,
                    bottom: 8.0,
                  ),
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
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: entry.value.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 15,
                          crossAxisSpacing: 15,
                          childAspectRatio: 0.75, // slightly smaller ratio avoids overflow
                        ),
                        itemBuilder: (context, index) {
                          final category = entry.value[index];
                          String? imagePath = category['image_url'];
                          Widget imageWidget;

                          if (imagePath != null && imagePath.isNotEmpty) {
                            if (imagePath.startsWith('http')) {
                              imageWidget = Image.network(
                                imagePath,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.image, color: Colors.grey, size: 30);
                                },
                              );
                            } else if (imagePath.startsWith('assets/')) {
                              imageWidget = Image.asset(imagePath, fit: BoxFit.contain);
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
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFF0F0F0),
                                    spreadRadius: 2,
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 55,
                                    height: 55,
                                    child: Center(child: imageWidget),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    category['name'] ?? 'Unknown',
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          }).toList(),
        ),
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: SideMenu(
  logoPath: "assets/images/mylogo.png",
  primaryColor: const Color(0xFF0A66C2),
  secondaryColor: const Color(0xFFD9E1F0),
  highlightColor: const Color(0xFF2A3A69),
  selectedMenu: "About Us",
  onMenuSelected: (menu) {
    Navigator.pop(context); // close the drawer first

    if (menu == "Settings") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );
    }

    // For other menu items, you can add more conditions
    else if (menu == "About Us") {
      // Navigate to About Us page
    }
  },
),

      body: SafeArea(
        child: Column(
          children: [
            // Top Image + Search Bar
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Image with rounded top corners
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  child: Image.asset(
                    'assets/images/newmain.png',
                    width: double.infinity,
                    height: 240, // Slightly bigger for better visual
                    fit: BoxFit.cover,
                  ),
                ),

                // Search bar + menu icon
                Positioned(
                  bottom: -25, // Overlapping effect
                  left: 16,
                  right: 16,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Menu icon
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.darkBlue,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white),
                            onPressed: () =>
                                _scaffoldKey.currentState?.openDrawer(),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Search input
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search for a category',
                              hintStyle: const TextStyle(
                                color: Color(0xFF616161),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFE6F0FA),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 35), // Space below search bar
            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   const SizedBox(height: 24),
// Padding(
//   padding: const EdgeInsets.symmetric(horizontal: 8.0),
//   child: Container(
//     padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
//     decoration: BoxDecoration(
//       color: Color(0xFFE6F0FA), // halka light blue background
//       borderRadius: BorderRadius.circular(10),
//     ),
//     child: const Text(
//       'Highlights',
//       style: TextStyle(
//         fontSize: 20,
//         fontWeight: FontWeight.bold,
//         color: AppColors.textDark, // tumhari theme ka darkBlue
//         letterSpacing: 0.5,
//       ),
//     ),
//   ),
// ),


//         const SizedBox(height: 12), // space between heading and carousel
//                     const AutoScrollCarousel(),
//                   const SizedBox(height: 24),
// Padding(
//   padding: const EdgeInsets.symmetric(horizontal: 8.0),
//   child: Container(
//     padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
//     decoration: BoxDecoration(
//       color: Color(0xFFE6F0FA), // halka light blue background
//       borderRadius: BorderRadius.circular(10),
//     ),
//     child: const Text(
//       'Categories',
//       style: TextStyle(
//         fontSize: 20,
//         fontWeight: FontWeight.bold,
//         color: AppColors.textDark, // tumhari theme ka darkBlue
//         letterSpacing: 0.5,
//       ),
//     ),
//   ),
// ),
// const SizedBox(height: 16),

// space before buildCategorySection()
                    buildCategorySection(),

                  
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

class AutoScrollCarousel extends StatefulWidget {
  const AutoScrollCarousel({Key? key}) : super(key: key);

  @override
  _AutoScrollCarouselState createState() => _AutoScrollCarouselState();
}

class _AutoScrollCarouselState extends State<AutoScrollCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.95);
  late Timer _timer;
  int _currentPage = 0;

  final List<String> images = [
    'assets/images/one.png',
    'assets/images/two.png',
    'assets/images/three.png',
    'assets/images/four.png',
    'assets/images/five.png',
    'assets/images/six.png',
    'assets/images/seven.png',
    'assets/images/eight.png',
    'assets/images/nine.png',
    'assets/images/ten.png',
    'assets/images/eleven.png',
    'assets/images/twelve.png',
    'assets/images/thirteen.png',
    'assets/images/fourteen.png',
    'assets/images/fifteen.png',
    'assets/images/sixteen.png',
    'assets/images/seventeen.png',
    'assets/images/eighteen.png',
  ];

  @override
  void initState() {
    super.initState();

    // Auto slide every 2 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        _currentPage++;
        if (_currentPage >= images.length) {
          _currentPage = 0; // loop back
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: PageView.builder(
        controller: _pageController,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6), // thoda gap
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                images[index],
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          );
        },
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'package:http/http.dart' as http;
// import 'package:servicebookingapp/helpers/my_colors.dart';
// import 'dart:convert';
// import '../helpers/backend.dart';
// import 'category_page.dart';
// import 'side_menu.dart';
// import 'provider_status_screen.dart';
// import '../widgets/settings.dart';
// import '../widgets/Contact.dart';
// //import '../widgets/ServiceRemovalRequest.dart';

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
//       return const Center(
//         child: CircularProgressIndicator(color: MyColors.primary),
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
//                         color: MyColors.textPrimary,
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
//                                     0.75, // slightly smaller ratio avoids overflow
//                               ),
//                           itemBuilder: (context, index) {
//                             final category = entry.value[index];
//                             String? imagePath = category['image_url'];
//                             Widget imageWidget;

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
//                                   color: MyColors.surface,
//                                   borderRadius: BorderRadius.circular(20),
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
//                                         color: MyColors.textPrimary,

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
//       backgroundColor: MyColors.background,
//       drawer: SideMenu(
//         logoPath: "assets/images/bglogo.png",
//         primaryColor: MyColors.primary,
//         secondaryColor: MyColors.surface,
//         highlightColor: MyColors.secondary,

//         selectedMenu: "Dashboard",
//         onMenuSelected: (menu) {
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
//           // For other menu items, you can add more conditions
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
//                     height: 240, // Slightly bigger for better visual
//                     fit: BoxFit.cover,
//                   ),
//                 ),

//                 // Search bar + menu icon
//                 Positioned(
//                   bottom: -25, // Overlapping effect
//                   left: 16,
//                   right: 16,
//                   child: Container(
//                     height: 50,
//                     decoration: BoxDecoration(
//                       color: MyColors.surface,
//                       borderRadius: BorderRadius.circular(25),
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
//                             color: MyColors.primary,
//                             borderRadius: BorderRadius.circular(25),
//                           ),
//                           child: Builder(
//                             builder: (context) {
//                               return IconButton(
//                                 icon: const Icon(
//                                   Icons.arrow_back_ios_new,
//                                   color: Colors.white,
//                                 ),
//                                 onPressed: () {
//                                   Scaffold.of(
//                                     context,
//                                   ).openDrawer(); // directly opens drawer smoothly
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
//                               color: MyColors.textPrimary,
//                               fontWeight: FontWeight.w500,
//                               fontSize: 16,
//                             ),
//                             decoration: InputDecoration(
//                               hintText: 'Search for a category',
//                               hintStyle: const TextStyle(
//                                 color: MyColors.textSecondary,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w400,
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(25),
//                                 borderSide: BorderSide.none,
//                               ),
//                               filled: true,
//                               fillColor: MyColors.surface,
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

//             const SizedBox(height: 35), // Space below search bar
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
    // ... existing logic preserved ...
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
      // Color updated: MyColors.primary -> kPrimaryColor
      return const Center(
        child: CircularProgressIndicator(color: kPrimaryColor), 
      );
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
                        // Color updated: MyColors.textPrimary -> kTextPrimary (Best fit for bold heading)
                        color: kTextPrimary, 
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
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 15,
                                crossAxisSpacing: 15,
                                childAspectRatio:
                                    0.75, // existing ratio preserved
                              ),
                          itemBuilder: (context, index) {
                            final category = entry.value[index];
                            String? imagePath = category['image_url'];
                            Widget imageWidget;
                            
                            // Image logic preserved (network, asset, or fallback icon)
                            if (imagePath != null && imagePath.isNotEmpty) {
                              if (imagePath.startsWith('http')) {
                                imageWidget = Image.network(
                                  imagePath,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.image,
                                      color: Colors.grey,
                                      size: 30,
                                    );
                                  },
                                );
                              } else if (imagePath.startsWith('assets/')) {
                                imageWidget = Image.asset(
                                  imagePath,
                                  fit: BoxFit.contain,
                                );
                              } else {
                                imageWidget = const Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                  size: 30,
                                );
                              }
                            } else {
                              imageWidget = const Icon(
                                Icons.image,
                                color: Colors.grey,
                                size: 30,
                              );
                            }

                            return GestureDetector(
                              onTap: () {
                                // Existing navigation logic preserved
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
                                  // Color updated: MyColors.surface -> kCardColor
                                  color: kCardColor, 
                                  borderRadius: BorderRadius.circular(20),
                                  // Box Shadow preserved 
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.4),
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
                                        // Color updated: MyColors.textPrimary -> kTextPrimary
                                        color: kTextPrimary, 
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
      // Color updated: MyColors.background -> kBackgroundColor
      backgroundColor: kBackgroundColor, 
      drawer: SideMenu(
        // Colors updated for drawer:
        logoPath: "assets/images/bglogo.png",
        primaryColor: kPrimaryColor, // MyColors.primary -> kPrimaryColor
        secondaryColor: kCardColor, // MyColors.surface -> kCardColor
        highlightColor: kSecondaryColor, // MyColors.secondary -> kSecondaryColor

        selectedMenu: "Dashboard",
        onMenuSelected: (menu) {
          // ... existing drawer navigation logic preserved ...
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ProviderStatusScreen(providerId: widget.currentUserId),
            ),
          );

          // close the drawer first

          if (menu == "Settings") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    SettingsScreen(currentUserId: widget.currentUserId),
              ),
            );
          }
          else if (menu == "Contact Us") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ContactUsPage()),
            );
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
                    height: 240, 
                    fit: BoxFit.cover,
                  ),
                ),

                // Search bar + menu icon
                Positioned(
                  bottom: -25, // Overlapping effect preserved
                  left: 16,
                  right: 16,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      // Color updated: MyColors.surface -> kCardColor
                      color: kCardColor, 
                      borderRadius: BorderRadius.circular(25),
                      // Box Shadow preserved 
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            // Color updated: MyColors.primary -> kPrimaryColor
                            color: kPrimaryColor, 
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Builder(
                            builder: (context) {
                              return IconButton(
                                icon: const Icon(
                                  // Icon is for opening the drawer based on logic
                                  Icons.arrow_back_ios_new,
                                  color: buttonText, // Using your white buttonText color
                                ),
                                onPressed: () {
                                  // Existing drawer open logic preserved
                                  Scaffold.of(
                                    context,
                                  ).openDrawer(); 
                                },
                              );
                            },
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Search input
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            style: const TextStyle(
                              // Color updated: MyColors.textPrimary -> kTextPrimary
                              color: kTextPrimary, 
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search for a category',
                              hintStyle: const TextStyle(
                                // Color updated: MyColors.textSecondary -> kTextSecondary
                                color: kTextSecondary, 
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              // Color updated: MyColors.surface -> kCardColor
                              fillColor: kCardColor, 
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

            const SizedBox(height: 35), // Space below search bar preserved
            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
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
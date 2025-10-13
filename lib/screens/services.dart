import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:servicebookingapp/helpers/my_colors.dart';
import 'dart:convert';
import '../helpers/backend.dart';
import 'category_page.dart';
import 'side_menu.dart';

import '../widgets/settings.dart';
import '../widgets/Contact.dart';
//import '../widgets/ServiceRemovalRequest.dart';

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
      return const Center(
        child: CircularProgressIndicator(color: MyColors.primary),
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
                        color: MyColors.textPrimary,
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
                                    0.75, // slightly smaller ratio avoids overflow
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
                                  color: MyColors.surface,
                                  borderRadius: BorderRadius.circular(20),
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
                                        color: MyColors.textPrimary,

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
      backgroundColor: MyColors.background,
      drawer: SideMenu(
        logoPath: "assets/images/bglogo.png",
        primaryColor: MyColors.primary,
        secondaryColor: MyColors.surface,
        highlightColor: MyColors.secondary,

        selectedMenu: "About Us",
        onMenuSelected: (menu) {
          Navigator.pop(context); // close the drawer first

          if (menu == "Settings") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    SettingsScreen(currentUserId: widget.currentUserId),
              ),
            );
          }
          // For other menu items, you can add more conditions
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
                      color: MyColors.surface,
                      borderRadius: BorderRadius.circular(25),
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
                            color: MyColors.primary,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Builder(
                            builder: (context) {
                              return IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Scaffold.of(
                                    context,
                                  ).openDrawer(); // directly opens drawer smoothly
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
                              color: MyColors.textPrimary,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search for a category',
                              hintStyle: const TextStyle(
                                color: MyColors.textSecondary,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: MyColors.surface,
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

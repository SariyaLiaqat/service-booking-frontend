// import 'package:flutter/material.dart';
// import 'MyProfileScreen.dart';
// import '../helpers/backend.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

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

//   @override
//   void initState() {
//     super.initState();
//     fetchCategoryProviders();
//   }

//  Future<void> fetchCategoryProviders() async {
//   try {
//     final url = Uri.parse('${Backend.baseUrl}/services?category_id=${widget.categoryId}');
//     final response = await http.get(url);
//     print('API Response: ${response.body}'); // Debug

//     if (response.statusCode == 200) {
//       final List services = jsonDecode(response.body);

//       // ✅ Extract unique providers
//       final uniqueProviders = <int, dynamic>{};
//       for (var service in services) {
//         final providerId = service['provider_id'];
//         if (!uniqueProviders.containsKey(providerId)) {
//           uniqueProviders[providerId] = {
//             'id': providerId,
//             'name': service['provider_name'],
//             'profile_image': service['provider_image'],
//             'skills': service['provider_skills'],
//             'average_rating': service['average_rating'],
//             'total_ratings': service['total_ratings'],
//           };
//         }
//       }

//       setState(() {
//         providers = uniqueProviders.values.toList();
//         isLoading = false;
//       });
//     } else {
//       setState(() => isLoading = false);
//       print('Failed: ${response.statusCode}');
//     }
//   } catch (e) {
//     setState(() => isLoading = false);
//     print('Error: $e');
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.categoryName)),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : GridView.builder(
//               padding: EdgeInsets.all(16),
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 childAspectRatio: 0.78,
//                 mainAxisSpacing: 16,
//                 crossAxisSpacing: 16,
//               ),
//               itemCount: providers.length,
//               itemBuilder: (context, index) {
//                 final provider = providers[index];
//                 return buildProviderCard(provider); // reuse existing method
//               },
//             ),
//     );
//   }

//  Widget buildProviderCard(dynamic provider) {
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

//    double avgRating = double.tryParse(provider['average_rating']?.toString() ?? '0') ?? 0.0;
// int totalRatings = int.tryParse(provider['total_ratings']?.toString() ?? '0') ?? 0;

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
//             // 🔹 Rating display
//             Row(
//   mainAxisAlignment: MainAxisAlignment.center,
//   children: [
//     Icon(Icons.star, color: Colors.amber, size: 16),
//     SizedBox(width: 4),
//     Text(avgRating.toStringAsFixed(1), style: TextStyle(color: Color(0xFF2A3A69))),
//     if (totalRatings > 0) ...[
//       SizedBox(width: 4),
//       Text('($totalRatings)', style: TextStyle(fontSize: 12, color: Color(0xFF5C74B1))),
//     ],
//   ],
// ),
//           ],
//         ),
//       ),
//     );
//   }

// }



import 'package:flutter/material.dart';
import 'package:servicebookingapp/helpers/colors.dart';
import 'MyProfileScreen.dart';
import '../helpers/backend.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../helpers/colors.dart';
import 'package:geolocator/geolocator.dart';


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
  @override
  void initState() {
    super.initState();
    fetchCategoryProviders();
  }

  //final url = Uri.parse('${Backend.baseUrl}/category_providers?category_id=${widget.categoryId}');
  Future<void> fetchCategoryProviders() async {
    try {
      final url = Uri.parse(
        '${Backend.baseUrl}/services?category_id=${widget.categoryId}',
      );
      final response = await http.get(url);
      print('API Response: ${response.body}');

      if (response.statusCode == 200) {
        final List fetchedServices = jsonDecode(response.body);

        // Group services by provider_id
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

        providers = uniqueProviders.values.toList();
        setState(() => isLoading = false);
      } else {
        setState(() => isLoading = false);
        print('Failed: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      print('Error: $e');
    }
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName, style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.darkBlue, // Your chosen blue
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: Column(
        children: [
          // ✅ Beautiful Search Bar below AppBar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(
                      color: Color(0xFF2A3A69), // textDark equivalent
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
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF5C74B1),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ✅ Rest of the body
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NearbyProvidersWithRatingsWidget(
                          currentUserId: widget.currentUserId,
                        ),
                        const SizedBox(height: 24),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.78,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                              ),
                          itemCount: providers.length,
                          itemBuilder: (context, index) {
                            final provider = providers[index];
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
    // ✅ Correct image mapping
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

    // ✅ Correct name mapping
    String displayName =
        provider['name'] ?? provider['provider_name'] ?? 'Unknown';

    // ✅ Correct skills mapping
    String skills = '';
    if (provider['skills'] != null && provider['skills'] is List) {
      skills = (provider['skills'] as List).join(', ');
    } else if (provider['provider_skills'] != null &&
        provider['provider_skills'] is List) {
      skills = (provider['provider_skills'] as List).join(', ');
    }

    // ✅ Rating
    double avgRating =
        double.tryParse(provider['average_rating']?.toString() ?? '0') ?? 0.0;
    int totalRatings =
        int.tryParse(provider['total_ratings']?.toString() ?? '0') ?? 0;

    // ✅ Correct provider ID for profile screen
    final providerId = provider['provider_id'] ?? provider['id'];

    return GestureDetector(
      onTap: () async {
        dynamic providerDetails;
        try {
          // 🔹 Make sure API endpoint is correct for provider details
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
        ///////
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFE6F0FA),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 35,
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
              child: imageUrl == null
                  ? const Icon(Icons.person, size: 35, color: Color(0xFF2A3A69))
                  : null,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              displayName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2A3A69),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              skills.isNotEmpty ? skills : '',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF5C74B1), fontSize: 12),
            ),
            const SizedBox(height: 4),

            // 🔹 Services list if available
          // 🔹 Services list (read-only, no delete)
if (provider['services'] != null && provider['services'] is List)
  for (var service in provider['services'])
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.05), // soft bg color for title
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '- ${service['title']}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF2A3A69),
            fontSize: 12,
          ),
        ),
      ),
    ),






            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  avgRating.toStringAsFixed(1),
                  style: const TextStyle(color: Color(0xFF2A3A69)),
                ),
                if (totalRatings > 0) ...[
                  const SizedBox(width: 4),
                  Text(
                    '($totalRatings)',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF5C74B1),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ✅ Nearby Providers with Ratings Widget
/// ✅ Nearby Providers with Ratings Widget
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (nearbyProviders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'No nearby providers found.',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
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
            'Nearby Providers',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),

        // Horizontal Scroll List
        SizedBox(
          height: 160,
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
                  width: 110,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 38,
                        backgroundImage: imageUrl != null
                            ? NetworkImage(imageUrl)
                            : null,
                        child: imageUrl == null
                            ? const Icon(
                                Icons.person,
                                size: 36,
                                color: Color(0xFF2A3A69),
                              )
                            : null,
                        backgroundColor: Colors.grey[200],
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 90,
                        child: Text(
                          provider['name'] ?? 'Unknown',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2A3A69),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            avgRating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Color(0xFF2A3A69),
                              fontSize: 12,
                            ),
                          ),
                          if (totalRatings > 0) ...[
                            const SizedBox(width: 2),
                            Text(
                              '($totalRatings)',
                              style: const TextStyle(
                                color: Color(0xFF5C74B1),
                                fontSize: 10,
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

        // Divider / All Providers Section Label
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            'Related Services For You',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

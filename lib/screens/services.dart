// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../helpers/backend.dart';
// import 'MyProfileScreen.dart';

// class ServicesScreen extends StatefulWidget {
//   final int currentUserId;
//   const ServicesScreen({Key? key, required this.currentUserId}) : super(key: key);

//   @override
//   ServicesScreenState createState() => ServicesScreenState();
// }

// class ServicesScreenState extends State<ServicesScreen> {
//   bool isLoading = true;
//   List<dynamic> providers = [];
//   List<dynamic> filteredProviders = [];
//   TextEditingController searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     fetchProviders();
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

//   Future<void> fetchProviders() async {
//     setState(() => isLoading = true);
//     try {
//       final url = Uri.parse('${Backend.baseUrl}/auth/services/providers');
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           providers = data['providers'] ?? [];
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
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(msg)),
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

//     return GestureDetector(
//       onTap: () async {
//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (_) => const Center(
//             child: CircularProgressIndicator(color: Colors.teal),
//           ),
//         );

//         dynamic providerDetails;
//         try {
//           final url = Uri.parse('${Backend.baseUrl}/auth/provider/${provider['id']}');
//           final response = await http.get(url);
//           if (response.statusCode == 200) {
//             providerDetails = jsonDecode(response.body);
//           } else {
//             providerDetails = provider;
//           }
//         } catch (_) {
//           providerDetails = provider;
//         }

//         Navigator.pop(context); // remove loading
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
//           color: const Color(0xFF1E1E1E),
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircleAvatar(
//               radius: 30,
//               backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
//               child: imageUrl == null
//                   ? const Icon(Icons.person, size: 30, color: Colors.white70)
//                   : null,
//               backgroundColor: Colors.grey[700],
//             ),
//             const SizedBox(height: 12),
//             Text(
//               provider['name'] ?? 'Unknown',
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//               textAlign: TextAlign.center,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 6),
//             Text(
//               skills.isNotEmpty ? skills : 'No skills',
//               style: const TextStyle(fontSize: 12, color: Colors.white70),
//               textAlign: TextAlign.center,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF121212),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF1E1E1E),
//         elevation: 1,
//         toolbarHeight: 60,
//         leadingWidth: 120,
//         leading: Row(
//           children: [
//             const SizedBox(width: 8),
//             IconButton(
//               icon: const Icon(Icons.menu, color: Colors.white),
//               onPressed: () {},
//             ),
//             const Text(
//               'Home',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.message, color: Colors.white),
//             onPressed: () {},
//           ),
//           IconButton(
//             icon: const Icon(Icons.notifications_none, color: Colors.white),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//               const Text(
//                 'Choose the service you would like to receive',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                   height: 1.2,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: searchController,
//                 style: const TextStyle(color: Colors.white),
//                 decoration: InputDecoration(
//                   hintText: 'Search for a service',
//                   hintStyle: const TextStyle(color: Colors.white54),
//                   prefixIcon: const Icon(Icons.search, color: Colors.white70),
//                   filled: true,
//                   fillColor: const Color(0xFF1E1E1E),
//                   contentPadding:
//                       const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Expanded(
//                 child: isLoading
//                     ? const Center(child: CircularProgressIndicator(color: Colors.teal))
//                     : filteredProviders.isEmpty
//                         ? const Center(
//                             child: Text(
//                               'No providers found',
//                               style: TextStyle(color: Colors.white70),
//                             ),
//                           )
//                         : GridView.builder(
//                             padding: const EdgeInsets.only(bottom: 24),
//                             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 3,
//                               childAspectRatio: 0.78, // Adjusted for overflow
//                               mainAxisSpacing: 16,
//                               crossAxisSpacing: 16,
//                             ),
//                             itemCount: filteredProviders.length,
//                             itemBuilder: (context, index) =>
//                                 buildProviderCard(filteredProviders[index]),
//                           ),
//               ),
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
// import 'MyProfileScreen.dart';

// class ServicesScreen extends StatefulWidget {
//   final int currentUserId;
//   const ServicesScreen({Key? key, required this.currentUserId})
//     : super(key: key);

//   @override
//   ServicesScreenState createState() => ServicesScreenState();
// }

// class ServicesScreenState extends State<ServicesScreen> {
//   bool isLoading = true;
//   List<dynamic> providers = [];
//   List<dynamic> filteredProviders = [];
//   TextEditingController searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     fetchProviders();
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

//   Future<void> fetchProviders() async {
//     setState(() => isLoading = true);
//     try {
//       final url = Uri.parse('${Backend.baseUrl}/provider');

//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           providers = data['providers'] ?? [];
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
//   String? imageUrl;
//   if (provider['profile_image'] != null && provider['profile_image'] != '') {
//     imageUrl = provider['profile_image'].startsWith('http')
//         ? provider['profile_image']
//         : '${Backend.baseUrl}/${provider['profile_image']}';
//   }

//   String skills = '';
//   if (provider['skills'] != null && provider['skills'] is List) {
//     skills = (provider['skills'] as List).join(', ');
//   }

//   // 🔹 Services preview
//   String servicesPreview = '';
//   if (provider['services'] != null && provider['services'] is List) {
//     List servicesList = provider['services'];
//     if (servicesList.isNotEmpty) {
//       int previewCount = servicesList.length > 3 ? 3 : servicesList.length;
//       servicesPreview =
//           servicesList.sublist(0, previewCount).map((s) => s['title']).join(', ');
//       if (servicesList.length > 3) {
//         servicesPreview += ' +${servicesList.length - 3} more';
//       }
//     } else {
//       servicesPreview = 'No services';
//     }
//   }

//   return GestureDetector(
//     onTap: () async {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (_) => const Center(
//           child: CircularProgressIndicator(color: Color(0xFF2A3A69)),
//         ),
//       );

//       dynamic providerDetails;
//       try {
//        final url = Uri.parse('${Backend.baseUrl}/services/providers/${provider['id']}');

//         final response = await http.get(url);
//         if (response.statusCode == 200) {
//           providerDetails = jsonDecode(response.body);
//         } else {
//           providerDetails = provider;
//         }
//       } catch (_) {
//         providerDetails = provider;
//       }

//       Navigator.pop(context); // remove loading
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => MyProfileScreen(
//             userData: providerDetails,
//             readOnly: widget.currentUserId != provider['id'],
//             currentUserId: widget.currentUserId,
//           ),
//         ),
//       );
//     },
//     child: Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: const Color(0xFFD9E1F0),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black26,
//             blurRadius: 6,
//             offset: Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircleAvatar(
//             radius: 35,
//             backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
//             child: imageUrl == null
//                 ? const Icon(Icons.person, size: 35, color: Color(0xFF2A3A69))
//                 : null,
//             backgroundColor: Colors.white,
//           ),
//           const SizedBox(height: 12),
//           Text(
//             provider['name'] ?? 'Unknown',
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF2A3A69),
//             ),
//             textAlign: TextAlign.center,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//           const SizedBox(height: 6),
//           Text(
//             skills.isNotEmpty ? skills : 'No skills',
//             style: const TextStyle(fontSize: 12, color: Color(0xFF5C74B1)),
//             textAlign: TextAlign.center,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//           const SizedBox(height: 6),
//           Text(
//             servicesPreview,
//             style: const TextStyle(fontSize: 12, color: Color(0xFF2A3A69)),
//             textAlign: TextAlign.center,
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     ),
//   );
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFFFFFFF),
//      appBar: AppBar(
//   backgroundColor: const Color(0xFF5C74B1),
//   elevation: 0,
//   toolbarHeight: 60,
//   leading: IconButton(
//     icon: const Icon(Icons.menu, color: Colors.white),
//     onPressed: () {},
//   ),
//   title: const Text(
//     'Services',
//     style: TextStyle(
//       color: Colors.white,
//       fontSize: 20,
//       fontWeight: FontWeight.bold,
//     ),
//   ),
// ),

//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//               const Text(
//                 'Choose the service you would like to receive',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF2A3A69),
//                   height: 1.3,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: searchController,
//                 style: const TextStyle(color: Color(0xFF2A3A69)),
//                 decoration: InputDecoration(
//                   hintText: 'Search for a service',
//                   hintStyle: const TextStyle(color: Color(0xFF5C74B1)),
//                   prefixIcon: const Icon(
//                     Icons.search,
//                     color: Color(0xFF5C74B1),
//                   ),
//                   filled: true,
//                   fillColor: const Color(0xFFD9E1F0),
//                   contentPadding: const EdgeInsets.symmetric(
//                     vertical: 0,
//                     horizontal: 16,
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Expanded(
//                 child: isLoading
//                     ? const Center(
//                         child: CircularProgressIndicator(
//                           color: Color(0xFF2A3A69),
//                         ),
//                       )
//                     : filteredProviders.isEmpty
//                     ? const Center(
//                         child: Text(
//                           'No providers found',
//                           style: TextStyle(color: Color(0xFF5C74B1)),
//                         ),
//                       )
//                     : GridView.builder(
//                         padding: const EdgeInsets.only(bottom: 24),
//                         gridDelegate:
//                             const SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 2, // 2 cards per row
//                               childAspectRatio: 0.78,
//                               mainAxisSpacing: 16,
//                               crossAxisSpacing: 16,
//                             ),
//                         itemCount: filteredProviders.length,
//                         itemBuilder: (context, index) =>
//                             buildProviderCard(filteredProviders[index]),
//                       ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



//// perfect///
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../helpers/backend.dart';
// import 'MyProfileScreen.dart';

// class ServicesScreen extends StatefulWidget {
//   final int currentUserId;
//   const ServicesScreen({Key? key, required this.currentUserId})
//     : super(key: key);

//   @override
//   ServicesScreenState createState() => ServicesScreenState();
// }

// class ServicesScreenState extends State<ServicesScreen> {
//   bool isLoading = true;
//   List<dynamic> providers = [];
//   List<dynamic> filteredProviders = [];
//   TextEditingController searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     fetchProviders();
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

//   Future<void> fetchProviders() async {
//     setState(() => isLoading = true);
//     try {
//       final url = Uri.parse('${Backend.baseUrl}/provider');

//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           providers = data['providers'] ?? [];
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
//   String? imageUrl;
//   if (provider['profile_image'] != null && provider['profile_image'] != '') {
//     imageUrl = provider['profile_image'].startsWith('http')
//         ? provider['profile_image']
//         : '${Backend.baseUrl}/${provider['profile_image']}';
//   }

//   String skills = '';
//   if (provider['skills'] != null && provider['skills'] is List) {
//     skills = (provider['skills'] as List).join(', ');
//   }

//   // 🔹 Services preview
//   String servicesPreview = '';
//   if (provider['services'] != null && provider['services'] is List) {
//     List servicesList = provider['services'];
//     if (servicesList.isNotEmpty) {
//       int previewCount = servicesList.length > 3 ? 3 : servicesList.length;
//       servicesPreview =
//           servicesList.sublist(0, previewCount).map((s) => s['title']).join(', ');
//       if (servicesList.length > 3) {
//         servicesPreview += ' +${servicesList.length - 3} more';
//       }
//     } else {
//       servicesPreview = 'No services';
//     }
//   }

//   return GestureDetector(
//     onTap: () async {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (_) => const Center(
//           child: CircularProgressIndicator(color: Color(0xFF2A3A69)),
//         ),
//       );

//       dynamic providerDetails;
//       try {
//         // ✅ Updated URL for single provider fetch
//         final url = Uri.parse('${Backend.baseUrl}/provider/services/providers/${provider['id']}');

//         final response = await http.get(url);
//         if (response.statusCode == 200) {
//           providerDetails = jsonDecode(response.body)['provider'];
//         } else {
//           providerDetails = provider;
//         }
//       } catch (_) {
//         providerDetails = provider;
//       }

//       Navigator.pop(context); // remove loading
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => MyProfileScreen(
//             userData: providerDetails,
//             readOnly: widget.currentUserId != provider['id'],
//             currentUserId: widget.currentUserId,
//           ),
//         ),
//       );
//     },
//     child: Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: const Color(0xFFD9E1F0),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black26,
//             blurRadius: 6,
//             offset: Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircleAvatar(
//             radius: 35,
//             backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
//             child: imageUrl == null
//                 ? const Icon(Icons.person, size: 35, color: Color(0xFF2A3A69))
//                 : null,
//             backgroundColor: Colors.white,
//           ),
//           const SizedBox(height: 12),
//           Text(
//             provider['name'] ?? 'Unknown',
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF2A3A69),
//             ),
//             textAlign: TextAlign.center,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//           const SizedBox(height: 6),
//           Text(
//             skills.isNotEmpty ? skills : 'No skills',
//             style: const TextStyle(fontSize: 12, color: Color(0xFF5C74B1)),
//             textAlign: TextAlign.center,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//           const SizedBox(height: 6),
//           Text(
//             servicesPreview,
//             style: const TextStyle(fontSize: 12, color: Color(0xFF2A3A69)),
//             textAlign: TextAlign.center,
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     ),
//   );
// }







//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFFFFFFF),
//      appBar: AppBar(
//   backgroundColor: const Color(0xFF5C74B1),
//   elevation: 0,
//   toolbarHeight: 60,
//   leading: IconButton(
//     icon: const Icon(Icons.menu, color: Colors.white),
//     onPressed: () {},
//   ),
//   title: const Text(
//     'Services',
//     style: TextStyle(
//       color: Colors.white,
//       fontSize: 20,
//       fontWeight: FontWeight.bold,
//     ),
//   ),
// ),

//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//               const Text(
//                 'Choose the service you would like to receive',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF2A3A69),
//                   height: 1.3,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: searchController,
//                 style: const TextStyle(color: Color(0xFF2A3A69)),
//                 decoration: InputDecoration(
//                   hintText: 'Search for a service',
//                   hintStyle: const TextStyle(color: Color(0xFF5C74B1)),
//                   prefixIcon: const Icon(
//                     Icons.search,
//                     color: Color(0xFF5C74B1),
//                   ),
//                   filled: true,
//                   fillColor: const Color(0xFFD9E1F0),
//                   contentPadding: const EdgeInsets.symmetric(
//                     vertical: 0,
//                     horizontal: 16,
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Expanded(
//                 child: isLoading
//                     ? const Center(
//                         child: CircularProgressIndicator(
//                           color: Color(0xFF2A3A69),
//                         ),
//                       )
//                     : filteredProviders.isEmpty
//                     ? const Center(
//                         child: Text(
//                           'No providers found',
//                           style: TextStyle(color: Color(0xFF5C74B1)),
//                         ),
//                       )
//                     : GridView.builder(
//                         padding: const EdgeInsets.only(bottom: 24),
//                         gridDelegate:
//                             const SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 2, // 2 cards per row
//                               childAspectRatio: 0.78,
//                               mainAxisSpacing: 16,
//                               crossAxisSpacing: 16,
//                             ),
//                         itemCount: filteredProviders.length,
//                         itemBuilder: (context, index) =>
//                             buildProviderCard(filteredProviders[index]),
//                       ),
//               ),
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
// import 'package:geolocator/geolocator.dart';
// import '../helpers/backend.dart';
// import 'MyProfileScreen.dart';

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

//   double? userLat;
//   double? userLng;

//   @override
//   void initState() {
//     super.initState();
//     getUserLocation();
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
//       final position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high);
//       setState(() {
//         userLat = position.latitude;
//         userLng = position.longitude;
//       });
//       fetchNearbyProviders();
//       fetchProviders();
//     } catch (e) {
//       showSnack('Location error: $e');
//       fetchProviders(); // fallback all providers
//     }
//   }

//   Future<void> fetchProviders() async {
//     setState(() => isLoading = true);
//     try {
//       final url = Uri.parse('${Backend.baseUrl}/provider');
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           providers = data['providers'] ?? [];
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
//           '${Backend.baseUrl}/provider/nearest?lat=$userLat&lng=$userLng&limit=10');
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

//   Widget buildProviderCard(dynamic provider, {bool showDistance = false}) {
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

//     String distanceText = '';
//     if (showDistance && provider['distance'] != null) {
//       distanceText = '${provider['distance'].toStringAsFixed(1)} km away';
//     }

//     return GestureDetector(
//       onTap: () async {
//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (_) => const Center(
//             child: CircularProgressIndicator(color: Color(0xFF2A3A69)),
//           ),
//         );

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

//         Navigator.pop(context); // remove loading
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
//         width: 140,
//         padding: const EdgeInsets.all(12),
//         margin: const EdgeInsets.only(right: 12),
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
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF2A3A69),
//               ),
//               textAlign: TextAlign.center,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 4),
//             Text(
//               skills.isNotEmpty ? skills : 'No skills',
//               style: const TextStyle(fontSize: 12, color: Color(0xFF5C74B1)),
//               textAlign: TextAlign.center,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//             if (distanceText.isNotEmpty) ...[
//               const SizedBox(height: 4),
//               Text(
//                 distanceText,
//                 style: const TextStyle(fontSize: 11, color: Colors.grey),
//                 textAlign: TextAlign.center,
//               )
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFFFFFFF),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF5C74B1),
//         elevation: 0,
//         toolbarHeight: 60,
//         leading: IconButton(
//           icon: const Icon(Icons.menu, color: Colors.white),
//           onPressed: () {},
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
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Choose the service you would like to receive',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF2A3A69),
//                   height: 1.3,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: searchController,
//                 style: const TextStyle(color: Color(0xFF2A3A69)),
//                 decoration: InputDecoration(
//                   hintText: 'Search for a service',
//                   hintStyle: const TextStyle(color: Color(0xFF5C74B1)),
//                   prefixIcon: const Icon(
//                     Icons.search,
//                     color: Color(0xFF5C74B1),
//                   ),
//                   filled: true,
//                   fillColor: const Color(0xFFD9E1F0),
//                   contentPadding: const EdgeInsets.symmetric(
//                     vertical: 0,
//                     horizontal: 16,
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               // 🔹 Nearby Providers Horizontal Section
//               if (nearbyProviders.isNotEmpty) ...[
//                 const Text(
//                   'Nearby Providers',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF2A3A69),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 SizedBox(
//                   height: 180,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: nearbyProviders.length,
//                     itemBuilder: (context, index) =>
//                         buildProviderCard(nearbyProviders[index], showDistance: true),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//               ],
//               // 🔹 All Providers Grid
//               Expanded(
//                 child: isLoading
//                     ? const Center(
//                         child: CircularProgressIndicator(
//                           color: Color(0xFF2A3A69),
//                         ),
//                       )
//                     : filteredProviders.isEmpty
//                         ? const Center(
//                             child: Text(
//                               'No providers found',
//                               style: TextStyle(color: Color(0xFF5C74B1)),
//                             ),
//                           )
//                         : GridView.builder(
//                             padding: const EdgeInsets.only(bottom: 24),
//                             gridDelegate:
//                                 const SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 2,
//                               childAspectRatio: 0.78,
//                               mainAxisSpacing: 16,
//                               crossAxisSpacing: 16,
//                             ),
//                             itemCount: filteredProviders.length,
//                             itemBuilder: (context, index) =>
//                                 buildProviderCard(filteredProviders[index]),
//                           ),
//               ),
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
import 'package:geolocator/geolocator.dart';
import '../helpers/backend.dart';
import 'MyProfileScreen.dart';

class ServicesScreen extends StatefulWidget {
  final int currentUserId;
  const ServicesScreen({Key? key, required this.currentUserId})
      : super(key: key);

  @override
  ServicesScreenState createState() => ServicesScreenState();
}

class ServicesScreenState extends State<ServicesScreen> {
  bool isLoading = true;
  List<dynamic> providers = [];
  List<dynamic> filteredProviders = [];
  List<dynamic> nearbyProviders = [];
  TextEditingController searchController = TextEditingController();

  double? userLat;
  double? userLng;

  @override
  void initState() {
    super.initState();
    getUserLocation();
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
      filteredProviders = providers.where((provider) {
        String name = provider['name']?.toLowerCase() ?? '';
        String skills = provider['skills'] != null
            ? (provider['skills'] as List).join(', ').toLowerCase()
            : '';
        return name.contains(query) || skills.contains(query);
      }).toList();
    });
  }

  Future<void> getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        showSnack('Please enable location services');
        fetchProviders();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          showSnack('Location permission denied');
          fetchProviders();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        showSnack('Location permissions are permanently denied');
        fetchProviders();
        return;
      }

      // Permission granted
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        userLat = position.latitude;
        userLng = position.longitude;
      });

      fetchNearbyProviders();
      fetchProviders();
    } catch (e) {
      showSnack('Location error: $e');
      fetchProviders(); // fallback all providers
    }
  }

  Future<void> fetchProviders() async {
    setState(() => isLoading = true);
    try {
      final url = Uri.parse('${Backend.baseUrl}/provider');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          providers = data['providers'] ?? [];
          filteredProviders = providers;
        });
      } else {
        showSnack('Failed to load providers ❌');
      }
    } catch (e) {
      showSnack('Error fetching providers: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchNearbyProviders() async {
    if (userLat == null || userLng == null) return;

    try {
      final url = Uri.parse(
          '${Backend.baseUrl}/provider/nearest?lat=$userLat&lng=$userLng&limit=10');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          nearbyProviders = data['providers'] ?? [];
        });
      } else {
        showSnack('Failed to load nearby providers ❌');
      }
    } catch (e) {
      showSnack('Error fetching nearby providers: $e');
    }
  }

  void showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget buildProviderCard(dynamic provider, {bool showDistance = false}) {
    String? imageUrl;
    if (provider['profile_image'] != null && provider['profile_image'] != '') {
      imageUrl = provider['profile_image'].startsWith('http')
          ? provider['profile_image']
          : '${Backend.baseUrl}/${provider['profile_image']}';
    }

    String skills = '';
    if (provider['skills'] != null && provider['skills'] is List) {
      skills = (provider['skills'] as List).join(', ');
    }

    String distanceText = '';
    if (showDistance && provider['distance'] != null) {
      distanceText = '${provider['distance'].toStringAsFixed(1)} km away';
    }

    return GestureDetector(
      onTap: () async {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(
            child: CircularProgressIndicator(color: Color(0xFF2A3A69)),
          ),
        );

        dynamic providerDetails;
        try {
          final url = Uri.parse(
              '${Backend.baseUrl}/provider/services/providers/${provider['id']}');
          final response = await http.get(url);
          if (response.statusCode == 200) {
            providerDetails = jsonDecode(response.body)['provider'];
          } else {
            providerDetails = provider;
          }
        } catch (_) {
          providerDetails = provider;
        }

        Navigator.pop(context); // remove loading
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MyProfileScreen(
              userData: providerDetails,
              readOnly: widget.currentUserId != provider['id'],
              currentUserId: widget.currentUserId,
            ),
          ),
        );
      },
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFD9E1F0),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
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
              provider['name'] ?? 'Unknown',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2A3A69),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              skills.isNotEmpty ? skills : 'No skills',
              style: const TextStyle(fontSize: 12, color: Color(0xFF5C74B1)),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (distanceText.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                distanceText,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                textAlign: TextAlign.center,
              )
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C74B1),
        elevation: 0,
        toolbarHeight: 60,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose the service you would like to receive',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A3A69),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: searchController,
                style: const TextStyle(color: Color(0xFF2A3A69)),
                decoration: InputDecoration(
                  hintText: 'Search for a service',
                  hintStyle: const TextStyle(color: Color(0xFF5C74B1)),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF5C74B1),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFD9E1F0),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 🔹 Nearby Providers Horizontal Section
              if (nearbyProviders.isNotEmpty) ...[
                const Text(
                  'Nearby Providers',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2A3A69),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: nearbyProviders.length,
                    itemBuilder: (context, index) =>
                        buildProviderCard(nearbyProviders[index], showDistance: true),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 🔹 All Providers Grid
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF2A3A69),
                        ),
                      )
                    : filteredProviders.isEmpty
                        ? const Center(
                            child: Text(
                              'No providers found',
                              style: TextStyle(color: Color(0xFF5C74B1)),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.only(bottom: 24),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.78,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                            ),
                            itemCount: filteredProviders.length,
                            itemBuilder: (context, index) =>
                                buildProviderCard(filteredProviders[index]),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

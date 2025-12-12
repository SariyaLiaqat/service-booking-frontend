
// //////////////////////////////////////
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import '../helpers/backend.dart';
// import '../models/ExternalProfileWidget.dart';
// import 'package:url_launcher/url_launcher.dart';

// import '../helpers/coolors.dart';

// class MyProfileScreen extends StatefulWidget {
//   final Map<String, dynamic> userData;
//   final VoidCallback? onProfileUpdated;
//   final int currentUserId;
//   final bool readOnly;

//   const MyProfileScreen({
//     required this.userData,
//     required this.currentUserId,
//     this.onProfileUpdated,
//     this.readOnly = false,
//     super.key,
//   });

//   @override
//   State<MyProfileScreen> createState() => _MyProfileScreenState();
// }

// class _MyProfileScreenState extends State<MyProfileScreen> {
//   late Map<String, dynamic> user;
//   bool isEditing = false;
//   bool isLoading = false;
//   final _formKey = GlobalKey<FormState>();
//   final GlobalKey<FormState> _servicesFormKey = GlobalKey<FormState>();

//   // Controllers
//   late TextEditingController nameController;
//   late TextEditingController usernameController;
//   late TextEditingController bioController;
//   late TextEditingController phoneController;
//   late TextEditingController addressController;
//   //late TextEditingController skillsController;
//   late TextEditingController experienceController;
//   late TextEditingController govIdController;
//   late TextEditingController portfolioController;
//   late TextEditingController hourlyRateController;
//   late TextEditingController languagesController;
//   late TextEditingController educationController;
//   late TextEditingController socialLinksController;

//   String? experienceLevel;
//   File? profileImageFile;
//   File? coverImageFile;
//   String? profileBase64;
//   String? coverBase64;
//   bool showOnServices = false;

//   //int? selectedCategory;
//   // --- Services ---
//   List<Map<String, dynamic>> services = [];
//   TextEditingController serviceTitleController = TextEditingController();
//   TextEditingController serviceDescController = TextEditingController();
//   TextEditingController servicePriceController = TextEditingController();
//   //--- Categories--

//   Map<String, dynamic>? selectedCategory;

//   List<Map<String, dynamic>> categories = [];
//   bool isLoadingCategories = true;
//   //---------------------

//   Future<void> fetchCategories() async {
//     try {
//       final response = await http.get(
//         Uri.parse('${Backend.baseUrl}/categories'),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         print("Categories API response: $data"); // 🔍 Debug print

//         setState(() {
//           categories = List<Map<String, dynamic>>.from(
//             data is List ? data : data['categories'], // ✅ Safe parsing
//           );
//           isLoadingCategories = false;
//         });

//         print("Parsed categories: $categories"); // 🔍 Debug print
//       } else {
//         print('Failed to load categories');
//         setState(() => isLoadingCategories = false);
//       }
//     } catch (e) {
//       print('Error fetching categories: $e');
//       setState(() => isLoadingCategories = false);
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _initUserData();
//     fetchCategories();
//   }

//   void _initUserData() {
//     user = Map.from(widget.userData);
//     // ✅ FIX: preselect category if editing
//     selectedCategory = user['category_id'] != null
//         ? categories.cast<Map<String, dynamic>?>().firstWhere(
//             (cat) => cat != null && cat['id'] == user['category_id'],
//             orElse: () => null,
//           )
//         : null;

//     nameController = TextEditingController(text: user['name']);
//     usernameController = TextEditingController(text: user['username']);
//     bioController = TextEditingController(text: user['bio']);
//     phoneController = TextEditingController(text: user['phone']);
//     addressController = TextEditingController(text: user['address']);
//     // skillsController = TextEditingController(
//     //   text: user['skills'] != null ? (user['skills'] as List).join(', ') : '',
//     // );
//     experienceController = TextEditingController(
//       text: user['experience_years']?.toString() ?? '',
//     );
//     govIdController = TextEditingController(text: user['gov_id'] ?? '');
//     portfolioController = TextEditingController(
//       text: user['portfolio_links'] != null
//           ? (user['portfolio_links'] as List).join('\n')
//           : '',
//     );
//     hourlyRateController = TextEditingController(
//       text: user['hourly_rate']?.toString() ?? '',
//     );
//     languagesController = TextEditingController(
//       text: user['languages'] != null
//           ? (user['languages'] as List).join(', ')
//           : '',
//     );
//     educationController = TextEditingController(
//       text: user['education'] != null
//           ? (user['education'] as List).join(', ')
//           : '',
//     );
//     socialLinksController = TextEditingController(
//       text: user['social_links'] != null
//           ? (user['social_links'] as List).join('\n')
//           : '',
//     );
//     experienceLevel = user['experience_level'];
//     showOnServices = user['show_on_services'] ?? false;
//     /////////////////////////////////////////

//     if (user['services'] != null) {
//       services = List<Map<String, dynamic>>.from(user['services']);
//     } else {
//       services = []; // ✅ Ensure empty list if null
//     }
//   }

//   //--------url laucher fucntion------------

//   Future<void> _launchUrl(String url) async {
//     Uri uri = Uri.parse(url);
//     if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Could not open link ❌')));
//     }
//   }

//   bool isPickingImage = false;

//   // --- Image Picker ---
//   Future<void> pickImage(bool isProfile) async {
//     if (widget.readOnly) return;
//     if (isPickingImage) return;

//     setState(() => isPickingImage = true); // ✅ mark as picking & update UI

//     await Future.delayed(const Duration(milliseconds: 100));
//     // gives time for UI to show "Opening gallery..." or dim effect

//     try {
//       final picker = ImagePicker();
//       final picked = await picker.pickImage(source: ImageSource.gallery);
//       if (picked != null) {
//         if (kIsWeb) {
//           final bytes = await picked.readAsBytes();
//           setState(() {
//             if (isProfile)
//               profileBase64 = base64Encode(bytes);
//             else
//               coverBase64 = base64Encode(bytes);
//           });
//         } else {
//           setState(() {
//             if (isProfile)
//               profileImageFile = File(picked.path);
//             else
//               coverImageFile = File(picked.path);
//           });
//         }
//       }
//     } catch (e) {
//       debugPrint('Error picking image: $e');
//     } finally {
//       setState(() => isPickingImage = false); // ✅ reset flag & update UI
//     }
//   }

//   ImageProvider<Object>? _getImage({required bool isProfile}) {
//     if (isProfile) {
//       if (kIsWeb && profileBase64 != null)
//         return MemoryImage(base64Decode(profileBase64!));
//       if (!kIsWeb && profileImageFile != null)
//         return FileImage(profileImageFile!);
//       if (user['profile_image'] != null && user['profile_image'] != '') {
//         final url = user['profile_image'].startsWith('http')
//             ? user['profile_image']
//             : '${Backend.baseUrl}/${user['profile_image']}';
//         return NetworkImage(url);
//       }
//     } else {
//       if (kIsWeb && coverBase64 != null)
//         return MemoryImage(base64Decode(coverBase64!));
//       if (!kIsWeb && coverImageFile != null) return FileImage(coverImageFile!);
//       if (user['cover_image'] != null && user['cover_image'] != '') {
//         final url = user['cover_image'].startsWith('http')
//             ? user['cover_image']
//             : '${Backend.baseUrl}/${user['cover_image']}';
//         return NetworkImage(url);
//       }
//     }
//     return null;
//   }

//   Future<void> _openExternalProviderProfile(int providerId) async {
//     setState(() => isLoading = true);
//     try {
//       final url = Uri.parse('${Backend.baseUrl}/auth/provider/$providerId');
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final providerData = data['provider'];

//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => MyProfileScreen(
//               userData: providerData,
//               currentUserId: widget.currentUserId,
//               readOnly: true, // external view
//             ),
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load provider profile ❌')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error: $e')));
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   // ✅ Profile Save Function (self-only)
//   Future<void> saveProfile() async {
//     if (widget.readOnly) return;
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => isLoading = true);
//     final validServices = services.where((s) {
//       return (s['title'] != null && s['title'].toString().trim().isNotEmpty) &&
//           (s['description'] != null &&
//               s['description'].toString().trim().isNotEmpty) &&
//           (s['category_id'] != null);
//     }).toList();
//     try {
//       Map<String, dynamic> body = {
//         'name': nameController.text.trim(),
//         'username': usernameController.text.trim(),
//         'bio': bioController.text.trim(),
//         'phone': phoneController.text.trim(),
//         'address': addressController.text.trim(),
//         //  'skills': services.map((s) => s['title']).toList(),
//         //  'show_on_services': showOnServices,
//         'portfolio_links': portfolioController.text
//             .split('\n')
//             .map((s) => s.trim())
//             .where((s) => s.isNotEmpty)
//             .toList(),

//         'hourly_rate': hourlyRateController.text.isNotEmpty
//             ? double.tryParse(hourlyRateController.text)
//             : null,
//         'languages': languagesController.text
//             .split(',')
//             .map((s) => s.trim())
//             .where((s) => s.isNotEmpty)
//             .toList(),
//         'education': educationController.text
//             .split(',')
//             .map((s) => s.trim())
//             .where((s) => s.isNotEmpty)
//             .toList(),
//         'social_links': socialLinksController.text
//             .split('\n') // ✅ split by new line
//             .map((s) => s.trim())
//             .where((s) => s.isNotEmpty)
//             .toList(),
//       };

//       if (user['role'] == 'provider') {
//         // Clean experience text to extract number only
//         String expText = experienceController.text.trim();
//         RegExp numberExp = RegExp(r'\d+');
//         int? years = int.tryParse(
//           numberExp.firstMatch(expText)?.group(0) ?? '',
//         );
//         body['experience_years'] = years;

//         body['gov_id'] = govIdController.text.trim();
//         body['experience_level'] = experienceLevel;
//       }

//       if (profileImageFile != null) {
//         body['profile_image'] = base64Encode(
//           profileImageFile!.readAsBytesSync(),
//         );
//       } else if (profileBase64 != null) {
//         body['profile_image'] = profileBase64;
//       }

//       if (coverImageFile != null) {
//         body['cover_image'] = base64Encode(coverImageFile!.readAsBytesSync());
//       } else if (coverBase64 != null) {
//         body['cover_image'] = coverBase64;
//       }

//       final url = Uri.parse(
//         '${Backend.baseUrl}/auth/update-profile/${user['id']}',
//       );
//       final response = await http.put(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(body),
//       );

//       final data = jsonDecode(response.body);
//       if (response.statusCode == 200) {
//         setState(() {
//           user = data['user'];
//           isEditing = false;
//           showOnServices = user['show_on_services'] ?? false;
//         });

//         if (widget.onProfileUpdated != null) widget.onProfileUpdated!();
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             backgroundColor: Color(0xFF262626),
//             content: Text(
//               'Profile updated successfully ✅',
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(data['message'] ?? 'Update failed ❌')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error: $e')));
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   // ✅ Service Add (provider-only, self-only)
//   Future<void> addService() async {
//     if (widget.readOnly) return;

//     final title = serviceTitleController.text.trim();
//     final desc = serviceDescController.text.trim();
//     final priceText = servicePriceController.text.trim();

//     if (selectedCategory == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select a category ❌')),
//       );
//       return;
//     }

//     if (title.isEmpty || desc.isEmpty || priceText.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please fill all service fields ❌')),
//       );
//       return;
//     }

//     final price = double.tryParse(priceText);
//     if (price == null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Price must be a number ❌')));
//       return;
//     }

//     setState(() => isLoading = true);

//     try {
//       final url = Uri.parse('${Backend.baseUrl}/services');
//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "provider_id": user['id'],
//           "title": title,
//           "description": desc,
//           "price": price,
//           "availability_status": true,
//           "category_id": selectedCategory?['id'],
//           "category": selectedCategory?['name'],
//         }),
//       );

//       if (response.statusCode == 201) {
//         // ✅ Service successfully added on backend
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text(
//               'Service added successfully ✅. You can check it in your selected category.',
//             ),
//           ),
//         );

//         // 🔹 Clear inputs
//         serviceTitleController.clear();
//         serviceDescController.clear();
//         servicePriceController.clear();
//         selectedCategory = null;

//         if (widget.onProfileUpdated != null) widget.onProfileUpdated!();
//       } else {
//         final error =
//             jsonDecode(response.body)['message'] ?? 'Failed to add service ❌';
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text(error)));
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error: $e')));
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   // ✅ Delete Profile (self-only)
//   Future<void> deleteProfile() async {
//     if (widget.readOnly) return;

//     bool confirm =
//         await showDialog(
//           context: context,
//           builder: (ctx) => AlertDialog(
//             backgroundColor: const Color(0xFFD9E1F0), // Light Blue background
//             title: const Text(
//               'Delete Profile',
//               style: TextStyle(color: Colors.black),
//             ),
//             content: const Text(
//               'Are you sure you want to delete your profile?',
//               style: TextStyle(color: Colors.black87),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(ctx, false),
//                 child: const Text(
//                   'Cancel',
//                   style: TextStyle(color: Colors.grey),
//                 ),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.pop(ctx, true),
//                 child: const Text(
//                   'Delete',
//                   style: TextStyle(color: Colors.red),
//                 ),
//               ),
//             ],
//           ),
//         ) ??
//         false;

//     if (!confirm) return;

//     setState(() => isLoading = true);
//     try {
//       final url = Uri.parse(
//         '${Backend.baseUrl}/auth/delete-profile/${user['id']}',
//       );
//       final response = await http.delete(url);

//       if (response.statusCode == 200) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Profile deleted successfully')),
//         );
//         Navigator.of(context).pop();
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to delete profile ❌')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error: $e')));
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isExternalView = widget.readOnly;

//     return Scaffold(
//       backgroundColor: kBackgroundColor, // White background
//       /////
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator(color: kTextPrimary))
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // --- Cover + Profile layout ---
//                     // --- Cover + Profile layout ---
//                     Stack(
//                       clipBehavior: Clip.none,
//                       children: [
//                         // 1️⃣ --- Cover Photo ---
//                         GestureDetector(
//                           onTap: isEditing && !isExternalView
//                               ? () => pickImage(false)
//                               : null,
//                           child: Container(
//                             height: 250,
//                             width: double.infinity,
//                             decoration: const BoxDecoration(
//                               color: Color(0xFFD9E1F0),
//                             ),
//                             child: (() {
//                               final imageProvider = _getImage(isProfile: false);
//                               if (imageProvider != null) {
//                                 return Image(
//                                   image: imageProvider,
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (context, error, stackTrace) =>
//                                       _coverPlaceholder(),
//                                 );
//                               } else {
//                                 return _coverPlaceholder();
//                               }
//                             })(),
//                           ),
//                         ),

//                         // 2️⃣ --- Profile Picture (Center Overlap) ---
//                       Positioned(
//   bottom: -60,
//   left: 0,
//   right: 0,
//   child: Center(
//     child: Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         GestureDetector(
//           onTap: () async {
//             if (isExternalView) return;
//             if (!isEditing) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text(
//                     "Enable edit mode to change profile picture",
//                   ),
//                 ),
//               );
//               return;
//             }
//             await pickImage(true);
//           },
//           child: Opacity(
//             opacity: isPickingImage ? 0.6 : 1.0,
//             child: SizedBox(
//               width: 140,
//               height: 140,
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   // Thin ring border
//                   Container(
//                     width: 120,
//                     height: 120,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: kPrimaryColor,
//                         width: 2, // thin border
//                       ),
//                     ),
//                   ),
//                   // Profile image
//                   ClipOval(
//                     child: SizedBox(
//                       width: 116,
//                       height: 116,
//                       child: _getImage(isProfile: true) != null
//                           ? Image(
//                               image: _getImage(isProfile: true)!,
//                               fit: BoxFit.cover,
//                             )
//                           : const Icon(
//                               Icons.person,
//                               size: 60,
//                               color: Color(0xFF5C74B1),
//                             ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         if (isPickingImage)
//           const Padding(
//             padding: EdgeInsets.only(top: 8.0),
//             child: Text(
//               "Opening gallery...",
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey,
//                 fontStyle: FontStyle.italic,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//       ],
//     ),
//   ),
// ),

//                         // 3️⃣ --- Main Edit/Close Icon (Top-right corner) ---
//                         if (!isExternalView)
//                           Positioned(
//                             top: 40,
//                             right: 16,
//                             child: GestureDetector(
//                               onTap: () =>
//                                   setState(() => isEditing = !isEditing),
//                               child: Container(
//                                 padding: const EdgeInsets.all(8),
//                                 decoration: BoxDecoration(
//                                   color: isEditing ? redAccent : kPrimaryColor,
//                                   shape: BoxShape.circle,
//                                   boxShadow: const [
//                                     BoxShadow(
//                                       color: Colors.black26,
//                                       blurRadius: 4,
//                                       offset: Offset(2, 2),
//                                     ),
//                                   ],
//                                 ),
//                                 child: Icon(
//                                   isEditing ? Icons.close : Icons.edit,
//                                   color: Colors.white,
//                                   size: 20,
//                                 ),
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                     const SizedBox(height: 100),

//                     //const SizedBox(height: 60),

//                     // Name & Username
//                     isEditing && !isExternalView
//                         ? Column(
//                             children: [
//                               _buildCustomTextField(
//                                 nameController,
//                                 'Full Name',
//                               ),
//                               const SizedBox(height: 10),
//                               _buildCustomTextField(
//                                 usernameController,
//                                 'Username / Display Name',
//                               ),
//                               const SizedBox(height: 10),
//                               _buildCustomTextField(
//                                 bioController,
//                                 'Bio',
//                                 maxLines: 2,
//                               ),
//                             ],
//                           )
//                         : Column(
//                             crossAxisAlignment: CrossAxisAlignment
//                                 .center, // Centered like LinkedIn
//                             children: [
//                               // ✅ Self profile view (non-external)
//                               if (!isExternalView) ...[
//                                 Text(
//                                   user['name'] ?? 'Your Name',
//                                   style: const TextStyle(
//                                     fontSize: 24,
//                                     fontWeight: FontWeight.bold,
//                                     color:
//                                         kTextPrimary, // Black text for premium look
//                                   ),
//                                 ),
//                                 if (user['username'] != null)
//                                   Padding(
//                                     padding: const EdgeInsets.only(top: 4),
//                                     child: Text(
//                                       '@${user['username']}',
//                                       style: const TextStyle(
//                                         fontSize: 16,
//                                         color:
//                                             kTextSecondary, // subtle grey for username
//                                       ),
//                                     ),
//                                   ),
//                                 if (user['bio'] != null &&
//                                     (user['bio'] as String).isNotEmpty)
//                                   Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                       vertical: 8.0,
//                                       horizontal: 16.0,
//                                     ),
//                                     child: Text(
//                                       user['bio'] ?? '',
//                                       textAlign: TextAlign.center,
//                                       style: const TextStyle(
//                                         fontSize: 15,
//                                         fontStyle: FontStyle
//                                             .italic, // italic for short bio
//                                         color: kTextSecondary, // softer black
//                                       ),
//                                     ),
//                                   ),
//                               ],

//                               // ✅ External profile view
//                               if (isExternalView)
//                                 ExternalProfileWidget(
//                                   userData: user,
//                                   currentUserId: widget.currentUserId,
//                                 ),
//                             ],
//                           ),

//                     const SizedBox(height: 16),

//                     // 📌 Contact Info Section
//                     isEditing && !isExternalView
//                         ? Column(
//                             children: [
//                               _buildCustomTextField(phoneController, 'Phone'),
//                               const SizedBox(height: 10),
//                               _buildCustomTextField(
//                                 addressController,
//                                 'Address',
//                               ),
//                             ],
//                           )
//                         : Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Divider(
//                                 color: kDividerColor, // subtle divider
//                                 thickness: 0.6,
//                                 height: 30,
//                               ),
//                               const Text(
//                                 "Contact Info",
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: heaidng,
//                                 ),
//                               ),
//                               const SizedBox(height: 12),

//                               // ✅ Phone
//                               Row(
//                                 children: [
//                                   const Icon(
//                                     Icons.phone,
//                                     size: 18,
//                                     color: kTextPrimary,
//                                   ),
//                                   const SizedBox(width: 8),
//                                   Text(
//                                     user['phone'] ?? '-',
//                                     style: const TextStyle(
//                                       fontSize: 16,
//                                       color: kTextSecondary,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 8),

//                               // ✅ Address
//                               Row(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const Icon(
//                                     Icons.location_on,
//                                     size: 18,
//                                     color: kTextPrimary,
//                                   ),
//                                   const SizedBox(width: 8),
//                                   Expanded(
//                                     child: Text(
//                                       user['address'] ?? '-',
//                                       style: const TextStyle(
//                                         fontSize: 16,
//                                         color: kTextSecondary, // white text
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),

//                     // Skills
//                     const SizedBox(height: 16),

//                     // Provider Section
//                     if (user['role'] == 'provider')
//                       Card(
//                         elevation: 2,
//                         color: kCardColor,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text(
//                                 "Details",
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: kTextPrimary,
//                                 ),
//                               ),
//                               const Divider(
//                                 color: kDividerColor,
//                                 thickness: 0.6,
//                                 height: 20,
//                               ),

//                               // ✅ Provider fields
//                               ..._buildProviderFields(
//                                 isEditing,
//                                 isExternalView,
//                               ),

//                               const SizedBox(height: 10),

//                               // ✅ Checkbox (only in edit mode)
//                               if (isEditing && !isExternalView)
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     CheckboxListTile(
//                                       title: const Text(
//                                         'Show your profile on services page?',
//                                         style: TextStyle(
//                                           fontSize: 15,
//                                           color: kTextPrimary,
//                                         ),
//                                       ),
//                                       value: showOnServices,
//                                       onChanged: (val) => setState(
//                                         () => showOnServices = val ?? false,
//                                       ),
//                                       activeColor: kPrimaryColor,
//                                       checkColor: Colors.white,
//                                       contentPadding: EdgeInsets.zero,
//                                       controlAffinity:
//                                           ListTileControlAffinity.leading,
//                                     ),
//                                     const Padding(
//                                       padding: EdgeInsets.only(left: 12.0),
//                                       child: Text(
//                                         "Enabling this makes your profile visible when users browse services.",
//                                         style: TextStyle(
//                                           fontSize: 13,
//                                           color: kTextSecondary,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                             ],
//                           ),
//                         ),
//                       ),

//                     const SizedBox(height: 20),

//                     // ✅ Save Button (only when editing)
//                     if (isEditing && !isExternalView)
//                       ElevatedButton(
//                         onPressed: saveProfile,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: kPrimaryColor, // theme primary
//                           padding: const EdgeInsets.symmetric(
//                             vertical: 16,
//                           ), // slightly taller
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           elevation: 4, // slightly stronger for premium feel
//                           shadowColor: Colors.white.withOpacity(
//                             0.3,
//                           ), // subtle shadow
//                         ),
//                         child: Center(
//                           child: Text(
//                             'Save Changes',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: buttonText, // theme button text
//                             ),
//                           ),
//                         ),
//                       ),

//                     if (!isExternalView) ...[
//                       const SizedBox(height: 10),

//                       // ❌ Delete Button (Outlined style)
//                       OutlinedButton(
//                         onPressed: deleteProfile,
//                         style: OutlinedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           side: const BorderSide(color: redAccent, width: 1.5),
//                           backgroundColor: kBackgroundColor, // dark surface
//                         ),
//                         child: Center(
//                           child: Text(
//                             'Delete Profile',
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: redAccent, // red text
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }

//   // Custom Text Field with theme colors
//   Widget _buildCustomTextField(
//     TextEditingController controller,
//     String label, {
//     int maxLines = 1,
//     bool isOptional = false,
//   }) {
//     return TextFormField(
//       controller: controller,
//       maxLines: maxLines,
//       style: const TextStyle(
//         color: kTextPrimary, // white text
//         fontSize: 16,
//       ),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(
//           color: kTextSecondary, // gray label
//           fontWeight: FontWeight.w500,
//         ),
//         filled: true,
//         fillColor: kCardColor, // dark background
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 14,
//           vertical: 12,
//         ),

//         // Borders
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(
//             color: kPrimaryColor, // primary color
//             width: 1.5,
//           ),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(
//             color: kDividerColor, // divider color
//             width: 1.2,
//           ),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: redAccent, width: 1.5),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: redAccent, width: 1.5),
//         ),
//       ),
//       validator: isOptional
//           ? null
//           : (val) => val == null || val.isEmpty ? 'Please enter $label' : null,
//     );
//   }

//   /////////////////////////////////////////////////////////////

//   ///

//   // ✅ Provider Fields Builder
//   List<Widget> _buildProviderFields(bool isEditing, bool isExternalView) {
//     return [
//       const SizedBox(height: 20),
//       const Text(
//         'Other Information',
//         style: TextStyle(
//           fontSize: 18,
//           color: heaidng,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//       const SizedBox(height: 10),

//       // --- Edit Mode ---
//       if (isEditing && !isExternalView)
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildCustomTextField(experienceController, 'Experience (years)'),
//             const SizedBox(height: 10),

//             // Experience Level
//             DropdownButtonFormField<String>(
//               value: experienceLevel,
//               decoration: InputDecoration(
//                 labelText: 'Experience Level',
//                 labelStyle: TextStyle(color: kTextPrimary),
//                 filled: true,
//                 fillColor: kBackgroundColor,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               items: ['Beginner', 'Intermediate', 'Expert']
//                   .map(
//                     (level) => DropdownMenuItem(
//                       value: level,
//                       child: Text(
//                         level,
//                         style: const TextStyle(
//                           color: kTextPrimary, // ✅ Text color changed
//                         ),
//                       ),
//                     ),
//                   )
//                   .toList(),
//               onChanged: (val) => setState(() => experienceLevel = val),
//             ),
//             const SizedBox(height: 10),

//             _buildCustomTextField(govIdController, 'Gov ID'),
//             const SizedBox(height: 10),
//             _buildCustomTextField(
//               portfolioController,
//               'Portfolio Links (one per line)',
//               maxLines: 4,
//               isOptional: true,
//             ),
//             const SizedBox(height: 10),
//             _buildCustomTextField(
//               hourlyRateController,
//               'Hourly Rate',
//               isOptional: true,
//             ),
//             const SizedBox(height: 10),
//             _buildCustomTextField(
//               languagesController,
//               'Languages (comma separated)',
//               isOptional: true,
//             ),
//             const SizedBox(height: 10),
//             _buildCustomTextField(
//               educationController,
//               'Education (comma separated)',
//             ),
//             const SizedBox(height: 10),
//             _buildCustomTextField(
//               socialLinksController,
//               'Social Links (one per line)',
//               maxLines: 4,
//               isOptional: true,
//             ),

//             ///////////////////////////// edit mode form......
//             const SizedBox(height: 20),
//             Form(
//               key: _servicesFormKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 20),
//                   const Text(
//                     'Services',
//                     style: TextStyle(
//                       color: heaidng, // white text on dark background

//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 10),

//                   isLoadingCategories
//                       ? const CircularProgressIndicator()
//                       : DropdownButtonFormField<Map<String, dynamic>>(
//                           value: selectedCategory,
//                           decoration: InputDecoration(
//                             labelText: 'Service Category',
//                             filled: true,
//                             fillColor: kCardColor,
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           dropdownColor:
//                               kCardColor, // Dropdown ka background black
//                           style: const TextStyle(color: kTextPrimary),
//                           items: categories
//                               .map(
//                                 (cat) => DropdownMenuItem<Map<String, dynamic>>(
//                                   value: cat,
//                                   child: Text(
//                                     cat['name'],
//                                     style: const TextStyle(color: kTextPrimary),
//                                   ),
//                                 ),
//                               )
//                               .toList(),
//                           onChanged: (val) =>
//                               setState(() => selectedCategory = val),
//                           validator: (val) =>
//                               val == null ? 'Please select a category' : null,
//                         ),
//                   const SizedBox(height: 10),

//                   _buildCustomTextField(
//                     serviceTitleController,
//                     'Service Title',
//                   ),
//                   const SizedBox(height: 10),
//                   TextFormField(
//                     controller: serviceDescController,
//                     maxLines: 5,
//                     minLines: 3,
//                     keyboardType: TextInputType.multiline,
//                     textInputAction: TextInputAction.newline,
//                     style: TextStyle(color: kTextPrimary, fontSize: 16),
//                     decoration: InputDecoration(
//                       labelText: 'Service Description',
//                       labelStyle: TextStyle(color: kTextSecondary),
//                       filled: true,
//                       fillColor: kCardColor,
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 14,
//                         vertical: 12,
//                       ),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                         borderSide: BorderSide(color: kDividerColor),
//                       ),
//                     ),
//                     validator: (val) => val == null || val.isEmpty
//                         ? 'Please enter Service Description'
//                         : null,
//                   ),
//                   const SizedBox(height: 10),
//                   _buildCustomTextField(
//                     servicePriceController,
//                     'Service Price',
//                   ),
//                   const SizedBox(height: 10),

//                   ElevatedButton(
//                     onPressed: () {
//                       if (_servicesFormKey.currentState!.validate()) {
//                         addService();
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: kPrimaryColor,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                     ),
//                     child: const Center(
//                       child: Text(
//                         'Add Service',
//                         style: TextStyle(
//                           color: buttonText,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 20),
//           ],
//         )
//       else
//         // --- Non-Edit Mode ---
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Experience: ${user['experience_years'] != null ? user['experience_years'].toString() : '-'} years',
//               style: TextStyle(color: kTextSecondary), // #A1A1A1
//             ),

//             Text(
//               'Level: ${user['experience_level'] ?? '-'}',
//               style: TextStyle(color: kTextSecondary), // #A1A1A1
//             ),
//             Text(
//               'Gov ID: ${user['gov_id'] ?? '-'}',
//               style: TextStyle(color: kTextSecondary), // #A1A1A1
//             ),
//             Text(
//               'Hourly Rate: PKR ${user['hourly_rate'] ?? '-'}',
//               style: TextStyle(color: kTextSecondary), // #A1A1A1
//             ),

//             const SizedBox(height: 10),
//             Wrap(
//               spacing: 6,
//               children: user['languages'] != null
//                   ? (user['languages'] as List)
//                         .map<Widget>(
//                           (l) => Chip(
//                             label: Text(l),
//                             backgroundColor: kSecondaryColor,
//                             labelStyle: const TextStyle(color: buttonText),
//                           ),
//                         )
//                         .toList()
//                   : const [Text('-', style: TextStyle(color: kTextSecondary))],
//             ),

//             const SizedBox(height: 12),
//             const Text(
//               'Portfolio Links:',
//               style: TextStyle(fontWeight: FontWeight.w600, color: heaidng),
//             ),
//             if (user['portfolio_links'] != null &&
//                 (user['portfolio_links'] as List).isNotEmpty)
//               ...(user['portfolio_links'] as List).map(
//                 (link) => GestureDetector(
//                   onTap: () => _launchUrl(link),
//                   child: Text(
//                     link,
//                     style: const TextStyle(
//                       color: kPrimaryColor,
//                       decoration: TextDecoration.underline,
//                     ),
//                   ),
//                 ),
//               ),

//             const SizedBox(height: 12),
//             const Text(
//               'Social Links:',
//               style: TextStyle(fontWeight: FontWeight.w600, color: heaidng),
//             ),
//             if (user['social_links'] != null &&
//                 (user['social_links'] as List).isNotEmpty)
//               ...(user['social_links'] as List).map(
//                 (link) => GestureDetector(
//                   onTap: () => _launchUrl(link),
//                   child: Text(
//                     link,
//                     style: const TextStyle(
//                       color: kPrimaryColor,
//                       decoration: TextDecoration.underline,
//                     ),
//                   ),
//                 ),
//               ),

//             const SizedBox(height: 12),
//             const Text(
//               '',
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black,
//               ),
//             ),

//             if (services.isNotEmpty)
//               ...services
//                   .map(
//                     (s) => Container(
//                       width: double.infinity, // parent width ke hisaab se
//                       margin: const EdgeInsets.symmetric(
//                         vertical: 8,
//                         horizontal: 12,
//                       ),
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: kDividerColor, // dark surface background
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: kTextSecondary, width: 1),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.white.withOpacity(
//                               0.1,
//                             ), // subtle shadow
//                             blurRadius: 6,
//                             offset: const Offset(0, 3),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Heading with subtle highlighted background
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               vertical: 6,
//                               horizontal: 8,
//                             ),
//                             decoration: BoxDecoration(
//                               color: kPrimaryColor.withOpacity(
//                                 0.15,
//                               ), // soft highlight
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                             child: Text(
//                               s['title'] ?? '-',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: kTextPrimary, // premium primary color
//                               ),
//                             ),
//                           ),
//                           //  const SizedBox(height: 3),
//                           // Price
//                           Text(
//                             'PKR ${s['price'] ?? "-"}',
//                             style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w500,
//                               color: kprice, // golden accent for price
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           // Description scrollable
//                           ConstrainedBox(
//                             constraints: const BoxConstraints(maxHeight: 200),
//                             child: SingleChildScrollView(
//                               child: Text(
//                                 s['description'] ?? '-',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color:
//                                       kTextPrimary, // white text for description
//                                   height: 1.4,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   )
//                   .toList(),
//             if (services.isEmpty)
//               const Text("", style: TextStyle(color: Colors.grey)),
//           ],
//         ),
//     ];
//   }
// }

// // --- Cover Placeholder Widget ---
// Widget _coverPlaceholder() {
//   return Container(
//     decoration: BoxDecoration(
//       color: const Color(0xFFD9E1F0),
//       borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
//     ),
//     child: const Center(
//       child: Text(
//         'Upload Cover Photo',
//         style: TextStyle(
//           color: Color(0xFF5C74B1),
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     ),
//   );
// }

























//////////////////////////////////////
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../helpers/backend.dart';
import '../models/ExternalProfileWidget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helpers/coolors.dart';

class MyProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final VoidCallback? onProfileUpdated;
  final int currentUserId;
  final bool readOnly;

  const MyProfileScreen({
    required this.userData,
    required this.currentUserId,
    this.onProfileUpdated,
    this.readOnly = false,
    super.key,
  });

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  late Map<String, dynamic> user;
  bool isEditing = false;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _servicesFormKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController nameController;
  late TextEditingController usernameController;
  late TextEditingController bioController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  //late TextEditingController skillsController;
  late TextEditingController experienceController;
  late TextEditingController govIdController;
  late TextEditingController portfolioController;
  late TextEditingController hourlyRateController;
  late TextEditingController languagesController;
  late TextEditingController educationController;
  late TextEditingController socialLinksController;

  String? experienceLevel;
  File? profileImageFile;
  File? coverImageFile;
  String? profileBase64;
  String? coverBase64;
  bool showOnServices = false;
bool isExpanded = false;
  //int? selectedCategory;
  // --- Services ---
  List<Map<String, dynamic>> services = [];
  TextEditingController serviceTitleController = TextEditingController();
  TextEditingController serviceDescController = TextEditingController();
  TextEditingController servicePriceController = TextEditingController();
  //--- Categories--

  Map<String, dynamic>? selectedCategory;
// inside your State class
Map<int, bool> isExpandedMap = {}; // key = service index

  List<Map<String, dynamic>> categories = [];
  bool isLoadingCategories = true;
  //---------------------
int wordCount = 0;

  void _updateWordCount(String text) {
    final words = text.trim().isEmpty ? [] : text.trim().split(RegExp(r'\s+'));
    setState(() {
      wordCount = words.length;
    });
  }
  Future<void> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('${Backend.baseUrl}/categories'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print("Categories API response: $data"); // 🔍 Debug print

        setState(() {
          categories = List<Map<String, dynamic>>.from(
            data is List ? data : data['categories'], // ✅ Safe parsing
          );
          isLoadingCategories = false;
        });

        print("Parsed categories: $categories"); // 🔍 Debug print
      } else {
        print('Failed to load categories');
        setState(() => isLoadingCategories = false);
      }
    } catch (e) {
      print('Error fetching categories: $e');
      setState(() => isLoadingCategories = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _initUserData();
    fetchCategories();
  }

  void _initUserData() {
    user = Map.from(widget.userData);
    // ✅ FIX: preselect category if editing
    selectedCategory = user['category_id'] != null
        ? categories.cast<Map<String, dynamic>?>().firstWhere(
            (cat) => cat != null && cat['id'] == user['category_id'],
            orElse: () => null,
          )
        : null;

    nameController = TextEditingController(text: user['name']);
    usernameController = TextEditingController(text: user['username']);
    bioController = TextEditingController(text: user['bio']);
    phoneController = TextEditingController(text: user['phone']);
    addressController = TextEditingController(text: user['address']);
    // skillsController = TextEditingController(
    //   text: user['skills'] != null ? (user['skills'] as List).join(', ') : '',
    // );
    experienceController = TextEditingController(
      text: user['experience_years']?.toString() ?? '',
    );
    govIdController = TextEditingController(text: user['gov_id'] ?? '');
    portfolioController = TextEditingController(
      text: user['portfolio_links'] != null
          ? (user['portfolio_links'] as List).join('\n')
          : '',
    );
    hourlyRateController = TextEditingController(
      text: user['hourly_rate']?.toString() ?? '',
    );
    languagesController = TextEditingController(
      text: user['languages'] != null
          ? (user['languages'] as List).join(', ')
          : '',
    );
    educationController = TextEditingController(
      text: user['education'] != null
          ? (user['education'] as List).join(', ')
          : '',
    );
    socialLinksController = TextEditingController(
      text: user['social_links'] != null
          ? (user['social_links'] as List).join('\n')
          : '',
    );
    experienceLevel = user['experience_level'];
    showOnServices = user['show_on_services'] ?? false;
    /////////////////////////////////////////

    if (user['services'] != null) {
      services = List<Map<String, dynamic>>.from(user['services']);
    } else {
      services = []; // ✅ Ensure empty list if null
    }
  }


String? serviceDescValidator(String? val) {
  if (val == null || val.trim().isEmpty) {
    return 'Please enter Service Description';
  }

  final words = val.trim().split(RegExp(r'\s+')); // split by spaces
  if (words.length < 300) {
    return 'Description must be at least 300 words';
  }
  if (words.length > 400) {
    return 'Description cannot exceed 400 words';
  }

  return null; // valid
}

  //--------url laucher fucntion------------

  Future<void> _launchUrl(String url) async {
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open link ❌')));
    }
  }

  bool isPickingImage = false;

  // --- Image Picker ---
  Future<void> pickImage(bool isProfile) async {
    if (widget.readOnly) return;
    if (isPickingImage) return;

    setState(() => isPickingImage = true); // ✅ mark as picking & update UI

    await Future.delayed(const Duration(milliseconds: 100));
    // gives time for UI to show "Opening gallery..." or dim effect

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        if (kIsWeb) {
          final bytes = await picked.readAsBytes();
          setState(() {
            if (isProfile)
              profileBase64 = base64Encode(bytes);
            else
              coverBase64 = base64Encode(bytes);
          });
        } else {
          setState(() {
            if (isProfile)
              profileImageFile = File(picked.path);
            else
              coverImageFile = File(picked.path);
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    } finally {
      setState(() => isPickingImage = false); // ✅ reset flag & update UI
    }
  }

  ImageProvider<Object>? _getImage({required bool isProfile}) {
    if (isProfile) {
      if (kIsWeb && profileBase64 != null)
        return MemoryImage(base64Decode(profileBase64!));
      if (!kIsWeb && profileImageFile != null)
        return FileImage(profileImageFile!);
      if (user['profile_image'] != null && user['profile_image'] != '') {
        final url = user['profile_image'].startsWith('http')
            ? user['profile_image']
            : '${Backend.baseUrl}/${user['profile_image']}';
        return NetworkImage(url);
      }
    } else {
      if (kIsWeb && coverBase64 != null)
        return MemoryImage(base64Decode(coverBase64!));
      if (!kIsWeb && coverImageFile != null) return FileImage(coverImageFile!);
      if (user['cover_image'] != null && user['cover_image'] != '') {
        final url = user['cover_image'].startsWith('http')
            ? user['cover_image']
            : '${Backend.baseUrl}/${user['cover_image']}';
        return NetworkImage(url);
      }
    }
    return null;
  }
  // ✅ Profile Save Function (self-only)
  Future<void> saveProfile() async {
    if (widget.readOnly) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      Map<String, dynamic> body = {
        'name': nameController.text.trim(),
        'username': usernameController.text.trim(),
        'bio': bioController.text.trim(),
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),
        //  'skills': services.map((s) => s['title']).toList(),
        //  'show_on_services': showOnServices,
        'portfolio_links': portfolioController.text
            .split('\n')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),

        'hourly_rate': hourlyRateController.text.isNotEmpty
            ? double.tryParse(hourlyRateController.text)
            : null,
        'languages': languagesController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        'education': educationController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        'social_links': socialLinksController.text
            .split('\n') // ✅ split by new line
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
      };

      if (user['role'] == 'provider') {
        // Clean experience text to extract number only
        String expText = experienceController.text.trim();
        RegExp numberExp = RegExp(r'\d+');
        int? years = int.tryParse(
          numberExp.firstMatch(expText)?.group(0) ?? '',
        );
        body['experience_years'] = years;

        body['gov_id'] = govIdController.text.trim();
        body['experience_level'] = experienceLevel;
      }

      if (profileImageFile != null) {
        body['profile_image'] = base64Encode(
          profileImageFile!.readAsBytesSync(),
        );
      } else if (profileBase64 != null) {
        body['profile_image'] = profileBase64;
      }

      if (coverImageFile != null) {
        body['cover_image'] = base64Encode(coverImageFile!.readAsBytesSync());
      } else if (coverBase64 != null) {
        body['cover_image'] = coverBase64;
      }

      final url = Uri.parse(
        '${Backend.baseUrl}/auth/update-profile/${user['id']}',
      );
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          user = data['user'];
          isEditing = false;
          showOnServices = user['show_on_services'] ?? false;
        });

        if (widget.onProfileUpdated != null) widget.onProfileUpdated!();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Color(0xFF262626),
            content: Text(
              'Profile updated successfully ✅',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Update failed ❌')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ✅ Service Add (provider-only, self-only)
  Future<void> addService() async {
    if (widget.readOnly) return;

    final title = serviceTitleController.text.trim();
    final desc = serviceDescController.text.trim();
    final priceText = servicePriceController.text.trim();

    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category ❌')),
      );
      return;
    }

    if (title.isEmpty || desc.isEmpty || priceText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all service fields ❌')),
      );
      return;
    }

    final price = double.tryParse(priceText);
    if (price == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Price must be a number ❌')));
      return;
    }

    setState(() => isLoading = true);

    try {
      final url = Uri.parse('${Backend.baseUrl}/services');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "provider_id": user['id'],
          "title": title,
          "description": desc,
          "price": price,
          "availability_status": true,
          "category_id": selectedCategory?['id'],
          "category": selectedCategory?['name'],
        }),
      );

      if (response.statusCode == 201) {
        // ✅ Service successfully added on backend
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Service added successfully ✅. You can check it in your selected category.',
            ),
          ),
        );

        // 🔹 Clear inputs
        serviceTitleController.clear();
        serviceDescController.clear();
        servicePriceController.clear();
        selectedCategory = null;

        if (widget.onProfileUpdated != null) widget.onProfileUpdated!();
      } else {
        final error =
            jsonDecode(response.body)['message'] ?? 'Failed to add service ❌';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ✅ Delete Profile (self-only)
  Future<void> deleteProfile() async {
    if (widget.readOnly) return;

    bool confirm =
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFFD9E1F0), // Light Blue background
            title: const Text(
              'Delete Profile',
              style: TextStyle(color: Colors.black),
            ),
            content: const Text(
              'Are you sure you want to delete your profile?',
              style: TextStyle(color: Colors.black87),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    setState(() => isLoading = true);
    try {
      final url = Uri.parse(
        '${Backend.baseUrl}/auth/delete-profile/${user['id']}',
      );
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile deleted successfully')),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete profile ❌')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExternalView = widget.readOnly;

    return Scaffold(
      backgroundColor: kBackgroundColor, // White background
      /////
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: kTextPrimary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Cover + Profile layout ---
                    // --- Cover + Profile layout ---
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // 1️⃣ --- Cover Photo ---
                        GestureDetector(
                          onTap: isEditing && !isExternalView
                              ? () => pickImage(false)
                              : null,
                          child: Container(
                            height: 250,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Color(0xFFD9E1F0),
                            ),
                            child: (() {
                              final imageProvider = _getImage(isProfile: false);
                              if (imageProvider != null) {
                                return Image(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _coverPlaceholder(),
                                );
                              } else {
                                return _coverPlaceholder();
                              }
                            })(),
                          ),
                        ),

                        // 2️⃣ --- Profile Picture (Center Overlap) ---
                      Positioned(
  bottom: -60,
  left: 0,
  right: 0,
  child: Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () async {
            if (isExternalView) return;
            if (!isEditing) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Enable edit mode to change profile picture",
                  ),
                ),
              );
              return;
            }
            await pickImage(true);
          },
          child: Opacity(
            opacity: isPickingImage ? 0.6 : 1.0,
            child: SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Thin ring border
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: kPrimaryColor,
                        width: 2, // thin border
                      ),
                    ),
                  ),
                  // Profile image
                  ClipOval(
                    child: SizedBox(
                      width: 116,
                      height: 116,
                      child: _getImage(isProfile: true) != null
                          ? Image(
                              image: _getImage(isProfile: true)!,
                              fit: BoxFit.cover,
                            )
                          : const Icon(
                              Icons.person,
                              size: 60,
                              color: Color(0xFF5C74B1),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isPickingImage)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              "Opening gallery...",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    ),
  ),
),

                        // 3️⃣ --- Main Edit/Close Icon (Top-right corner) ---
                        if (!isExternalView)
                          Positioned(
                            top: 40,
                            right: 16,
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => isEditing = !isEditing),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isEditing ? redAccent : kPrimaryColor,
                                  shape: BoxShape.circle,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isEditing ? Icons.close : Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 100),

                    //const SizedBox(height: 60),

                    // Name & Username
                    isEditing && !isExternalView
                        ? Column(
                            children: [
                              _buildCustomTextField(
                                nameController,
                                'Full Name',
                              ),
                              const SizedBox(height: 10),
                              _buildCustomTextField(
                                usernameController,
                                'Username / Display Name',
                              ),
                              const SizedBox(height: 10),
                              _buildCustomTextField(
                                bioController,
                                'Bio',
                                maxLines: 2,
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment
                                .center, // Centered like LinkedIn
                            children: [
                              // ✅ Self profile view (non-external)
                              if (!isExternalView) ...[
                                Text(
                                  user['name'] ?? 'Your Name',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        kTextPrimary, // Black text for premium look
                                  ),
                                ),
                                if (user['username'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      '@${user['username']}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color:
                                            kTextSecondary, // subtle grey for username
                                      ),
                                    ),
                                  ),
                                if (user['bio'] != null &&
                                    (user['bio'] as String).isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                      horizontal: 16.0,
                                    ),
                                    child: Text(
                                      user['bio'] ?? '',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontStyle: FontStyle
                                            .italic, // italic for short bio
                                        color: kTextSecondary, // softer black
                                      ),
                                    ),
                                  ),
                              ],

                              // ✅ External profile view
                              if (isExternalView)
                                ExternalProfileWidget(
                                  userData: user,
                                  currentUserId: widget.currentUserId,
                                ),
                            ],
                          ),

                    const SizedBox(height: 16),

                    // 📌 Contact Info Section
                    isEditing && !isExternalView
                        ? Column(
                            children: [
                              _buildCustomTextField(phoneController, 'Phone'),
                              const SizedBox(height: 10),
                              _buildCustomTextField(
                                addressController,
                                'Address',
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(
                                color: kDividerColor, // subtle divider
                                thickness: 0.6,
                                height: 30,
                              ),
                              const Text(
                                "Contact Info",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: heaidng,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // ✅ Phone
                              Row(
                                children: [
                                  const Icon(
                                    Icons.phone,
                                    size: 18,
                                    color: kTextPrimary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    user['phone'] ?? '-',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: kTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // ✅ Address
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 18,
                                    color: kTextPrimary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      user['address'] ?? '-',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: kTextSecondary, // white text
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                    // Skills
                    const SizedBox(height: 16),

                    // Provider Section
                    if (user['role'] == 'provider')
                      Card(
                        elevation: 2,
                        color: kCardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Details",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: kTextPrimary,
                                ),
                              ),
                              const Divider(
                                color: kDividerColor,
                                thickness: 0.6,
                                height: 20,
                              ),

                              // ✅ Provider fields
                              ..._buildProviderFields(
                                isEditing,
                                isExternalView,
                              ),

                              const SizedBox(height: 10),

                              // ✅ Checkbox (only in edit mode)
                              if (isEditing && !isExternalView)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CheckboxListTile(
                                      title: const Text(
                                        'Show your profile on services page?',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: kTextPrimary,
                                        ),
                                      ),
                                      value: showOnServices,
                                      onChanged: (val) => setState(
                                        () => showOnServices = val ?? false,
                                      ),
                                      activeColor: kPrimaryColor,
                                      checkColor: Colors.white,
                                      contentPadding: EdgeInsets.zero,
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(left: 12.0),
                                      child: Text(
                                        "Enabling this makes your profile visible when users browse services.",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: kTextSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    // ✅ Save Button (only when editing)
                    if (isEditing && !isExternalView)
                      ElevatedButton(
                        onPressed: saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor, // theme primary
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ), // slightly taller
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4, // slightly stronger for premium feel
                          shadowColor: Colors.white.withOpacity(
                            0.3,
                          ), // subtle shadow
                        ),
                        child: Center(
                          child: Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: buttonText, // theme button text
                            ),
                          ),
                        ),
                      ),

                    if (!isExternalView) ...[
                      const SizedBox(height: 10),

                      // ❌ Delete Button (Outlined style)
                      OutlinedButton(
                        onPressed: deleteProfile,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: redAccent, width: 1.5),
                          backgroundColor: kBackgroundColor, // dark surface
                        ),
                        child: Center(
                          child: Text(
                            'Delete Profile',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: redAccent, // red text
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  // Custom Text Field with theme colors
  Widget _buildCustomTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    bool isOptional = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        color: kTextPrimary, // white text
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: kTextSecondary, // gray label
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: kCardColor, // dark background
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),

        // Borders
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: kPrimaryColor, // primary color
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: kDividerColor, // divider color
            width: 1.2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: redAccent, width: 1.5),
        ),
      ),
      validator: isOptional
          ? null
          : (val) => val == null || val.isEmpty ? 'Please enter $label' : null,
    );
  }

  /////////////////////////////////////////////////////////////

  ///

  // ✅ Provider Fields Builder
  List<Widget> _buildProviderFields(bool isEditing, bool isExternalView) {
    return [
      const SizedBox(height: 20),
      const Text(
        'Other Information',
        style: TextStyle(
          fontSize: 18,
          color: heaidng,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 10),

      // --- Edit Mode ---
      if (isEditing && !isExternalView)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCustomTextField(experienceController, 'Experience (years)'),
            const SizedBox(height: 10),

            // Experience Level
            DropdownButtonFormField<String>(
              value: experienceLevel,
              decoration: InputDecoration(
                labelText: 'Experience Level',
                labelStyle: TextStyle(color: kTextPrimary),
                filled: true,
                fillColor: kBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: ['Beginner', 'Intermediate', 'Expert']
                  .map(
                    (level) => DropdownMenuItem(
                      value: level,
                      child: Text(
                        level,
                        style: const TextStyle(
                          color: kTextPrimary, // ✅ Text color changed
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => experienceLevel = val),
            ),
            const SizedBox(height: 10),

            _buildCustomTextField(govIdController, 'Gov ID'),
            const SizedBox(height: 10),
            _buildCustomTextField(
              portfolioController,
              'Portfolio Links (one per line)',
              maxLines: 4,
              isOptional: true,
            ),
            const SizedBox(height: 10),
            _buildCustomTextField(
              hourlyRateController,
              'Hourly Rate',
              isOptional: true,
            ),
            const SizedBox(height: 10),
            _buildCustomTextField(
              languagesController,
              'Languages (comma separated)',
              isOptional: true,
            ),
            const SizedBox(height: 10),
            _buildCustomTextField(
              educationController,
              'Education (comma separated)',
            ),
            const SizedBox(height: 10),
            _buildCustomTextField(
              socialLinksController,
              'Social Links (one per line)',
              maxLines: 4,
              isOptional: true,
            ),

            ///////////////////////////// edit mode form......
            const SizedBox(height: 20),
            Form(
              key: _servicesFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Services',
                    style: TextStyle(
                      color: heaidng, // white text on dark background

                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),

                  isLoadingCategories
                      ? const CircularProgressIndicator()
                      : DropdownButtonFormField<Map<String, dynamic>>(
                          value: selectedCategory,
                          decoration: InputDecoration(
                            labelText: 'Service Category',
                            filled: true,
                            fillColor: kCardColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          dropdownColor:
                              kCardColor, // Dropdown ka background black
                          style: const TextStyle(color: kTextPrimary),
                          items: categories
                              .map(
                                (cat) => DropdownMenuItem<Map<String, dynamic>>(
                                  value: cat,
                                  child: Text(
                                    cat['name'],
                                    style: const TextStyle(color: kTextPrimary),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => selectedCategory = val),
                          validator: (val) =>
                              val == null ? 'Please select a category' : null,
                        ),
                  const SizedBox(height: 10),

                  _buildCustomTextField(
                    serviceTitleController,
                    'Service Title',
                  ),
                  const SizedBox(height: 10),
                 TextFormField(
          controller: serviceDescController,
          maxLines: 10,
          minLines: 5,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          style: TextStyle(color: kTextPrimary, fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Service Description',
            labelStyle: TextStyle(color: kTextSecondary),
            filled: true,
            fillColor: kCardColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: kDividerColor),
            ),
            hintText: 'Write about your service in detail (300-400 words)...',
          ),
          validator: serviceDescValidator,
          onChanged: _updateWordCount,
        ),
        const SizedBox(height: 6),
        Text(
          '$wordCount / 400 words',
          style: TextStyle(
            fontSize: 12,
            color: wordCount < 300 ? Colors.red : Colors.grey,
          ),
        ),














                  const SizedBox(height: 10),
                  _buildCustomTextField(
                    servicePriceController,
                    'Service Price',
                  ),
                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: () {
                      if (_servicesFormKey.currentState!.validate()) {
                        addService();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Center(
                      child: Text(
                        'Add Service',
                        style: TextStyle(
                          color: buttonText,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        )
      else
        // --- Non-Edit Mode ---
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Experience: ${user['experience_years'] != null ? user['experience_years'].toString() : '-'} years',
              style: TextStyle(color: kTextSecondary), // #A1A1A1
            ),

            Text(
              'Level: ${user['experience_level'] ?? '-'}',
              style: TextStyle(color: kTextSecondary), // #A1A1A1
            ),
            Text(
              'Gov ID: ${user['gov_id'] ?? '-'}',
              style: TextStyle(color: kTextSecondary), // #A1A1A1
            ),
            Text(
              'Hourly Rate: PKR ${user['hourly_rate'] ?? '-'}',
              style: TextStyle(color: kTextSecondary), // #A1A1A1
            ),

            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              children: user['languages'] != null
                  ? (user['languages'] as List)
                        .map<Widget>(
                          (l) => Chip(
                            label: Text(l),
                            backgroundColor: kSecondaryColor,
                            labelStyle: const TextStyle(color: buttonText),
                          ),
                        )
                        .toList()
                  : const [Text('-', style: TextStyle(color: kTextSecondary))],
            ),

            const SizedBox(height: 12),
            const Text(
              'Portfolio Links:',
              style: TextStyle(fontWeight: FontWeight.w600, color: heaidng),
            ),
            if (user['portfolio_links'] != null &&
                (user['portfolio_links'] as List).isNotEmpty)
              ...(user['portfolio_links'] as List).map(
                (link) => GestureDetector(
                  onTap: () => _launchUrl(link),
                  child: Text(
                    link,
                    style: const TextStyle(
                      color: kPrimaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 12),
            const Text(
              'Social Links:',
              style: TextStyle(fontWeight: FontWeight.w600, color: heaidng),
            ),
            if (user['social_links'] != null &&
                (user['social_links'] as List).isNotEmpty)
              ...(user['social_links'] as List).map(
                (link) => GestureDetector(
                  onTap: () => _launchUrl(link),
                  child: Text(
                    link,
                    style: const TextStyle(
                      color: kPrimaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 12),
            const Text(
              '',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            if (services.isNotEmpty)
             ...services.map((s) {
  int index = services.indexOf(s);
  bool isExpanded = isExpandedMap[index] ?? false;

  String fullText = s['description'] ?? "-";
  String shortText = fullText.length > 200
      ? fullText.substring(0, 200) + "..."
      : fullText;

  return Container(
    width: double.infinity, // parent ki full width
    margin: const EdgeInsets.symmetric(vertical: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: kBackgroundColor,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: Colors.black.withOpacity(0.2),
        width: 2,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          s['title'] ?? '-',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: kTextPrimary,
          ),
        ),

        SizedBox(height: 6),

        // Price
        Text(
          "PKR ${s['price'] ?? "-"}",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: kprice,
          ),
        ),

        SizedBox(height: 10),

        // Description
        Text(
          isExpanded ? fullText : shortText,
          style: TextStyle(
            fontSize: 14,
            color: kTextPrimary,
            height: 1.4,
          ),
        ),

        if (fullText.length > 200)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {
                setState(() {
                  isExpandedMap[index] = !isExpanded;
                });
              },
              child: Text(
                isExpanded ? "View Less" : "View More",
                style: TextStyle(
                  fontSize: 14,
                  color: kPrimaryColor,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}).toList(),

            if (services.isEmpty)
              const Text("", style: TextStyle(color: Colors.grey)),
          ],
        ),
    ];
  }
}

// --- Cover Placeholder Widget ---
Widget _coverPlaceholder() {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFFD9E1F0),
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
    ),
    child: const Center(
      child: Text(
        'Upload Cover Photo',
        style: TextStyle(
          color: Color(0xFF5C74B1),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

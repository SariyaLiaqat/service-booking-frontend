
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import '../helpers/backend.dart';
// import '../models/action_buttons.dart';
// import '../models/ExternalProfileWidget.dart';

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

//   // Controllers
//   late TextEditingController nameController;
//   late TextEditingController usernameController;
//   late TextEditingController bioController;
//   late TextEditingController phoneController;
//   late TextEditingController addressController;
//   late TextEditingController skillsController;
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

//   // --- Services ---
//   List<Map<String, dynamic>> services = [];
//   TextEditingController serviceTitleController = TextEditingController();
//   TextEditingController serviceDescController = TextEditingController();
//   TextEditingController servicePriceController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _initUserData();
//   }

//   void _initUserData() {
//     user = Map.from(widget.userData);

//     nameController = TextEditingController(text: user['name']);
//     usernameController = TextEditingController(text: user['username']);
//     bioController = TextEditingController(text: user['bio']);
//     phoneController = TextEditingController(text: user['phone']);
//     addressController = TextEditingController(text: user['address']);
//     skillsController = TextEditingController(
//         text: user['skills'] != null ? (user['skills'] as List).join(', ') : '');
//     experienceController =
//         TextEditingController(text: user['experience_years']?.toString() ?? '');
//     govIdController = TextEditingController(text: user['gov_id'] ?? '');
//     portfolioController = TextEditingController(
//         text: user['portfolio_links'] != null
//             ? (user['portfolio_links'] as List).join(', ')
//             : '');
//     hourlyRateController =
//         TextEditingController(text: user['hourly_rate']?.toString() ?? '');
//     languagesController = TextEditingController(
//         text: user['languages'] != null ? (user['languages'] as List).join(', ') : '');
//     educationController = TextEditingController(
//         text: user['education'] != null ? (user['education'] as List).join(', ') : '');
//     socialLinksController = TextEditingController(
//         text: user['social_links'] != null
//             ? (user['social_links'] as List).join(', ')
//             : '');
//     experienceLevel = user['experience_level'];
//     showOnServices = user['show_on_services'] ?? false;

//     if (user['services'] != null) {
//       services = List<Map<String, dynamic>>.from(user['services']);
//     }
//   }

//   // --- Image Picker ---
//   Future<void> pickImage(bool isProfile) async {
//     if (widget.readOnly) return;

//     final picker = ImagePicker();
//     final picked = await picker.pickImage(source: ImageSource.gallery);
//     if (picked != null) {
//       if (kIsWeb) {
//         final bytes = await picked.readAsBytes();
//         setState(() {
//           if (isProfile)
//             profileBase64 = base64Encode(bytes);
//           else
//             coverBase64 = base64Encode(bytes);
//         });
//       } else {
//         setState(() {
//           if (isProfile)
//             profileImageFile = File(picked.path);
//           else
//             coverImageFile = File(picked.path);
//         });
//       }
//     }
//   }

//   ImageProvider<Object>? _getImage({required bool isProfile}) {
//     if (isProfile) {
//       if (kIsWeb && profileBase64 != null) return MemoryImage(base64Decode(profileBase64!));
//       if (!kIsWeb && profileImageFile != null) return FileImage(profileImageFile!);
//       if (user['profile_image'] != null && user['profile_image'] != '') {
//         final url = user['profile_image'].startsWith('http')
//             ? user['profile_image']
//             : '${Backend.baseUrl}/${user['profile_image']}';
//         return NetworkImage(url);
//       }
//     } else {
//       if (kIsWeb && coverBase64 != null) return MemoryImage(base64Decode(coverBase64!));
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

//   // ✅ Profile Save Function (self-only)
//   Future<void> saveProfile() async {
//     if (widget.readOnly) return;
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => isLoading = true);

//     try {
//       Map<String, dynamic> body = {
//         'name': nameController.text.trim(),
//         'username': usernameController.text.trim(),
//         'bio': bioController.text.trim(),
//         'phone': phoneController.text.trim(),
//         'address': addressController.text.trim(),
//         'skills': skillsController.text
//             .split(',')
//             .map((s) => s.trim())
//             .where((s) => s.isNotEmpty)
//             .toList(),
//         'show_on_services': showOnServices,
//         'portfolio_links': portfolioController.text
//     .split('\n') // ✅ split by new line
//     .map((s) => s.trim())
//     .where((s) => s.isNotEmpty)
//     .toList(),

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
//     .split('\n') // ✅ split by new line
//     .map((s) => s.trim())
//     .where((s) => s.isNotEmpty)
//     .toList(),
//       };

//       if (user['role'] == 'provider') {
//   // Clean experience text to extract number only
//   String expText = experienceController.text.trim();
//   RegExp numberExp = RegExp(r'\d+'); // Matches digits
//   int? years = int.tryParse(numberExp.firstMatch(expText)?.group(0) ?? '');
  
//   body['experience_years'] = years;
//   body['gov_id'] = govIdController.text.trim();
//   body['experience_level'] = experienceLevel;
// }


//       if (profileImageFile != null) {
//         body['profile_image'] = base64Encode(profileImageFile!.readAsBytesSync());
//       } else if (profileBase64 != null) {
//         body['profile_image'] = profileBase64;
//       }

//       if (coverImageFile != null) {
//         body['cover_image'] = base64Encode(coverImageFile!.readAsBytesSync());
//       } else if (coverBase64 != null) {
//         body['cover_image'] = coverBase64;
//       }

//       final url = Uri.parse('${Backend.baseUrl}/auth/update-profile/${user['id']}');
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
//         ScaffoldMessenger.of(context)
//             .showSnackBar(const SnackBar(content: Text('Profile updated successfully ✅')));
//       } else {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text(data['message'] ?? 'Update failed ❌')));
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Error: $e')));
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }










//   // ✅ Service Add (provider-only, self-only)
//   Future<void> addService() async {
//   if (widget.readOnly) return;

//   final title = serviceTitleController.text.trim();
//   final desc = serviceDescController.text.trim();
//   final priceText = servicePriceController.text.trim();

//   if (title.isEmpty || desc.isEmpty || priceText.isEmpty) {
//     ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please fill all service fields ❌')));
//     return;
//   }

//   final price = double.tryParse(priceText);
//   if (price == null) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(const SnackBar(content: Text('Price must be a number ❌')));
//     return;
//   }

//   setState(() => isLoading = true);
//   try {
//     final url = Uri.parse('${Backend.baseUrl}/services');
//     final response = await http.post(
//       url,
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({
//         "provider_id": user['id'],
//         "title": title,
//         "description": desc,
//         "price": price,
//         "availability_status": true,
//         "category": "General",
//         "sub_category": "Basic",
//       }),
//     );

//     if (response.statusCode == 201) {
//       final data = jsonDecode(response.body);
//       setState(() {
//         // ✅ Update local services list
//         services.add(data['service']);
//         // ✅ Sync with user map so it reflects everywhere
//         user['services'] = services;
//       });

//       // Clear fields
//       serviceTitleController.clear();
//       serviceDescController.clear();
//       servicePriceController.clear();

//       if (widget.onProfileUpdated != null) widget.onProfileUpdated!();

//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text('Service added successfully ✅')));
//     } else {
//       final resBody = jsonDecode(response.body);
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text('Failed to add service ❌ ${resBody['message'] ?? ''}')));
//     }
//   } catch (e) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text('Error: $e')));
//   } finally {
//     setState(() => isLoading = false);
//   }
// }




//   // ✅ Delete Profile (self-only)
//   Future<void> deleteProfile() async {
//     if (widget.readOnly) return;

//     bool confirm = await showDialog(
//           context: context,
//           builder: (ctx) => AlertDialog(
//             backgroundColor: const Color(0xFFD9E1F0), // Light Blue background
//             title: const Text('Delete Profile', style: TextStyle(color: Colors.black)),
//             content: const Text('Are you sure you want to delete your profile?',
//                 style: TextStyle(color: Colors.black87)),
//             actions: [
//               TextButton(
//                   onPressed: () => Navigator.pop(ctx, false),
//                   child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
//               TextButton(
//                   onPressed: () => Navigator.pop(ctx, true),
//                   child: const Text('Delete', style: TextStyle(color: Colors.red))),
//             ],
//           ),
//         ) ??
//         false;

//     if (!confirm) return;

//     setState(() => isLoading = true);
//     try {
//       final url = Uri.parse('${Backend.baseUrl}/auth/delete-profile/${user['id']}');
//       final response = await http.delete(url);

//       if (response.statusCode == 200) {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(const SnackBar(content: Text('Profile deleted successfully')));
//         Navigator.of(context).pop();
//       } else {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(const SnackBar(content: Text('Failed to delete profile ❌')));
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Error: $e')));
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isExternalView = widget.readOnly;

//     return Scaffold(
//       backgroundColor: const Color(0xFFFFFFFF), // White background
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF2A3A69), // Dark Blue primary
//         title: Text(isExternalView ? 'Provider Profile' : 'My Profile'),
//         actions: [
//           if (!isExternalView)
//             IconButton(
//               icon: Icon(isEditing ? Icons.close : Icons.edit, color: Colors.white),
//               onPressed: () => setState(() => isEditing = !isEditing),
//             ),
//         ],
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator(color: Color(0xFF2A3A69)))
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Cover + Profile layout
//                     Stack(
//                       children: [
//                         GestureDetector(
//                           onTap: isEditing && !isExternalView ? () => pickImage(false) : null,
//                           child: Container(
//                             height: 150,
//                             width: double.infinity,
//                             decoration: BoxDecoration(
//                               color: const Color(0xFFD9E1F0), // Light Blue card/faint
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: _getImage(isProfile: false) != null
//                                 ? ClipRRect(
//                                     borderRadius: BorderRadius.circular(8),
//                                     child: Image(
//                                       image: _getImage(isProfile: false)!,
//                                       fit: BoxFit.cover,
//                                     ),
//                                   )
//                                 : const Center(
//                                     child: Text('Upload Cover Photo',
//                                         style: TextStyle(color: Color(0xFF5C74B1)))),
//                           ),
//                         ),
//                         Positioned(
//                           left: 16,
//                           bottom: -40,
//                           child: GestureDetector(
//                             onTap: isEditing && !isExternalView ? () => pickImage(true) : null,
//                             child: CircleAvatar(
//                               radius: 50,
//                               backgroundImage: _getImage(isProfile: true),
//                               backgroundColor: const Color(0xFFD9E1F0),
//                               child: _getImage(isProfile: true) == null
//                                   ? const Icon(Icons.person, size: 50, color: Color(0xFF5C74B1))
//                                   : null,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 60),

//                     // Name & Username
//                     isEditing && !isExternalView
//                         ? Column(
//                             children: [
//                               _buildCustomTextField(nameController, 'Full Name'),
//                               const SizedBox(height: 10),
//                               _buildCustomTextField(usernameController, 'Username / Display Name'),
//                               const SizedBox(height: 10),
//                               _buildCustomTextField(bioController, 'Bio', maxLines: 2),
//                             ],
//                           )
//                         : Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(user['name'] ?? 'Your Name',
//                                   style: const TextStyle(
//                                       fontSize: 22,
//                                       fontWeight: FontWeight.bold,
//                                       color: Color(0xFF2A3A69))), // Dark Blue
//                               if (user['username'] != null)
//                                 Text('@${user['username']}', style: const TextStyle(color: Color(0xFF5C74B1))), // Medium Blue
//                               if (user['bio'] != null && (user['bio'] as String).isNotEmpty)
//   Padding(
//     padding: const EdgeInsets.symmetric(vertical: 8.0),
//     child: Text(user['bio'] ?? '',
//         style: const TextStyle(color: Color(0xFF5C74B1))),
//   ),

//                             if (isExternalView)
//   ExternalProfileWidget(
//     userData: user,
//     currentUserId: widget.currentUserId,
//   ),

//                             ],
//                           ),

//                     const SizedBox(height: 16),

//                     // Contact & Address
//                     isEditing && !isExternalView
//                         ? Column(
//                             children: [
//                               _buildCustomTextField(phoneController, 'Phone'),
//                               const SizedBox(height: 10),
//                               _buildCustomTextField(addressController, 'Address'),
//                             ],
//                           )
//                         : Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text('Phone: ${user['phone'] ?? '-'}', style: const TextStyle(color: Color(0xFF5C74B1))),
//                               Text('Address: ${user['address'] ?? '-'}', style: const TextStyle(color: Color(0xFF5C74B1))),
//                             ],
//                           ),

//                     const SizedBox(height: 16),

//                     // Skills
//                     isEditing && !isExternalView
//                         ? _buildCustomTextField(skillsController, 'Skills (comma separated)')
//                         : Wrap(
//                             spacing: 6,
//                             children: user['skills'] != null
//                                 ? (user['skills'] as List)
//                                     .map<Widget>((skill) => Chip(
//                                           label: Text(skill),
//                                           backgroundColor: const Color(0xFF2A3A69), // Dark Blue
//                                           labelStyle: const TextStyle(color: Colors.white),
//                                         ))
//                                     .toList()
//                                 : const [Text('No skills', style: TextStyle(color: Color(0xFF5C74B1)))],
//                           ),

//                     const SizedBox(height: 20),

//                     // Provider Fields
//                     if (user['role'] == 'provider')
//                       ..._buildProviderFields(isEditing, isExternalView),

//                     if (isEditing && !isExternalView)
//                       CheckboxListTile(
//                         title: const Text('Show your profile on services page?',
//                             style: TextStyle(color: Color(0xFF5C74B1))),
//                         value: showOnServices,
//                         onChanged: (val) => setState(() => showOnServices = val ?? false),
//                         activeColor: const Color(0xFF2A3A69),
//                         checkColor: Colors.white,
//                       ),

//                     const SizedBox(height: 20),

//                     if (isEditing && !isExternalView)
//                       ElevatedButton(
//                           onPressed: saveProfile,
//                           style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFF2A3A69),
//                               padding: const EdgeInsets.symmetric(vertical: 14)),
//                           child: const Center(
//                               child: Text('Save Changes',
//                                   style: TextStyle(fontSize: 16, color: Colors.white)))),

//                     if (!isExternalView) ...[
//                       const SizedBox(height: 10),
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.red,
//                             padding: const EdgeInsets.symmetric(vertical: 14)),
//                         onPressed: deleteProfile,
//                         child: const Center(
//                             child: Text('Delete Profile',
//                                 style: TextStyle(fontSize: 16, color: Colors.white))),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }

//   // Custom Text Field with theme colors
//   Widget _buildCustomTextField(TextEditingController controller, String label,
//       {int maxLines = 1}) {
//     return TextFormField(
//       controller: controller,
//       maxLines: maxLines,
//       style: const TextStyle(color: Color(0xFF2A3A69)),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(color: Color(0xFF5C74B1)),
//         filled: true,
//         fillColor: const Color(0xFFD9E1F0),
//         focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: const BorderSide(color: Color(0xFF2A3A69))),
//         enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: const BorderSide(color: Color(0xFF5C74B1))),
//         errorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: const BorderSide(color: Colors.red)),
//       ),
//       validator: (val) => val == null || val.isEmpty ? 'Please enter $label' : null,
//     );
//   }
// /////////////////////////////////////////////////////////////
// ///
// ///








//   // ✅ Provider Fields Builder
//   List<Widget> _buildProviderFields(bool isEditing, bool isExternalView) {
//   return [
//     const SizedBox(height: 20),
//     const Text('Provider Info',
//         style: TextStyle(
//             fontSize: 18, color: Color(0xFF2A3A69), fontWeight: FontWeight.bold)),
//     const SizedBox(height: 10),

//     // --- Edit Mode ---
//     if (isEditing && !isExternalView)
//       Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildCustomTextField(experienceController, 'Experience (years)'),
//           const SizedBox(height: 10),
//           DropdownButtonFormField<String>(
//             value: experienceLevel,
//             decoration: InputDecoration(
//               labelText: 'Experience Level',
//               labelStyle: const TextStyle(color: Color(0xFF5C74B1)),
//               filled: true,
//               fillColor: const Color(0xFFD9E1F0),
//               focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: const BorderSide(color: Color(0xFF2A3A69))),
//               enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: const BorderSide(color: Color(0xFF5C74B1))),
//             ),
//             items: ['Beginner', 'Intermediate', 'Expert']
//                 .map((level) => DropdownMenuItem(value: level, child: Text(level)))
//                 .toList(),
//             onChanged: (val) => setState(() => experienceLevel = val),
//           ),
//           const SizedBox(height: 10),
//           _buildCustomTextField(govIdController, 'Gov ID'),
//           const SizedBox(height: 10),
//           _buildCustomTextField(
//               portfolioController, 'Portfolio Links (one per line)',
//               maxLines: 4),
//           const SizedBox(height: 10),
//           _buildCustomTextField(hourlyRateController, 'Hourly Rate'),
//           const SizedBox(height: 10),
//           _buildCustomTextField(
//               languagesController, 'Languages (comma separated)'),
//           const SizedBox(height: 10),
//           _buildCustomTextField(
//               educationController, 'Education (comma separated)'),
//           const SizedBox(height: 10),
//           _buildCustomTextField(
//               socialLinksController, 'Social Links (one per line)',
//               maxLines: 4),
//           const SizedBox(height: 20),
//           const Text('Services',
//               style: TextStyle(
//                   color: Color(0xFF2A3A69),
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold)),
//           const SizedBox(height: 10),
//           ...services.map((s) => Card(
//                 color: const Color(0xFFD9E1F0),
//                 child: ListTile(
//                   title: Text(s['title'], style: const TextStyle(color: Color(0xFF2A3A69))),
//                   subtitle: Text('${s['description'] ?? ''} - PKR ${s['price']}',
//                       style: const TextStyle(color: Color(0xFF5C74B1))),
//                 ),
//               )),
//           const SizedBox(height: 10),
//           _buildCustomTextField(serviceTitleController, 'Service Title'),
//           const SizedBox(height: 10),
//           _buildCustomTextField(serviceDescController, 'Service Description'),
//           const SizedBox(height: 10),
//           _buildCustomTextField(servicePriceController, 'Service Price'),
//           const SizedBox(height: 10),
//           ElevatedButton(
//               onPressed: addService,
//               style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF2A3A69),
//                   padding: const EdgeInsets.symmetric(vertical: 14)),
//               child: const Center(
//                   child: Text('Add Service', style: TextStyle(color: Colors.white, fontSize: 16)))),
//         ],
//       )
//     else
//       // --- Non-Edit Mode ---
//       Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Experience: ${user['experience_years'] ?? '-'} years',
//               style: const TextStyle(color: Color(0xFF5C74B1))),
//           Text('Level: ${user['experience_level'] ?? '-'}',
//               style: const TextStyle(color: Color(0xFF5C74B1))),
//           Text('Gov ID: ${user['gov_id'] ?? '-'}',
//               style: const TextStyle(color: Color(0xFF5C74B1))),
//           Text('Hourly Rate: PKR ${user['hourly_rate'] ?? '-'}',
//               style: const TextStyle(color: Color(0xFF5C74B1))),
//           Wrap(
//             spacing: 6,
//             children: user['languages'] != null
//                 ? (user['languages'] as List)
//                     .map<Widget>((l) => Chip(
//                           label: Text(l),
//                           backgroundColor: const Color(0xFF2A3A69),
//                           labelStyle: const TextStyle(color: Colors.white),
//                         ))
//                     .toList()
//                 : const [Text('-', style: TextStyle(color: Color(0xFF5C74B1)))],
//           ),
//           const SizedBox(height: 10),
//           const Text('Portfolio Links:',
//               style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A3A69))),
//           if (user['portfolio_links'] != null && (user['portfolio_links'] as List).isNotEmpty)
//             ... (user['portfolio_links'] as List)
//                 .map((link) => Text(link, style: const TextStyle(color: Color(0xFF5C74B1)))),
//           const SizedBox(height: 10),
//           const Text('Social Links:',
//               style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A3A69))),
//           if (user['social_links'] != null && (user['social_links'] as List).isNotEmpty)
//             ... (user['social_links'] as List)
//                 .map((link) => Text(link, style: const TextStyle(color: Color(0xFF5C74B1)))),
//           const SizedBox(height: 10),
//           const Text('Services:',
//               style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A3A69))),
//           if (user['services'] != null && (user['services'] as List).isNotEmpty)
//             ... (user['services'] as List).map((s) => Card(
//                   color: const Color(0xFFD9E1F0),
//                   child: ListTile(
//                     title: Text(s['title'], style: const TextStyle(color: Color(0xFF2A3A69))),
//                     subtitle: Text('${s['description'] ?? ''} - PKR ${s['price']}',
//                         style: const TextStyle(color: Color(0xFF5C74B1))),
//                   ),
//                 ))
//           else
//             const Text('No services available', style: TextStyle(color: Color(0xFF5C74B1))),
//         ],
//       ),
//   ];
// }

// }





















import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../helpers/backend.dart';
import '../models/action_buttons.dart';
import '../models/ExternalProfileWidget.dart';

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

  // Controllers
  late TextEditingController nameController;
  late TextEditingController usernameController;
  late TextEditingController bioController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController skillsController;
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

  // --- Services ---
  List<Map<String, dynamic>> services = [];
  TextEditingController serviceTitleController = TextEditingController();
  TextEditingController serviceDescController = TextEditingController();
  TextEditingController servicePriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initUserData();
  }

  void _initUserData() {
    user = Map.from(widget.userData);

    nameController = TextEditingController(text: user['name']);
    usernameController = TextEditingController(text: user['username']);
    bioController = TextEditingController(text: user['bio']);
    phoneController = TextEditingController(text: user['phone']);
    addressController = TextEditingController(text: user['address']);
    skillsController = TextEditingController(
        text: user['skills'] != null ? (user['skills'] as List).join(', ') : '');
    experienceController =
        TextEditingController(text: user['experience_years']?.toString() ?? '');
    govIdController = TextEditingController(text: user['gov_id'] ?? '');
    portfolioController = TextEditingController(
        text: user['portfolio_links'] != null
            ? (user['portfolio_links'] as List).join(', ')
            : '');
    hourlyRateController =
        TextEditingController(text: user['hourly_rate']?.toString() ?? '');
    languagesController = TextEditingController(
        text: user['languages'] != null ? (user['languages'] as List).join(', ') : '');
    educationController = TextEditingController(
        text: user['education'] != null ? (user['education'] as List).join(', ') : '');
    socialLinksController = TextEditingController(
        text: user['social_links'] != null
            ? (user['social_links'] as List).join(', ')
            : '');
    experienceLevel = user['experience_level'];
    showOnServices = user['show_on_services'] ?? false;

    if (user['services'] != null) {
      services = List<Map<String, dynamic>>.from(user['services']);
    }
  }

  // --- Image Picker ---
  Future<void> pickImage(bool isProfile) async {
    if (widget.readOnly) return;

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
  }

  ImageProvider<Object>? _getImage({required bool isProfile}) {
    if (isProfile) {
      if (kIsWeb && profileBase64 != null) return MemoryImage(base64Decode(profileBase64!));
      if (!kIsWeb && profileImageFile != null) return FileImage(profileImageFile!);
      if (user['profile_image'] != null && user['profile_image'] != '') {
        final url = user['profile_image'].startsWith('http')
            ? user['profile_image']
            : '${Backend.baseUrl}/${user['profile_image']}';
        return NetworkImage(url);
      }
    } else {
      if (kIsWeb && coverBase64 != null) return MemoryImage(base64Decode(coverBase64!));
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




Future<void> _openExternalProviderProfile(int providerId) async {
  setState(() => isLoading = true);
  try {
    final url = Uri.parse('${Backend.baseUrl}/auth/provider/$providerId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final providerData = data['provider'];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MyProfileScreen(
            userData: providerData,
            currentUserId: widget.currentUserId,
            readOnly: true, // external view
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load provider profile ❌')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
  } finally {
    setState(() => isLoading = false);
  }
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
        'skills': skillsController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        'show_on_services': showOnServices,
        'portfolio_links': portfolioController.text
    .split('\n') // ✅ split by new line
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
  RegExp numberExp = RegExp(r'\d+'); // Matches digits
  int? years = int.tryParse(numberExp.firstMatch(expText)?.group(0) ?? '');
  
  body['experience_years'] = years;
  body['gov_id'] = govIdController.text.trim();
  body['experience_level'] = experienceLevel;
}


      if (profileImageFile != null) {
        body['profile_image'] = base64Encode(profileImageFile!.readAsBytesSync());
      } else if (profileBase64 != null) {
        body['profile_image'] = profileBase64;
      }

      if (coverImageFile != null) {
        body['cover_image'] = base64Encode(coverImageFile!.readAsBytesSync());
      } else if (coverBase64 != null) {
        body['cover_image'] = coverBase64;
      }

      final url = Uri.parse('${Backend.baseUrl}/auth/update-profile/${user['id']}');
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
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Profile updated successfully ✅')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(data['message'] ?? 'Update failed ❌')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
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

  if (title.isEmpty || desc.isEmpty || priceText.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all service fields ❌')));
    return;
  }

  final price = double.tryParse(priceText);
  if (price == null) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Price must be a number ❌')));
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
        "category": "General",
        "sub_category": "Basic",
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      setState(() {
        // ✅ Update local services list
        services.add(data['service']);
        // ✅ Sync with user map so it reflects everywhere
        user['services'] = services;
      });

      // Clear fields
      serviceTitleController.clear();
      serviceDescController.clear();
      servicePriceController.clear();

      if (widget.onProfileUpdated != null) widget.onProfileUpdated!();

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Service added successfully ✅')));
    } else {
      final resBody = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to add service ❌ ${resBody['message'] ?? ''}')));
    }
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Error: $e')));
  } finally {
    setState(() => isLoading = false);
  }
}




  // ✅ Delete Profile (self-only)
  Future<void> deleteProfile() async {
    if (widget.readOnly) return;

    bool confirm = await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFFD9E1F0), // Light Blue background
            title: const Text('Delete Profile', style: TextStyle(color: Colors.black)),
            content: const Text('Are you sure you want to delete your profile?',
                style: TextStyle(color: Colors.black87)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Delete', style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    setState(() => isLoading = true);
    try {
      final url = Uri.parse('${Backend.baseUrl}/auth/delete-profile/${user['id']}');
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Profile deleted successfully')));
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Failed to delete profile ❌')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExternalView = widget.readOnly;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // White background
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A3A69), // Dark Blue primary
        title: Text(isExternalView ? 'Provider Profile' : 'My Profile'),
        actions: [
          if (!isExternalView)
            IconButton(
              icon: Icon(isEditing ? Icons.close : Icons.edit, color: Colors.white),
              onPressed: () => setState(() => isEditing = !isEditing),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2A3A69)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cover + Profile layout
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: isEditing && !isExternalView ? () => pickImage(false) : null,
                          child: Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD9E1F0), // Light Blue card/faint
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _getImage(isProfile: false) != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image(
                                      image: _getImage(isProfile: false)!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Center(
                                    child: Text('Upload Cover Photo',
                                        style: TextStyle(color: Color(0xFF5C74B1)))),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          bottom: -40,
                          child: GestureDetector(
                            onTap: isEditing && !isExternalView ? () => pickImage(true) : null,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: _getImage(isProfile: true),
                              backgroundColor: const Color(0xFFD9E1F0),
                              child: _getImage(isProfile: true) == null
                                  ? const Icon(Icons.person, size: 50, color: Color(0xFF5C74B1))
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 60),

                    // Name & Username
                    isEditing && !isExternalView
                        ? Column(
                            children: [
                              _buildCustomTextField(nameController, 'Full Name'),
                              const SizedBox(height: 10),
                              _buildCustomTextField(usernameController, 'Username / Display Name'),
                              const SizedBox(height: 10),
                              _buildCustomTextField(bioController, 'Bio', maxLines: 2),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user['name'] ?? 'Your Name',
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2A3A69))), // Dark Blue
                              if (user['username'] != null)
                                Text('@${user['username']}', style: const TextStyle(color: Color(0xFF5C74B1))), // Medium Blue
                              if (user['bio'] != null && (user['bio'] as String).isNotEmpty)
  Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Text(user['bio'] ?? '',
        style: const TextStyle(color: Color(0xFF5C74B1))),
  ),

                            if (isExternalView)
  ExternalProfileWidget(
    userData: user,
    currentUserId: widget.currentUserId,
  ),

                            ],
                          ),

                    const SizedBox(height: 16),

                    // Contact & Address
                    isEditing && !isExternalView
                        ? Column(
                            children: [
                              _buildCustomTextField(phoneController, 'Phone'),
                              const SizedBox(height: 10),
                              _buildCustomTextField(addressController, 'Address'),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Phone: ${user['phone'] ?? '-'}', style: const TextStyle(color: Color(0xFF5C74B1))),
                              Text('Address: ${user['address'] ?? '-'}', style: const TextStyle(color: Color(0xFF5C74B1))),
                            ],
                          ),

                    const SizedBox(height: 16),

                    // Skills
                    isEditing && !isExternalView
                        ? _buildCustomTextField(skillsController, 'Skills (comma separated)')
                        : Wrap(
                            spacing: 6,
                            children: user['skills'] != null
                                ? (user['skills'] as List)
                                    .map<Widget>((skill) => Chip(
                                          label: Text(skill),
                                          backgroundColor: const Color(0xFF2A3A69), // Dark Blue
                                          labelStyle: const TextStyle(color: Colors.white),
                                        ))
                                    .toList()
                                : const [Text('No skills', style: TextStyle(color: Color(0xFF5C74B1)))],
                          ),

                    const SizedBox(height: 20),

                    // Provider Fields
                    if (user['role'] == 'provider')
                      ..._buildProviderFields(isEditing, isExternalView),

                    if (isEditing && !isExternalView)
                      CheckboxListTile(
                        title: const Text('Show your profile on services page?',
                            style: TextStyle(color: Color(0xFF5C74B1))),
                        value: showOnServices,
                        onChanged: (val) => setState(() => showOnServices = val ?? false),
                        activeColor: const Color(0xFF2A3A69),
                        checkColor: Colors.white,
                      ),

                    const SizedBox(height: 20),

                    if (isEditing && !isExternalView)
                      ElevatedButton(
                          onPressed: saveProfile,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2A3A69),
                              padding: const EdgeInsets.symmetric(vertical: 14)),
                          child: const Center(
                              child: Text('Save Changes',
                                  style: TextStyle(fontSize: 16, color: Colors.white)))),

                    if (!isExternalView) ...[
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 14)),
                        onPressed: deleteProfile,
                        child: const Center(
                            child: Text('Delete Profile',
                                style: TextStyle(fontSize: 16, color: Colors.white))),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  // Custom Text Field with theme colors
  Widget _buildCustomTextField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Color(0xFF2A3A69)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF5C74B1)),
        filled: true,
        fillColor: const Color(0xFFD9E1F0),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF2A3A69))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF5C74B1))),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red)),
      ),
      validator: (val) => val == null || val.isEmpty ? 'Please enter $label' : null,
    );
  }
/////////////////////////////////////////////////////////////
///
///








  // ✅ Provider Fields Builder
  List<Widget> _buildProviderFields(bool isEditing, bool isExternalView) {
  return [
    const SizedBox(height: 20),
    const Text('Provider Info',
        style: TextStyle(
            fontSize: 18, color: Color(0xFF2A3A69), fontWeight: FontWeight.bold)),
    const SizedBox(height: 10),

    // --- Edit Mode ---
    if (isEditing && !isExternalView)
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCustomTextField(experienceController, 'Experience (years)'),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: experienceLevel,
            decoration: InputDecoration(
              labelText: 'Experience Level',
              labelStyle: const TextStyle(color: Color(0xFF5C74B1)),
              filled: true,
              fillColor: const Color(0xFFD9E1F0),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2A3A69))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF5C74B1))),
            ),
            items: ['Beginner', 'Intermediate', 'Expert']
                .map((level) => DropdownMenuItem(value: level, child: Text(level)))
                .toList(),
            onChanged: (val) => setState(() => experienceLevel = val),
          ),
          const SizedBox(height: 10),
          _buildCustomTextField(govIdController, 'Gov ID'),
          const SizedBox(height: 10),
          _buildCustomTextField(
              portfolioController, 'Portfolio Links (one per line)',
              maxLines: 4),
          const SizedBox(height: 10),
          _buildCustomTextField(hourlyRateController, 'Hourly Rate'),
          const SizedBox(height: 10),
          _buildCustomTextField(
              languagesController, 'Languages (comma separated)'),
          const SizedBox(height: 10),
          _buildCustomTextField(
              educationController, 'Education (comma separated)'),
          const SizedBox(height: 10),
          _buildCustomTextField(
              socialLinksController, 'Social Links (one per line)',
              maxLines: 4),
          const SizedBox(height: 20),
          const Text('Services',
              style: TextStyle(
                  color: Color(0xFF2A3A69),
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...services.map((s) => Card(
                color: const Color(0xFFD9E1F0),
                child: ListTile(
                  title: Text(s['title'], style: const TextStyle(color: Color(0xFF2A3A69))),
                  subtitle: Text('${s['description'] ?? ''} - PKR ${s['price']}',
                      style: const TextStyle(color: Color(0xFF5C74B1))),
                ),
              )),
          const SizedBox(height: 10),
          _buildCustomTextField(serviceTitleController, 'Service Title'),
          const SizedBox(height: 10),
          _buildCustomTextField(serviceDescController, 'Service Description'),
          const SizedBox(height: 10),
          _buildCustomTextField(servicePriceController, 'Service Price'),
          const SizedBox(height: 10),
          ElevatedButton(
              onPressed: addService,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A3A69),
                  padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Center(
                  child: Text('Add Service', style: TextStyle(color: Colors.white, fontSize: 16)))),
        ],
      )
    else
      // --- Non-Edit Mode ---
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Experience: ${user['experience_years'] ?? '-'} years',
              style: const TextStyle(color: Color(0xFF5C74B1))),
          Text('Level: ${user['experience_level'] ?? '-'}',
              style: const TextStyle(color: Color(0xFF5C74B1))),
          Text('Gov ID: ${user['gov_id'] ?? '-'}',
              style: const TextStyle(color: Color(0xFF5C74B1))),
          Text('Hourly Rate: PKR ${user['hourly_rate'] ?? '-'}',
              style: const TextStyle(color: Color(0xFF5C74B1))),
          Wrap(
            spacing: 6,
            children: user['languages'] != null
                ? (user['languages'] as List)
                    .map<Widget>((l) => Chip(
                          label: Text(l),
                          backgroundColor: const Color(0xFF2A3A69),
                          labelStyle: const TextStyle(color: Colors.white),
                        ))
                    .toList()
                : const [Text('-', style: TextStyle(color: Color(0xFF5C74B1)))],
          ),
          const SizedBox(height: 10),
          const Text('Portfolio Links:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A3A69))),
          if (user['portfolio_links'] != null && (user['portfolio_links'] as List).isNotEmpty)
            ... (user['portfolio_links'] as List)
                .map((link) => Text(link, style: const TextStyle(color: Color(0xFF5C74B1)))),
          const SizedBox(height: 10),
          const Text('Social Links:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A3A69))),
          if (user['social_links'] != null && (user['social_links'] as List).isNotEmpty)
            ... (user['social_links'] as List)
                .map((link) => Text(link, style: const TextStyle(color: Color(0xFF5C74B1)))),
          const SizedBox(height: 10),
          const Text('Services:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A3A69))),
          if (user['services'] != null && (user['services'] as List).isNotEmpty)
            ... (user['services'] as List).map((s) => Card(
                  color: const Color(0xFFD9E1F0),
                  child: ListTile(
                    title: Text(s['title'], style: const TextStyle(color: Color(0xFF2A3A69))),
                    subtitle: Text('${s['description'] ?? ''} - PKR ${s['price']}',
                        style: const TextStyle(color: Color(0xFF5C74B1))),
                  ),
                ))
          else
            const Text('No services available', style: TextStyle(color: Color(0xFF5C74B1))),
        ],
      ),
  ];
}

}





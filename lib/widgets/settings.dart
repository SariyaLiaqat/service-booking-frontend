


// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:geolocator/geolocator.dart';
// import '../helpers/backend.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../helpers/coolors.dart'; // updated colors

// class SettingsScreen extends StatelessWidget {
//   final int currentUserId;
//   const SettingsScreen({super.key, required this.currentUserId});

//   // 🔹 Open location settings
//   Future<void> _openLocationSettings(BuildContext context) async {
//     PermissionStatus status = await Permission.location.status;

//     if (status.isDenied || status.isPermanentlyDenied) {
//       bool opened = await openAppSettings();
//       if (!opened) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('⚠️ Cannot open settings. Please enable manually.'),
//             backgroundColor: redAccent,
//           ),
//         );
//       }
//     } else if (status.isGranted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('✅ Location already enabled!'),
//           backgroundColor: kSuccessColor,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kBackgroundColor,
//       appBar: AppBar(
//         backgroundColor: kCardColor,
//         title: const Text(
//           "Settings",
//           style: TextStyle(fontWeight: FontWeight.bold, color: kTextPrimary),
//         ),
//         centerTitle: true,
//         elevation: 4,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(
//             bottom: Radius.circular(20),
//           ),
//         ),
//       ),
//       body: Stack(
//         children: [
//           SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // 🔹 Location Card
//                 Card(
//                   color: kCardColor,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   elevation: 4,
//                   shadowColor: Colors.black.withOpacity(0.2),
//                   child: ListTile(
//                     contentPadding:
//                         const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                     leading: Icon(Icons.location_on,
//                         color: kSecondaryColor, size: 32),
//                     title: Text("Enable Location",
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                             color: kTextPrimary)),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(height: 4),
//                         Text(
//                           "Turn on location to see nearby service providers and be visible in the list.",
//                           style: TextStyle(fontSize: 14, color: kTextSecondary),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           "Your location helps us connect you with clients quickly and efficiently. "
//                           "Make sure your GPS is enabled for best results.",
//                           style: TextStyle(fontSize: 12, color: kTextHint),
//                         ),
//                       ],
//                     ),
//                     trailing: ElevatedButton(
//                       onPressed: () => _openLocationSettings(context),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: kPrimaryColor,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                       ),
//                       child: const Text(
//                         "Open",
//                         style: TextStyle(color: buttonText),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 24),

//                 // 🔹 App Info Card
//                 Card(
//                   color: kCardColor,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   elevation: 4,
//                   shadowColor: Colors.black.withOpacity(0.2),
//                   child: ListTile(
//                     contentPadding:
//                         const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                     leading: Icon(Icons.info_outline,
//                         color: kSecondaryColor, size: 32),
//                     title: Text("App Version",
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                             color: kTextPrimary)),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(height: 4),
//                         Text("Version 1.0.0",
//                             style: TextStyle(
//                                 fontSize: 14, color: kTextSecondary)),
//                         const SizedBox(height: 8),
//                         Text(
//                           "Stay updated! Make sure you are using the latest version for the best experience and new features.",
//                           style: TextStyle(fontSize: 12, color: kTextHint),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 120), // extra space for button
//               ],
//             ),
//           ),

//           // 🔹 Positioned Button at bottom
//           Positioned(
//             left: 16,
//             right: 16,
//             bottom: 16,
//             child: ElevatedButton(
//               onPressed: () => updateLocation(context, currentUserId),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: kPrimaryColor,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16)),
//                 padding: const EdgeInsets.symmetric(vertical: 18),
//               ),
//               child: const Text(
//                 "Update Location",
//                 style: TextStyle(
//                     fontSize: 18, fontWeight: FontWeight.bold, color: buttonText),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // 🔹 Update Location Function
// Future<void> updateLocation(BuildContext context, int currentUserId) async {
//   try {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content:
//               const Text('⚠️ Location services are disabled. Please enable GPS.'),
//           backgroundColor: redAccent,
//         ),
//       );
//       return;
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text('⚠️ Location permission denied.'),
//             backgroundColor: redAccent,
//           ),
//         );
//         return;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text(
//               '❌ Location permission permanently denied. Enable from settings.'),
//           backgroundColor: redAccent,
//         ),
//       );
//       return;
//     }

//     Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );

//     // ✅ Send location to backend
//     final url = Uri.parse('${Backend.baseUrl}/provider/$currentUserId/location');
//     await http.put(
//       url,
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({
//         "latitude": position.latitude,
//         "longitude": position.longitude,
//       }),
//     );

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content:
//             Text('✅ Location updated: ${position.latitude}, ${position.longitude}'),
//         backgroundColor: kSuccessColor,
//       ),
//     );
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('⚠️ Location error: ${e.toString()}'),
//         backgroundColor: redAccent,
//       ),
//     );
//   }
// }









import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import '../helpers/backend.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../helpers/coolors.dart';

class SettingsScreen extends StatefulWidget {
  final int currentUserId;
  const SettingsScreen({super.key, required this.currentUserId});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isUpdatingLocation = false;

  Future<void> _openLocationSettings(BuildContext context) async {
    PermissionStatus status = await Permission.location.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      await openAppSettings();
    } else {
      _showSnackBar(context, '✅ Location permission is already active!', kSuccessColor);
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _handleUpdateLocation() async {
    setState(() => isUpdatingLocation = true);
    await updateLocationLogic(context, widget.currentUserId);
    setState(() => isUpdatingLocation = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kTextPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.w800, color: kTextPrimary, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildSectionHeader("Account & Privacy"),
                  _buildSettingTile(
                    icon: Icons.my_location_rounded,
                    title: "System Permissions",
                    subtitle: "Manage location access in device settings",
                    onTap: () => _openLocationSettings(context),
                  ),
                  const Divider(height: 1, indent: 70, color: kDividerColor),
                  
                  _buildSectionHeader("Application Info"),
                  _buildSettingTile(
                    icon: Icons.info_outline_rounded,
                    title: "App Version",
                    subtitle: "v1.0.2 Stable Release",
                    trailing: const Text("Up to date", style: TextStyle(color: kSuccessColor, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const Divider(height: 1, indent: 70, color: kDividerColor),
                  _buildSettingTile(
                    icon: Icons.description_outlined,
                    title: "Terms of Service",
                    subtitle: "Read our usage guidelines",
                    onTap: () {}, 
                  ),

                  const SizedBox(height: 30),
                  // 🔹 Helpful Tip Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kPrimaryColor.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb_outline_rounded, color: kPrimaryColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Keeping your location updated ensures you get the most accurate local service requests.",
                              style: TextStyle(color: kTextSecondary, fontSize: 13, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🔹 Fixed Bottom Action Area
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: kCardColor,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isUpdatingLocation ? null : _handleUpdateLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: isUpdatingLocation
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.refresh_rounded, color: Colors.white),
                            SizedBox(width: 10),
                            Text("Update Live Location", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildSettingTile({required IconData icon, required String title, required String subtitle, Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: kCardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: kDividerColor.withOpacity(0.5))),
        child: Icon(icon, color: kTextPrimary, size: 22),
      ),
      title: Text(title, style: const TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
      subtitle: Text(subtitle, style: const TextStyle(color: kTextSecondary, fontSize: 13)),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: kTextHint),
    );
  }
}

// 🔹 Extracted Logic for Cleanliness
Future<void> updateLocationLogic(BuildContext context, int currentUserId) async {
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError(context, '⚠️ GPS is disabled. Please enable it.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    final url = Uri.parse('${Backend.baseUrl}/provider/$currentUserId/location');
    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"latitude": position.latitude, "longitude": position.longitude}),
    );

    if (response.statusCode == 200) {
      _showSuccess(context, '✅ Location synced successfully!');
    } else {
      _showError(context, '❌ Server sync failed.');
    }
  } catch (e) {
    _showError(context, '⚠️ Error: ${e.toString()}');
  }
}

void _showError(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: redAccent));
}

void _showSuccess(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: kSuccessColor));
}
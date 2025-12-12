









// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:geolocator/geolocator.dart';
// import '../helpers/backend.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../helpers/my_colors.dart';

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
//             backgroundColor: MyColors.error,
//           ),
//         );
//       }
//     } else if (status.isGranted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('✅ Location already enabled!'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: MyColors.background,
//       appBar: AppBar(
//         backgroundColor: MyColors.surface,
//         title: const Text(
//           "Settings",
//           style: TextStyle(fontWeight: FontWeight.bold,color: MyColors.textPrimary),
//         ),
//         centerTitle: true,
//         elevation: 4,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(
//             bottom: Radius.circular(20),
//           ),
//         ),
//       ),
//     body: Stack(
//     children: [
//       SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // 🔹 Location Card
//             Card(
//               color: MyColors.surface,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               elevation: 4,
//               shadowColor: Colors.black.withOpacity(0.2),
//               child: ListTile(
//                 contentPadding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 leading: Icon(Icons.location_on, color: MyColors.secondary, size: 32),
//                 title: Text("Enable Location",
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18,
//                         color: MyColors.textPrimary)),
//                 subtitle: Text(
//                     "Turn on location to see nearby service providers and be visible in the list.",
//                     style: TextStyle(fontSize: 14, color: MyColors.textSecondary)),
//                 trailing: ElevatedButton(
//                   onPressed: () => _openLocationSettings(context),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: MyColors.primary,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                   ),
//                   child: const Text(
//                     "Open",
//                     style: TextStyle(color: MyColors.buttonText),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),

//             // 🔹 App Info Card
//             Card(
//               color: MyColors.surface,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               elevation: 4,
//               shadowColor: Colors.black.withOpacity(0.2),
//               child: ListTile(
//                 contentPadding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 leading: Icon(Icons.info_outline, color: MyColors.secondary, size: 32),
//                 title: Text("App Version",
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18,
//                         color: MyColors.textPrimary)),
//                 subtitle: Text("Version 1.0.0",
//                     style: TextStyle(fontSize: 14, color: MyColors.textSecondary)),
//               ),
//             ),
//             const SizedBox(height: 120), // extra space for button
//           ],
//         ),
//       ),

//       // 🔹 Positioned Button at bottom
//       Positioned(
//         left: 16,
//         right: 16,
//         bottom: 16,
//         child: ElevatedButton(
//           onPressed: () => updateLocation(context, currentUserId),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: MyColors.primary,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//             padding: const EdgeInsets.symmetric(vertical: 18),
//           ),
//           child: const Text(
//             "Update Location",
//             style: TextStyle(
//                 fontSize: 18, fontWeight: FontWeight.bold, color: MyColors.buttonText),
//           ),
//         ),
//       ),
//     ],
//   ),
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
//           content: const Text('⚠️ Location services are disabled. Please enable GPS.'),
//           backgroundColor: MyColors.error,
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
//             backgroundColor: MyColors.error,
//           ),
//         );
//         return;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('❌ Location permission permanently denied. Enable from settings.'),
//           backgroundColor: MyColors.error,
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
//         content: Text('✅ Location updated: ${position.latitude}, ${position.longitude}'),
//         backgroundColor: Colors.green,
//       ),
//     );
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('⚠️ Location error: ${e.toString()}'),
//         backgroundColor: MyColors.error,
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
import '../helpers/coolors.dart'; // updated colors

class SettingsScreen extends StatelessWidget {
  final int currentUserId;
  const SettingsScreen({super.key, required this.currentUserId});

  // 🔹 Open location settings
  Future<void> _openLocationSettings(BuildContext context) async {
    PermissionStatus status = await Permission.location.status;

    if (status.isDenied || status.isPermanentlyDenied) {
      bool opened = await openAppSettings();
      if (!opened) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Cannot open settings. Please enable manually.'),
            backgroundColor: redAccent,
          ),
        );
      }
    } else if (status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Location already enabled!'),
          backgroundColor: kSuccessColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kCardColor,
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.bold, color: kTextPrimary),
        ),
        centerTitle: true,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 🔹 Location Card
                Card(
                  color: kCardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.2),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: Icon(Icons.location_on,
                        color: kSecondaryColor, size: 32),
                    title: Text("Enable Location",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: kTextPrimary)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          "Turn on location to see nearby service providers and be visible in the list.",
                          style: TextStyle(fontSize: 14, color: kTextSecondary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Your location helps us connect you with clients quickly and efficiently. "
                          "Make sure your GPS is enabled for best results.",
                          style: TextStyle(fontSize: 12, color: kTextHint),
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => _openLocationSettings(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Open",
                        style: TextStyle(color: buttonText),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 🔹 App Info Card
                Card(
                  color: kCardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.2),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: Icon(Icons.info_outline,
                        color: kSecondaryColor, size: 32),
                    title: Text("App Version",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: kTextPrimary)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text("Version 1.0.0",
                            style: TextStyle(
                                fontSize: 14, color: kTextSecondary)),
                        const SizedBox(height: 8),
                        Text(
                          "Stay updated! Make sure you are using the latest version for the best experience and new features.",
                          style: TextStyle(fontSize: 12, color: kTextHint),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 120), // extra space for button
              ],
            ),
          ),

          // 🔹 Positioned Button at bottom
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: ElevatedButton(
              onPressed: () => updateLocation(context, currentUserId),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              child: const Text(
                "Update Location",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: buttonText),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🔹 Update Location Function
Future<void> updateLocation(BuildContext context, int currentUserId) async {
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('⚠️ Location services are disabled. Please enable GPS.'),
          backgroundColor: redAccent,
        ),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('⚠️ Location permission denied.'),
            backgroundColor: redAccent,
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              '❌ Location permission permanently denied. Enable from settings.'),
          backgroundColor: redAccent,
        ),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // ✅ Send location to backend
    final url = Uri.parse('${Backend.baseUrl}/provider/$currentUserId/location');
    await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "latitude": position.latitude,
        "longitude": position.longitude,
      }),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('✅ Location updated: ${position.latitude}, ${position.longitude}'),
        backgroundColor: kSuccessColor,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⚠️ Location error: ${e.toString()}'),
        backgroundColor: redAccent,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // 🔹 Function to open location settings
  Future<void> _openLocationSettings(BuildContext context) async {
    PermissionStatus status = await Permission.location.status;

    if (status.isDenied || status.isPermanentlyDenied) {
      bool opened = await openAppSettings();
      if (!opened) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Cannot open settings. Please enable manually.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } else if (status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Location already enabled!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A66C2),
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔹 Location Option Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
              shadowColor: Colors.grey.withOpacity(0.2),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                leading: const Icon(
                  Icons.location_on,
                  color: Color(0xFF0A66C2),
                  size: 32,
                ),
                title: const Text(
                  "Enable Location",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: const Text(
                  "Turn on location to see nearby service providers and be visible in the list.",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                trailing: ElevatedButton(
                  onPressed: () => _openLocationSettings(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A66C2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text("Open"),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 🔹 App Info Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
              shadowColor: Colors.grey.withOpacity(0.2),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                leading: const Icon(
                  Icons.info_outline,
                  color: Color(0xFF0A66C2),
                  size: 32,
                ),
                title: const Text(
                  "App Version",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: const Text(
                  "Version 1.0.0",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ),
            ),
 const SizedBox(height: 24),
ElevatedButton(
  onPressed: () => updateLocation(context),
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF0A66C2),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    padding: const EdgeInsets.symmetric(vertical: 16),
  ),
  child: const Text(
    "Update Location",
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color:Colors.white),
  ),
),




            const SizedBox(height: 24),

            // 🔹 Logout Card (Optional)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
              shadowColor: Colors.grey.withOpacity(0.2),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                leading: const Icon(
                  Icons.logout,
                  color: Colors.redAccent,
                  size: 32,
                ),
                title: const Text(
                  "Logout",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    // 🔹 Add your logout logic here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text("Logout"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}





Future<void> updateLocation(BuildContext context) async {
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Location services are disabled. Please enable GPS.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Location permission denied.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Location permission permanently denied. Enable from settings.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // ✅ Show success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Location updated: ${position.latitude}, ${position.longitude}'),
        backgroundColor: Colors.green,
      ),
    );

    // 🔹 Optional: send to backend
    // await updateUserLocationOnServer(position.latitude, position.longitude);

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⚠️ Location error: ${e.toString()}'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}

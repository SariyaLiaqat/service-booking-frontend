// nearby_providers_widget.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import '../helpers/backend.dart';
import 'MyProfileScreen.dart';

class NearbyProvidersWidget extends StatefulWidget {
  final int currentUserId;
  const NearbyProvidersWidget({Key? key, required this.currentUserId})
      : super(key: key);

  @override
  _NearbyProvidersWidgetState createState() => _NearbyProvidersWidgetState();
}

class _NearbyProvidersWidgetState extends State<NearbyProvidersWidget> {
  List<dynamic> nearbyProviders = [];
  double? userLat;
  double? userLng;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getUserLocation();
  }

  Future<void> getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        showSnack('Please enable location services');
        setState(() => isLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          showSnack('Location permission denied');
          setState(() => isLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        showSnack('Location permissions are permanently denied');
        setState(() => isLoading = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        userLat = position.latitude;
        userLng = position.longitude;
      });

      fetchNearbyProviders();
    } catch (e) {
      showSnack('Location error: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchNearbyProviders() async {
    if (userLat == null || userLng == null) return;

    try {
      final url = Uri.parse(
        '${Backend.baseUrl}/provider/nearest?lat=$userLat&lng=$userLng&limit=10',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          nearbyProviders = data['providers'] ?? [];
          isLoading = false;
        });
      } else {
        showSnack('Failed to load nearby providers ❌');
        setState(() => isLoading = false);
      }
    } catch (e) {
      showSnack('Error fetching nearby providers: $e');
      setState(() => isLoading = false);
    }
  }

  void showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget buildNearbyCard(dynamic provider) {
    String? imageUrl;
    if (provider['profile_image'] != null && provider['profile_image'] != '') {
      imageUrl = provider['profile_image'].startsWith('http')
          ? provider['profile_image']
          : '${Backend.baseUrl}/${provider['profile_image']}';
    }

    return GestureDetector(
      onTap: () async {
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
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
            child: imageUrl == null
                ? const Icon(Icons.person, size: 40, color: Color(0xFF2A3A69))
                : null,
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 80,
            child: Text(
              provider['name'] ?? 'Unknown',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF2A3A69)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F0FA),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
              ],
            ),
            child: const Text(
              'Your Nearby Providers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A66C2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 130,
          child: nearbyProviders.isNotEmpty
              ? ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: nearbyProviders.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) =>
                      buildNearbyCard(nearbyProviders[index]),
                )
              : Center(
                  child: Text(
                    'No nearby providers available',
                    style: TextStyle(
                      color: Color(0xFF5C74B1),
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'MyProfileScreen.dart';
import '../helpers/backend.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  @override
  void initState() {
    super.initState();
    fetchCategoryProviders();
  }

 Future<void> fetchCategoryProviders() async {
  try {
    final url = Uri.parse('${Backend.baseUrl}/services?category_id=${widget.categoryId}');
    final response = await http.get(url);
    print('API Response: ${response.body}'); // Debug

    if (response.statusCode == 200) {
      final List services = jsonDecode(response.body);

      // ✅ Extract unique providers
      final uniqueProviders = <int, dynamic>{};
      for (var service in services) {
        final providerId = service['provider_id'];
        if (!uniqueProviders.containsKey(providerId)) {
          uniqueProviders[providerId] = {
            'id': providerId,
            'name': service['provider_name'],
            'profile_image': service['provider_image'],
            'skills': service['provider_skills'],
            'average_rating': service['average_rating'],
            'total_ratings': service['total_ratings'],
          };
        }
      }

      setState(() {
        providers = uniqueProviders.values.toList();
        isLoading = false;
      });
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
      appBar: AppBar(title: Text(widget.categoryName)),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.78,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: providers.length,
              itemBuilder: (context, index) {
                final provider = providers[index];
                return buildProviderCard(provider); // reuse existing method
              },
            ),
    );
  }

 Widget buildProviderCard(dynamic provider) {
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

   double avgRating = double.tryParse(provider['average_rating']?.toString() ?? '0') ?? 0.0;
int totalRatings = int.tryParse(provider['total_ratings']?.toString() ?? '0') ?? 0;


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
      child: Container(
        padding: const EdgeInsets.all(12),
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
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF2A3A69)),
            ),
            const SizedBox(height: 4),
            Text(
              skills.isNotEmpty ? skills : 'No skills',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF5C74B1), fontSize: 12),
            ),
            const SizedBox(height: 6),
            // 🔹 Rating display
            Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Icon(Icons.star, color: Colors.amber, size: 16),
    SizedBox(width: 4),
    Text(avgRating.toStringAsFixed(1), style: TextStyle(color: Color(0xFF2A3A69))),
    if (totalRatings > 0) ...[
      SizedBox(width: 4),
      Text('($totalRatings)', style: TextStyle(fontSize: 12, color: Color(0xFF5C74B1))),
    ],
  ],
),
          ],
        ),
      ),
    );
  }

}

import 'package:flutter/material.dart';
import '../helpers/coolors.dart';
import '../helpers/backend.dart';
import 'package:lottie/lottie.dart';

class HighRatedProvidersWidget extends StatelessWidget {
  final List<dynamic> providers;

  const HighRatedProvidersWidget({Key? key, required this.providers})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filter only providers with rating >= 3
    final highRated = providers.where((p) {
      final rating =
          double.tryParse(p['average_rating']?.toString() ?? '0') ?? 0.0;
      return rating >= 3.0;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Section Title (always visible) ---
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'High Related Providers',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: kTextPrimary,
              ),
            ),
            SizedBox(height: 4),
            Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                color: kSecondaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),

        // --- Body ---
        if (highRated.isEmpty)
          Center(
            child: Column(
              children: [
                SizedBox(
                  height: 150,
                  child: Lottie.asset('assets/lottie/AI Searching.json'),
                ),
                const SizedBox(height: 8),
                const Text(
                  'No high rated providers found.',
                  style: TextStyle(color: kTextHint, fontSize: 16),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: highRated.length,
              itemBuilder: (context, index) {
                final provider = highRated[index];

                String? imageUrl;

                if (provider['profile_image'] != null &&
                    provider['profile_image'] != '') {
                  imageUrl = provider['profile_image'].startsWith('http')
                      ? provider['profile_image']
                      : '${Backend.baseUrl}/${provider['profile_image']}';
                } else if (provider['provider_image'] != null &&
                    provider['provider_image'] != '') {
                  imageUrl = provider['provider_image'].startsWith('http')
                      ? provider['provider_image']
                      : '${Backend.baseUrl}/${provider['provider_image']}';
                }

                final name =
                    provider['name'] ?? provider['provider_name'] ?? 'Unknown';
                final rating =
                    double.tryParse(
                      provider['average_rating']?.toString() ?? '0',
                    ) ??
                    0.0;

                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kCardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: heaidng.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // IMAGE
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 70,
                          width: 100,
                          color: kDividerColor,
                          child: imageUrl != null
                              ? Image.network(imageUrl, fit: BoxFit.cover)
                              : const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: kTextHint,
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // NAME
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: kTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // RATING
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: kWarningColor,
                            size: 16,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              color: kTextPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 20),
      ],
    );
  }
}

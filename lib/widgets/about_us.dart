// import 'package:flutter/material.dart';
// import '../helpers/coolors.dart';

// class AboutUsPage extends StatelessWidget {
//   const AboutUsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kBackgroundColor,
//       appBar: AppBar(
//         backgroundColor: kBackgroundColor,
//         elevation: 0,
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new_rounded,
//               color: kTextPrimary, size: 20),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           "Our Story",
//           style: TextStyle(
//               color: kTextPrimary,
//               fontWeight: FontWeight.bold,
//               letterSpacing: -0.5),
//         ),
//       ),
//       body: SingleChildScrollView(
//         physics: const BouncingScrollPhysics(),
//         child: Column(
//           children: [
//             _buildHeroSection(),
//             Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildSectionTitle("The Vision"),
//                   _buildBodyText(
//                     "This isn't just a booking app; it's a bridge between excellence and convenience. "
//                     "Our mission is to connect users with trusted service providers while ensuring transparency, "
//                     "reliability, and peace of mind for everyone involved.",
//                   ),

//                   const SizedBox(height: 30),

//                   _buildSectionTitle("How It Works"),
//                   const SizedBox(height: 15),
//                   _buildStep(Icons.search_rounded, "Discover",
//                       "Explore verified service providers near you."),
//                   _buildStep(Icons.event_available_rounded, "Book",
//                       "Choose a time slot that fits your schedule."),
//                   _buildStep(Icons.task_alt_rounded, "Relax",
//                       "Get the job done professionally and on time."),

//                   const SizedBox(height: 30),

//                   /// 🔐 APP RULES
//                   _buildSectionTitle("App Rules & Guidelines"),
//                   const SizedBox(height: 10),
//                   _buildRule(
//                       "Honest Profiles",
//                       "Users and service providers must provide accurate and truthful information."),
//                   _buildRule(
//                       "Respect & Professionalism",
//                       "All communication must remain respectful. Abuse or harassment is not tolerated."),
//                   _buildRule(
//                       "Booking Commitment",
//                       "Once a booking is confirmed, both parties are expected to honor it."),
//                   _buildRule(
//                       "Payments & Charges",
//                       "Any charges agreed upon must be transparent. Hidden fees are strictly prohibited."),
//                   _buildRule(
//                       "Safety First",
//                       "Our platform may suspend accounts that violate safety or trust policies."),

//                   const SizedBox(height: 30),

//                   /// 👤 USER RULES
//                   _buildSectionTitle("For Users"),
//                   const SizedBox(height: 10),
//                   _buildBullet(
//                       "Book services responsibly and provide correct location details."),
//                   _buildBullet(
//                       "Avoid last-minute cancellations without valid reasons."),
//                   _buildBullet(
//                       "Treat service providers with respect and fairness."),

//                   const SizedBox(height: 30),

//                   /// 🧑‍🔧 PROVIDER RULES
//                   _buildSectionTitle("For Service Providers"),
//                   const SizedBox(height: 10),
//                   _buildBullet(
//                       "Deliver services professionally and on time."),
//                   _buildBullet(
//                       "Maintain honest pricing and service descriptions."),
//                   _buildBullet(
//                       "Any misconduct may result in account suspension."),

//                   const SizedBox(height: 35),

//                   _buildDeveloperCard(),

//                   const SizedBox(height: 40),

//                   Center(
//                     child: Text(
//                       "Version 1.0.2 • Built with Trust & Care ❤️",
//                       style: TextStyle(color: kTextHint, fontSize: 12),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ================= UI COMPONENTS =================

//   Widget _buildHeroSection() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.85)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(40),
//           bottomRight: Radius.circular(40),
//         ),
//       ),
//       child: const Column(
//         children: [
//           CircleAvatar(
//             radius: 50,
//             backgroundColor: Colors.white24,
//             child: Icon(Icons.auto_awesome_rounded,
//                 size: 50, color: Colors.white),
//           ),
//           SizedBox(height: 20),
//           Text(
//             "Service With Integrity",
//             style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 26,
//                 fontWeight: FontWeight.w900),
//           ),
//           Text(
//             "Reliable Help, Anytime.",
//             style: TextStyle(color: Colors.white70, fontSize: 16),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Text(
//       title,
//       style: const TextStyle(
//         color: kTextPrimary,
//         fontSize: 22,
//         fontWeight: FontWeight.bold,
//       ),
//     );
//   }

//   Widget _buildBodyText(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 10),
//       child: Text(
//         text,
//         style: const TextStyle(
//             color: kTextSecondary, fontSize: 15, height: 1.6),
//       ),
//     );
//   }

//   Widget _buildStep(IconData icon, String title, String desc) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 15),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: kPrimaryColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(icon, color: kPrimaryColor),
//           ),
//           const SizedBox(width: 15),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(title,
//                     style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: kTextPrimary)),
//                 Text(desc,
//                     style: const TextStyle(
//                         color: kTextSecondary, fontSize: 13)),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildRule(String title, String desc) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text("• $title",
//               style: const TextStyle(
//                   fontWeight: FontWeight.bold, color: kTextPrimary)),
//           const SizedBox(height: 4),
//           Text(desc,
//               style: const TextStyle(
//                   color: kTextSecondary, fontSize: 13)),
//         ],
//       ),
//     );
//   }

//   Widget _buildBullet(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Text(
//         "• $text",
//         style:
//             const TextStyle(color: kTextSecondary, fontSize: 14),
//       ),
//     );
//   }

//   Widget _buildDeveloperCard() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: kCardColor,
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: kDividerColor.withOpacity(0.5)),
//       ),
//       child: Column(
//         children: [
//           _buildSectionTitle("Meet the Creator"),
//           const SizedBox(height: 15),
//           const CircleAvatar(
//             radius: 40,
//             backgroundColor: kSecondaryColor,
//             child: Icon(Icons.person_rounded,
//                 size: 40, color: Colors.white),
//           ),
//           const SizedBox(height: 10),
//           const Text(
//             "Built by a Passionate Developer",
//             style:
//                 TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//           ),
//           const Text(
//             "Focused on building reliable, human-centered digital solutions that truly help people.",
//             textAlign: TextAlign.center,
//             style: TextStyle(
//                 color: kTextSecondary,
//                 fontSize: 13,
//                 height: 1.5),
//           ),
//         ],
//       ),
//     );
//   }
// }


















import 'package:flutter/material.dart';
import '../helpers/coolors.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 🔹 Sleek Modern AppBar
          SliverAppBar(
            expandedHeight: 220.0,
            floating: false,
            pinned: true,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                "Our Story",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  letterSpacing: -0.5,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Opacity(
                    opacity: 0.2,
                    child: Icon(Icons.auto_awesome_rounded, size: 150, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Vision Section
                  _buildHeader("The Vision"),
                  const SizedBox(height: 12),
                  Text(
                    "Connect Pro is a bridge between excellence and convenience. We empower local talent by connecting them with users who value quality, transparency, and reliability.",
                    style: TextStyle(color: kTextSecondary, fontSize: 16, height: 1.6, letterSpacing: 0.2),
                  ),

                  const SizedBox(height: 40),

                  // 🔹 Bento-Style Process Section
                  _buildHeader("How It Works"),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildBentoCard(Icons.search_rounded, "Discover", "Verified pros."),
                      const SizedBox(width: 12),
                      _buildBentoCard(Icons.event_available_rounded, "Book", "Secure slots."),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildBentoCard(Icons.task_alt_rounded, "Relax", "Professional results delivered.", fullWidth: true),

                  const SizedBox(height: 40),

                  // 🔹 Community Guidelines
                  _buildHeader("Trust & Safety"),
                  const SizedBox(height: 16),
                  _buildPolicyItem("Honest Profiles", "All users must provide truthful information for community safety."),
                  _buildPolicyItem("Zero Tolerance", "Professionalism is mandatory. Harassment leads to immediate bans."),
                  _buildPolicyItem("Transparent Pricing", "No hidden fees. What you see is what you pay."),

                  const SizedBox(height: 50),

                  // 🔹 Professional Creator Card
                  _buildCreatorCard(),

                  const SizedBox(height: 40),

                  Center(
                    child: Column(
                      children: [
                        Text("Version 1.0.2", style: TextStyle(color: kTextHint, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text("Connect Pro • Launch Edition", style: TextStyle(color: kTextHint, fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI BUILDERS ---

  Widget _buildHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5)),
        const SizedBox(height: 4),
        Container(width: 40, height: 3, decoration: BoxDecoration(color: kSecondaryColor, borderRadius: BorderRadius.circular(2))),
      ],
    );
  }

  Widget _buildBentoCard(IconData icon, String title, String sub, {bool fullWidth = false}) {
    return Expanded(
      flex: fullWidth ? 0 : 1,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kDividerColor.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: kPrimaryColor, size: 28),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kTextPrimary)),
            const SizedBox(height: 4),
            Text(sub, style: const TextStyle(color: kTextSecondary, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.verified_user_rounded, color: kSuccessColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: kTextPrimary, fontSize: 15)),
                Text(desc, style: const TextStyle(color: kTextSecondary, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kTextPrimary, // Dark professional background
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(color: kSecondaryColor, shape: BoxShape.circle),
            child: const CircleAvatar(
              radius: 45,
              backgroundImage: AssetImage('assets/images/sariya.jpeg'),
            ),
          ),
          const SizedBox(height: 16),
          const Text("Sariya", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
          const Text("Lead Product Developer", style: TextStyle(color: kSecondaryColor, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          const Text(
            "Focused on building human-centered digital solutions that prioritize safety, speed, and user satisfaction.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}
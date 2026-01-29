import 'package:flutter/material.dart';
import '../helpers/coolors.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: kTextPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Our Story",
          style: TextStyle(
              color: kTextPrimary,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeroSection(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("The Vision"),
                  _buildBodyText(
                    "This isn't just a booking app; it's a bridge between excellence and convenience. "
                    "Our mission is to connect users with trusted service providers while ensuring transparency, "
                    "reliability, and peace of mind for everyone involved.",
                  ),

                  const SizedBox(height: 30),

                  _buildSectionTitle("How It Works"),
                  const SizedBox(height: 15),
                  _buildStep(Icons.search_rounded, "Discover",
                      "Explore verified service providers near you."),
                  _buildStep(Icons.event_available_rounded, "Book",
                      "Choose a time slot that fits your schedule."),
                  _buildStep(Icons.task_alt_rounded, "Relax",
                      "Get the job done professionally and on time."),

                  const SizedBox(height: 30),

                  /// 🔐 APP RULES
                  _buildSectionTitle("App Rules & Guidelines"),
                  const SizedBox(height: 10),
                  _buildRule(
                      "Honest Profiles",
                      "Users and service providers must provide accurate and truthful information."),
                  _buildRule(
                      "Respect & Professionalism",
                      "All communication must remain respectful. Abuse or harassment is not tolerated."),
                  _buildRule(
                      "Booking Commitment",
                      "Once a booking is confirmed, both parties are expected to honor it."),
                  _buildRule(
                      "Payments & Charges",
                      "Any charges agreed upon must be transparent. Hidden fees are strictly prohibited."),
                  _buildRule(
                      "Safety First",
                      "Our platform may suspend accounts that violate safety or trust policies."),

                  const SizedBox(height: 30),

                  /// 👤 USER RULES
                  _buildSectionTitle("For Users"),
                  const SizedBox(height: 10),
                  _buildBullet(
                      "Book services responsibly and provide correct location details."),
                  _buildBullet(
                      "Avoid last-minute cancellations without valid reasons."),
                  _buildBullet(
                      "Treat service providers with respect and fairness."),

                  const SizedBox(height: 30),

                  /// 🧑‍🔧 PROVIDER RULES
                  _buildSectionTitle("For Service Providers"),
                  const SizedBox(height: 10),
                  _buildBullet(
                      "Deliver services professionally and on time."),
                  _buildBullet(
                      "Maintain honest pricing and service descriptions."),
                  _buildBullet(
                      "Any misconduct may result in account suspension."),

                  const SizedBox(height: 35),

                  _buildDeveloperCard(),

                  const SizedBox(height: 40),

                  Center(
                    child: Text(
                      "Version 1.0.2 • Built with Trust & Care ❤️",
                      style: TextStyle(color: kTextHint, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= UI COMPONENTS =================

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: const Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white24,
            child: Icon(Icons.auto_awesome_rounded,
                size: 50, color: Colors.white),
          ),
          SizedBox(height: 20),
          Text(
            "Service With Integrity",
            style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900),
          ),
          Text(
            "Reliable Help, Anytime.",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: kTextPrimary,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildBodyText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        text,
        style: const TextStyle(
            color: kTextSecondary, fontSize: 15, height: 1.6),
      ),
    );
  }

  Widget _buildStep(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: kPrimaryColor),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kTextPrimary)),
                Text(desc,
                    style: const TextStyle(
                        color: kTextSecondary, fontSize: 13)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRule(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• $title",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: kTextPrimary)),
          const SizedBox(height: 4),
          Text(desc,
              style: const TextStyle(
                  color: kTextSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        "• $text",
        style:
            const TextStyle(color: kTextSecondary, fontSize: 14),
      ),
    );
  }

  Widget _buildDeveloperCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kDividerColor.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          _buildSectionTitle("Meet the Creator"),
          const SizedBox(height: 15),
          const CircleAvatar(
            radius: 40,
            backgroundColor: kSecondaryColor,
            child: Icon(Icons.person_rounded,
                size: 40, color: Colors.white),
          ),
          const SizedBox(height: 10),
          const Text(
            "Built by a Passionate Developer",
            style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Text(
            "Focused on building reliable, human-centered digital solutions that truly help people.",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: kTextSecondary,
                fontSize: 13,
                height: 1.5),
          ),
        ],
      ),
    );
  }
}

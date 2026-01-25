import 'package:flutter/material.dart';
import 'dart:ui';
import '../helpers/coolors.dart';
class MenuItemModel {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  MenuItemModel({required this.title, required this.icon, required this.onTap});
}

class SideMenu extends StatelessWidget {
  final String logoPath;
  final Color primaryColor;
  final Color secondaryColor;
  final Color highlightColor;
  final String selectedMenu;
  final Function(String) onMenuSelected;

  const SideMenu({
    Key? key,
    required this.logoPath,
    required this.primaryColor,
    required this.secondaryColor,
    required this.highlightColor,
    required this.selectedMenu,
    required this.onMenuSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      MenuItemModel(
          title: 'Dashboard',
          icon: Icons.info_outline,
          onTap: () => onMenuSelected('Dashboard')),
      MenuItemModel(
          title: 'About Us',
          icon: Icons.info_outline,
          onTap: () => onMenuSelected('About Us')),
      MenuItemModel(
          title: 'Contact Us',
          icon: Icons.contact_phone_outlined,
          onTap: () => onMenuSelected('Contact Us')),
      MenuItemModel(
          title: 'Settings',
          icon: Icons.settings_outlined,
          onTap: () => onMenuSelected('Settings')),
      MenuItemModel(
          title: 'Exit',
          icon: Icons.logout,
          onTap: () => onMenuSelected('Exit')),
    ];

   return Drawer(
  width: MediaQuery.of(context).size.width * 0.62, // 👈 slim & premium
  backgroundColor: Colors.transparent,
  child: SafeArea(
    child: ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(28),
        bottomRight: Radius.circular(28),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                secondaryColor.withOpacity(0.85),
                secondaryColor.withOpacity(0.65),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 30,
                offset: const Offset(10, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              // 🔹 Glassy Header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 26),
                child: Column(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.35),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          logoPath,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Connect Pro',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your service simplified',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              Divider(
                color: Colors.white.withOpacity(0.2),
                thickness: 1,
              ),

              // 🔹 Menu items
              Expanded(
                child: ListView.builder(
                  itemCount: menuItems.length,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    final isSelected = item.title == selectedMenu;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryColor.withOpacity(0.25)
                              : Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: ListTile(
                          leading: Icon(
                            item.icon,
                            color: isSelected
                                ? primaryColor
                                : kSecondaryColor,
                          ),
                          title: Text(
                            item.title,
                            style: TextStyle(
                              color: isSelected
                                  ? primaryColor
                                  : kSecondaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onTap: item.onTap,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 🔹 Footer
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text(
                  "Made with ❤️ by Sariya",
                  style: TextStyle(
                    color: kSecondaryColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);

  }
}

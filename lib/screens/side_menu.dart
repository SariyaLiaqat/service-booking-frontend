import 'package:flutter/material.dart';

class MenuItemModel {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  MenuItemModel({required this.title, required this.icon, required this.onTap});
}

class SideMenu extends StatelessWidget {
  final String logoPath; // Asset path for logo
  final Color primaryColor; // Main color (selected, icons)
  final Color secondaryColor; // Background color
  final Color highlightColor; // Text/icons color
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
          title: 'About Us',
          icon: Icons.info_outline,
          onTap: () => onMenuSelected('About Us')),
      MenuItemModel(
          title: 'Contact Us',
          icon: Icons.contact_phone_outlined,
          onTap: () => onMenuSelected('Contact Us')),
      MenuItemModel(
          title: 'Need Help',
          icon: Icons.help_outline,
          onTap: () => onMenuSelected('Need Help')),
      MenuItemModel(
          title: 'Settings',
          icon: Icons.settings_outlined,
          onTap: () => onMenuSelected('Settings')),
      MenuItemModel(
          title: 'Logout',
          icon: Icons.logout,
          onTap: () => onMenuSelected('Logout')),
    ];

    return Drawer(
      width: MediaQuery.of(context).size.width *
          0.7, // ✅ 70% of screen width for perfect look
      backgroundColor: secondaryColor,
      child: Column(
        children: [
          // 🔹 Header with centered logo
          DrawerHeader(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            child: Container(
              alignment: Alignment.center,
              color: primaryColor.withOpacity(0.1), // subtle header background
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage(logoPath),
              ),
            ),
          ),

          // 🔹 Menu items
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isSelected = item.title == selectedMenu;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Material(
                    color: isSelected ? primaryColor.withOpacity(0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: ListTile(
                      leading: Icon(item.icon,
                          color: isSelected ? primaryColor : highlightColor),
                      title: Text(
                        item.title,
                        style: TextStyle(
                          color: isSelected ? primaryColor : highlightColor,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                      onTap: item.onTap,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      hoverColor: primaryColor.withOpacity(0.1),
                    ),
                  ),
                );
              },
            ),
          ),

          // 🔹 Footer
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Made With ❤️",
              style: TextStyle(color: highlightColor, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

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
      width: MediaQuery.of(context).size.width * 0.7,
      backgroundColor: secondaryColor,
      child: SafeArea(
        child: Column(
          children: [
            // 🔹 Compact header (less spacing)
           // 🔹 Better centered header
Padding(
  padding: const EdgeInsets.symmetric(vertical: 24),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // 👇 Centered logo
      Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
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
      ),

      const SizedBox(height: 10), // space between logo and title

      // 👇 Text just below logo
      Text(
        'Connect Pro',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: primaryColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        'Your service simplified',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  ),
),


            const Divider(height: 1, color: Colors.white24),

            // 🔹 Menu list (expand to take space)
            Expanded(
              child: ListView.builder(
                itemCount: menuItems.length,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  final isSelected = item.title == selectedMenu;

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Material(
                      color: isSelected
                          ? primaryColor.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                        leading: Icon(item.icon,
                            color: isSelected ? primaryColor : highlightColor),
                        title: Text(
                          item.title,
                          style: TextStyle(
                            color: isSelected ? primaryColor : highlightColor,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
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

            // 🔹 Footer fixed at bottom
            Padding(
              padding: const EdgeInsets.only(bottom: 12, top: 4),
              child: Text(
                "Made With ❤️",
                style: TextStyle(color: highlightColor, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:agrikeep/utils/theme.dart';

class BottomNav extends StatefulWidget {
  final String activeTab;
  final Function(String) onTabChange;

  const BottomNav({
    super.key,
    required this.activeTab,
    required this.onTabChange,
  });

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  final List<BottomNavItem> _tabs = [
    BottomNavItem(
      id: 'home',
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
    ),
    BottomNavItem(
      id: 'recommendations',
      label: 'Recommend',
      icon: Icons.auto_awesome_outlined,
      activeIcon: Icons.auto_awesome,
    ),
    BottomNavItem(
      id: 'records',
      label: 'Records',
      icon: Icons.list_alt_outlined,
      activeIcon: Icons.list_alt,
    ),
    BottomNavItem(
      id: 'profile',
      label: 'Profile',
      icon: Icons.person_outlined,
      activeIcon: Icons.person,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AgriKeepTheme.borderColor,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _tabs.map((tab) {
              final isActive = widget.activeTab == tab.id;
              return _buildNavItem(tab, isActive);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BottomNavItem tab, bool isActive) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onTabChange(tab.id),
          highlightColor: AgriKeepTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isActive ? tab.activeIcon : tab.icon,
                  size: 24,
                  color: isActive
                      ? AgriKeepTheme.primaryColor
                      : AgriKeepTheme.textTertiary,
                ),
                const SizedBox(height: 4),
                Text(
                  tab.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive
                        ? AgriKeepTheme.primaryColor
                        : AgriKeepTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BottomNavItem {
  final String id;
  final String label;
  final IconData icon;
  final IconData activeIcon;

  BottomNavItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}*/

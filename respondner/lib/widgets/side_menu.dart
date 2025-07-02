import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget {
  final String username;
  final bool isAdmin;
  final int selectedIndex;
  final Function(int) onItemSelected; // Callback function

  const SideMenu({
    super.key,
    required this.username,
    required this.isAdmin,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: const Color(0xFFa61c1c),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserProfile(),
          const SizedBox(height: 40),
          _buildNavItem(0, 'Dashboard'),
          _buildNavItem(1, 'Summary'),
          _buildNavItem(2, 'About us'),
          if (isAdmin) _buildNavItem(3, 'Accounts'),
          const Spacer(),
          _buildNavItem(4, 'Sign Out'),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildUserProfile() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 25, backgroundColor: Colors.white,
          child: Icon(Icons.person, size: 30, color: Color(0xFFa61c1c)),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isAdmin ? 'Admin' : 'Responder', style: const TextStyle(color: Colors.white70, fontSize: 14)),
            Text(username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ],
    );
  }

  Widget _buildNavItem(int index, String title) {
    final bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onItemSelected(index), // Use the callback
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFFa61c1c) : Colors.white,
            fontWeight: FontWeight.bold, fontSize: 16,
          ),
        ),
      ),
    );
  }
}
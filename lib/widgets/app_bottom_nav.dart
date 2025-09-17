import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  const AppBottomNav({super.key, required this.currentIndex});

  void _go(BuildContext context, int index) {
    if (index == currentIndex) return;
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
        break;
      case 1:
        Navigator.pushNamedAndRemoveUntil(context, '/explore', (r) => false);
        break;
      case 2:
        Navigator.pushNamedAndRemoveUntil(context, '/trips', (r) => false);
        break;
      case 3:
        Navigator.pushNamedAndRemoveUntil(context, '/profile', (r) => false);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => _go(context, i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF9B59B6),
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home_outlined), activeIcon: const Icon(Icons.home), label: 'nav.home'.tr()),
          BottomNavigationBarItem(icon: const Icon(Icons.explore_outlined), activeIcon: const Icon(Icons.explore), label: 'nav.explore'.tr()),
          BottomNavigationBarItem(icon: const Icon(Icons.calendar_today_outlined), activeIcon: const Icon(Icons.calendar_today), label: 'nav.trips'.tr()),
          BottomNavigationBarItem(icon: const Icon(Icons.person_outline), activeIcon: const Icon(Icons.person), label: 'nav.profile'.tr()),
        ],
      ),
    );
  }
}



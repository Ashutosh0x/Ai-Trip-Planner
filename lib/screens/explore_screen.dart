import 'package:flutter/material.dart';
import '../widgets/app_bottom_nav.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ExploreTile(
            title: 'Trip Preferences',
            subtitle: 'Choose interests, pace, and travel style',
            icon: Icons.tune,
            onTap: () => Navigator.pushNamed(context, '/trip-preferences'),
          ),
          const SizedBox(height: 12),
          _ExploreTile(
            title: 'Budget Preferences',
            subtitle: 'Set your budget range and currency',
            icon: Icons.attach_money,
            onTap: () => Navigator.pushNamed(context, '/budget-preferences'),
          ),
          const SizedBox(height: 12),
          _ExploreTile(
            title: 'Start Riding (Map)',
            subtitle: 'Open the live map and start your journey',
            icon: Icons.map,
            onTap: () => Navigator.pushNamed(context, '/start-riding'),
          ),
          const SizedBox(height: 12),
          _ExploreTile(
            title: 'Payments',
            subtitle: 'Checkout and payment confirmation',
            icon: Icons.payment,
            onTap: () => Navigator.pushNamed(context, '/confirm-pay'),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}

class _ExploreTile extends StatelessWidget {
  const _ExploreTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF4ECDC4)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

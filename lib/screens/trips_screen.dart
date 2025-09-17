import 'package:flutter/material.dart';
import '../widgets/app_bottom_nav.dart';

class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Plan new trip',
            onPressed: () => Navigator.pushNamed(context, '/trip-planning'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _TripCard(
            title: 'Upcoming: Paris Weekend',
            subtitle: 'Mar 14 - Mar 17 • Budget: €600',
            onOpen: () => Navigator.pushNamed(context, '/trip-preferences'),
          ),
          const SizedBox(height: 12),
          _TripCard(
            title: 'Saved: Tokyo Cherry Blossoms',
            subtitle: 'Apr • Draft itinerary saved',
            onOpen: () => Navigator.pushNamed(context, '/saved-trips'),
          ),
          const SizedBox(height: 12),
          _TripCard(
            title: 'Recent: Goa Getaway',
            subtitle: 'Completed • View memories',
            onOpen: () => Navigator.pushNamed(context, '/ai-picks'),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({
    required this.title,
    required this.subtitle,
    required this.onOpen,
  });

  final String title;
  final String subtitle;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF9B59B6).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.flight_takeoff,
                  color: Color(0xFF9B59B6),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

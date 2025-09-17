import 'package:flutter/material.dart';

class TripPlanningScreen extends StatelessWidget {
  const TripPlanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Your Trip'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Trip Planning Screen - Coming Soon!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

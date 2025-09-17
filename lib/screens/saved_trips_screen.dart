import 'package:flutter/material.dart';

class SavedTripsScreen extends StatelessWidget {
  const SavedTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Trips'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Saved Trips Screen - Coming Soon!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

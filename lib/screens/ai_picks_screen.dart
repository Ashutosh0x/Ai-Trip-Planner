import 'package:flutter/material.dart';

class AIPicksScreen extends StatelessWidget {
  const AIPicksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Picks'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'AI Picks Screen - Coming Soon!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

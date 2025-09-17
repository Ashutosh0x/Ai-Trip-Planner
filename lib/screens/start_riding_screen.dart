import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';

class StartRidingScreen extends StatefulWidget {
  const StartRidingScreen({super.key});

  @override
  State<StartRidingScreen> createState() => _StartRidingScreenState();
}

class _StartRidingScreenState extends State<StartRidingScreen> {
  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDarkMode;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark ? [
              const Color(0xFF1A1A2E), // Dark blue
              const Color(0xFF16213E), // Darker blue
            ] : [
              const Color(0xFF8EC5FC), // Light teal
              const Color(0xFFE0C3FC), // Light purple
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Back button and title
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Start Riding',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Directions for your AI planned trip',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 48), // Balance the back button
                      ],
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Map Interface
                        Container(
                          height: 300,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Stack(
                            children: [
                              // Map placeholder with route
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.green[100]!,
                                      Colors.blue[50]!,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: CustomPaint(
                                  painter: RoutePainter(),
                                  size: const Size(double.infinity, 300),
                                ),
                              ),
                              
                              // Current Location Marker
                              Positioned(
                                left: 20,
                                bottom: 20,
                                child: _buildMapMarker(
                                  Icons.location_on,
                                  'Current Location',
                                  Colors.orange,
                                ),
                              ),
                              
                              // AI Recommended Destination Marker
                              Positioned(
                                right: 20,
                                top: 20,
                                child: _buildMapMarker(
                                  Icons.place,
                                  'AI Recommended Destination',
                                  Colors.blue,
                                ),
                              ),
                              
                              // Map Icons (Points of Interest)
                              Positioned(
                                left: 80,
                                top: 100,
                                child: _buildMapIcon(Icons.camera_alt, Colors.white),
                              ),
                              Positioned(
                                left: 120,
                                top: 80,
                                child: _buildMapIcon(Icons.restaurant, Colors.white),
                              ),
                              Positioned(
                                right: 80,
                                top: 120,
                                child: _buildMapIcon(Icons.account_balance, Colors.white),
                              ),
                              Positioned(
                                left: 150,
                                top: 150,
                                child: _buildMapIcon(Icons.hotel, Colors.white),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Suggestion Cards
                        const Text(
                          'Suggested Stops',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        SizedBox(
                          height: 120,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _buildSuggestionCard(
                                'Scenic Viewpoint',
                                'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=300&h=200&fit=crop',
                                Icons.landscape,
                              ),
                              const SizedBox(width: 12),
                              _buildSuggestionCard(
                                'Local Eats',
                                'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=300&h=200&fit=crop',
                                Icons.restaurant,
                              ),
                              const SizedBox(width: 12),
                              _buildSuggestionCard(
                                'Local Eats',
                                'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=300&h=200&fit=crop',
                                Icons.fastfood,
                              ),
                              const SizedBox(width: 12),
                              _buildSuggestionCard(
                                'Historical Stop',
                                'https://images.unsplash.com/photo-1539650116574-75c0c6d73c6e?w=300&h=200&fit=crop',
                                Icons.account_balance,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Navigate Trip Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey[300]!),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                // Navigate to Confirm & Pay screen
                                Navigator.pushNamed(context, '/confirm-pay');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Navigate Trip',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // View Full Itinerary Link
                        Center(
                          child: TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Opening full itinerary...'),
                                  backgroundColor: Color(0xFF4ECDC4),
                                ),
                              );
                            },
                            child: const Text(
                              'View Full Itinerary',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF4ECDC4),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapMarker(IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapIcon(IconData icon, Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[300]!, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.grey[700],
        size: 16,
      ),
    );
  }

  Widget _buildSuggestionCard(String title, String imageUrl, IconData fallbackIcon) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.blue[100]!,
                    Colors.purple[100]!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      fallbackIcon,
                      color: Colors.grey[600],
                      size: 30,
                    );
                  },
                ),
              ),
            ),
          ),
          // Title
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for drawing the route line
class RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // Draw a curved route from bottom-left to top-right
    path.moveTo(30, size.height - 50);
    path.quadraticBezierTo(
      size.width * 0.3, size.height * 0.6,
      size.width * 0.5, size.height * 0.4,
    );
    path.quadraticBezierTo(
      size.width * 0.7, size.height * 0.2,
      size.width - 30, 30,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

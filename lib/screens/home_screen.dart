import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../widgets/profile_picture_widget.dart';
import '../services/theme_service.dart';
import '../services/firebase_service.dart';
import '../widgets/app_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  bool _isFabExpanded = false;
  bool _showWanderAI = false;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _lastWords = '';
  final FlutterTts _tts = FlutterTts();

  // Sample popular destinations data
  final List<Map<String, dynamic>> _popularDestinations = [
    {
      'name': 'Marrakech, Morocco',
      'image': 'https://images.unsplash.com/photo-1539650116574-75c0c6d73c6e?w=300&h=200&fit=crop',
      'rating': 4.5,
      'reviews': '1.2k',
    },
    {
      'name': 'Patagonia, Argentina',
      'image': 'https://images.unsplash.com/photo-1519904981063-b0cf448d479e?w=300&h=200&fit=crop',
      'rating': 4.8,
      'reviews': '856',
    },
    {
      'name': 'Tokyo, Japan',
      'image': 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=300&h=200&fit=crop',
      'rating': 4.7,
      'reviews': '2.1k',
    },
    {
      'name': 'Santorini, Greece',
      'image': 'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=300&h=200&fit=crop',
      'rating': 4.6,
      'reviews': '1.8k',
    },
    {
      'name': 'Bali, Indonesia',
      'image': 'https://images.unsplash.com/photo-1537953773345-d172ccf13cf1?w=300&h=200&fit=crop',
      'rating': 4.9,
      'reviews': '3.2k',
    },
  ];

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDarkMode;
    
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _buildExpandableFab(),
      body: Stack(
        children: [
          Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark ? [
              const Color(0xFF1A1A2E), // Dark blue
              const Color(0xFF16213E), // Darker blue
            ] : [
              const Color(0xFF4ECDC4), // Light teal
              const Color(0xFF9B59B6), // Light purple
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeader(),
                
                const SizedBox(height: 30),
                
                // Greeting Text
                const Text(
                  'Where will you explore next?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Search Input
                _buildSearchInput(),
                
                const SizedBox(height: 30),
                
                // Action Buttons
                _buildActionButtons(),
                
                const SizedBox(height: 30),
                
                // Popular Destinations Section
                _buildPopularDestinations(),
                
                const SizedBox(height: 100), // Space for bottom navigation
              ],
            ),
          ),
        ),
      ),
          if (_showWanderAI) _buildWanderAIOverlay(context, isDark),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Profile Picture
        ProfilePictureWidget(
          size: 50,
          showEditButton: false,
          imageUrl: FirebaseService.currentUser?.photoURL,
          userId: FirebaseService.currentUser?.uid,
          onImageChanged: (imageUrl) {},
        ),
        
        const SizedBox(width: 15),
        
        // App Name
        const Text(
          'Alventura',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
        const Spacer(),
        
        // Notification Icon
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              // Handle notifications
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tell me about your dream trip...',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 16,
          ),
          prefixIcon: GestureDetector(
            onTap: _toggleListen,
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF9B59B6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _isListening ? Icons.mic_none : Icons.mic,
                color: const Color(0xFF9B59B6),
                size: 20,
              ),
            ),
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4ECDC4).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.psychology,
              color: Color(0xFF4ECDC4),
              size: 20,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        onSubmitted: (value) {
          // Handle search
          _handleSearch(value);
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Plan a New Journey Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              // Navigate to trip planning
              Navigator.pushNamed(context, '/trip-planning');
            },
            icon: const Icon(
              Icons.explore,
              color: Colors.white,
            ),
            label: const Text(
              'Plan a New Journey',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF9B59B6),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // My Saved Trips and Discover AI Picks Buttons
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to saved trips
                    Navigator.pushNamed(context, '/saved-trips');
                  },
                  icon: const Icon(
                    Icons.bookmark_border,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'My Saved Trips',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF9B59B6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to AI picks
                    Navigator.pushNamed(context, '/ai-picks');
                  },
                  icon: const Icon(
                    Icons.lightbulb_outline,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Discover AI Picks',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF9B59B6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPopularDestinations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular Destinations',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
        const SizedBox(height: 16),
        
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _popularDestinations.length,
            itemBuilder: (context, index) {
              final destination = _popularDestinations[index];
              return _buildDestinationCard(destination);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExpandableFab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: !_isFabExpanded
              ? const SizedBox.shrink()
              : Column(
                  key: const ValueKey('expanded'),
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _FabActionChip(
                      label: 'Plan',
                      icon: Icons.add,
                      color: const Color(0xFFB69BE0),
                      onTap: () {
                        Navigator.pushNamed(context, '/trip-planning');
                        setState(() {
                          _isFabExpanded = false;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _FabActionChip(
                      label: 'New Event',
                      icon: Icons.event,
                      color: const Color(0xFFD1C2F3),
                      onTap: () {
                        Navigator.pushNamed(context, '/new-event');
                        setState(() {
                          _isFabExpanded = false;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
        ),
        FloatingActionButton(
          backgroundColor: const Color(0xFF6A3CBC),
          onPressed: () {
            setState(() {
              _isFabExpanded = !_isFabExpanded;
            });
          },
          child: Icon(_isFabExpanded ? Icons.close : Icons.add, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildWanderAIOverlay(BuildContext context, bool isDark) {
    return Align(
      alignment: Alignment.centerRight,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        width: MediaQuery.of(context).size.width * 0.86,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111827) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(-4, 0),
            ),
          ],
        ),
        child: _WanderAIChat(
          onClose: () {
            setState(() {
              _showWanderAI = false;
            });
          },
        ),
      ),
    );
  }

  Widget _buildDestinationCard(Map<String, dynamic> destination) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Destination Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: Container(
              height: 120,
              width: double.infinity,
              child: Image.network(
                destination['image'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Destination Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    // Star Rating
                    ...List.generate(5, (index) {
                      return Icon(
                        index < destination['rating'].floor()
                            ? Icons.star
                            : Icons.star_border,
                        size: 14,
                        color: Colors.amber,
                      );
                    }),
                    
                    const SizedBox(width: 4),
                    
                    Text(
                      '${destination['reviews']}+',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() { return const SizedBox.shrink(); }

  void _handleSearch(String query) {
    if (query.isNotEmpty) {
      // Navigate to search results or trip planning with the query
      Navigator.pushNamed(context, '/search', arguments: query);
    }
  }

  Future<void> _toggleListen() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    final bool available = await _speech.initialize(
      onStatus: (status) {
        if (status.contains('notListening')) {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        setState(() => _isListening = false);
      },
    );
    if (!available) {
      return;
    }
    setState(() => _isListening = true);
    _speech.listen(
      listenMode: stt.ListenMode.dictation,
      onResult: (result) {
        setState(() {
          _lastWords = result.recognizedWords;
          _searchController.text = _lastWords;
          _searchController.selection = TextSelection.fromPosition(
            TextPosition(offset: _searchController.text.length),
          );
        });
        if (result.finalResult && _lastWords.trim().isNotEmpty) {
          _speech.stop();
          setState(() => _isListening = false);
          _handleSearch(_lastWords.trim());
        }
      },
    );
  }
}

class _FabActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FabActionChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.4),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: const Color(0xFF512DA8)),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF3D2A7A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WanderAIChat extends StatefulWidget {
  final VoidCallback onClose;

  const _WanderAIChat({required this.onClose});

  @override
  State<_WanderAIChat> createState() => _WanderAIChatState();
}

class _WanderAIChatState extends State<_WanderAIChat> {
  final TextEditingController _messageController = TextEditingController();
  final List<String> _messages = <String>[
    'Hi! I\'m WanderAI. Ask me to plan your next trip.'
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF6A3CBC),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white),
              const SizedBox(width: 8),
              const Text(
                'WanderAI',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.close, color: Colors.white.withOpacity(0.7)),
                onPressed: widget.onClose,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final text = _messages[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  text,
                  style: const TextStyle(color: Color(0xFF3D2A7A)),
                ),
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your travel question... ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF6A3CBC),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6A3CBC).withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _send,
                    icon: const Icon(Icons.send, color: Colors.white),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _send() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(text);
      _messageController.clear();
    });
  }
}

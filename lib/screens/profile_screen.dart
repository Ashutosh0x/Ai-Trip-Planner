import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../widgets/app_bottom_nav.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = '';
  String _userEmail = '';
  String _userCountry = '';
  String _userBio = '';
  String? _profileImageUrl;

  int totalTrips = 0;
  int savedTrips = 0;
  int countriesVisited = 0;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseService.currentUser;
    if (user == null) {
      setState(() {
        _loading = false;
      });
      return;
    }
    try {
      final data = await AuthService.getUserProfile(user.uid);
      setState(() {
        _userName = (data?['fullName'] as String?)?.trim().isNotEmpty == true
            ? data!['fullName'] as String
            : (user.displayName ?? '');
        _userEmail = user.email ?? '';
        _profileImageUrl = (data?['profileImageUrl'] as String?) ?? user.photoURL;
        _userCountry = (data?['country'] as String?) ?? (data?['onboardingPreferences']?['country'] as String?) ?? '';
        _userBio = (data?['onboardingPreferences']?['dreamTrip'] as String?) ?? '';
        // Counters could come from other collections; keep defaults if absent
        totalTrips = (data?['stats']?['totalTrips'] as int?) ?? totalTrips;
        savedTrips = (data?['stats']?['savedTrips'] as int?) ?? savedTrips;
        countriesVisited = (data?['stats']?['countriesVisited'] as int?) ?? countriesVisited;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDarkMode;
    
    return Scaffold(
      body: Stack(
        children: [
          if (_loading)
            const Center(child: CircularProgressIndicator()),
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&h=1200&fit=crop'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Translucent Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark ? [
                  const Color(0xFF1A1A2E).withOpacity(0.85), // Dark blue
                  const Color(0xFF16213E).withOpacity(0.85), // Darker blue
                ] : [
                  const Color(0xFF8EC5FC).withOpacity(0.85), // Light blue
                  const Color(0xFFE0C3FC).withOpacity(0.85), // Light purple
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
              children: [
                // Header
                _buildHeader(),
                
                // Profile Stats
                _buildProfileStats(),
                
                // Profile Information
                _buildProfileInfo(),
                
                // Menu Options
                _buildMenuOptions(),
                
                // Trip History
                _buildTripHistory(),
                
                // Settings
                _buildSettings(),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    ),
    bottomNavigationBar: const AppBottomNav(currentIndex: 3),
  );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              Text(
                'Profile',
                style: GoogleFonts.dosis(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.black87),
                onPressed: () {
                  _showEditProfileDialog();
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Profile Picture and Basic Info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Profile Picture
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF4ECDC4),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4ECDC4).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                        ? Image.network(
                            _profileImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFF4ECDC4),
                                child: const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: const Color(0xFF4ECDC4),
                            child: const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Name
                Text(
                  _userName.isNotEmpty ? _userName : 'Traveler',
                  style: GoogleFonts.dosis(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Email
                Text(
                  _userEmail,
                  style: GoogleFonts.dosis(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                
                // Country
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFF4ECDC4), size: 20),
                    const SizedBox(width: 4),
                    Text(
                      _userCountry,
                      style: GoogleFonts.dosis(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Bio
                Text(
                  _userBio,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dosis(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("Total Trips", totalTrips.toString(), Icons.flight_takeoff),
          _buildStatItem("Saved Trips", savedTrips.toString(), Icons.bookmark),
          _buildStatItem("Countries", countriesVisited.toString(), Icons.public),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF4ECDC4).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF4ECDC4),
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.dosis(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.dosis(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
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
          Text(
            'Personal Information',
            style: GoogleFonts.dosis(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.person, 'Full Name', _userName.isNotEmpty ? _userName : 'Traveler'),
          _buildInfoRow(Icons.email, 'Email', _userEmail),
          _buildInfoRow(Icons.location_on, 'Country', _userCountry),
          _buildInfoRow(Icons.calendar_today, 'Member Since', 'January 2024'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4ECDC4), size: 20),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: GoogleFonts.dosis(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.dosis(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOptions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuTile(Icons.favorite, 'My Favorites', () {}),
          _buildMenuTile(Icons.history, 'Trip History', () {}),
          _buildMenuTile(Icons.notifications, 'Notifications', () {}),
          _buildMenuTile(Icons.help, 'Help & Support', () {}),
        ],
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF4ECDC4).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF4ECDC4), size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.dosis(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildTripHistory() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Trips',
                style: GoogleFonts.dosis(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View All',
                  style: GoogleFonts.dosis(
                    fontSize: 14,
                    color: const Color(0xFF4ECDC4),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTripCard('Paris, France', 'March 15-20, 2024', '5 days', Icons.flight),
          _buildTripCard('Tokyo, Japan', 'February 8-15, 2024', '7 days', Icons.flight),
          _buildTripCard('New York, USA', 'January 20-25, 2024', '5 days', Icons.flight),
        ],
      ),
    );
  }

  Widget _buildTripCard(String destination, String date, String duration, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4ECDC4).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF4ECDC4), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination,
                  style: GoogleFonts.dosis(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  date,
                  style: GoogleFonts.dosis(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            duration,
            style: GoogleFonts.dosis(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF4ECDC4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuTile(Icons.credit_card, 'Payment Methods', () {
            Navigator.pushNamed(context, '/saved-payment-methods');
          }),
          _buildMenuTile(Icons.settings, 'Settings', () {
            Navigator.pushNamed(context, '/settings');
          }),
          _buildMenuTile(Icons.privacy_tip, 'Privacy Policy', () {}),
          _buildMenuTile(Icons.description, 'Terms of Service', () {}),
          _buildMenuTile(Icons.logout, 'Sign Out', () {
            _showLogoutDialog();
          }),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    Navigator.pushNamed(context, '/edit-profile');
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Sign Out',
          style: GoogleFonts.dosis(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.dosis(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text(
              'Sign Out',
              style: GoogleFonts.dosis(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

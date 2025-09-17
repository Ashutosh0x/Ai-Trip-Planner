import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';

class BudgetPreferencesScreen extends StatefulWidget {
  const BudgetPreferencesScreen({super.key});

  @override
  State<BudgetPreferencesScreen> createState() => _BudgetPreferencesScreenState();
}

class _BudgetPreferencesScreenState extends State<BudgetPreferencesScreen> {
  // Daily spend slider value (0-100, representing $50-$200+)
  double _dailySpendValue = 50.0;
  
  // Selected budget category
  String _selectedBudgetCategory = 'Economy';
  
  // Flight class selection
  String _selectedFlightClass = 'Hostel/Shared';
  
  // Accommodation toggles
  bool _hotelEnabled = false;
  bool _boutiqueResortEnabled = false;

  String _getDailySpendText() {
    if (_dailySpendValue <= 25) {
      return '\$50 - \$75';
    } else if (_dailySpendValue <= 50) {
      return '\$75 - \$100';
    } else if (_dailySpendValue <= 75) {
      return '\$100 - \$150';
    } else {
      return '\$150 - \$200+';
    }
  }

  void _selectBudgetCategory(String category) {
    setState(() {
      _selectedBudgetCategory = category;
    });
  }

  void _selectFlightClass() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Flight Class'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.flight),
                title: const Text('Economy'),
                onTap: () {
                  setState(() {
                    _selectedFlightClass = 'Economy';
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.flight),
                title: const Text('Business'),
                onTap: () {
                  setState(() {
                    _selectedFlightClass = 'Business';
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.flight),
                title: const Text('First Class'),
                onTap: () {
                  setState(() {
                    _selectedFlightClass = 'First Class';
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.hotel),
                title: const Text('Hostel/Shared'),
                onTap: () {
                  setState(() {
                    _selectedFlightClass = 'Hostel/Shared';
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

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
              const Color(0xFFE0C3FC), // Soft purple
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with logo and app name
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    // App Logo
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.sentiment_very_satisfied,
                        color: Color(0xFF4ECDC4),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // App Name
                    const Text(
                      'Alventura',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    // Notification Icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Screen Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Budget Preferences',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
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
                        // Average Daily Spend Section
                        const Text(
                          'Average Daily Spend',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Slider Container
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    '\$50',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    _getDailySpendText(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF4ECDC4),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Text(
                                    '\$200+',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: const Color(0xFF4ECDC4),
                                  inactiveTrackColor: Colors.grey[300],
                                  thumbColor: Colors.white,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 12,
                                  ),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 20,
                                  ),
                                  overlayColor: const Color(0xFF4ECDC4).withOpacity(0.2),
                                ),
                                child: Slider(
                                  value: _dailySpendValue,
                                  min: 0,
                                  max: 100,
                                  divisions: 100,
                                  onChanged: (value) {
                                    setState(() {
                                      _dailySpendValue = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Budget Category Section
                        const Text(
                          'Budget Category',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Budget Category Buttons
                        Row(
                          children: [
                            Expanded(
                              child: _buildBudgetCategoryButton(
                                'Economy',
                                Icons.luggage,
                                'Budget-friendly travel',
                                _selectedBudgetCategory == 'Economy',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildBudgetCategoryButton(
                                'Standard',
                                Icons.business_center,
                                'Comfortable experience',
                                _selectedBudgetCategory == 'Standard',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildBudgetCategoryButton(
                                'Luxury',
                                Icons.diamond,
                                'Premium amenities',
                                _selectedBudgetCategory == 'Luxury',
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Flight Class Section
                        const Text(
                          'Flight Class',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        GestureDetector(
                          onTap: _selectFlightClass,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.flight,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _selectedFlightClass,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.grey[600],
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Accommodation Type Section
                        const Text(
                          'Accommodation Type',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Hotel Toggle
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                'Hotel',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              Switch(
                                value: _hotelEnabled,
                                onChanged: (value) {
                                  setState(() {
                                    _hotelEnabled = value;
                                  });
                                },
                                activeColor: const Color(0xFF4ECDC4),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Boutique/Resort Toggle
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                'Boutique/Resort',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              Switch(
                                value: _boutiqueResortEnabled,
                                onChanged: (value) {
                                  setState(() {
                                    _boutiqueResortEnabled = value;
                                  });
                                },
                                activeColor: const Color(0xFF4ECDC4),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Save Preferences Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF4ECDC4),
                                  Color(0xFF9B59B6),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4ECDC4).withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                // Navigate to Start Riding screen
                                Navigator.pushNamed(context, '/start-riding');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Save Preferences',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
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
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBudgetCategoryButton(
    String title,
    IconData icon,
    String subtitle,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => _selectBudgetCategory(title),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4ECDC4).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF4ECDC4) : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? const Color(0xFF4ECDC4) : Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF4ECDC4) : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', true),
              _buildNavItem(Icons.bookmark_border, 'Bookmark', false),
              _buildNavItem(Icons.calendar_today, 'Calendar', false),
              _buildNavItem(Icons.person_outline, 'Profile', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF4ECDC4).withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isActive ? Border.all(
              color: const Color(0xFF4ECDC4),
              width: 2,
            ) : null,
          ),
          child: Icon(
            icon,
            color: isActive ? const Color(0xFF4ECDC4) : Colors.grey[600],
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? const Color(0xFF4ECDC4) : Colors.grey[600],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

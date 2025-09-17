import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';

class TripPreferencesScreen extends StatefulWidget {
  const TripPreferencesScreen({super.key});

  @override
  State<TripPreferencesScreen> createState() => _TripPreferencesScreenState();
}

class _TripPreferencesScreenState extends State<TripPreferencesScreen> {
  // Selected trip styles
  final Set<String> _selectedTripStyles = {'Adventure & Exploration', 'Culture & History'};
  
  // Selected travel group
  String _selectedTravelGroup = 'Partner/Couple';
  
  // Travel dates
  DateTime? _departureDate;
  int _duration = 10;

  @override
  void initState() {
    super.initState();
    _departureDate = DateTime(2024, 10, 15); // Default date
  }

  void _toggleTripStyle(String style) {
    setState(() {
      if (_selectedTripStyles.contains(style)) {
        _selectedTripStyles.remove(style);
      } else {
        _selectedTripStyles.add(style);
      }
    });
  }

  void _selectTravelGroup(String group) {
    setState(() {
      _selectedTravelGroup = group;
    });
  }

  Future<void> _selectDepartureDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _departureDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _departureDate) {
      setState(() {
        _departureDate = picked;
      });
    }
  }

  void _selectDuration() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Duration'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(30, (index) {
              final days = index + 1;
              return ListTile(
                title: Text('$days ${days == 1 ? 'Day' : 'Days'}'),
                onTap: () {
                  setState(() {
                    _duration = days;
                  });
                  Navigator.of(context).pop();
                },
              );
            }),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
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
              const Color(0xFF8EC5FC), // Light blue
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
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            'Trip Preferences',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tell us more about ideal adventure.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
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
                        // Trip Style Section
                        const Text(
                          'Trip Style',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Trip Style Grid
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.0,
                          children: [
                            _buildTripStyleCard(
                              'Relaxing & Resorts',
                              Icons.beach_access,
                              _selectedTripStyles.contains('Relaxing & Resorts'),
                            ),
                            _buildTripStyleCard(
                              'Adventure & Exploration',
                              Icons.landscape,
                              _selectedTripStyles.contains('Adventure & Exploration'),
                            ),
                            _buildTripStyleCard(
                              'Culture & History',
                              Icons.account_balance,
                              _selectedTripStyles.contains('Culture & History'),
                            ),
                            _buildTripStyleCard(
                              'Foodie Culinary',
                              Icons.restaurant,
                              _selectedTripStyles.contains('Foodie Culinary'),
                            ),
                            _buildTripStyleCard(
                              'Road Trip & Scenic Drives',
                              Icons.directions_car,
                              _selectedTripStyles.contains('Road Trip & Scenic Drives'),
                            ),
                            _buildTripStyleCard(
                              'Backpacking & Budget',
                              Icons.backpack,
                              _selectedTripStyles.contains('Backpacking & Budget'),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Travel Date Section
                        const Text(
                          'When are you looking to travel?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Departure Date
                        GestureDetector(
                          onTap: _selectDepartureDate,
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
                                  Icons.calendar_today,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Departure Date',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _formatDate(_departureDate!),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Duration
                        GestureDetector(
                          onTap: _selectDuration,
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
                                  Icons.access_time,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Duration',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '$_duration ${_duration == 1 ? 'Day' : 'Days'}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Travel Group Section
                        const Text(
                          'Travel Group',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Travel Group Selector
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildTravelGroupButton('Solo'),
                              ),
                              Expanded(
                                child: _buildTravelGroupButton('Partner/Couple'),
                              ),
                              Expanded(
                                child: _buildTravelGroupButton('Family/Group'),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Continue Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate to Budget Preferences screen
                              Navigator.pushNamed(context, '/budget-preferences');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4ECDC4),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
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

  Widget _buildTripStyleCard(String title, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () => _toggleTripStyle(title),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0C3FC) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF4ECDC4) : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 32,
                    color: isSelected ? const Color(0xFF4ECDC4) : Colors.grey[600],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? const Color(0xFF4ECDC4) : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4ECDC4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTravelGroupButton(String group) {
    final isSelected = _selectedTravelGroup == group;
    return GestureDetector(
      onTap: () => _selectTravelGroup(group),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          group,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? const Color(0xFF4ECDC4) : Colors.black87,
          ),
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
              _buildNavItem(Icons.favorite_border, 'Favorites', false),
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

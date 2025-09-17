import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../services/theme_service.dart';
import '../widgets/profile_picture_widget.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _dreamTripController = TextEditingController();
  String _travelStyle = 'Flexible';
  final Set<String> _activities = <String>{};
  String? _profileUrl;
  bool _isSaving = false;

  final List<String> _activityOptions = const [
    'Hiking', 'Sightseeing', 'Food Tours', 'Culture', 'Relaxing', 'Adventure', 'Nightlife'
  ];

  @override
  void initState() {
    super.initState();
    final User? user = FirebaseService.currentUser;
    _nameController.text = user?.displayName ?? '';
    _emailController.text = user?.email ?? '';
    _profileUrl = user?.photoURL;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _countryController.dispose();
    _dreamTripController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tell us about yourself'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ProfilePictureWidget(
                    imageUrl: _profileUrl,
                    userId: FirebaseService.currentUser?.uid,
                    onImageChanged: (url) {
                      setState(() { _profileUrl = url; });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _nameController,
                        label: 'Name',
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        isDark: isDark,
                        icon: Icons.person,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        readOnly: true,
                        isDark: isDark,
                        icon: Icons.email,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _countryController,
                        label: 'Country/Region',
                        isDark: isDark,
                        icon: Icons.public,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdown(isDark),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _dreamTripController,
                  label: 'Briefly describe your dream trip',
                  isDark: isDark,
                  icon: Icons.description,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                const Text('Preferred Activities:'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _activityOptions.map((a) => FilterChip(
                    label: Text(a),
                    selected: _activities.contains(a),
                    onSelected: (sel) {
                      setState(() {
                        sel ? _activities.add(a) : _activities.remove(a);
                      });
                    },
                  )).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A3CBC),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Let's Get Started!"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(bool isDark) {
    return InputDecorator(
      decoration: _decoration('Travel Style', isDark, icon: Icons.style),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _travelStyle,
          items: const [
            DropdownMenuItem(value: 'Flexible', child: Text('Flexible')),
            DropdownMenuItem(value: 'Budget', child: Text('Budget')),
            DropdownMenuItem(value: 'Luxury', child: Text('Luxury')),
            DropdownMenuItem(value: 'Backpacking', child: Text('Backpacking')),
          ],
          onChanged: (v) => setState(() { if (v != null) _travelStyle = v; }),
        ),
      ),
    );
  }

  InputDecoration _decoration(String label, bool isDark, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: isDark ? Colors.white70 : const Color(0xFF9B59B6)) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool readOnly = false,
    int maxLines = 1,
    String? Function(String?)? validator,
    required bool isDark,
    IconData? icon,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      decoration: _decoration(label, isDark, icon: icon),
      validator: validator,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isSaving = true; });
    try {
      final User? user = FirebaseService.currentUser;
      if (user == null) throw Exception('Not signed in');

      // Update auth profile if needed
      if (user.displayName == null || user.displayName!.isEmpty) {
        await user.updateDisplayName(_nameController.text.trim());
      }
      if (_profileUrl != null && _profileUrl != user.photoURL) {
        await user.updatePhotoURL(_profileUrl);
      }

      // Persist profile + preferences
      await AuthService.saveUserProfile(
        uid: user.uid,
        email: _emailController.text.trim(),
        fullName: _nameController.text.trim(),
        profileImageUrl: _profileUrl,
        onboardingPreferences: {
          'travelStyle': _travelStyle,
          'country': _countryController.text.trim(),
          'dreamTrip': _dreamTripController.text.trim(),
          'activities': _activities.toList(),
        },
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() { _isSaving = false; });
    }
  }
}

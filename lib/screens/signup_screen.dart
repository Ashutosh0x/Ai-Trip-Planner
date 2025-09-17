import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../services/theme_service.dart';
import '../widgets/profile_picture_widget.dart';
import '../widgets/google_sign_in_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  String? _profileImageUrl;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _countryController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _signUpWithEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('Passwords do not match', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (result != null) {
        // Update user profile with additional information
        await result.user?.updateDisplayName(_nameController.text.trim());
        
        // Save additional user data to Firestore
        await FirebaseFirestore.instance.collection('users').doc(result.user?.uid).set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'country': _countryController.text.trim(),
          'dreamTrip': _bioController.text.trim(),
          'profileImageUrl': _profileImageUrl,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        _showSnackBar('Account created successfully!');
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.signInWithGoogle();
      if (result != null) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signUpWithMicrosoft() async {
    setState(() { _isLoading = true; });
    try {
      final result = await AuthService.signInWithMicrosoft();
      if (result != null) Navigator.pushReplacementNamed(context, '/onboarding');
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _signUpWithTwitter() async {
    setState(() { _isLoading = true; });
    try {
      final result = await AuthService.signInWithTwitter();
      if (result != null) Navigator.pushReplacementNamed(context, '/onboarding');
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDarkMode;
    
    return Scaffold(
      body: Stack(
        children: [
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
            color: (isDark ? const Color(0xFF1A1A2E) : Colors.white).withOpacity(0.85),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // Back Button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: isDark ? Colors.white70 : const Color(0xFF9B59B6),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Welcome Text
                Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Join us and start your adventure',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.grey[600],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Profile Picture Section
                Center(
                  child: ProfilePictureWidget(
                    onImageChanged: (imageUrl) {
                      setState(() {
                        _profileImageUrl = imageUrl;
                      });
                    },
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Name Field
                TextFormField(
                  controller: _nameController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey[600]),
                    prefixIcon: Icon(
                      Icons.person,
                      color: isDark ? Colors.white70 : const Color(0xFF9B59B6),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white30 : const Color(0xFF9B59B6).withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white30 : const Color(0xFF9B59B6).withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white : const Color(0xFF9B59B6),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey[600]),
                    prefixIcon: Icon(
                      Icons.email,
                      color: isDark ? Colors.white70 : const Color(0xFF9B59B6),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white30 : const Color(0xFF9B59B6).withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white30 : const Color(0xFF9B59B6).withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white : const Color(0xFF9B59B6),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Country Field
                TextFormField(
                  controller: _countryController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Country',
                    labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey[600]),
                    prefixIcon: Icon(
                      Icons.location_on,
                      color: isDark ? Colors.white70 : const Color(0xFF9B59B6),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white30 : const Color(0xFF9B59B6).withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white30 : const Color(0xFF9B59B6).withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white : const Color(0xFF9B59B6),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your country';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Bio Field
                TextFormField(
                  controller: _bioController,
                  maxLines: 3,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Tell us about your dream trip',
                    labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey[600]),
                    prefixIcon: Icon(
                      Icons.description,
                      color: isDark ? Colors.white70 : const Color(0xFF9B59B6),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white30 : const Color(0xFF9B59B6).withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white30 : const Color(0xFF9B59B6).withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white : const Color(0xFF9B59B6),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey[600]),
                    prefixIcon: Icon(
                      Icons.lock,
                      color: isDark ? Colors.white70 : const Color(0xFF9B59B6),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white30 : const Color(0xFF9B59B6).withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white30 : const Color(0xFF9B59B6).withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white : const Color(0xFF9B59B6),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey[600]),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: isDark ? Colors.white70 : const Color(0xFF9B59B6),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white30 : const Color(0xFF9B59B6).withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white30 : const Color(0xFF9B59B6).withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white : const Color(0xFF9B59B6),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 30),
                
                // Sign Up Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signUpWithEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'SIGN UP',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: isDark ? Colors.white30 : Colors.grey[300],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: isDark ? Colors.white30 : Colors.grey[300],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Sign In Prompt
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey[600],
                        fontSize: 14,
                      ),
                      children: [
                        const TextSpan(text: "Already have an account? "),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF9B59B6),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Google Sign Up Button
                GoogleSignInButton(
                  onPressed: _isLoading ? null : _signUpWithGoogle,
                  isLoading: _isLoading,
                  text: 'Sign up with Google',
                ),
                
                const SizedBox(height: 20),
                
                // Other Social Sign Up Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Microsoft
                    GestureDetector(
                      onTap: _isLoading ? null : _signUpWithMicrosoft,
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white,
                        child: Image.asset(
                          'assets/social login icons/microsoft.png',
                          width: 28,
                          height: 28,
                          errorBuilder: (_, __, ___) => const Icon(Icons.window, color: Color(0xFF00BCF2)),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 20),
                    
                    // Twitter
                    GestureDetector(
                      onTap: _isLoading ? null : _signUpWithTwitter,
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white,
                        child: Image.asset(
                          'assets/social login icons/twitter.png',
                          width: 28,
                          height: 28,
                          errorBuilder: (_, __, ___) => const Icon(Icons.alternate_email, color: Color(0xFF1DA1F2)),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    ],
  ),
);
  }
}
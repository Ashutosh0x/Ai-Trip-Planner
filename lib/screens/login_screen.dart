import 'package:flutter/material.dart';
import '../services/biometric_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../services/theme_service.dart';
import '../widgets/google_sign_in_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginWithEmail() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      _showSnackBar('Please fill in all fields', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check for test credentials first
      if (_emailController.text.trim() == 'ashutosh@gmail.com' &&
          _passwordController.text.trim() == 'password@123') {
        // Simulate successful login for test credentials
        await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
        Navigator.pushReplacementNamed(context, '/home');
        return;
      }

      final result = await AuthService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (result != null) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.signInWithGoogle();
      if (result != null) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loginWithMicrosoft() async {
    setState(() { _isLoading = true; });
    try {
      final result = await AuthService.signInWithMicrosoft();
      if (result != null) Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _loginWithTwitter() async {
    setState(() { _isLoading = true; });
    try {
      final result = await AuthService.signInWithTwitter();
      if (result != null) Navigator.pushReplacementNamed(context, '/home');
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
    // Try biometric quick-login on build (non-blocking)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final bio = BiometricAuthService();
        final String? token = await bio.authenticateAndGetToken();
        if (token != null && mounted) {
          // TODO: validate/refresh token with backend if applicable
          Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (_) {}
    });
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
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Sign in to continue your journey',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 60),
              
              // Username/Email Field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Username or Email',
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
              ),
              
              const SizedBox(height: 30),
              
              // Login Button
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
                  onPressed: _isLoading ? null : _loginWithEmail,
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
                          'LOGIN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Forgot Password
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/forgot-password');
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : const Color(0xFF9B59B6),
                      fontSize: 14,
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
              
              // Sign Up Prompt
              Center(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey[600],
                      fontSize: 14,
                    ),
                    children: [
                      const TextSpan(text: "Don't have an account? "),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: Text(
                            'Sign Up',
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
              
              // Google Sign In Button
              GoogleSignInButton(
                onPressed: _isLoading ? null : _loginWithGoogle,
                isLoading: _isLoading,
                text: 'Sign in with Google',
              ),
              
              const SizedBox(height: 20),
              
              // Other Social Login Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Microsoft
                  GestureDetector(
                    onTap: _isLoading ? null : _loginWithMicrosoft,
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
                    onTap: _isLoading ? null : _loginWithTwitter,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
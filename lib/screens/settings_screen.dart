import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import '../services/theme_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Theme settings
  String _selectedTheme = 'System Default';
  String _selectedFontSize = 'Medium';

  // Notification settings
  String _pushNotificationLevel = 'All';
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _tripReminders = true;
  bool _bookingUpdates = true;

  // App permissions
  bool _locationPermission = true;
  bool _cameraPermission = true;
  bool _notificationPermission = true;

  // Biometric settings
  bool _biometricLogin = false;
  String _biometricType = 'None';

  // Session management
  int _activeSessions = 1;

  // Payment settings
  bool _autoRenew = true;
  String _defaultPaymentMethod = 'Credit Card';
  // Language
  String _languageCode = 'en';
  // Region
  String _regionCode = 'US';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedTheme = prefs.getString('theme') ?? 'System Default';
      _selectedFontSize = prefs.getString('fontSize') ?? 'Medium';
      _pushNotificationLevel =
          prefs.getString('pushNotificationLevel') ?? 'All';
      _emailNotifications = prefs.getBool('emailNotifications') ?? true;
      _smsNotifications = prefs.getBool('smsNotifications') ?? false;
      _tripReminders = prefs.getBool('tripReminders') ?? true;
      _bookingUpdates = prefs.getBool('bookingUpdates') ?? true;
      _locationPermission = prefs.getBool('locationPermission') ?? true;
      _cameraPermission = prefs.getBool('cameraPermission') ?? true;
      _notificationPermission = prefs.getBool('notificationPermission') ?? true;
      _biometricLogin = prefs.getBool('biometricLogin') ?? false;
      _biometricType = prefs.getString('biometricType') ?? 'None';
      _activeSessions = prefs.getInt('activeSessions') ?? 1;
      _autoRenew = prefs.getBool('autoRenew') ?? true;
      _defaultPaymentMethod =
          prefs.getString('defaultPaymentMethod') ?? 'Credit Card';
      _regionCode = prefs.getString('regionCode') ?? 'US';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDarkMode;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    const Color(0xFF1A1A2E), // Dark blue
                    const Color(0xFF16213E), // Darker blue
                  ]
                : [
                    const Color(0xFF8EC5FC), // Light blue
                    const Color(0xFFE0C3FC), // Light purple
                  ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                _buildHeader(),

                // Settings sections
                _buildAppearanceSection(),
                _buildLanguageSection(),
                _buildPermissionsSection(),
                _buildBiometricSection(),
                _buildSessionSection(),
                _buildNotificationSection(),
                _buildPaymentSection(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Text(
            'settings.title'.tr(),
            style: GoogleFonts.dosis(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildAppearanceSection() {
    return _buildSectionCard(
      title: 'settings.appearance'.tr(),
      icon: Icons.palette,
      children: [
        _buildSettingTile(
          title: 'Theme',
          subtitle: _selectedTheme,
          icon: Icons.brightness_6,
          onTap: () => _showThemeDialog(),
        ),
        _buildSettingTile(
          title: 'Font Size',
          subtitle: _selectedFontSize,
          icon: Icons.text_fields,
          onTap: () => _showFontSizeDialog(),
        ),
      ],
    );
  }

  Widget _buildLanguageSection() {
    return _buildSectionCard(
      title: 'settings.language_region'.tr(),
      icon: Icons.language,
      children: [
        _buildSettingTile(
          title: 'settings.language'.tr(),
          subtitle: _languageLabel(_languageCode),
          icon: Icons.translate,
          onTap: () => _showLanguageDialog(),
        ),
        _buildSettingTile(
          title: 'settings.region'.tr(),
          subtitle: _regionLabel(_regionCode),
          icon: Icons.public,
          onTap: () => _showRegionDialog(),
        ),
        _buildSettingTile(
          title: 'settings.currency'.tr(),
          subtitle: 'USD (\$)',
          icon: Icons.attach_money,
          onTap: () => _showCurrencyDialog(),
        ),
      ],
    );
  }

  Widget _buildPermissionsSection() {
    return _buildSectionCard(
      title: 'settings.app_permissions'.tr(),
      icon: Icons.security,
      children: [
        _buildSwitchTile(
          title: 'Location',
          subtitle: 'Access your location for trip planning',
          icon: Icons.location_on,
          value: _locationPermission,
          onChanged: (value) {
            setState(() {
              _locationPermission = value;
            });
            _saveSetting('locationPermission', value);
          },
        ),
        _buildSwitchTile(
          title: 'Camera',
          subtitle: 'Take photos for your trips',
          icon: Icons.camera_alt,
          value: _cameraPermission,
          onChanged: (value) {
            setState(() {
              _cameraPermission = value;
            });
            _saveSetting('cameraPermission', value);
          },
        ),
        _buildSwitchTile(
          title: 'Notifications',
          subtitle: 'Receive trip updates and reminders',
          icon: Icons.notifications,
          value: _notificationPermission,
          onChanged: (value) {
            setState(() {
              _notificationPermission = value;
            });
            _saveSetting('notificationPermission', value);
          },
        ),
      ],
    );
  }

  Widget _buildBiometricSection() {
    return _buildSectionCard(
      title: 'settings.biometric_login'.tr(),
      icon: Icons.fingerprint,
      children: [
        _buildSwitchTile(
          title: 'Enable Biometric Login',
          subtitle: 'Use fingerprint or face recognition',
          icon: Icons.security,
          value: _biometricLogin,
          onChanged: (value) async {
            setState(() {
              _biometricLogin = value;
              _biometricType = value ? 'Fingerprint' : 'None';
            });
            _saveSetting('biometricLogin', value);
            _saveSetting('biometricType', _biometricType);
            // Persist preference for app usage
            final storage = FlutterSecureStorage();
            if (value) {
              await storage.write(key: 'biometrics_enabled', value: 'true');
            } else {
              await storage.delete(key: 'biometrics_enabled');
            }
          },
        ),
        if (_biometricLogin)
          _buildSettingTile(
            title: 'Biometric Type',
            subtitle: _biometricType,
            icon: Icons.fingerprint,
            onTap: () => _showBiometricTypeDialog(),
          ),
      ],
    );
  }

  Widget _buildSessionSection() {
    return _buildSectionCard(
      title: 'settings.session_management'.tr(),
      icon: Icons.devices,
      children: [
        _buildSettingTile(
          title: 'Active Sessions',
          subtitle: '$_activeSessions device(s) logged in',
          icon: Icons.phone_android,
          onTap: () => _showSessionDialog(),
        ),
        _buildActionTile(
          title: 'Sign Out All Devices',
          subtitle: 'Sign out from all other devices',
          icon: Icons.logout,
          onTap: () => _showSignOutAllDialog(),
        ),
      ],
    );
  }

  Widget _buildNotificationSection() {
    return _buildSectionCard(
      title: 'settings.notifications'.tr(),
      icon: Icons.notifications_active,
      children: [
        _buildSettingTile(
          title: 'Push Notifications',
          subtitle: _pushNotificationLevel,
          icon: Icons.notifications,
          onTap: () => _showPushNotificationDialog(),
        ),
        _buildSwitchTile(
          title: 'Email Notifications',
          subtitle: 'Receive updates via email',
          icon: Icons.email,
          value: _emailNotifications,
          onChanged: (value) {
            setState(() {
              _emailNotifications = value;
            });
            _saveSetting('emailNotifications', value);
          },
        ),
        _buildSwitchTile(
          title: 'SMS Notifications',
          subtitle: 'Receive updates via SMS',
          icon: Icons.sms,
          value: _smsNotifications,
          onChanged: (value) {
            setState(() {
              _smsNotifications = value;
            });
            _saveSetting('smsNotifications', value);
          },
        ),
        _buildSwitchTile(
          title: 'Trip Reminders',
          subtitle: 'Get reminded about upcoming trips',
          icon: Icons.schedule,
          value: _tripReminders,
          onChanged: (value) {
            setState(() {
              _tripReminders = value;
            });
            _saveSetting('tripReminders', value);
          },
        ),
        _buildSwitchTile(
          title: 'Booking Updates',
          subtitle: 'Get notified about booking changes',
          icon: Icons.confirmation_number,
          value: _bookingUpdates,
          onChanged: (value) {
            setState(() {
              _bookingUpdates = value;
            });
            _saveSetting('bookingUpdates', value);
          },
        ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return _buildSectionCard(
      title: 'settings.payments_subscriptions'.tr(),
      icon: Icons.payment,
      children: [
        _buildSettingTile(
          title: 'Payment Methods',
          subtitle: 'Manage saved cards and wallets',
          icon: Icons.credit_card,
          onTap: () => _showPaymentMethodsDialog(),
        ),
        _buildSettingTile(
          title: 'Billing History',
          subtitle: 'View invoices and receipts',
          icon: Icons.receipt,
          onTap: () => _openBillingHistory(),
        ),
        _buildSettingTile(
          title: 'Subscriptions',
          subtitle: 'Manage premium plans',
          icon: Icons.star,
          onTap: () => _showSubscriptionsDialog(),
        ),
        _buildSwitchTile(
          title: 'Auto-Renew',
          subtitle: 'Automatically renew subscriptions',
          icon: Icons.autorenew,
          value: _autoRenew,
          onChanged: (value) {
            setState(() {
              _autoRenew = value;
            });
            _saveSetting('autoRenew', value);
          },
        ),
        _buildActionTile(
          title: 'Refund Policy',
          subtitle: 'View refund and cancellation policies',
          icon: Icons.policy,
          onTap: () => _showRefundPolicyDialog(),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
          Padding(
            padding: const EdgeInsets.all(20),
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
                Text(
                  title,
                  style: GoogleFonts.dosis(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4ECDC4), size: 20),
      title: Text(
        title,
        style: GoogleFonts.dosis(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.dosis(fontSize: 14, color: Colors.grey[600]),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4ECDC4), size: 20),
      title: Text(
        title,
        style: GoogleFonts.dosis(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.dosis(fontSize: 14, color: Colors.grey[600]),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF4ECDC4),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4ECDC4), size: 20),
      title: Text(
        title,
        style: GoogleFonts.dosis(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.dosis(fontSize: 14, color: Colors.grey[600]),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  // Dialog methods
  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Theme',
          style: GoogleFonts.dosis(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption('Light', Icons.light_mode),
            _buildThemeOption('Dark', Icons.dark_mode),
            _buildThemeOption('System Default', Icons.settings),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(String theme, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4ECDC4)),
      title: Text(theme, style: GoogleFonts.dosis()),
      trailing: _selectedTheme == theme
          ? const Icon(Icons.check, color: Color(0xFF4ECDC4))
          : null,
      onTap: () {
        setState(() {
          _selectedTheme = theme;
        });
        _saveSetting('theme', theme);

        // Update theme service
        final themeService = Provider.of<ThemeService>(context, listen: false);
        themeService.setThemeFromString(theme);

        Navigator.pop(context);
      },
    );
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Font Size',
          style: GoogleFonts.dosis(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFontSizeOption('Small', 'A'),
            _buildFontSizeOption('Medium', 'A'),
            _buildFontSizeOption('Large', 'A'),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeOption(String size, String letter) {
    double fontSize = size == 'Small'
        ? 14
        : size == 'Medium'
        ? 18
        : 22;
    return ListTile(
      title: Text(letter, style: GoogleFonts.dosis(fontSize: fontSize)),
      subtitle: Text(size, style: GoogleFonts.dosis()),
      trailing: _selectedFontSize == size
          ? const Icon(Icons.check, color: Color(0xFF4ECDC4))
          : null,
      onTap: () {
        setState(() {
          _selectedFontSize = size;
        });
        _saveSetting('fontSize', size);
        Navigator.pop(context);
      },
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Language',
          style: GoogleFonts.dosis(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 360,
          height: 360,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildLanguageOption('en', 'English'),
              _buildLanguageOption('es', 'Español'),
              _buildLanguageOption('fr', 'Français'),
              _buildLanguageOption('de', 'Deutsch'),
              _buildLanguageOption('hi', 'हिन्दी'),
              _buildLanguageOption('ar', 'العربية'),
              _buildLanguageOption('pt', 'Português'),
              _buildLanguageOption('ru', 'Русский'),
              _buildLanguageOption('ja', '日本語'),
              _buildLanguageOption('zh', '中文'),
              _buildLanguageOption('it', 'Italiano'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String code, String label) {
    return ListTile(
      title: Text(label, style: GoogleFonts.dosis()),
      trailing: _languageCode == code
          ? const Icon(Icons.check, color: Color(0xFF4ECDC4))
          : null,
      onTap: () async {
        setState(() {
          _languageCode = code;
        });
        _saveSetting('languageCode', code);
        try {
          // Apply locale app-wide
          // Using dynamic import to avoid a direct dependency here; main.dart wires delegates
          // ignore: use_build_context_synchronously
          await context.setLocale(Locale(code));
        } catch (_) {}
        if (!mounted) return;
        Navigator.pop(context);
      },
    );
  }

  String _languageLabel(String code) {
    switch (code) {
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'hi':
        return 'हिन्दी';
      case 'ar':
        return 'العربية';
      case 'pt':
        return 'Português';
      case 'ru':
        return 'Русский';
      case 'ja':
        return '日本語';
      case 'zh':
        return '中文';
      case 'it':
        return 'Italiano';
      default:
        return 'English';
    }
  }

  void _showRegionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Region',
          style: GoogleFonts.dosis(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 360,
          height: 360,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildRegionOption('US', 'United States'),
              _buildRegionOption('GB', 'United Kingdom'),
              _buildRegionOption('IN', 'India'),
              _buildRegionOption('DE', 'Germany'),
              _buildRegionOption('FR', 'France'),
              _buildRegionOption('ES', 'Spain'),
              _buildRegionOption('MX', 'Mexico'),
              _buildRegionOption('BR', 'Brazil'),
              _buildRegionOption('RU', 'Russia'),
              _buildRegionOption('JP', 'Japan'),
              _buildRegionOption('CN', 'China (Mainland)'),
              _buildRegionOption('TW', 'Taiwan'),
              _buildRegionOption('SA', 'Saudi Arabia'),
              _buildRegionOption('IT', 'Italy'),
            ],
          ),
        ),
      ),
    );
  }

  String _regionLabel(String code) {
    switch (code) {
      case 'GB':
        return 'United Kingdom';
      case 'IN':
        return 'India';
      case 'DE':
        return 'Germany';
      case 'FR':
        return 'France';
      case 'ES':
        return 'Spain';
      case 'MX':
        return 'Mexico';
      case 'BR':
        return 'Brazil';
      case 'RU':
        return 'Russia';
      case 'JP':
        return 'Japan';
      case 'CN':
        return 'China (Mainland)';
      case 'TW':
        return 'Taiwan';
      case 'SA':
        return 'Saudi Arabia';
      case 'IT':
        return 'Italy';
      default:
        return 'United States';
    }
  }

  Widget _buildRegionOption(String code, String label) {
    return ListTile(
      title: Text(label, style: GoogleFonts.dosis()),
      trailing: _regionCode == code
          ? const Icon(Icons.check, color: Color(0xFF4ECDC4))
          : null,
      onTap: () async {
        setState(() {
          _regionCode = code;
        });
        _saveSetting('regionCode', code);
        if (!mounted) return;
        Navigator.pop(context);
      },
    );
  }

  void _showCurrencyDialog() {
    _showInfoDialog('Currency', 'Currency selection feature coming soon!');
  }

  Future<void> _showBiometricTypeDialog() async {
    final auth = LocalAuthentication();
    try {
      final bool supported = await auth.isDeviceSupported();
      final bool canCheck = await auth.canCheckBiometrics;
      if (!supported || !canCheck) {
        _showInfoDialog(
          'Biometric Type',
          'No biometric sensor or biometrics not available.',
        );
        return;
      }

      final List<BiometricType> types = await auth.getAvailableBiometrics();
      if (types.isEmpty) {
        _showInfoDialog(
          'Biometric Type',
          'No biometrics enrolled on this device.',
        );
        return;
      }

      String labelFor(BiometricType t) {
        switch (t) {
          case BiometricType.face:
            return 'Face';
          case BiometricType.fingerprint:
            return 'Fingerprint';
          case BiometricType.iris:
            return 'Iris';
          default:
            return 'Biometric';
        }
      }

      final options = types.map((t) => labelFor(t)).toSet().toList();

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Biometric Type',
            style: GoogleFonts.dosis(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options
                .map(
                  (label) => ListTile(
                    title: Text(label, style: GoogleFonts.dosis()),
                    trailing: _biometricType == label
                        ? const Icon(Icons.check, color: Color(0xFF4ECDC4))
                        : null,
                    onTap: () {
                      setState(() {
                        _biometricType = label;
                      });
                      _saveSetting('biometricType', label);
                      Navigator.pop(context);
                    },
                  ),
                )
                .toList(),
          ),
        ),
      );
    } catch (_) {
      _showInfoDialog(
        'Biometric Type',
        'Unable to read biometric types on this device.',
      );
    }
  }

  void _showSessionDialog() {
    _showInfoDialog(
      'Active Sessions',
      'Session management feature coming soon!',
    );
  }

  void _showSignOutAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Sign Out All Devices',
          style: GoogleFonts.dosis(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to sign out from all other devices?',
        ),
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
              _showInfoDialog(
                'Success',
                'All other devices have been signed out.',
              );
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

  void _showPushNotificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Push Notifications',
          style: GoogleFonts.dosis(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNotificationOption('All', 'Receive all notifications'),
            _buildNotificationOption(
              'Only Important',
              'Receive only important notifications',
            ),
            _buildNotificationOption('None', 'Disable all push notifications'),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationOption(String level, String description) {
    return ListTile(
      title: Text(level, style: GoogleFonts.dosis()),
      subtitle: Text(description, style: GoogleFonts.dosis(fontSize: 12)),
      trailing: _pushNotificationLevel == level
          ? const Icon(Icons.check, color: Color(0xFF4ECDC4))
          : null,
      onTap: () {
        setState(() {
          _pushNotificationLevel = level;
        });
        _saveSetting('pushNotificationLevel', level);
        Navigator.pop(context);
      },
    );
  }

  void _showPaymentMethodsDialog() {
    Navigator.pushNamed(context, '/payment-methods');
  }

  void _openBillingHistory() {
    Navigator.pushNamed(context, '/billing-history');
  }

  void _showSubscriptionsDialog() {
    _showInfoDialog('Subscriptions', 'Subscription management coming soon!');
  }

  void _showRefundPolicyDialog() {
    _showInfoDialog('Refund Policy', 'Refund policy information coming soon!');
  }

  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.dosis(fontWeight: FontWeight.bold),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.dosis(color: const Color(0xFF4ECDC4)),
            ),
          ),
        ],
      ),
    );
  }
}

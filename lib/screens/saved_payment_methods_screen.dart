import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/secure_payment_service.dart';

class SavedPaymentMethodsScreen extends StatefulWidget {
  const SavedPaymentMethodsScreen({super.key});

  @override
  State<SavedPaymentMethodsScreen> createState() => _SavedPaymentMethodsScreenState();
}

class _SavedPaymentMethodsScreenState extends State<SavedPaymentMethodsScreen> {
  final SecurePaymentService _paymentService = SecurePaymentService(
    backendBaseUrl: const String.fromEnvironment('BACKEND_BASE_URL', 
        defaultValue: 'http://10.0.2.2:5001/ai-trip-planner-26100/us-central1/api'),
  );

  List<SavedPaymentMethod> _savedMethods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedPaymentMethods();
  }

  Future<void> _loadSavedPaymentMethods() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final methods = await _paymentService.getSavedPaymentMethods();
      setState(() {
        _savedMethods = methods;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load payment methods: $e');
    }
  }

  Future<void> _deletePaymentMethod(SavedPaymentMethod method) async {
    final confirmed = await _showDeleteConfirmationDialog(method);
    if (!confirmed) return;

    try {
      await _paymentService.deleteSavedPaymentMethod(method.id);
      _loadSavedPaymentMethods();
      _showSuccessSnackBar('Payment method deleted successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to delete payment method: $e');
    }
  }

  Future<bool> _showDeleteConfirmationDialog(SavedPaymentMethod method) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Payment Method',
          style: GoogleFonts.dosis(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete your ${method.displayName} ending in ${method.last4}?',
          style: GoogleFonts.dosis(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.dosis(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Delete',
              style: GoogleFonts.dosis(color: Colors.red),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1A1A2E).withOpacity(0.85),
                  const Color(0xFF16213E).withOpacity(0.85),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),
                
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
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _savedMethods.isEmpty
                            ? _buildEmptyState()
                            : _buildPaymentMethodsList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              Text(
                'Payment Methods',
                style: GoogleFonts.dosis(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  // Navigate to add payment method screen
                  Navigator.pushNamed(context, '/confirm-pay');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF4ECDC4).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.credit_card_off,
                size: 60,
                color: Color(0xFF4ECDC4),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Payment Methods',
              style: GoogleFonts.dosis(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add a payment method to make bookings faster and more convenient.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dosis(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/confirm-pay');
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Payment Method'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4ECDC4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsList() {
    return Column(
      children: [
        // Add New Button
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/confirm-pay');
              },
              icon: const Icon(Icons.add),
              label: const Text('Add New Payment Method'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4ECDC4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        
        // Payment Methods List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _savedMethods.length,
            itemBuilder: (context, index) {
              final method = _savedMethods[index];
              return _buildPaymentMethodCard(method);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(SavedPaymentMethod method) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Card Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getCardColor(method.cardType).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCardIcon(method.cardType),
              color: _getCardColor(method.cardType),
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Card Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${method.displayName} •••• ${method.last4}',
                  style: GoogleFonts.dosis(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Added ${_formatDate(method.createdAt)}',
                  style: GoogleFonts.dosis(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Delete Button
          IconButton(
            onPressed: () => _deletePaymentMethod(method),
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCardColor(CardType cardType) {
    switch (cardType) {
      case CardType.visa:
        return Colors.blue;
      case CardType.mastercard:
        return Colors.red;
      case CardType.amex:
        return Colors.green;
      case CardType.discover:
        return Colors.orange;
      default:
        return const Color(0xFF4ECDC4);
    }
  }

  IconData _getCardIcon(CardType cardType) {
    switch (cardType) {
      case CardType.visa:
        return Icons.credit_card;
      case CardType.mastercard:
        return Icons.credit_card;
      case CardType.amex:
        return Icons.credit_card;
      case CardType.discover:
        return Icons.credit_card;
      default:
        return Icons.credit_card;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else {
      return '${(difference.inDays / 365).floor()} years ago';
    }
  }
}

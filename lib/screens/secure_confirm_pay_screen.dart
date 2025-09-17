import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import '../services/secure_payment_service.dart';
import '../services/theme_service.dart';

class SecureConfirmPayScreen extends StatefulWidget {
  const SecureConfirmPayScreen({super.key});

  @override
  State<SecureConfirmPayScreen> createState() => _SecureConfirmPayScreenState();
}

class _SecureConfirmPayScreenState extends State<SecureConfirmPayScreen> {
  final SecurePaymentService _paymentService = SecurePaymentService(
    backendBaseUrl: const String.fromEnvironment('BACKEND_BASE_URL', 
        defaultValue: 'http://10.0.2.2:5001/ai-trip-planner-26100/us-central1/api'),
  );

  // Form controllers
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cvcController = TextEditingController();
  final TextEditingController _billingAddressController = TextEditingController();
  
  // Payment method selection
  String _selectedPaymentMethod = 'card';
  SavedPaymentMethod? _selectedSavedMethod;
  
  // Loading and validation states
  bool _isProcessing = false;
  bool _isCardValid = false;
  bool _saveCard = false;
  
  // Card data for validation
  String _cardNumber = '';
  String _cardName = '';
  String _expiryDate = '';
  String _cvc = '';
  CardType _cardType = CardType.unknown;
  
  // Saved payment methods
  List<SavedPaymentMethod> _savedMethods = [];

  @override
  void initState() {
    super.initState();
    _initializeStripe();
    _loadSavedPaymentMethods();
    
    // Add listeners to text controllers
    _cardNumberController.addListener(_updateCardNumber);
    _nameController.addListener(_updateCardName);
    _expiryController.addListener(_updateExpiryDate);
    _cvcController.addListener(_updateCVC);
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _nameController.dispose();
    _cvcController.dispose();
    _billingAddressController.dispose();
    super.dispose();
  }

  Future<void> _initializeStripe() async {
    // Initialize Stripe with your publishable key
    await SecurePaymentService.initializeStripe(
      'pk_test_51S84WfAx2N1ptLzZhkNMYFc8s22M40kXoawmUttlNaohJC7FtZbgDGveuXB5v6jmdLLvxxSSHTRMqXbgdPY0X4Po00F2vgX0sW',
    );
    
    // Initialize Google Pay
    await SecurePaymentService.initializeGooglePay(
      merchantName: 'Alventura',
      countryCode: 'US',
      testEnv: true,
    );
  }

  Future<void> _loadSavedPaymentMethods() async {
    final methods = await _paymentService.getSavedPaymentMethods();
    setState(() {
      _savedMethods = methods;
    });
  }

  void _updateCardNumber() {
    String value = _cardNumberController.text;
    String formatted = CardValidator.formatCardNumber(value);
    
    if (formatted != value) {
      _cardNumberController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    
    setState(() {
      _cardNumber = formatted;
      _cardType = CardValidator.getCardType(formatted);
      _validateCard();
    });
  }

  void _updateCardName() {
    setState(() {
      _cardName = _nameController.text;
      _validateCard();
    });
  }

  void _updateExpiryDate() {
    String value = _expiryController.text;
    String formatted = CardValidator.formatExpiryDate(value);
    
    if (formatted != value) {
      _expiryController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    
    setState(() {
      _expiryDate = formatted;
      _validateCard();
    });
  }

  void _updateCVC() {
    setState(() {
      _cvc = _cvcController.text;
      _validateCard();
    });
  }

  void _validateCard() {
    bool isValid = CardValidator.isValidCardNumber(_cardNumber) &&
                   CardValidator.isValidExpiryDate(_expiryDate) &&
                   CardValidator.isValidCVC(_cvc, _cardType) &&
                   _cardName.isNotEmpty;
    
    setState(() {
      _isCardValid = isValid;
    });
  }

  void _selectPaymentMethod(String method) {
    setState(() {
      _selectedPaymentMethod = method;
      _selectedSavedMethod = null;
    });
  }

  void _selectSavedPaymentMethod(SavedPaymentMethod method) {
    setState(() {
      _selectedPaymentMethod = 'saved';
      _selectedSavedMethod = method;
    });
  }

  Future<void> _processPayment() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Create payment intent
      final clientSecret = await _paymentService.createPaymentIntent(
        amount: 24000, // $240.00 in cents
        currency: 'usd',
        metadata: {
          'event': 'Patagonia Glaciers Tour',
          'tickets': '2',
        },
      );

      PaymentResult result;

      // Process payment based on selected method
      switch (_selectedPaymentMethod) {
        case 'card':
          result = await _paymentService.processCardPayment(
            clientSecret: clientSecret,
            cardholderName: _nameController.text,
            billingAddress: _billingAddressController.text,
            saveCard: _saveCard,
          );
          break;
          
        case 'google_pay':
          result = await _paymentService.processGooglePayPayment(
            clientSecret: clientSecret,
          );
          break;
          
        case 'saved':
          if (_selectedSavedMethod == null) {
            throw Exception('No saved payment method selected');
          }
          result = await _paymentService.processSavedPaymentMethod(
            clientSecret: clientSecret,
            paymentMethodId: _selectedSavedMethod!.id,
          );
          break;
          
        default:
          throw Exception('Invalid payment method');
      }

      if (result.isSuccess) {
        _showSuccessDialog();
      } else {
        _showErrorDialog(result.errorMessage ?? 'Payment failed');
      }

    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('Payment Successful!'),
          ],
        ),
        content: const Text('Your booking has been confirmed. You will receive a confirmation email shortly.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Payment Failed'),
          ],
        ),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
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
              const Color(0xFF1A1A2E),
              const Color(0xFF16213E),
            ] : [
              const Color(0xFF8EC5FC),
              const Color(0xFFE0C3FC),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Event Summary
                        _buildEventSummary(),
                        
                        const SizedBox(height: 24),
                        
                        // Payment Methods
                        _buildPaymentMethodsSection(),
                        
                        const SizedBox(height: 24),
                        
                        // Card Details (if card selected)
                        if (_selectedPaymentMethod == 'card') ...[
                          _buildCardDetailsSection(),
                          const SizedBox(height: 16),
                        ],
                        
                        // Billing Address
                        _buildBillingAddressSection(),
                        
                        const SizedBox(height: 24),
                        
                        // Complete Booking Button
                        _buildCompleteBookingButton(),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
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
          const Text(
            'Alventura',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildEventSummary() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Event Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [Colors.blue[100]!, Colors.purple[100]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=300&h=200&fit=crop',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.landscape, color: Colors.grey, size: 40);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Patagonia Glaciers Tour',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'December 15, 2024',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '2x Tickets: \$240.00 USD',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4ECDC4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        
        // Saved Payment Methods
        if (_savedMethods.isNotEmpty) ...[
          ..._savedMethods.map((method) => _buildPaymentMethodOption(
            'saved',
            '${method.displayName} •••• ${method.last4}',
            Icons.credit_card,
            isSelected: _selectedPaymentMethod == 'saved' && _selectedSavedMethod?.id == method.id,
            onTap: () => _selectSavedPaymentMethod(method),
          )),
          const SizedBox(height: 12),
        ],
        
        // Card Payment
        _buildPaymentMethodOption(
          'card',
          'Credit or Debit Card',
          Icons.credit_card,
          isSelected: _selectedPaymentMethod == 'card',
          onTap: () => _selectPaymentMethod('card'),
        ),
        
        const SizedBox(height: 12),
        
        // Google Pay
        _buildPaymentMethodOption(
          'google_pay',
          'Google Pay',
          Icons.account_balance_wallet,
          isSelected: _selectedPaymentMethod == 'google_pay',
          onTap: () => _selectPaymentMethod('google_pay'),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodOption(
    String value,
    String title,
    IconData icon, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4ECDC4).withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF4ECDC4) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF4ECDC4) : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? const Color(0xFF4ECDC4) : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF4ECDC4),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Card Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        
        // Stripe CardField with built-in animations and beautiful card UI
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: CardField(
            onCardChanged: (card) {
              setState(() {
                _isCardValid = card?.complete ?? false;
              });
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF4ECDC4), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Cardholder Name
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Cardholder Name',
            hintText: 'John Doe',
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Save Card Option
        Row(
          children: [
            Checkbox(
              value: _saveCard,
              onChanged: (value) {
                setState(() {
                  _saveCard = value ?? false;
                });
              },
            ),
            const Text('Save this card for future payments'),
          ],
        ),
      ],
    );
  }

  Widget _buildBillingAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Billing Address',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _billingAddressController,
          decoration: InputDecoration(
            labelText: 'Address',
            hintText: '123 Main Street, City, State',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompleteBookingButton() {
    bool canProceed = false;
    
    switch (_selectedPaymentMethod) {
      case 'card':
        canProceed = _isCardValid;
        break;
      case 'google_pay':
        canProceed = true;
        break;
      case 'saved':
        canProceed = _selectedSavedMethod != null;
        break;
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: canProceed && !_isProcessing ? _processPayment : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4ECDC4),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isProcessing
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Processing...'),
                ],
              )
            : Text(
                _selectedPaymentMethod == 'google_pay' 
                    ? 'Pay with Google Pay'
                    : 'Complete Booking',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  IconData _getCardIcon() {
    switch (_cardType) {
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
}

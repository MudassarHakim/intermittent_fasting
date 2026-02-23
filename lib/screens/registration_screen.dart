import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:country_picker/country_picker.dart';
import 'package:go_router/go_router.dart';
import '../app/theme.dart';
import '../services/auth_service.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  
  Country? _selectedCountry;
  bool _isLoading = false;
  bool _magicLinkSent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _sendMagicLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService.signInWithMagicLink(_emailController.text.trim());
      
      setState(() {
        _magicLinkSent = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send magic link. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _completeProfile() async {
    if (_selectedCountry == null || _mobileController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService.saveUserProfile(
        email: _emailController.text.trim(),
        country: _selectedCountry!.name,
        mobileNo: '${_selectedCountry!.phoneCode}${_mobileController.text.trim()}',
      );

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save profile. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                
                // Header
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_add_rounded,
                      size: 48,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                Center(
                  child: Text(
                    _magicLinkSent ? 'Check Your Email' : 'Create Account',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    _magicLinkSent 
                        ? 'We sent a magic link to ${_emailController.text}'
                        : 'Join us to track your fasting journey',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),

                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppTheme.error, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: AppTheme.error, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                if (!_magicLinkSent) ...[
                  // Email field
                  const Text(
                    'Email Address',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'your@email.com',
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: AppTheme.surfaceCard,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: AppTheme.textMuted.withValues(alpha: 0.1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppTheme.primary),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Country picker
                  const Text(
                    'Country',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      showCountryPicker(
                        context: context,
                        showPhoneCode: true,
                        countryListTheme: CountryListThemeData(
                          backgroundColor: AppTheme.surfaceCard,
                          textStyle: const TextStyle(color: AppTheme.textPrimary),
                          searchTextStyle: const TextStyle(color: AppTheme.textPrimary),
                          bottomSheetHeight: 500,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                          inputDecoration: InputDecoration(
                            hintText: 'Search country',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: AppTheme.surfaceLight,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        onSelect: (Country country) {
                          setState(() {
                            _selectedCountry = country;
                          });
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppTheme.textMuted.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.flag_outlined, color: AppTheme.textMuted),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedCountry?.name ?? 'Select your country',
                              style: TextStyle(
                                fontSize: 16,
                                color: _selectedCountry != null
                                    ? AppTheme.textPrimary
                                    : AppTheme.textMuted,
                              ),
                            ),
                          ),
                          if (_selectedCountry != null)
                            Text(
                              _selectedCountry!.flagEmoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                          const Icon(Icons.chevron_right, color: AppTheme.textMuted),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Mobile number
                  const Text(
                    'Mobile Number',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Enter mobile number',
                      prefixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 12),
                          const Icon(Icons.phone_outlined),
                          if (_selectedCountry != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '+${_selectedCountry!.phoneCode}',
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              height: 24,
                              width: 1,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              color: AppTheme.textMuted.withValues(alpha: 0.3),
                            ),
                          ],
                        ],
                      ),
                      filled: true,
                      fillColor: AppTheme.surfaceCard,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: AppTheme.textMuted.withValues(alpha: 0.1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppTheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendMagicLink,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Send Magic Link',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ] else ...[
                  // Magic link sent confirmation
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.mark_email_read_rounded,
                          size: 48,
                          color: AppTheme.success,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Magic link sent!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.success,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Click the link in your email to sign in. The link expires in 1 hour.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _magicLinkSent = false;
                            });
                          },
                          child: const Text('Use a different email'),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Skip button (guest mode)
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/home'),
                    child: const Text(
                      'Continue as Guest',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Creator info
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'Created by',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          // Open creator website
                        },
                        child: const Text(
                          'Mudassar Hakim',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Text(
                        'mudassarhakim.com',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

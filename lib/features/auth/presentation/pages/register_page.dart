import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'login_page.dart';
import '../../../../core/providers/theme_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _gender;

  // Focus nodes map
  late final Map<String, FocusNode> _focusNodes;

  void _initFocusNodes() {
    _focusNodes = {
      'firstName': FocusNode(),
      'lastName': FocusNode(),
      'email': FocusNode(),
      'phone': FocusNode(),
      'password': FocusNode(),
      'confirmPassword': FocusNode(),
    };
  }

  // UI state
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _termsAccepted = false;
  int _currentStep = 0;

  // Animations & controllers
  late final AnimationController _animationController;
  final PageController _pageController = PageController();
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initFocusNodes();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.2, 0.8, curve: Curves.elasticOut)),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic)),
    );
  }

  @override
  void dispose() {
    // Dispose controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    // Dispose focus nodes
    for (final node in _focusNodes.values) {
      node.dispose();
    }

    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      _showError('Veuillez corriger les erreurs du formulaire.');
      return;
    }
    if (!_termsAccepted) {
      _showError('Veuillez accepter les conditions d\'utilisation');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await AuthService().register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        gender: _gender,
      );

      if (!mounted) return;

      if (result != null && result['success'] == true) {
        _showSuccess(result['message'] ?? 'Compte créé avec succès');
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => LoginPage(
                prefilledEmail: _emailController.text.trim(),
                prefilledPassword: _passwordController.text,
                showRegistrationSuccess: true,
              ),
            ),
            (route) => false,
          );
        }
      } else {
        _showError(result != null ? (result['message'] ?? 'Erreur lors de la création') : 'Erreur inconnue');
      }
    } catch (e) {
      _showError('Erreur réseau: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
          ],
        ),
        backgroundColor: const Color(0xFFFF3B6D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF27AE60),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  void _toggleTheme() {
    final themeProvider = context.read<ThemeProvider>();
    themeProvider.toggleTheme();
    HapticFeedback.mediumImpact();
  }

  void _nextStep() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    if (_currentStep < 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Widget _buildStepIndicator() {
    final List<String> steps = ['Infos', 'Sécurité'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: steps.asMap().entries.map((entry) {
          final index = entry.key;
          final isActive = _currentStep == index;
          final isCompleted = _currentStep > index;

          return Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isActive ? 50 : 40,
                height: isActive ? 50 : 40,
                decoration: BoxDecoration(
                  gradient: (isActive || isCompleted)
                      ? const LinearGradient(colors: [Color(0xFF00F5FF), Color(0xFF0080FF)])
                      : null,
                  color: (isActive || isCompleted) ? null : Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: (isActive || isCompleted) ? const Color(0xFF00F5FF) : Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00F5FF).withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, size: 24, color: Colors.white)
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: (isActive || isCompleted) ? Colors.white : Colors.white.withOpacity(0.6),
                            fontWeight: FontWeight.bold,
                            fontSize: isActive ? 20 : 16,
                          ),
                        ),
                ),
              ),
              if (index < steps.length - 1)
                Container(
                  width: 30,
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isCompleted ? const Color(0xFF00F5FF) : Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // Step 1: personal info
  Widget _buildPersonalInfoStep() {
    final theme = Theme.of(context);
    final List<String> genders = ['Homme', 'Femme', 'Autre'];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Informations personnelles',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // First name
          _buildThemedTextField(
            controller: _firstNameController,
            focusNode: _focusNodes['firstName']!,
            label: 'Prénom *',
            hint: 'Entrez votre prénom',
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Veuillez entrer votre prénom';
              return null;
            },
            onFieldSubmitted: (_) => _focusNodes['lastName']?.requestFocus(),
          ),
          const SizedBox(height: 16),

          // Last name
          _buildThemedTextField(
            controller: _lastNameController,
            focusNode: _focusNodes['lastName']!,
            label: 'Nom *',
            hint: 'Entrez votre nom',
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Veuillez entrer votre nom';
              return null;
            },
            onFieldSubmitted: (_) => _focusNodes['email']?.requestFocus(),
          ),
          const SizedBox(height: 16),

          // Email
          _buildThemedTextField(
            controller: _emailController,
            focusNode: _focusNodes['email']!,
            label: 'Email *',
            hint: 'votre@email.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Veuillez entrer votre email';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) return 'Veuillez entrer un email valide';
              return null;
            },
            onFieldSubmitted: (_) => _focusNodes['phone']?.requestFocus(),
          ),
          const SizedBox(height: 16),

          // Phone
          _buildThemedPhoneField(),
          const SizedBox(height: 16),

          // Gender
          DropdownButtonFormField<String>(
            value: _gender,
            decoration: _buildThemedInputDecoration(labelText: 'Genre', hintText: 'Sélectionnez votre genre'),
            dropdownColor: theme.colorScheme.surface,
            style: theme.textTheme.bodyMedium,
            icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.onSurface.withOpacity(0.6)),
            items: genders.map((String gender) {
              return DropdownMenuItem<String>(value: gender, child: Text(gender));
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _gender = newValue;
              });
            },
          ),
        ],
      ),
    );
  }

  // Step 2: security
  Widget _buildSecurityStep() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sécurité',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
          ),
          const SizedBox(height: 20),

          // Terms checkbox
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: isDark 
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _termsAccepted 
                    ? theme.colorScheme.primary 
                    : (isDark ? Colors.white.withOpacity(0.18) : Colors.black.withOpacity(0.12)),
                width: _termsAccepted ? 2.5 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _termsAccepted
                      ? theme.colorScheme.primary.withOpacity(0.15)
                      : (isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05)),
                  blurRadius: _termsAccepted ? 15 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _termsAccepted = !_termsAccepted;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _termsAccepted ? theme.colorScheme.primary : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _termsAccepted ? theme.colorScheme.primary : theme.colorScheme.outline),
                    ),
                    child: _termsAccepted ? Icon(Icons.check, color: theme.colorScheme.onPrimary, size: 16) : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: 'J\'accepte les ', style: theme.textTheme.bodyMedium?.copyWith(color: isDark ? Colors.white70 : Colors.black87)),
                        TextSpan(text: 'conditions d\'utilisation', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Password
          Container(
            decoration: BoxDecoration(
              color: isDark 
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.02),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark 
                    ? Colors.white.withOpacity(0.15)
                    : Colors.black.withOpacity(0.08),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark 
                      ? Colors.black.withOpacity(0.2)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              focusNode: _focusNodes['password'],
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _focusNodes['confirmPassword']?.requestFocus(),
              style: theme.textTheme.bodyLarge?.copyWith(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                labelStyle: theme.textTheme.bodyMedium?.copyWith(color: isDark ? Colors.white70 : Colors.black87),
                prefixIcon: Icon(Icons.lock_outline, color: isDark ? Colors.white70 : Colors.black87),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: isDark ? Colors.white70 : Colors.black87),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Veuillez entrer un mot de passe';
                if (value.length < 8) return 'Le mot de passe doit contenir au moins 8 caractères';
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),

          // Confirm password
          Container(
            decoration: BoxDecoration(
              color: isDark 
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.02),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark 
                    ? Colors.white.withOpacity(0.15)
                    : Colors.black.withOpacity(0.08),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark 
                      ? Colors.black.withOpacity(0.2)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              focusNode: _focusNodes['confirmPassword'],
              textInputAction: TextInputAction.done,
              style: theme.textTheme.bodyLarge?.copyWith(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'Confirmer le mot de passe',
                labelStyle: theme.textTheme.bodyMedium?.copyWith(color: isDark ? Colors.white70 : Colors.black87),
                prefixIcon: Icon(Icons.lock_outline, color: isDark ? Colors.white70 : Colors.black87),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: isDark ? Colors.white70 : Colors.black87),
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Veuillez confirmer votre mot de passe';
                if (value != _passwordController.text) return 'Les mots de passe ne correspondent pas';
                return null;
              },
            ),
          ),

          // Warning if terms not accepted
          if (!_termsAccepted) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withOpacity(isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: theme.colorScheme.error.withOpacity(isDark ? 0.4 : 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.error.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: theme.colorScheme.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Veuillez accepter les conditions d\'utilisation pour continuer',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Themed input decoration
  InputDecoration _buildThemedInputDecoration({required String labelText, String? hintText}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InputDecoration(
      labelText: labelText,
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: isDark ? Colors.white70 : Colors.black87,
        fontWeight: FontWeight.w500,
      ),
      hintText: hintText,
      hintStyle: theme.textTheme.bodyMedium?.copyWith(
        color: isDark ? Colors.white38 : Colors.black38,
        fontWeight: FontWeight.w400,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.15)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.error, width: 2.5),
      ),
      filled: true,
      fillColor: isDark 
          ? Colors.white.withOpacity(0.05)
          : Colors.black.withOpacity(0.02),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
    );
  }

  Widget _buildThemedTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    String? Function(String?)? validator,
    void Function(String)? onFieldSubmitted,
  }) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: theme.textTheme.bodyLarge,
      decoration: _buildThemedInputDecoration(labelText: label, hintText: hint),
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
    );
  }

  Widget _buildThemedPhoneField() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: _phoneController,
      focusNode: _focusNodes['phone']!,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      style: theme.textTheme.bodyLarge?.copyWith(color: isDark ? Colors.white : Colors.black),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(9),
      ],
      decoration: InputDecoration(
        labelText: 'Téléphone *',
        labelStyle: theme.textTheme.bodyMedium?.copyWith(color: isDark ? Colors.white70 : Colors.black87),
        hintText: '6XX XXX XXX',
        hintStyle: theme.textTheme.bodyMedium?.copyWith(color: isDark ? Colors.white38 : Colors.black38),
        prefixIcon: Icon(Icons.phone, color: isDark ? Colors.white70 : Colors.black87),
        prefixText: '+237 ',
        prefixStyle: theme.textTheme.bodyMedium?.copyWith(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2.5),
        ),
        filled: true,
        fillColor: isDark 
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.02),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Veuillez entrer votre numéro de téléphone';
        if (value.trim().length != 9 || !RegExp(r'^[23679]').hasMatch(value.trim())) return 'Numéro de téléphone invalide pour le Cameroun';
        return null;
      },
    );
  }

  Widget _buildThemeToggle(bool isDarkMode) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [const Color(0xFFFFD93D).withOpacity(0.3), const Color(0xFFFFA500).withOpacity(0.3)]
                  : [const Color(0xFF1A1F3A).withOpacity(0.2), const Color(0xFF0A0E27).withOpacity(0.2)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDarkMode ? const Color(0xFFFFD93D).withOpacity(0.5) : const Color(0xFF1A1F3A).withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: (isDarkMode ? const Color(0xFFFFD93D) : const Color(0xFF1A1F3A)).withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleTheme,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Icon(isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: isDarkMode ? const Color(0xFFFFD93D) : const Color(0xFF1A1F3A), size: 30),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0A0E27), Color(0xFF1A1F3A), Color(0xFF0F1629)])
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.08),
                        theme.colorScheme.secondary.withOpacity(0.06),
                        theme.scaffoldBackgroundColor,
                      ],
                    ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                  constraints: BoxConstraints(minHeight: size.height - MediaQuery.of(context).padding.vertical),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        theme.colorScheme.primary,
                                        theme.colorScheme.secondary,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.colorScheme.primary.withOpacity(0.4),
                                        blurRadius: 40,
                                        spreadRadius: 8,
                                        offset: const Offset(0, 8),
                                      ),
                                      BoxShadow(
                                        color: theme.colorScheme.secondary.withOpacity(0.2),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.school_rounded,
                                    size: 56,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Créer un compte',
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? Colors.white : theme.colorScheme.primary,
                                    letterSpacing: 1.2,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Rejoignez notre communauté étudiante',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: isDark ? Colors.white70 : theme.colorScheme.onSurface.withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),

                          SlideTransition(
                            position: _slideAnimation,
                            child: Column(
                              children: [
                                _buildStepIndicator(),
                                const SizedBox(height: 32),
                                Container(
                                  height: 480,
                                  padding: const EdgeInsets.all(28),
                                  decoration: BoxDecoration(
                                    color: isDark 
                                        ? Colors.white.withOpacity(0.06)
                                        : Colors.white.withOpacity(0.95),
                                    borderRadius: BorderRadius.circular(28),
                                    border: Border.all(
                                      color: isDark 
                                          ? Colors.white.withOpacity(0.15)
                                          : Colors.black.withOpacity(0.08),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isDark 
                                            ? Colors.black.withOpacity(0.4)
                                            : Colors.black.withOpacity(0.08),
                                        blurRadius: 30,
                                        offset: const Offset(0, 15),
                                        spreadRadius: 0,
                                      ),
                                      BoxShadow(
                                        color: theme.colorScheme.primary.withOpacity(isDark ? 0.1 : 0.05),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: PageView(controller: _pageController, physics: const NeverScrollableScrollPhysics(), children: [_buildPersonalInfoStep(), _buildSecurityStep()]),
                                ),
                                const SizedBox(height: 24),

                                Row(
                                  children: [
                                    if (_currentStep > 0)
                                      Expanded(
                                        child: Container(
                                          height: 56,
                                          decoration: BoxDecoration(
                                            color: isDark 
                                                ? Colors.white.withOpacity(0.06)
                                                : Colors.black.withOpacity(0.05),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: isDark 
                                                  ? Colors.white.withOpacity(0.18)
                                                  : Colors.black.withOpacity(0.12),
                                              width: 1.5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: isDark 
                                                    ? Colors.black.withOpacity(0.2)
                                                    : Colors.black.withOpacity(0.05),
                                                blurRadius: 15,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: TextButton(
                                            onPressed: _previousStep,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
                                                const SizedBox(width: 8),
                                                Text('Retour', style: theme.textTheme.titleSmall?.copyWith(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (_currentStep > 0) const SizedBox(width: 16),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        height: 56,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              theme.colorScheme.primary,
                                              theme.colorScheme.secondary,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: theme.colorScheme.primary.withOpacity(0.4),
                                              blurRadius: 25,
                                              offset: const Offset(0, 8),
                                              spreadRadius: 0,
                                            ),
                                            BoxShadow(
                                              color: theme.colorScheme.secondary.withOpacity(0.2),
                                              blurRadius: 15,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          onPressed: _currentStep < 1 ? _nextStep : (_isLoading || !_termsAccepted ? null : _register),
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                                          child: _isLoading
                                              ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary)))
                                              : Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(_currentStep < 1 ? 'Suivant' : 'Créer mon compte', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold)),
                                                    const SizedBox(width: 8),
                                                    Icon(_currentStep < 1 ? Icons.arrow_forward : Icons.check_circle, color: theme.colorScheme.onPrimary),
                                                  ],
                                                ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                Center(
                                  child: TextButton(
                                    onPressed: _isLoading
                                        ? null
                                        : () {
                                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                                          },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Déjà un compte ? ', style: theme.textTheme.bodyMedium?.copyWith(color: isDark ? Colors.white70 : Colors.black87)),
                                        Text('Connectez-vous', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
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
              ),
            ),
          ),
          // optional theme toggle in top-right (uncomment if you want)
          // Positioned(top: 0, right: 0, child: _buildThemeToggle(isDark)),
        ],
      ),
    );
  }
}

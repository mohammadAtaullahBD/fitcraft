import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fitcraft/app/router.dart';
import 'package:fitcraft/core/utils/theme.dart';
import 'package:fitcraft/features/auth/presentation/auth_feedback.dart';
import 'package:fitcraft/features/auth/presentation/auth_strings.dart';
import 'package:fitcraft/features/auth/presentation/auth_validation.dart';
import 'package:fitcraft/features/auth/presentation/auth_widgets.dart';
import 'package:fitcraft/features/auth/state/auth_action_state.dart';
import 'package:fitcraft/features/auth/state/auth_form_notifier.dart';

/// Premium dark-themed login screen.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  /// Starts email/password sign-in if the form is valid.
  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authFormNotifierProvider.notifier).signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  /// Starts the Google sign-in flow.
  Future<void> _signInWithGoogle() async {
    await ref.read(authFormNotifierProvider.notifier).signInWithGoogle();
  }

  /// Displays an auth-related error snackbar.
  void _showError(String message) {
    if (!mounted) return;
    showAuthErrorFeedback(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final authActionState = ref.watch(authFormNotifierProvider);
    final isLoading = authActionState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    ref.listen<AuthActionState>(authFormNotifierProvider, (previous, next) {
      next.whenOrNull(error: _showError);
    });

    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 48),
                    _buildEmailField(),
                    const SizedBox(height: 16),
                    _buildPasswordField(),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push(AppRoutes.forgotPassword),
                        child: Text(
                          AuthStrings.forgotPassword,
                          style: const TextStyle(
                            color: AppTheme.accent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildLoginButton(isLoading),
                    const SizedBox(height: 20),
                    const AuthDivider(label: AuthStrings.continueWithDivider),
                    const SizedBox(height: 20),
                    _buildGoogleButton(isLoading),
                    const SizedBox(height: 32),
                    AuthFooterLink(
                      prompt: AuthStrings.noAccountPrompt,
                      actionLabel: AuthStrings.signUp,
                      onTap: () => context.push(AppRoutes.signup),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the branded FitCraft logo/header block.
  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.accessibility_new,
            size: 44,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          AuthStrings.appName,
          style: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          AuthStrings.appTagline,
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: AppTheme.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  /// Builds the email input field.
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: const InputDecoration(
        hintText: AuthStrings.emailHint,
        prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textSecondary),
      ),
      validator: validateEmail,
    );
  }

  /// Builds the password input field.
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _signInWithEmail(),
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        hintText: AuthStrings.passwordHint,
        prefixIcon:
            const Icon(Icons.lock_outline, color: AppTheme.textSecondary),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppTheme.textSecondary,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: validateLoginPassword,
    );
  }

  /// Builds the primary login button.
  Widget _buildLoginButton(bool isLoading) {
    return AuthPrimaryButton(
      isLoading: isLoading,
      onPressed: _signInWithEmail,
      label: AuthStrings.logIn,
    );
  }

  /// Builds the Google sign-in button.
  Widget _buildGoogleButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : _signInWithGoogle,
        icon: Image.network(
          'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
          width: 22,
          height: 22,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.g_mobiledata, size: 28),
        ),
        label: Text(
          AuthStrings.continueWithGoogle,
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            color: AppTheme.surfaceLight,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: AppTheme.surface,
        ),
      ),
    );
  }
}

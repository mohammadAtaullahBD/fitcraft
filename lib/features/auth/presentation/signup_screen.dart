import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fitcraft/app/router.dart';
import 'package:fitcraft/core/utils/theme.dart';
import 'package:fitcraft/features/auth/presentation/auth_feedback.dart';
import 'package:fitcraft/features/auth/presentation/auth_strings.dart';
import 'package:fitcraft/features/auth/presentation/auth_validation.dart';
import 'package:fitcraft/features/auth/presentation/auth_widgets.dart';
import 'package:fitcraft/features/auth/presentation/password_strength.dart';
import 'package:fitcraft/features/auth/state/auth_action_state.dart';
import 'package:fitcraft/features/auth/state/auth_form_notifier.dart';

/// Premium dark-themed sign-up screen.
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  /// Starts account creation if the form is valid.
  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authFormNotifierProvider.notifier).signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim(),
        );
  }

  /// Displays an auth-related error snackbar.
  void _showError(String message) {
    if (!mounted) return;
    showAuthErrorFeedback(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final strength = calculatePasswordStrength(_passwordController.text);
    final authActionState = ref.watch(authFormNotifierProvider);
    final isLoading = authActionState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    ref.listen<AuthActionState>(authFormNotifierProvider, (previous, next) {
      next.whenOrNull(
        error: _showError,
        success: (message) {
          if (!mounted) return;
          context.go(AppRoutes.login);
          showAuthSuccessFeedback(
            context,
            message ?? AuthStrings.verificationEmailSent,
          );
          ref.read(authFormNotifierProvider.notifier).reset();
        },
      );
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
                    _buildHeader(),
                    const SizedBox(height: 36),
                    _buildNameField(),
                    const SizedBox(height: 16),
                    _buildEmailField(),
                    const SizedBox(height: 16),
                    _buildPasswordField(),
                    if (_passwordController.text.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _buildStrengthIndicator(strength),
                    ],
                    const SizedBox(height: 16),
                    _buildConfirmPasswordField(),
                    const SizedBox(height: 32),
                    _buildCreateAccountButton(isLoading),
                    const SizedBox(height: 28),
                    _buildLoginLink(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the screen header.
  Widget _buildHeader() {
    return const AuthHeader(
      title: AuthStrings.createAccountTitle,
      subtitle: AuthStrings.createAccountSubtitle,
    );
  }

  /// Builds the display-name field.
  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: const InputDecoration(
        hintText: AuthStrings.fullNameHint,
        prefixIcon: Icon(Icons.person_outline, color: AppTheme.textSecondary),
      ),
      validator: validateDisplayName,
    );
  }

  /// Builds the email field.
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

  /// Builds the password field.
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.next,
      style: const TextStyle(color: AppTheme.textPrimary),
      onChanged: (_) => setState(() {}),
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
      validator: validateSignupPassword,
    );
  }

  /// Builds the password strength indicator row.
  Widget _buildStrengthIndicator(int strength) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: strength / 4,
              backgroundColor: AppTheme.surfaceLight,
              color: passwordStrengthColor(strength),
              minHeight: 4,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          passwordStrengthLabel(strength),
          style: TextStyle(
            color: passwordStrengthColor(strength),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Builds the confirm-password field.
  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirm,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _signUp(),
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        hintText: AuthStrings.confirmPasswordHint,
        prefixIcon:
            const Icon(Icons.lock_outline, color: AppTheme.textSecondary),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirm
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppTheme.textSecondary,
          ),
          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
        ),
      ),
      validator: (value) => validatePasswordConfirmation(
        value,
        _passwordController.text,
      ),
    );
  }

  /// Builds the primary account-creation button.
  Widget _buildCreateAccountButton(bool isLoading) {
    return AuthPrimaryButton(
      isLoading: isLoading,
      onPressed: _signUp,
      label: AuthStrings.createAccount,
    );
  }

  /// Builds the link back to the login screen.
  Widget _buildLoginLink() {
    return AuthFooterLink(
      prompt: AuthStrings.alreadyHaveAccount,
      actionLabel: AuthStrings.logIn,
      onTap: () => context.pop(),
    );
  }
}

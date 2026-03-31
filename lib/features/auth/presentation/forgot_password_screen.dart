import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fitcraft/core/utils/theme.dart';
import 'package:fitcraft/features/auth/presentation/auth_feedback.dart';
import 'package:fitcraft/features/auth/presentation/auth_strings.dart';
import 'package:fitcraft/features/auth/presentation/auth_validation.dart';
import 'package:fitcraft/features/auth/presentation/auth_widgets.dart';
import 'package:fitcraft/features/auth/state/auth_action_state.dart';
import 'package:fitcraft/features/auth/state/auth_form_notifier.dart';

/// Forgot-password screen — email field + send reset link.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

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
    _fadeController.dispose();
    super.dispose();
  }

  /// Sends a reset-link request when the form is valid.
  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authFormNotifierProvider.notifier)
        .sendResetLink(_emailController.text.trim());
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
      next.whenOrNull(
        error: _showError,
        success: (_) {
          if (!mounted) return;
          setState(() => _emailSent = true);
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
              child: _emailSent
                  ? _buildSuccessState()
                  : _buildFormState(isLoading),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the reset-password form with loading-aware actions.
  Widget _buildFormState(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildResetIcon(),
          const SizedBox(height: 28),
          _buildHeader(),
          const SizedBox(height: 36),
          _buildEmailField(),
          const SizedBox(height: 28),
          _buildSendButton(isLoading),
          const SizedBox(height: 24),
          _buildBackToLoginTextButton(),
        ],
      ),
    );
  }

  /// Builds the icon shown above the reset form.
  Widget _buildResetIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Icon(
        Icons.lock_reset,
        size: 40,
        color: AppTheme.accent,
      ),
    );
  }

  /// Builds the title and subtitle for the reset form.
  Widget _buildHeader() {
    return const AuthHeader(
      title: AuthStrings.resetPasswordTitle,
      subtitle: AuthStrings.resetPasswordSubtitle,
    );
  }

  /// Builds the email input field.
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _sendResetLink(),
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: const InputDecoration(
        hintText: AuthStrings.emailHint,
        prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textSecondary),
      ),
      validator: validateEmail,
    );
  }

  /// Builds the primary reset-link button.
  Widget _buildSendButton(bool isLoading) {
    return AuthPrimaryButton(
      isLoading: isLoading,
      onPressed: _sendResetLink,
      label: AuthStrings.sendResetLink,
    );
  }

  /// Builds the text button that returns to login.
  Widget _buildBackToLoginTextButton() {
    return TextButton.icon(
      onPressed: () => context.pop(),
      icon: const Icon(Icons.arrow_back, size: 18),
      label: const Text(AuthStrings.backToLogin),
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.textSecondary,
      ),
    );
  }

  /// Builds the success state shown after a reset email is sent.
  Widget _buildSuccessState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: AppTheme.success.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            size: 44,
            color: AppTheme.success,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          AuthStrings.checkYourEmail,
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '${AuthStrings.resetEmailSuccessPrefix}${_emailController.text.trim()}',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: AppTheme.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 36),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              AuthStrings.backToLogin,
              style: GoogleFonts.outfit(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

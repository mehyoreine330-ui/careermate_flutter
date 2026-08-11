import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/responsive.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_background.dart';
import '../../widgets/auth_desktop_layout.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glow_button.dart';
import '../../widgets/sleek_text_field.dart';
import 'employer_login_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) return;

    final controller = ref.read(authControllerProvider.notifier);
    if (_isSignUp) {
      controller.signUp(email: email, password: password);
    } else {
      controller.signInWithPassword(email: email, password: password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                error is AuthException ? error.message : l10n.commonSomethingWentWrong,
              ),
            ),
          );
        },
      );
    });

    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: isDesktop
              ? AuthDesktopLayout(
                  headline: l10n.authHeadlineCandidate,
                  description: l10n.authDescriptionCandidate,
                  child: _AuthForm(authState: authState, isSignUp: _isSignUp, onToggle: _toggle, onSubmit: _submit, emailController: _emailController, passwordController: _passwordController),
                )
              : Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: _AuthForm(
                        authState: authState,
                        isSignUp: _isSignUp,
                        onToggle: _toggle,
                        onSubmit: _submit,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        showBrandHeader: true,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  void _toggle() => setState(() => _isSignUp = !_isSignUp);
}

class _AuthForm extends StatelessWidget {
  const _AuthForm({
    required this.authState,
    required this.isSignUp,
    required this.onToggle,
    required this.onSubmit,
    required this.emailController,
    required this.passwordController,
    this.showBrandHeader = false,
  });

  final AsyncValue<void> authState;
  final bool isSignUp;
  final VoidCallback onToggle;
  final VoidCallback onSubmit;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool showBrandHeader;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GlassCard(
      glowColor: AppColors.accentIndigo,
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showBrandHeader) ...[
            ShaderMask(
              shaderCallback: (bounds) => AppColors.accentGradient.createShader(bounds),
              child: const Text(
                'CareerMate',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
            const SizedBox(height: 28),
          ],
          Text(
            isSignUp ? l10n.authCreateAccount : l10n.authWelcomeBack,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            isSignUp ? l10n.authStartOptimizing : l10n.authSignInContinue,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 28),
          SleekTextField(
            controller: emailController,
            label: l10n.authEmailLabel,
            hint: l10n.authEmailHint,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.alternate_email_rounded,
          ),
          const SizedBox(height: 18),
          SleekTextField(
            controller: passwordController,
            label: l10n.authPasswordLabel,
            hint: l10n.authPasswordHint,
            obscureText: true,
            prefixIcon: Icons.lock_outline_rounded,
          ),
          if (!isSignUp) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                ),
                child: Text(
                  l10n.authForgotPassword,
                  style: const TextStyle(color: AppColors.accentCyan, fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          GlowButton(
            label: isSignUp ? l10n.authSignUp : l10n.authSignIn,
            isLoading: authState.isLoading,
            onPressed: onSubmit,
          ),
          const SizedBox(height: 18),
          Center(
            child: TextButton(
              onPressed: onToggle,
              child: Text(
                isSignUp ? l10n.authAlreadyHaveAccount : l10n.authNoAccount,
                style: const TextStyle(
                  color: AppColors.accentCyan,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EmployerLoginScreen()),
              ),
              child: Text(
                l10n.authHiringSignInAsEmployer,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

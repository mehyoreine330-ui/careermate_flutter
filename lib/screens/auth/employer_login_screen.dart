import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/responsive.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/employer_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_background.dart';
import '../../widgets/auth_desktop_layout.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glow_button.dart';
import '../../widgets/sleek_text_field.dart';
import 'forgot_password_screen.dart';

/// Entry point for company accounts — a fully separate sign up/sign in flow
/// from the candidate LoginScreen (reached via its "Hiring? Sign in as an
/// Employer" link), reusing the same Supabase Auth mechanism underneath
/// (authControllerProvider) but creating a `companies` row instead of a
/// `profiles` row at sign up. Pops itself on success — app.dart's
/// _AccountTypeGate, watching the auth stream, then takes over routing.
class EmployerLoginScreen extends ConsumerStatefulWidget {
  const EmployerLoginScreen({super.key});

  @override
  ConsumerState<EmployerLoginScreen> createState() => _EmployerLoginScreenState();
}

class _EmployerLoginScreenState extends ConsumerState<EmployerLoginScreen> {
  final _companyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _submitting = false;

  @override
  void dispose() {
    _companyNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggle() => setState(() => _isSignUp = !_isSignUp);

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final companyName = _companyNameController.text.trim();
    if (email.isEmpty || password.isEmpty) return;
    if (_isSignUp && companyName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.employerAuthEnterCompanyName)),
      );
      return;
    }

    setState(() => _submitting = true);
    final authController = ref.read(authControllerProvider.notifier);

    // Use the user returned directly from the auth call rather than
    // re-reading currentUserProvider afterward — the auth-state-change
    // stream that provider derives from can lag a beat behind the call
    // resolving, which previously caused the company-row write below to
    // run with no authenticated user and silently fail.
    final authUser = _isSignUp
        ? await authController.signUp(email: email, password: password)
        : await authController.signInWithPassword(email: email, password: password);
    if (!mounted) return;

    final authState = ref.read(authControllerProvider);
    if (authState.hasError) {
      setState(() => _submitting = false);
      final error = authState.error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error is AuthException ? error.message : l10n.employerAuthGenericError),
        ),
      );
      return;
    }

    if (authUser == null) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.employerAuthGenericError)),
      );
      return;
    }

    final supabase = ref.read(supabaseClientProvider);

    if (_isSignUp) {
      try {
        await supabase.from('companies').upsert({
          'id': authUser.id,
          'email': authUser.email ?? email,
          'company_name': companyName,
        });
        ref.invalidate(companyProfileProvider);
      } catch (_) {
        if (!mounted) return;
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.employerAuthProfileSaveFailed)),
        );
        Navigator.of(context).pop();
        return;
      }
    } else {
      final companyRow = await supabase.from('companies').select('id').eq('id', authUser.id).maybeSingle();
      if (!mounted) return;
      if (companyRow == null) {
        await supabase.auth.signOut();
        if (!mounted) return;
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.employerAuthNoAccountFound)),
        );
        return;
      }
    }

    if (!mounted) return;
    setState(() => _submitting = false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: isDesktop
              ? AuthDesktopLayout(
                  headline: l10n.employerAuthHeadline,
                  description: l10n.employerAuthDescription,
                  child: _EmployerAuthForm(
                    isSignUp: _isSignUp,
                    submitting: _submitting,
                    onToggle: _toggle,
                    onSubmit: _submit,
                    companyNameController: _companyNameController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                  ),
                )
              : Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: _EmployerAuthForm(
                        isSignUp: _isSignUp,
                        submitting: _submitting,
                        onToggle: _toggle,
                        onSubmit: _submit,
                        companyNameController: _companyNameController,
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
}

class _EmployerAuthForm extends StatelessWidget {
  const _EmployerAuthForm({
    required this.isSignUp,
    required this.submitting,
    required this.onToggle,
    required this.onSubmit,
    required this.companyNameController,
    required this.emailController,
    required this.passwordController,
    this.showBrandHeader = false,
  });

  final bool isSignUp;
  final bool submitting;
  final VoidCallback onToggle;
  final VoidCallback onSubmit;
  final TextEditingController companyNameController;
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
                'CareerMate for Employers',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
            const SizedBox(height: 28),
          ],
          Text(
            isSignUp ? l10n.employerAuthCreateAccount : l10n.employerAuthSignIn,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            isSignUp ? l10n.employerAuthStartPosting : l10n.employerAuthSignInToManage,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 28),
          if (isSignUp) ...[
            SleekTextField(
              controller: companyNameController,
              label: l10n.employerAuthCompanyName,
              hint: l10n.employerAuthCompanyNameHint,
              prefixIcon: Icons.apartment_rounded,
            ),
            const SizedBox(height: 18),
          ],
          SleekTextField(
            controller: emailController,
            label: l10n.employerAuthWorkEmail,
            hint: l10n.employerAuthWorkEmailHint,
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
            label: isSignUp ? l10n.employerAuthCreateCompanyAccount : l10n.authSignIn,
            isLoading: submitting,
            onPressed: submitting ? null : onSubmit,
          ),
          const SizedBox(height: 18),
          Center(
            child: TextButton(
              onPressed: onToggle,
              child: Text(
                isSignUp ? l10n.employerAuthAlreadyHaveAccount : l10n.employerAuthNoAccount,
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
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.employerAuthCandidateSignIn,
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

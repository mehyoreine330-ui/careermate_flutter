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

/// Requests a password-reset email via Supabase Auth. Works for both
/// candidate and employer accounts — password reset isn't account-type
/// specific, it's the same underlying Supabase Auth user either way.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    await ref.read(authControllerProvider.notifier).sendPasswordResetEmail(email);
    if (!mounted) return;

    final state = ref.read(authControllerProvider);
    if (state.hasError) {
      final error = state.error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error is AuthException ? error.message : l10n.commonSomethingWentWrong),
        ),
      );
      return;
    }

    setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDesktop = Responsive.isDesktop(context);
    final sending = ref.watch(authControllerProvider).isLoading;

    final form = GlassCard(
      glowColor: AppColors.accentIndigo,
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 4),
              Text(
                l10n.forgotPasswordTitle,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_sent) ...[
            const SizedBox(height: 8),
            const Icon(Icons.mark_email_read_outlined, color: AppColors.accentCyan, size: 40),
            const SizedBox(height: 16),
            Text(
              l10n.forgotPasswordCheckEmail,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.forgotPasswordSentBody(_emailController.text.trim()),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5, height: 1.45),
            ),
          ] else ...[
            Text(
              l10n.forgotPasswordBody,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5, height: 1.4),
            ),
            const SizedBox(height: 24),
            SleekTextField(
              controller: _emailController,
              label: l10n.authEmailLabel,
              hint: l10n.authEmailHint,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.alternate_email_rounded,
            ),
            const SizedBox(height: 24),
            GlowButton(
              label: l10n.forgotPasswordSendLink,
              isLoading: sending,
              onPressed: sending ? null : _submit,
            ),
          ],
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: isDesktop
              ? AuthDesktopLayout(
                  headline: l10n.forgotPasswordHeadline,
                  description: l10n.forgotPasswordDescription,
                  child: form,
                )
              : Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: form,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

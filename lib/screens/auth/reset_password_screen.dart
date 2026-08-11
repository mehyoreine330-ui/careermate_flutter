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

/// Shown by app.dart's _AuthGate when Supabase fires
/// AuthChangeEvent.passwordRecovery (the user followed a reset-password
/// email link). Sets a new password using the recovery session Supabase
/// already established, then signs out so the user re-authenticates
/// cleanly with their new password.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  @override
  void dispose() {
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final password = _newPassword.text;
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.resetPasswordTooShort)),
      );
      return;
    }
    if (password != _confirmPassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.resetPasswordMismatch)),
      );
      return;
    }

    await ref.read(authControllerProvider.notifier).updatePassword(password);
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

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.resetPasswordUpdated)),
    );
    await ref.read(supabaseClientProvider).auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDesktop = Responsive.isDesktop(context);
    final saving = ref.watch(authControllerProvider).isLoading;

    final form = GlassCard(
      glowColor: AppColors.accentIndigo,
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.resetPasswordSetNew,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.resetPasswordChooseNew,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
          ),
          const SizedBox(height: 24),
          SleekTextField(controller: _newPassword, label: l10n.resetPasswordNewPassword, obscureText: true),
          const SizedBox(height: 18),
          SleekTextField(controller: _confirmPassword, label: l10n.resetPasswordConfirmPassword, obscureText: true),
          const SizedBox(height: 24),
          GlowButton(
            label: l10n.resetPasswordUpdate,
            isLoading: saving,
            onPressed: saving ? null : _submit,
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: isDesktop
              ? AuthDesktopLayout(
                  headline: l10n.resetPasswordHeadline,
                  description: l10n.resetPasswordDescription,
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

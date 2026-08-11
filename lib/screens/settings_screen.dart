import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/generated/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/fade_in.dart';
import '../widgets/glass_card.dart';
import '../widgets/glow_button.dart';
import '../widgets/legal_links_card.dart';
import '../widgets/sleek_text_field.dart';

/// Settings: appearance/notification placeholders, a real language switcher
/// (persisted to Supabase via [localeProvider], applies instantly with no
/// app restart), a real Change Password flow (Supabase self-service
/// `auth.updateUser`), and a Delete Account entry point with a confirmation
/// dialog. Account deletion itself needs an admin-privileged backend
/// endpoint that doesn't exist yet — the dialog is wired up so the
/// destructive action has a safe home once that lands, rather than
/// performing an irreversible delete with no server support.
class SettingsContent extends ConsumerStatefulWidget {
  const SettingsContent({super.key});

  @override
  ConsumerState<SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends ConsumerState<SettingsContent> {
  bool _darkMode = true;
  bool _emailNotifications = true;
  bool _pushNotifications = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);

    return SingleChildScrollView(
      child: FadeSlideIn(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.accentGradient),
                  child: const Icon(Icons.settings_outlined,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 14),
                Text(l10n.settingsTitle,
                    style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 54),
              child: Text(
                l10n.settingsSubtitle,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
            const SizedBox(height: 28),
            _SectionCard(
              title: l10n.settingsAppearance,
              children: [
                _SwitchRow(
                  label: l10n.settingsDarkMode,
                  subtitle: l10n.settingsDarkModeSubtitle,
                  value: _darkMode,
                  onChanged: null,
                ),
                const SizedBox(height: 16),
                _LanguageDropdownRow(
                  label: l10n.settingsLanguage,
                  value: currentLocale,
                  onChanged: (locale) {
                    if (locale != null) {
                      ref.read(localeProvider.notifier).setLocale(locale);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SectionCard(
              title: l10n.settingsNotifications,
              children: [
                _SwitchRow(
                  label: l10n.settingsEmailNotifications,
                  subtitle: l10n.settingsEmailNotificationsSubtitle,
                  value: _emailNotifications,
                  onChanged: (v) => setState(() => _emailNotifications = v),
                ),
                const SizedBox(height: 16),
                _SwitchRow(
                  label: l10n.settingsPushNotifications,
                  subtitle: l10n.settingsPushNotificationsSubtitle,
                  value: _pushNotifications,
                  onChanged: (v) => setState(() => _pushNotifications = v),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const _ChangePasswordCard(),
            const SizedBox(height: 20),
            const _DeleteAccountCard(),
            const SizedBox(height: 20),
            const LegalLinksCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16.5)),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow(
      {required this.label,
      required this.subtitle,
      required this.value,
      required this.onChanged});

  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 3),
              Text(subtitle,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.accentCyan,
        ),
      ],
    );
  }
}

/// The real language picker — lists every locale in [kSupportedLocales]
/// under its own native name (see [kLocaleNativeNames]) so a user can find
/// their language regardless of the app's current display language.
/// Selecting one calls [LocaleController.setLocale], which updates the UI
/// immediately (no restart) and persists the choice to Supabase.
class _LanguageDropdownRow extends StatelessWidget {
  const _LanguageDropdownRow(
      {required this.label, required this.value, required this.onChanged});

  final String label;
  final Locale value;
  final ValueChanged<Locale?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ),
        DropdownButton<Locale>(
          value: value,
          dropdownColor: AppColors.surface,
          underline: const SizedBox.shrink(),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          items: [
            for (final locale in kSupportedLocales)
              DropdownMenuItem(
                value: locale,
                child: Text(kLocaleNativeNames[locale.languageCode] ??
                    locale.languageCode),
              ),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _ChangePasswordCard extends ConsumerStatefulWidget {
  const _ChangePasswordCard();

  @override
  ConsumerState<_ChangePasswordCard> createState() =>
      _ChangePasswordCardState();
}

class _ChangePasswordCardState extends ConsumerState<_ChangePasswordCard> {
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _saving = false;

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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.settingsPasswordTooShort)));
      return;
    }
    if (password != _confirmPassword.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.settingsPasswordMismatch)));
      return;
    }

    setState(() => _saving = true);
    try {
      await ref
          .read(supabaseClientProvider)
          .auth
          .updateUser(UserAttributes(password: password));
      if (!mounted) return;
      _newPassword.clear();
      _confirmPassword.clear();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.settingsPasswordUpdated)));
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _SectionCard(
      title: l10n.settingsChangePassword,
      children: [
        SleekTextField(
            controller: _newPassword,
            label: l10n.resetPasswordNewPassword,
            obscureText: true),
        const SizedBox(height: 14),
        SleekTextField(
            controller: _confirmPassword,
            label: l10n.resetPasswordConfirmPassword,
            obscureText: true),
        const SizedBox(height: 16),
        GlowButton(
          label: l10n.settingsUpdatePassword,
          expand: false,
          isLoading: _saving,
          onPressed: _saving ? null : _submit,
        ),
      ],
    );
  }
}

class _DeleteAccountCard extends StatelessWidget {
  const _DeleteAccountCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GlassCard(
      glowColor: AppColors.danger,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.settingsDeleteAccount,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
          const SizedBox(height: 8),
          Text(
            l10n.settingsDeleteAccountBody,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12.5, height: 1.4),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: const BorderSide(color: AppColors.danger),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => _confirmDelete(context),
            child: Text(l10n.settingsDeleteMyAccount),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(l10n.settingsDeleteAccountConfirmTitle,
            style: const TextStyle(color: Colors.white)),
        content: Text(
          l10n.settingsDeleteAccountConfirmBody,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.settingsDeleteAccountUnavailable)),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
  }
}

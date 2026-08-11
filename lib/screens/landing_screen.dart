import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/responsive.dart';
import '../l10n/generated/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/glow_button.dart';
import '../widgets/responsive_card_grid.dart';
import 'auth/login_screen.dart';

/// Pre-authentication marketing landing page: shown instead of [LoginScreen]
/// whenever there is no Supabase session (see app.dart's `_AuthGate`).
/// Purely additive — "Get Started" is the only way forward, and it just
/// pushes the existing, untouched [LoginScreen] on top.
class LandingScreen extends ConsumerWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDesktop = Responsive.isDesktop(context);
    final horizontalPadding = Responsive.isMobile(context) ? 20.0 : (isDesktop ? 64.0 : 40.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(horizontalPadding, 56, horizontalPadding, 40),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1080),
                    child: _EntranceFade(
                      child: Column(
                        children: [
                          _Hero(l10n: l10n, isDesktop: isDesktop),
                          const SizedBox(height: 56),
                          _FeatureSection(l10n: l10n),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const Positioned(top: 4, right: 4, child: _LanguageSelector()),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple one-shot fade + rise entrance for the whole page — a `TweenAnimationBuilder`
/// needs no controller/dispose bookkeeping since it only ever plays once per mount.
class _EntranceFade extends StatelessWidget {
  const _EntranceFade({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(offset: Offset(0, (1 - value) * 16), child: child),
        );
      },
      child: child,
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.l10n, required this.isDesktop});

  final AppLocalizations l10n;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => AppColors.accentGradient.createShader(bounds),
          child: Text(
            'CareerMate',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isDesktop ? 52 : 38,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.05,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.landingSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isDesktop ? 20 : 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: isDesktop ? 48 : 32),
        _ProfessionsIllustration(size: isDesktop ? 340 : 250),
        SizedBox(height: isDesktop ? 48 : 32),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Text(
            l10n.landingDescription,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: isDesktop ? 16.5 : 14.5,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 32),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: isDesktop ? 280 : 0),
          child: GlowButton(
            label: l10n.landingGetStarted,
            icon: Icons.arrow_forward_rounded,
            expand: !isDesktop,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
          ),
        ),
      ],
    );
  }
}

/// Six floating profession badges orbiting a central "AI" orb — built entirely
/// from Flutter primitives (no image assets/packages) so it stays crisp at
/// any size and matches the app's existing glass/neon-gradient visual language.
class _ProfessionsIllustration extends StatefulWidget {
  const _ProfessionsIllustration({required this.size});

  final double size;

  @override
  State<_ProfessionsIllustration> createState() => _ProfessionsIllustrationState();
}

class _ProfessionsIllustrationState extends State<_ProfessionsIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _badges = [
    (icon: Icons.medical_services_rounded, color: AppColors.accentIndigo, align: Alignment(-0.8, -0.9)),
    (icon: Icons.code_rounded, color: AppColors.accentCyan, align: Alignment(0.8, -0.9)),
    (icon: Icons.school_rounded, color: Color(0xFFA78BFA), align: Alignment(-1.0, 0.0)),
    (icon: Icons.gavel_rounded, color: Color(0xFFFBBF24), align: Alignment(1.0, 0.0)),
    (icon: Icons.business_center_rounded, color: Color(0xFF34D399), align: Alignment(-0.55, 0.95)),
    (icon: Icons.engineering_rounded, color: Color(0xFFFB7185), align: Alignment(0.55, 0.95)),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badgeSize = widget.size * 0.2;
    final centerSize = widget.size * 0.34;

    return ExcludeSemantics(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Soft ambient halo behind everything, unifying the composition.
            Container(
              width: widget.size * 0.82,
              height: widget.size * 0.82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentIndigo.withValues(alpha: 0.22),
                    AppColors.accentIndigo.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
            // Central AI orb.
            Container(
              width: centerSize,
              height: centerSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.accentGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentIndigo.withValues(alpha: 0.45),
                    blurRadius: 36,
                    spreadRadius: -4,
                  ),
                ],
                border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 2),
              ),
              child: Icon(Icons.auto_awesome_rounded, color: Colors.white, size: centerSize * 0.42),
            ),
            for (var i = 0; i < _badges.length; i++)
              Align(
                alignment: _badges[i].align,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final phase = i * (2 * math.pi / _badges.length);
                    final dy = math.sin(_controller.value * 2 * math.pi + phase) * (widget.size * 0.025);
                    return Transform.translate(offset: Offset(0, dy), child: child);
                  },
                  child: _ProfessionBadge(
                    icon: _badges[i].icon,
                    color: _badges[i].color,
                    size: badgeSize,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfessionBadge extends StatelessWidget {
  const _ProfessionBadge({required this.icon, required this.color, required this.size});

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.7)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 20, spreadRadius: -4),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.46),
    );
  }
}

class _FeatureSection extends StatelessWidget {
  const _FeatureSection({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final features = [
      (
        icon: Icons.description_outlined,
        title: l10n.landingFeatureResumeTitle,
        subtitle: l10n.landingFeatureResumeSubtitle,
      ),
      (
        icon: Icons.work_outline_rounded,
        title: l10n.landingFeatureJobMatchTitle,
        subtitle: l10n.landingFeatureJobMatchSubtitle,
      ),
      (
        icon: Icons.mic_none_outlined,
        title: l10n.landingFeatureInterviewTitle,
        subtitle: l10n.landingFeatureInterviewSubtitle,
      ),
      (
        icon: Icons.route_outlined,
        title: l10n.landingFeatureRoadmapTitle,
        subtitle: l10n.landingFeatureRoadmapSubtitle,
      ),
      (
        icon: Icons.menu_book_outlined,
        title: l10n.landingFeatureLearningTitle,
        subtitle: l10n.landingFeatureLearningSubtitle,
      ),
      (
        icon: Icons.translate_rounded,
        title: l10n.landingFeatureLanguageTitle,
        subtitle: l10n.landingFeatureLanguageSubtitle,
      ),
    ];

    return ResponsiveCardGrid(
      spacing: 16,
      columnsForWidth: (width) {
        if (width >= 900) return 3;
        if (width >= 560) return 2;
        return 1;
      },
      cards: [
        for (final feature in features)
          _FeatureCard(icon: feature.icon, title: feature.title, subtitle: feature.subtitle),
      ],
    );
  }
}

/// Static (non-interactive) highlight card — informational only, so unlike
/// [QuickActionCard] it deliberately has no hover/tap affordance to imply.
class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: AppColors.accentGradient,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.4),
          ),
        ],
      ),
    );
  }
}

/// Compact language picker pinned to the top-right corner (fixed screen
/// position in every locale, LTR or RTL) — reuses the exact same
/// [localeProvider] / [kSupportedLocales] / [kLocaleNativeNames] the Settings
/// screen's language picker already uses, so switching here is identical to
/// switching there: instant, app-wide, and persisted once signed in.
class _LanguageSelector extends ConsumerWidget {
  const _LanguageSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.language_rounded, size: 16, color: AppColors.accentCyan),
          const SizedBox(width: 6),
          DropdownButtonHideUnderline(
            child: DropdownButton<Locale>(
              value: currentLocale,
              isDense: true,
              dropdownColor: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              icon: const Icon(Icons.expand_more_rounded, color: AppColors.textSecondary, size: 16),
              style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
              items: [
                for (final locale in kSupportedLocales)
                  DropdownMenuItem(
                    value: locale,
                    child: Text(kLocaleNativeNames[locale.languageCode] ?? locale.languageCode),
                  ),
              ],
              onChanged: (locale) {
                if (locale != null) ref.read(localeProvider.notifier).setLocale(locale);
              },
            ),
          ),
        ],
      ),
    );
  }
}

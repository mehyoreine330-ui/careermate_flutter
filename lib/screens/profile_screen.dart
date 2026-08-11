import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_exception.dart';
import '../core/responsive.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/onboarding_models.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/resume_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/empty_state.dart';
import '../widgets/fade_in.dart';
import '../widgets/glass_card.dart';
import '../widgets/glow_button.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/sleek_text_field.dart';

/// My Profile: view + edit the fields collected during onboarding, plus a
/// read-only email and resume-upload status. Saves go straight to Supabase's
/// `profiles` table (same RLS-protected upsert pattern as onboarding).
class ProfileContent extends ConsumerStatefulWidget {
  const ProfileContent({super.key});

  @override
  ConsumerState<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends ConsumerState<ProfileContent> {
  bool _editing = false;

  late final TextEditingController _fullName;
  late final TextEditingController _country;
  late final TextEditingController _university;
  late final TextEditingController _major;
  late final TextEditingController _graduationYear;
  late final TextEditingController _dreamJob;
  late final TextEditingController _targetCountry;
  late final TextEditingController _skills;

  bool _controllersReady = false;

  void _initControllers(OnboardingProfile profile) {
    if (_controllersReady) return;
    _fullName = TextEditingController(text: profile.fullName);
    _country = TextEditingController(text: profile.country);
    _university = TextEditingController(text: profile.university);
    _major = TextEditingController(text: profile.major);
    _graduationYear = TextEditingController(text: profile.graduationYear);
    _dreamJob = TextEditingController(text: profile.dreamJob);
    _targetCountry = TextEditingController(text: profile.targetCountry);
    _skills = TextEditingController(text: profile.skills);
    _controllersReady = true;
  }

  @override
  void dispose() {
    if (_controllersReady) {
      _fullName.dispose();
      _country.dispose();
      _university.dispose();
      _major.dispose();
      _graduationYear.dispose();
      _dreamJob.dispose();
      _targetCountry.dispose();
      _skills.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    await ref.read(profileEditControllerProvider.notifier).updateFields({
      'full_name': _fullName.text.trim(),
      'country': _country.text.trim(),
      'university': _university.text.trim(),
      'major': _major.text.trim(),
      'graduation_year': _graduationYear.text.trim(),
      'dream_job': _dreamJob.text.trim(),
      'target_country': _targetCountry.text.trim(),
      'skills': _skills.text.trim(),
    });

    if (!mounted) return;
    final editState = ref.read(profileEditControllerProvider);
    if (editState.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            editState.error is ApiException
                ? (editState.error as ApiException).message
                : l10n.profileCouldNotUpdate,
          ),
        ),
      );
      return;
    }
    setState(() => _editing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.profileUpdated)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profileAsync = ref.watch(userProfileProvider);
    final resumeAsync = ref.watch(latestResumeSummaryProvider);
    final user = ref.watch(currentUserProvider);
    final isDesktop = Responsive.isDesktop(context);
    final saving = ref.watch(profileEditControllerProvider).isLoading;

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
                  child: const Icon(Icons.person_outline_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(l10n.profileTitle,
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
                profileAsync.maybeWhen(
                  data: (profile) => profile == null
                      ? const SizedBox.shrink()
                      : (_editing
                          ? Row(
                              children: [
                                TextButton(
                                  onPressed: saving
                                      ? null
                                      : () => setState(() => _editing = false),
                                  child: Text(l10n.commonCancel),
                                ),
                                const SizedBox(width: 8),
                                GlowButton(
                                  label: l10n.commonSave,
                                  expand: false,
                                  isLoading: saving,
                                  onPressed: saving ? null : _save,
                                ),
                              ],
                            )
                          : GlowButton(
                              label: l10n.commonEditProfile,
                              icon: Icons.edit_outlined,
                              expand: false,
                              onPressed: () => setState(() => _editing = true),
                            )),
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 54),
              child: Text(
                l10n.profileSubtitle,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
            const SizedBox(height: 22),
            profileAsync.when(
              data: (profile) {
                if (profile == null) {
                  return EmptyStateCard(
                    icon: Icons.person_off_outlined,
                    message: l10n.profileNotFound,
                  );
                }
                _initControllers(profile);
                return _editing
                    ? _EditForm(
                        isDesktop: isDesktop,
                        fullName: _fullName,
                        country: _country,
                        university: _university,
                        major: _major,
                        graduationYear: _graduationYear,
                        dreamJob: _dreamJob,
                        targetCountry: _targetCountry,
                        skills: _skills,
                      )
                    : _ViewGrid(
                        isDesktop: isDesktop,
                        profile: profile,
                        email: user?.email ?? '',
                        resumeStatus: resumeAsync,
                      );
              },
              loading: () => _ProfileSkeleton(isDesktop: isDesktop),
              error: (error, _) => EmptyStateCard(
                icon: Icons.error_outline_rounded,
                glowColor: AppColors.danger,
                message: l10n.profileCouldNotLoad(error.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton({required this.isDesktop});

  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = isDesktop ? 2 : 1;
        const spacing = 16.0;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (var i = 0; i < 6; i++)
              SizedBox(
                  width: itemWidth,
                  child: const ShimmerCard(lines: 1, titleWidth: 90)),
          ],
        );
      },
    );
  }
}

class _ViewGrid extends StatelessWidget {
  const _ViewGrid({
    required this.isDesktop,
    required this.profile,
    required this.email,
    required this.resumeStatus,
  });

  final bool isDesktop;
  final OnboardingProfile profile;
  final String email;
  final AsyncValue resumeStatus;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final resumeLabel = resumeStatus.when(
      data: (r) => r == null
          ? l10n.profileNoResumeUploaded
          : l10n.profileResumeUploaded(r.atsScore),
      loading: () => l10n.profileChecking,
      error: (_, __) => l10n.commonUnknown,
    );

    final fields = <MapEntry<String, String>>[
      MapEntry(
          l10n.profileFullName,
          profile.fullName.isEmpty
              ? l10n.commonNotAvailable
              : profile.fullName),
      MapEntry(
          l10n.profileEmail, email.isEmpty ? l10n.commonNotAvailable : email),
      MapEntry(l10n.profileCountry,
          profile.country.isEmpty ? l10n.commonNotAvailable : profile.country),
      MapEntry(l10n.profileFieldOfStudy,
          profile.major.isEmpty ? l10n.commonNotAvailable : profile.major),
      MapEntry(
          l10n.profileUniversity,
          profile.university.isEmpty
              ? l10n.commonNotAvailable
              : profile.university),
      MapEntry(
          l10n.profileGraduationYear,
          profile.graduationYear.isEmpty
              ? l10n.commonNotAvailable
              : profile.graduationYear),
      MapEntry(
          l10n.profileDreamJob,
          profile.dreamJob.isEmpty
              ? l10n.commonNotAvailable
              : profile.dreamJob),
      MapEntry(
          l10n.profileTargetCountry,
          profile.targetCountry.isEmpty
              ? l10n.commonNotAvailable
              : profile.targetCountry),
      MapEntry(l10n.profileSkills,
          profile.skills.isEmpty ? l10n.commonNotAvailable : profile.skills),
      MapEntry(l10n.profileResumeStatus, resumeLabel),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = isDesktop ? 2 : 1;
        const spacing = 16.0;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final field in fields)
              SizedBox(
                width: itemWidth,
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        field.key.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(field.value,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14.5)),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _EditForm extends StatelessWidget {
  const _EditForm({
    required this.isDesktop,
    required this.fullName,
    required this.country,
    required this.university,
    required this.major,
    required this.graduationYear,
    required this.dreamJob,
    required this.targetCountry,
    required this.skills,
  });

  final bool isDesktop;
  final TextEditingController fullName;
  final TextEditingController country;
  final TextEditingController university;
  final TextEditingController major;
  final TextEditingController graduationYear;
  final TextEditingController dreamJob;
  final TextEditingController targetCountry;
  final TextEditingController skills;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldRow(isDesktop: isDesktop, children: [
            SleekTextField(controller: fullName, label: l10n.profileFullName),
            SleekTextField(controller: country, label: l10n.profileCountry),
          ]),
          const SizedBox(height: 16),
          _FieldRow(isDesktop: isDesktop, children: [
            SleekTextField(controller: major, label: l10n.profileFieldOfStudy),
            SleekTextField(
                controller: university, label: l10n.profileUniversity),
          ]),
          const SizedBox(height: 16),
          _FieldRow(isDesktop: isDesktop, children: [
            SleekTextField(
                controller: graduationYear, label: l10n.profileGraduationYear),
            SleekTextField(
                controller: targetCountry, label: l10n.profileTargetCountry),
          ]),
          const SizedBox(height: 16),
          SleekTextField(controller: dreamJob, label: l10n.profileDreamJob),
          const SizedBox(height: 16),
          SleekTextField(controller: skills, label: l10n.profileSkills),
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.isDesktop, required this.children});

  final bool isDesktop;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (!isDesktop) {
      return Column(
        children: [
          for (final child in children) ...[child, const SizedBox(height: 16)],
        ],
      );
    }
    return Row(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: 16),
          Expanded(child: children[i]),
        ],
      ],
    );
  }
}

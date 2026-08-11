/// Onboarding profile data — maps directly onto Supabase's `profiles` table.
///
/// Requires one new column beyond the original schema (careermate-backend's
/// db design only had `country`, not a free-text city):
///
///   alter table public.profiles add column if not exists city text;
///
/// `target_industry` and `remote_preference` already existed in that schema
/// and are reused here as-is — "Target Career" maps to target_industry,
/// "Preferred Internship Type" maps to remote_preference (remote/hybrid/
/// onsite/any), so no other migration is needed.
class OnboardingProfile {
  const OnboardingProfile({
    required this.fullName,
    required this.city,
    required this.targetIndustry,
    required this.remotePreference,
    this.onboardingCompleted = false,
    this.country = '',
    this.university = '',
    this.major = '',
    this.graduationYear = '',
    this.workExperience = '',
    this.skills = '',
    this.dreamJob = '',
    this.targetCountry = '',
    this.hasResume = '',
  });

  final String fullName;
  final String city;
  final String targetIndustry;
  final String remotePreference; // 'remote' | 'hybrid' | 'onsite' | 'any'

  /// Set once the AI Welcome onboarding chat (lib/screens/ai_welcome_screen.dart)
  /// finishes — the auth gate uses this, not [isComplete], to decide whether
  /// a returning user goes straight to the dashboard.
  final bool onboardingCompleted;

  // Fields collected by the AI Welcome onboarding chat (see
  // careermate-backend/routers/onboarding.py's ONBOARDING_FIELDS) — free-text
  // answers stored as-is, used by My Profile / discipline-aware Career Report.
  final String country;
  final String university;
  final String major; // field of study
  final String graduationYear;
  final String workExperience;
  final String skills;
  final String dreamJob;
  final String targetCountry;
  final String hasResume; // free-text answer, not a bool

  factory OnboardingProfile.fromJson(Map<String, dynamic> json) => OnboardingProfile(
        fullName: json['full_name'] as String? ?? '',
        city: json['city'] as String? ?? '',
        targetIndustry: json['target_industry'] as String? ?? '',
        remotePreference: json['remote_preference'] as String? ?? 'any',
        onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
        country: json['country'] as String? ?? '',
        university: json['university'] as String? ?? '',
        major: json['major'] as String? ?? '',
        graduationYear: json['graduation_year'] as String? ?? '',
        workExperience: json['work_experience'] as String? ?? '',
        skills: json['skills'] as String? ?? '',
        dreamJob: json['dream_job'] as String? ?? '',
        targetCountry: json['target_country'] as String? ?? '',
        hasResume: json['has_resume'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        'city': city,
        'target_industry': targetIndustry,
        'remote_preference': remotePreference,
        'country': country,
        'university': university,
        'major': major,
        'graduation_year': graduationYear,
        'work_experience': workExperience,
        'skills': skills,
        'dream_job': dreamJob,
        'target_country': targetCountry,
        'has_resume': hasResume,
      };

  OnboardingProfile copyWith({
    String? fullName,
    String? city,
    String? targetIndustry,
    String? remotePreference,
    String? country,
    String? university,
    String? major,
    String? graduationYear,
    String? workExperience,
    String? skills,
    String? dreamJob,
    String? targetCountry,
  }) {
    return OnboardingProfile(
      fullName: fullName ?? this.fullName,
      city: city ?? this.city,
      targetIndustry: targetIndustry ?? this.targetIndustry,
      remotePreference: remotePreference ?? this.remotePreference,
      onboardingCompleted: onboardingCompleted,
      country: country ?? this.country,
      university: university ?? this.university,
      major: major ?? this.major,
      graduationYear: graduationYear ?? this.graduationYear,
      workExperience: workExperience ?? this.workExperience,
      skills: skills ?? this.skills,
      dreamJob: dreamJob ?? this.dreamJob,
      targetCountry: targetCountry ?? this.targetCountry,
      hasResume: hasResume,
    );
  }

  /// Whether onboarding has meaningfully been completed — used by the auth
  /// gate to decide between showing the onboarding chat or the app shell.
  bool get isComplete => fullName.isNotEmpty && city.isNotEmpty && targetIndustry.isNotEmpty;
}

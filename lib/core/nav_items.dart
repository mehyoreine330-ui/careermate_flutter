import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

/// How a sidebar tap behaves: swap the shell's content area in place, or
/// push a full-screen route on top of the shell (for the two fully-built
/// feature screens with their own back button, plus sign-out as an action).
enum NavAction { contentSwap, pushScreen, signOut }

class NavItem {
  const NavItem({
    required this.key,
    required this.icon,
    required this.action,
  });

  final String key;
  final IconData icon;
  final NavAction action;
}

/// Resolves a [NavItem.key] to its localized label — kept as a lookup
/// function rather than a field on [NavItem] because [kNavItems] /
/// [kEmployerNavItems] are top-level `const` lists (built once at compile
/// time), while the label text must react to the current locale.
String navItemLabel(AppLocalizations l10n, String key) {
  switch (key) {
    case 'dashboard':
      return l10n.navDashboard;
    case 'resume_analyzer':
      return l10n.navResumeAnalyzer;
    case 'career_report':
      return l10n.navCareerReport;
    case 'career_roadmap':
      return l10n.navCareerRoadmap;
    case 'job_matching':
      return l10n.navJobMatching;
    case 'saved_jobs':
      return l10n.navSavedJobs;
    case 'internships':
      return l10n.navInternships;
    case 'ai_career_coach':
      return l10n.navAiCareerCoach;
    case 'learning_hub':
      return l10n.navLearningHub;
    case 'mock_interview':
      return l10n.navMockInterview;
    case 'ai_avatar':
      return l10n.navAiAvatar;
    case 'profile':
      return l10n.navMyProfile;
    case 'settings':
      return l10n.navSettings;
    case 'logout':
      return l10n.navLogout;
    case 'employer_dashboard':
      return l10n.navEmployerDashboard;
    case 'employer_jobs':
      return l10n.navEmployerJobs;
    case 'employer_company_profile':
      return l10n.navEmployerCompanyProfile;
    default:
      return key;
  }
}

/// The 12 items in CareerMate's permanent candidate navigation, in display
/// order. `contentSwap` items are rendered inside AppShellScreen's own
/// content area (sidebar stays visible); `pushScreen` items open an
/// existing, fully-built screen via Navigator.push (their own back button
/// returns to the shell); `signOut` is an action, not a page.
const List<NavItem> kNavItems = [
  NavItem(key: 'dashboard', icon: Icons.dashboard_rounded, action: NavAction.contentSwap),
  NavItem(key: 'resume_analyzer', icon: Icons.description_outlined, action: NavAction.pushScreen),
  NavItem(key: 'career_report', icon: Icons.auto_awesome_rounded, action: NavAction.pushScreen),
  NavItem(key: 'career_roadmap', icon: Icons.route_outlined, action: NavAction.pushScreen),
  NavItem(key: 'job_matching', icon: Icons.work_outline_rounded, action: NavAction.contentSwap),
  NavItem(key: 'saved_jobs', icon: Icons.bookmark_outline_rounded, action: NavAction.contentSwap),
  NavItem(key: 'internships', icon: Icons.school_outlined, action: NavAction.contentSwap),
  NavItem(key: 'ai_career_coach', icon: Icons.support_agent_rounded, action: NavAction.contentSwap),
  NavItem(key: 'learning_hub', icon: Icons.menu_book_outlined, action: NavAction.contentSwap),
  NavItem(key: 'mock_interview', icon: Icons.mic_none_outlined, action: NavAction.pushScreen),
  NavItem(key: 'ai_avatar', icon: Icons.face_retouching_natural_rounded, action: NavAction.contentSwap),
  NavItem(key: 'profile', icon: Icons.person_outline_rounded, action: NavAction.contentSwap),
  NavItem(key: 'settings', icon: Icons.settings_outlined, action: NavAction.contentSwap),
  NavItem(key: 'logout', icon: Icons.logout_rounded, action: NavAction.signOut),
];

/// The Employer Portal's own permanent navigation — a fully separate
/// experience from the candidate app (see app.dart's _AccountTypeGate),
/// rendered by the same SidebarNav widget with this list instead.
const List<NavItem> kEmployerNavItems = [
  NavItem(key: 'employer_dashboard', icon: Icons.dashboard_rounded, action: NavAction.contentSwap),
  NavItem(key: 'employer_jobs', icon: Icons.work_outline_rounded, action: NavAction.contentSwap),
  NavItem(key: 'employer_company_profile', icon: Icons.apartment_rounded, action: NavAction.contentSwap),
  NavItem(key: 'logout', icon: Icons.logout_rounded, action: NavAction.signOut),
];

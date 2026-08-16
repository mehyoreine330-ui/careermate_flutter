import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/nav_items.dart';
import '../core/responsive.dart';
import '../l10n/generated/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/fade_in.dart';
import '../widgets/icon_glow_button.dart';
import '../widgets/notification_bell_button.dart';
import '../widgets/sidebar_nav.dart';
import 'ai_avatar_screen.dart';
import 'career_coach_screen.dart';
import 'career_report_screen.dart';
import 'career_roadmap_screen.dart';
import 'dashboard_home_content.dart';
import 'internships_screen.dart';
import 'job_matching_screen.dart';
import 'learning_hub_screen.dart';
import 'mock_interview_screen.dart';
import 'profile_screen.dart';
import 'resume_analyzer_screen.dart';
import 'saved_jobs_screen.dart';
import 'settings_screen.dart';

/// The application shell: a permanent left sidebar on desktop / a
/// collapsible drawer on mobile, wrapping every content-swap page
/// (Dashboard, the "Coming Soon" modules, My Profile, Settings). The two
/// fully-built feature screens (Resume Analyzer, Career Report) and Mock
/// Interview are pushed on top via Navigator instead of embedded here —
/// they're complete screens with their own back button and business logic
/// that must keep working exactly as before.
class AppShellScreen extends ConsumerStatefulWidget {
  const AppShellScreen({super.key});

  @override
  ConsumerState<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends ConsumerState<AppShellScreen> {
  String _selectedKey = 'dashboard';
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _handleSelect(NavItem item) {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      _scaffoldKey.currentState?.closeDrawer();
    }
    switch (item.action) {
      case NavAction.contentSwap:
        setState(() => _selectedKey = item.key);
        break;
      case NavAction.pushScreen:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => _screenFor(item.key)));
        break;
      case NavAction.signOut:
        ref.read(authControllerProvider.notifier).signOut();
        break;
    }
  }

  Widget _screenFor(String key) {
    switch (key) {
      case 'resume_analyzer':
        return const ResumeAnalyzerScreen();
      case 'career_report':
        return const CareerReportScreen();
      case 'career_roadmap':
        return const CareerRoadmapScreen();
      case 'mock_interview':
        return const MockInterviewScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _contentFor(String key) {
    switch (key) {
      case 'dashboard':
        return DashboardHomeContent(
            onNavigate: (k) => setState(() => _selectedKey = k));
      case 'job_matching':
        return const JobMatchingContent();
      case 'saved_jobs':
        return const SavedJobsContent();
      case 'internships':
        return const InternshipsContent();
      case 'ai_career_coach':
        return const AiCareerCoachContent();
      case 'learning_hub':
        return const LearningHubContent();
      case 'ai_avatar':
        return const AiAvatarContent();
      case 'profile':
        return const ProfileContent();
      case 'settings':
        return const SettingsContent();
      default:
        return DashboardHomeContent(
            onNavigate: (k) => setState(() => _selectedKey = k));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDesktop = Responsive.isDesktop(context);
    final content = Padding(
      padding:
          EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 18, vertical: 18),
      // Keyed by the selected tab so switching pages cross-fades in the new
      // content instead of an instant, jarring swap.
      child: FadeSlideIn(
          key: ValueKey(_selectedKey), child: _contentFor(_selectedKey)),
    );

    if (isDesktop) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: AppBackground(
          child: SafeArea(
            child: Row(
              children: [
                SidebarNav(selectedKey: _selectedKey, onSelect: _handleSelect),
                Expanded(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 18, right: 40, bottom: 4),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: NotificationBellButton(),
                        ),
                      ),
                      Expanded(child: content),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      drawer: Drawer(
        backgroundColor: AppColors.bgTop,
        child: SidebarNav(
            selectedKey: _selectedKey,
            onSelect: _handleSelect,
            width: double.infinity),
      ),
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    IconGlowButton(
                      icon: Icons.menu_rounded,
                      tooltip: l10n.commonMenu,
                      onTap: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                    const SizedBox(width: 12),
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.accentGradient.createShader(bounds),
                      child: const Text(
                        'CareerMate',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white),
                      ),
                    ),
                    const Spacer(),
                    const NotificationBellButton(),
                  ],
                ),
              ),
              Expanded(child: content),
            ],
          ),
        ),
      ),
    );
  }
}

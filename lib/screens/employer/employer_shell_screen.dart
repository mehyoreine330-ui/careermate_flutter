import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/nav_items.dart';
import '../../core/responsive.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_background.dart';
import '../../widgets/icon_glow_button.dart';
import '../../widgets/notification_bell_button.dart';
import '../../widgets/sidebar_nav.dart';
import 'company_profile_content.dart';
import 'employer_dashboard_content.dart';
import 'employer_jobs_content.dart';

/// The Employer Portal's own shell — mirrors AppShellScreen's structure
/// exactly (permanent desktop rail / collapsible mobile drawer, same
/// SidebarNav widget) but with kEmployerNavItems instead of kNavItems, and
/// no candidate features anywhere in it. Reached only via
/// app.dart's _AccountTypeGate, once a `companies` row is confirmed to
/// exist for the signed-in account.
class EmployerShellScreen extends ConsumerStatefulWidget {
  const EmployerShellScreen({super.key});

  @override
  ConsumerState<EmployerShellScreen> createState() => _EmployerShellScreenState();
}

class _EmployerShellScreenState extends ConsumerState<EmployerShellScreen> {
  String _selectedKey = 'employer_dashboard';
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
        break;
      case NavAction.signOut:
        ref.read(authControllerProvider.notifier).signOut();
        break;
    }
  }

  Widget _contentFor(String key) {
    switch (key) {
      case 'employer_dashboard':
        return EmployerDashboardContent(onNavigate: (k) => setState(() => _selectedKey = k));
      case 'employer_jobs':
        return const EmployerJobsContent();
      case 'employer_company_profile':
        return const CompanyProfileContent();
      default:
        return EmployerDashboardContent(onNavigate: (k) => setState(() => _selectedKey = k));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDesktop = Responsive.isDesktop(context);
    final content = Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 18, vertical: 18),
      child: _contentFor(_selectedKey),
    );

    if (isDesktop) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: AppBackground(
          child: SafeArea(
            child: Row(
              children: [
                SidebarNav(selectedKey: _selectedKey, onSelect: _handleSelect, items: kEmployerNavItems),
                Expanded(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 14, right: 40),
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
          width: double.infinity,
          items: kEmployerNavItems,
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    IconGlowButton(
                      icon: Icons.menu_rounded,
                      tooltip: l10n.commonMenu,
                      onTap: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                    const SizedBox(width: 12),
                    ShaderMask(
                      shaderCallback: (bounds) => AppColors.accentGradient.createShader(bounds),
                      child: const Text(
                        'CareerMate for Employers',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
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

import 'package:flutter/material.dart';

import '../core/responsive.dart';
import '../theme/app_colors.dart';
import '../widgets/fade_in.dart';
import '../widgets/glass_card.dart';
import '../widgets/glow_button.dart';
import '../widgets/icon_glow_button.dart';
import 'career_coach_screen.dart';
import 'mock_interview_screen.dart';

/// AI Avatar hub. There is no external avatar-rendering SDK/API configured
/// in this project (no 3D/video avatar backend exists), so rather than a
/// dead "Coming Soon" placeholder, this surfaces the app's two real,
/// working AI interaction modes — the Career Coach chat and the Mock
/// Interview flow — through an avatar-branded launcher. Nothing here is
/// simulated: both destinations are the same fully-functional, backend-
/// connected screens reachable elsewhere in the sidebar.
///
/// If a real avatar SDK is integrated later, this is the file to replace
/// the `_AvatarHub` view in — the launcher cards below are intentionally
/// self-contained so swapping them out doesn't touch the rest of the app.
class AiAvatarContent extends StatefulWidget {
  const AiAvatarContent({super.key});

  @override
  State<AiAvatarContent> createState() => _AiAvatarContentState();
}

enum _AvatarMode { hub, coaching }

class _AiAvatarContentState extends State<AiAvatarContent> {
  _AvatarMode _mode = _AvatarMode.hub;

  @override
  Widget build(BuildContext context) {
    if (_mode == _AvatarMode.coaching) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconGlowButton(
                icon: Icons.arrow_back_rounded,
                tooltip: 'Back',
                onTap: () => setState(() => _mode = _AvatarMode.hub),
              ),
              const SizedBox(width: 14),
              Text('AI Avatar — Coaching Session', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 16),
          const Expanded(child: AiCareerCoachContent()),
        ],
      );
    }
    return _AvatarHub(onStartCoaching: () => setState(() => _mode = _AvatarMode.coaching));
  }
}

class _AvatarHub extends StatelessWidget {
  const _AvatarHub({required this.onStartCoaching});

  final VoidCallback onStartCoaching;

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    return SingleChildScrollView(
      child: FadeSlideIn(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _AvatarOrb(),
                  const SizedBox(height: 20),
                  Text('Your AI Avatar', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    'A personal, always-available AI presence for your job search — '
                    'talk through your career questions, or jump straight into interview practice.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            isDesktop
                ? Row(
                    children: [
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.support_agent_rounded,
                          title: 'Start Coaching Session',
                          description:
                              'Chat live with your AI Career Coach — personalized to your resume, '
                              'skills, and goals.',
                          buttonLabel: 'Start Coaching',
                          onTap: (_) => onStartCoaching(),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.mic_rounded,
                          title: 'Start Mock Interview',
                          description:
                              'Practice with AI-generated interview questions for your target role '
                              'and get scored feedback.',
                          buttonLabel: 'Start Interview',
                          onTap: (context) => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const MockInterviewScreen()),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _ActionCard(
                        icon: Icons.support_agent_rounded,
                        title: 'Start Coaching Session',
                        description:
                            'Chat live with your AI Career Coach — personalized to your resume, '
                            'skills, and goals.',
                        buttonLabel: 'Start Coaching',
                        onTap: (_) => onStartCoaching(),
                      ),
                      const SizedBox(height: 16),
                      _ActionCard(
                        icon: Icons.mic_rounded,
                        title: 'Start Mock Interview',
                        description:
                            'Practice with AI-generated interview questions for your target role '
                            'and get scored feedback.',
                        buttonLabel: 'Start Interview',
                        onTap: (context) => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const MockInterviewScreen()),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

class _AvatarOrb extends StatefulWidget {
  @override
  State<_AvatarOrb> createState() => _AvatarOrbState();
}

class _AvatarOrbState extends State<_AvatarOrb> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1.0 + (_controller.value * 0.06);
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.accentGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.accentCyan.withValues(alpha: 0.4),
              blurRadius: 32,
              spreadRadius: 4,
            ),
          ],
        ),
        child: const Icon(Icons.face_retouching_natural_rounded, color: Colors.white, size: 44),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final void Function(BuildContext context) onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accentIndigo.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.accentCyan),
          ),
          const SizedBox(height: 14),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          GlowButton(
            label: buttonLabel,
            icon: Icons.arrow_forward_rounded,
            onPressed: () => onTap(context),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/responsive.dart';
import '../l10n/generated/app_localizations.dart';
import '../providers/text_interview_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/fade_in.dart';
import '../widgets/glass_card.dart';
import '../widgets/glow_button.dart';
import '../widgets/gradient_progress_ring.dart';
import '../widgets/icon_glow_button.dart';
import '../widgets/sleek_text_field.dart';

/// Text-based Mock Interview: enter a target role, answer AI-generated
/// questions one at a time, then get a scored evaluation with strengths,
/// weaknesses, communication feedback, and improvement suggestions.
///
/// Both AI calls (question generation, evaluation) have a safe local
/// fallback if the backend is unreachable — see text_interview_provider.dart
/// — so this screen always stays usable end to end.
class MockInterviewScreen extends ConsumerWidget {
  const MockInterviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDesktop = Responsive.isDesktop(context);
    final state = ref.watch(textInterviewControllerProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 18, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconGlowButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip: l10n.commonBack,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 14),
                    Text(l10n.mockInterviewTitle, style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: FadeSlideIn(
                          key: ValueKey(state.phase),
                          child: switch (state.phase) {
                            TextInterviewPhase.setup => const _SetupCard(),
                            TextInterviewPhase.loadingQuestions => const _LoadingCard(
                                message: 'Preparing your interview questions…',
                              ),
                            TextInterviewPhase.inProgress =>
                              _QuestionCard(key: ValueKey('q-${state.currentIndex}')),
                            TextInterviewPhase.submitting => const _LoadingCard(
                                message: 'Evaluating your interview…',
                              ),
                            TextInterviewPhase.results => const _ResultsCard(),
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SetupCard extends ConsumerStatefulWidget {
  const _SetupCard();

  @override
  ConsumerState<_SetupCard> createState() => _SetupCardState();
}

class _SetupCardState extends ConsumerState<_SetupCard> {
  final _roleController = TextEditingController();

  @override
  void dispose() {
    _roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.mic_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 16),
          Text('Practice a mock interview', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Enter the role you\'re targeting and get 6-7 tailored interview questions — '
            'behavioral and role-specific — then a full scored evaluation at the end.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          SleekTextField(
            controller: _roleController,
            label: 'Target role',
            hint: 'e.g. Registered Nurse, Backend Engineer, High School Teacher',
            prefixIcon: Icons.work_outline_rounded,
          ),
          const SizedBox(height: 20),
          GlowButton(
            label: 'Start Interview',
            icon: Icons.play_arrow_rounded,
            onPressed: () {
              final role = _roleController.text.trim();
              if (role.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter a target role to begin.')),
                );
                return;
              }
              ref.read(textInterviewControllerProvider.notifier).startInterview(role);
            },
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          const SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(height: 20),
          Text(message, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _QuestionCard extends ConsumerStatefulWidget {
  const _QuestionCard({super.key});

  @override
  ConsumerState<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends ConsumerState<_QuestionCard> {
  final _answerController = TextEditingController();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(textInterviewControllerProvider);
    final index = state.currentIndex;
    final total = state.questions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.usedFallbackQuestions)
          _FallbackBanner(
            message: 'Using a general question set — the AI question generator was '
                'unreachable, so these are curated for "${state.targetRole}" instead.',
          ),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: total == 0 ? 0 : (index + 1) / total,
                  minHeight: 8,
                  backgroundColor: AppColors.accentIndigo.withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation(AppColors.accentCyan),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text('${index + 1} / $total', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 20),
        GlassCard(
          key: ValueKey(index),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Question ${index + 1}', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Text(
                state.questions[index],
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              SleekTextField(
                controller: _answerController,
                label: 'Your answer',
                hint: 'Type your answer here…',
                maxLines: 6,
              ),
              const SizedBox(height: 20),
              GlowButton(
                label: state.isLastQuestion ? 'Finish Interview' : 'Next Question',
                icon: state.isLastQuestion ? Icons.flag_rounded : Icons.arrow_forward_rounded,
                onPressed: () {
                  final answer = _answerController.text.trim();
                  ref.read(textInterviewControllerProvider.notifier).submitAnswer(answer);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResultsCard extends ConsumerWidget {
  const _ResultsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(textInterviewControllerProvider);
    final result = state.evaluation!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.usedFallbackEvaluation)
          const _FallbackBanner(
            message: 'This is a quick offline estimate — the AI evaluator was unreachable. '
                'Try again in a moment for full, personalized feedback.',
          ),
        GlassCard(
          child: Column(
            children: [
              GradientProgressRing(progress: result.overallScore / 100),
              const SizedBox(height: 8),
              Text('Overall Score', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 4),
              Text('${result.overallScore} / 100', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _FeedbackSection(
          icon: Icons.check_circle_outline_rounded,
          iconColor: AppColors.accentCyan,
          title: 'Strengths',
          items: result.strengths,
        ),
        const SizedBox(height: 16),
        _FeedbackSection(
          icon: Icons.trending_up_rounded,
          iconColor: Colors.amber,
          title: 'Areas to Improve',
          items: result.weaknesses,
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.accentIndigo),
                  const SizedBox(width: 10),
                  Text('Communication Feedback', style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 10),
              Text(result.communicationFeedback, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _FeedbackSection(
          icon: Icons.lightbulb_outline_rounded,
          iconColor: Colors.orangeAccent,
          title: 'Improvement Suggestions',
          items: result.improvementSuggestions,
        ),
        const SizedBox(height: 24),
        GlowButton(
          label: 'Start New Interview',
          icon: Icons.refresh_rounded,
          onPressed: () => ref.read(textInterviewControllerProvider.notifier).reset(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _FeedbackSection extends StatelessWidget {
  const _FeedbackSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.items,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 10),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(item, style: Theme.of(context).textTheme.bodyMedium)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _FallbackBanner extends StatelessWidget {
  const _FallbackBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 18, color: Colors.amber),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

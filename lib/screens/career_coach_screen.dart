import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/career_coach_models.dart';
import '../providers/career_coach_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/fade_in.dart';
import '../widgets/glass_card.dart';
import '../widgets/shimmer_loading.dart';

List<String> _suggestedQuestions(AppLocalizations l10n) => [
      l10n.careerCoachQ1,
      l10n.careerCoachQ2,
      l10n.careerCoachQ3,
      l10n.careerCoachQ4,
      l10n.careerCoachQ5,
      l10n.careerCoachQ6,
      l10n.careerCoachQ7,
      l10n.careerCoachQ8,
    ];

/// AI Career Coach chat — personalized to the candidate's resume, career
/// report, field of study, skills, dream job, and target country (all
/// gathered server-side; this widget only renders the conversation).
/// Rendered inside AppShellScreen's content-swap area, same as Dashboard/
/// Profile/Settings, so the sidebar stays visible.
class AiCareerCoachContent extends ConsumerStatefulWidget {
  const AiCareerCoachContent({super.key});

  @override
  ConsumerState<AiCareerCoachContent> createState() =>
      _AiCareerCoachContentState();
}

class _AiCareerCoachContentState extends ConsumerState<AiCareerCoachContent> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(coachChatProvider.notifier).loadHistory();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _send([String? suggested]) {
    final text = suggested ?? _textController.text;
    if (text.trim().isEmpty) return;
    ref.read(coachChatProvider.notifier).sendMessage(text);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(coachChatProvider);

    ref.listen(coachChatProvider, (previous, next) {
      if (next.messages.length != previous?.messages.length ||
          next.isSending != previous?.isSending) {
        _scrollToBottom();
      }
    });

    return FadeSlideIn(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, gradient: AppColors.accentGradient),
                child: const Icon(Icons.support_agent_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Text(l10n.careerCoachTitle,
                  style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 54),
            child: Text(
              l10n.careerCoachSubtitle,
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: state.isLoadingHistory
                ? const _ChatHistorySkeleton()
                : ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      for (final message in state.messages)
                        _ChatBubble(message: message),
                      if (state.isSending) const _TypingBubble(),
                      // Scrolls with the transcript instead of sitting in a fixed
                      // sibling slot — keeps the composer reachable even on short
                      // viewports where header + all 8 chips wouldn't otherwise fit.
                      if (state.messages.isEmpty && !state.isSending)
                        _SuggestedQuestions(onTap: _send),
                    ],
                  ),
          ),
          if (state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                state.errorMessage!,
                style:
                    const TextStyle(color: AppColors.warning, fontSize: 12.5),
              ),
            ),
          _Composer(
            controller: _textController,
            enabled: !state.isSending,
            onSend: () => _send(),
          ),
        ],
      ),
    );
  }
}

/// A few chat-bubble-shaped shimmer placeholders (alternating sides, like a
/// real conversation) shown while the persisted history loads — replaces a
/// bare centered spinner with something that mirrors the eventual content.
class _ChatHistorySkeleton extends StatelessWidget {
  const _ChatHistorySkeleton();

  @override
  Widget build(BuildContext context) {
    const widths = [220.0, 160.0, 260.0, 180.0];
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        for (var i = 0; i < widths.length; i++)
          Align(
            alignment: i.isEven ? Alignment.centerLeft : Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ShimmerBox(width: widths[i], height: 40, borderRadius: 16),
            ),
          ),
      ],
    );
  }
}

class _SuggestedQuestions extends StatelessWidget {
  const _SuggestedQuestions({required this.onTap});

  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.careerCoachTryAsking,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final question in _suggestedQuestions(l10n))
                _SuggestionChip(label: question, onTap: () => onTap(question)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatefulWidget {
  const _SuggestionChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_SuggestionChip> createState() => _SuggestionChipState();
}

class _SuggestionChipState extends State<_SuggestionChip> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: Colors.white.withValues(alpha: _hovering ? 0.09 : 0.05),
            border: Border.all(
              color: _hovering
                  ? AppColors.accentCyan.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.14),
            ),
          ),
          child: Text(widget.label,
              style: const TextStyle(color: Colors.white, fontSize: 13)),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final CoachMessage message;

  @override
  Widget build(BuildContext context) {
    final isAi = message.isFromAi;
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        constraints: const BoxConstraints(maxWidth: 560),
        child: isAi
            ? GlassCard(
                borderRadius: 16,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(message.content,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14.5, height: 1.45)),
              )
            : Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: AppColors.accentGradient,
                ),
                child: Text(
                  message.content,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      height: 1.45,
                      fontWeight: FontWeight.w600),
                ),
              ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: GlassCard(
          borderRadius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: const _TypingDots(),
        ),
      ),
    );
  }
}

/// Three dots that pulse in sequence, looping — the "AI is typing" cue.
class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 8,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (i) {
              final t = (_controller.value - (i * 0.2)) % 1.0;
              final opacity = 0.3 + 0.7 * (t < 0.5 ? t * 2 : (1 - t) * 2);
              return Opacity(
                opacity: opacity.clamp(0.3, 1.0),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: AppColors.accentCyan),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer(
      {required this.controller, required this.enabled, required this.onSend});

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white.withValues(alpha: 0.04),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: TextField(
              controller: controller,
              enabled: enabled,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              style: const TextStyle(color: Colors.white, fontSize: 14.5),
              cursorColor: AppColors.accentCyan,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).careerCoachComposerHint,
                hintStyle: const TextStyle(color: Colors.white38),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: enabled ? onSend : null,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: enabled
                    ? AppColors.accentGradient
                    : LinearGradient(colors: [
                        AppColors.accentIndigo.withValues(alpha: 0.35),
                        AppColors.accentCyan.withValues(alpha: 0.35),
                      ]),
              ),
              child: const Icon(Icons.arrow_upward_rounded,
                  color: Colors.white, size: 22),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/onboarding_chat_models.dart';
import '../providers/onboarding_chat_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/fade_in.dart';
import '../widgets/glass_card.dart';

/// First-run "AI Welcome" screen: a short conversational onboarding — the AI
/// career coach asks one question at a time (full name, country, university,
/// major, ...) and every answer is saved to `profiles` as it's given. Shown
/// by the auth gate instead of the dashboard until `profiles.onboarding_completed`
/// is true; once the last answer is saved, app.dart's gate re-routes to the
/// dashboard on its own — this screen never navigates itself.
class AiWelcomeScreen extends ConsumerStatefulWidget {
  const AiWelcomeScreen({super.key});

  @override
  ConsumerState<AiWelcomeScreen> createState() => _AiWelcomeScreenState();
}

class _AiWelcomeScreenState extends ConsumerState<AiWelcomeScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingChatProvider.notifier).start();
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

  void _submit() {
    final text = _textController.text;
    if (text.trim().isEmpty) return;
    ref.read(onboardingChatProvider.notifier).submitAnswer(text);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingChatProvider);

    ref.listen(onboardingChatProvider, (previous, next) {
      if (next.messages.length != previous?.messages.length) _scrollToBottom();
    });

    final canSend =
        !state.isSending && !state.isComplete && state.currentFieldKey != null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: FadeSlideIn(
                  child: Column(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppColors.accentGradient.createShader(bounds),
                        child: Text(
                          AppLocalizations.of(context).aiWelcomeTitle,
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount:
                              state.messages.length + (state.isSending ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= state.messages.length) {
                              return const _TypingBubble();
                            }
                            return _ChatBubble(message: state.messages[index]);
                          },
                        ),
                      ),
                      if (state.errorMessage != null) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            state.errorMessage!,
                            style: const TextStyle(
                                color: AppColors.warning, fontSize: 12.5),
                          ),
                        ),
                      ],
                      if (!state.isComplete)
                        _Composer(
                            controller: _textController,
                            enabled: canSend,
                            onSend: _submit),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final OnboardingChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isAi = message.isFromAi;
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        constraints: const BoxConstraints(maxWidth: 480),
        child: isAi
            ? GlassCard(
                borderRadius: 16,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(message.text,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14.5, height: 1.4)),
              )
            : Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: AppColors.accentGradient,
                ),
                child: Text(
                  message.text,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      height: 1.4,
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
          child: const SizedBox(
            width: 20,
            height: 14,
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.accentCyan),
              ),
            ),
          ),
        ),
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
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
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
                  hintText: AppLocalizations.of(context).aiWelcomeComposerHint,
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
      ),
    );
  }
}

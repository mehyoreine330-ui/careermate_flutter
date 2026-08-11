import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../l10n/generated/app_localizations.dart';
import '../providers/interview_provider.dart';

class MockInterviewScreen extends ConsumerStatefulWidget {
  const MockInterviewScreen({super.key});

  @override
  ConsumerState<MockInterviewScreen> createState() => _MockInterviewScreenState();
}

class _MockInterviewScreenState extends ConsumerState<MockInterviewScreen> {
  late final String _interviewId;
  // Captured once, while `ref` is definitely still valid, so dispose() can
  // call endInterview() on the plain Dart object directly — calling
  // ref.read() from dispose() intermittently throws "Cannot use ref after
  // the widget was disposed" depending on teardown order.
  late final InterviewController _controller;

  @override
  void initState() {
    super.initState();
    // TODO(backend): replace with the id returned by a
    // POST /api/v1/interviews call once that endpoint exists, so the
    // session is persisted to the mock_interviews table server-side.
    // A client-generated id works today because the WS route doesn't
    // validate it against the DB yet.
    _interviewId = const Uuid().v4();
    _controller = ref.read(interviewControllerProvider.notifier);
    Future.microtask(() => _controller.startInterview(_interviewId));
  }

  @override
  void dispose() {
    _controller.endInterview();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(interviewControllerProvider);
    final notifier = ref.read(interviewControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.mockInterviewTitle)),
      body: Column(
        children: [
          _StatusBanner(status: state.status, errorMessage: state.errorMessage),
          Expanded(
            child: state.history.isEmpty
                ? Center(child: Text(l10n.mockInterviewPressHold))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.history.length,
                    itemBuilder: (context, index) {
                      final turn = state.history[index];
                      final isAi = turn.speaker == 'ai';
                      return Align(
                        alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isAi
                                ? Theme.of(context).colorScheme.surfaceContainerHighest
                                : Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(turn.text),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _RecordButton(
                status: state.status,
                onPressStart: notifier.startAnswer,
                onPressEnd: notifier.submitAnswer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.status, required this.errorMessage});

  final InterviewConnectionStatus status;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (status == InterviewConnectionStatus.error) {
      return Container(
        width: double.infinity,
        color: Theme.of(context).colorScheme.errorContainer,
        padding: const EdgeInsets.all(12),
        child: Text(errorMessage ?? l10n.mockInterviewConnectionError),
      );
    }

    final label = switch (status) {
      InterviewConnectionStatus.connecting => l10n.mockInterviewConnecting,
      InterviewConnectionStatus.processing => l10n.mockInterviewThinking,
      InterviewConnectionStatus.completed => l10n.mockInterviewComplete,
      _ => null,
    };
    if (label == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.secondaryContainer,
      padding: const EdgeInsets.all(8),
      child: Text(label, textAlign: TextAlign.center),
    );
  }
}

class _RecordButton extends StatelessWidget {
  const _RecordButton({
    required this.status,
    required this.onPressStart,
    required this.onPressEnd,
  });

  final InterviewConnectionStatus status;
  final VoidCallback onPressStart;
  final VoidCallback onPressEnd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isRecording = status == InterviewConnectionStatus.recording;
    final isDisabled = status == InterviewConnectionStatus.connecting ||
        status == InterviewConnectionStatus.processing ||
        status == InterviewConnectionStatus.completed ||
        status == InterviewConnectionStatus.error;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onLongPressStart: isDisabled ? null : (_) => onPressStart(),
          onLongPressEnd: isDisabled ? null : (_) => onPressEnd(),
          child: Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isRecording ? Colors.red : Theme.of(context).colorScheme.primary,
            ),
            child: Icon(
              isRecording ? Icons.stop : Icons.mic,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isRecording ? l10n.mockInterviewReleaseToSend : l10n.mockInterviewPressAndHold,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

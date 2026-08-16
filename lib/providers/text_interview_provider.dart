import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/interview_models.dart';
import 'locale_provider.dart';
import 'resume_provider.dart' show apiServiceProvider;

enum TextInterviewPhase { setup, loadingQuestions, inProgress, submitting, results }

class TextInterviewState {
  const TextInterviewState({
    this.phase = TextInterviewPhase.setup,
    this.targetRole = '',
    this.questions = const [],
    this.currentIndex = 0,
    this.answers = const [],
    this.evaluation,
    this.usedFallbackQuestions = false,
    this.usedFallbackEvaluation = false,
  });

  final TextInterviewPhase phase;
  final String targetRole;
  final List<String> questions;
  final int currentIndex;
  final List<String> answers; // one per question answered so far
  final InterviewEvaluationResult? evaluation;
  final bool usedFallbackQuestions;
  final bool usedFallbackEvaluation;

  bool get isLastQuestion => currentIndex >= questions.length - 1;

  TextInterviewState copyWith({
    TextInterviewPhase? phase,
    String? targetRole,
    List<String>? questions,
    int? currentIndex,
    List<String>? answers,
    InterviewEvaluationResult? evaluation,
    bool? usedFallbackQuestions,
    bool? usedFallbackEvaluation,
  }) {
    return TextInterviewState(
      phase: phase ?? this.phase,
      targetRole: targetRole ?? this.targetRole,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      evaluation: evaluation ?? this.evaluation,
      usedFallbackQuestions: usedFallbackQuestions ?? this.usedFallbackQuestions,
      usedFallbackEvaluation: usedFallbackEvaluation ?? this.usedFallbackEvaluation,
    );
  }
}

/// Drives the text-based Mock Interview flow: pick a target role -> AI
/// generates questions -> answer one at a time -> AI scores the full
/// transcript. Both AI calls have a safe, clearly-labeled local fallback
/// (a curated question bank / a simple heuristic score) so the page stays
/// usable even if the backend call fails — see [_fallbackQuestionsFor] and
/// [_fallbackEvaluation].
class TextInterviewController extends Notifier<TextInterviewState> {
  @override
  TextInterviewState build() => const TextInterviewState();

  Future<void> startInterview(String targetRole) async {
    state = TextInterviewState(phase: TextInterviewPhase.loadingQuestions, targetRole: targetRole);
    final language = ref.read(localeProvider).languageCode;
    try {
      final questions = await ref
          .read(apiServiceProvider)
          .generateInterviewQuestions(targetRole: targetRole, language: language);
      state = state.copyWith(phase: TextInterviewPhase.inProgress, questions: questions);
    } catch (_) {
      // Safe frontend fallback: the page stays fully usable even if the
      // backend/AI call fails (network error, CORS, cold-start timeout).
      state = state.copyWith(
        phase: TextInterviewPhase.inProgress,
        questions: _fallbackQuestionsFor(targetRole),
        usedFallbackQuestions: true,
      );
    }
  }

  Future<void> submitAnswer(String answer) async {
    final updatedAnswers = [...state.answers, answer.trim()];
    if (!state.isLastQuestion) {
      state = state.copyWith(answers: updatedAnswers, currentIndex: state.currentIndex + 1);
      return;
    }
    // Last question answered — score the full transcript.
    state = state.copyWith(answers: updatedAnswers, phase: TextInterviewPhase.submitting);
    final qaPairs = [
      for (var i = 0; i < state.questions.length; i++)
        InterviewAnswer(question: state.questions[i], answer: updatedAnswers[i]),
    ];
    final language = ref.read(localeProvider).languageCode;
    try {
      final result = await ref.read(apiServiceProvider).evaluateInterview(
            targetRole: state.targetRole,
            qaPairs: qaPairs,
            language: language,
          );
      state = state.copyWith(phase: TextInterviewPhase.results, evaluation: result);
    } catch (_) {
      state = state.copyWith(
        phase: TextInterviewPhase.results,
        evaluation: _fallbackEvaluation(qaPairs),
        usedFallbackEvaluation: true,
      );
    }
  }

  void reset() => state = const TextInterviewState();

  static const Map<String, List<String>> _questionBanks = {
    'tech': [
      'Tell me about a challenging technical problem you solved recently. What was your approach?',
      'Describe a time you had to work closely with a difficult teammate. How did you handle it?',
      'How do you decide when a piece of code is "done" and ready to ship?',
      'Tell me about a project you\'re proud of. What was your specific contribution?',
      'How do you approach learning a new technology or tool under a deadline?',
      'Describe a time you disagreed with a technical decision. What did you do?',
    ],
    'healthcare': [
      'What drew you to this field, and what keeps you motivated day to day?',
      'Describe a time you had to stay calm under pressure with a patient or client.',
      'Tell me about a time you worked as part of a care team to reach a good outcome.',
      'How do you handle a situation where a patient or family member is upset or anxious?',
      'What do you do to stay current with best practices in your field?',
      'Describe a mistake you learned from early in your career.',
    ],
    'education': [
      'What inspired you to go into teaching or education?',
      'Describe a time you adapted your approach for a student who was struggling.',
      'How do you handle a disruptive or disengaged student or group?',
      'Tell me about a lesson or project you\'re particularly proud of.',
      'How do you communicate with parents or stakeholders about a student\'s progress?',
      'How do you keep up with changes in curriculum or teaching methods?',
    ],
    'business': [
      'Tell me about a time you had to persuade someone to see things your way.',
      'Describe a project where you had to manage competing priorities.',
      'How do you approach a task or goal you\'ve never done before?',
      'Tell me about a time you missed a target or deadline. What happened?',
      'How do you handle disagreement with a manager or client?',
      'What metrics do you use to know you\'re doing a good job?',
    ],
    'generic': [
      'Tell me a bit about your background and what led you to this role.',
      'Describe a challenge you faced at work and how you handled it.',
      'Tell me about a time you worked well as part of a team.',
      'What are you most proud of in your career so far?',
      'How do you handle stress or a heavy workload?',
      'Where do you see yourself developing in the next couple of years?',
    ],
  };

  List<String> _fallbackQuestionsFor(String targetRole) {
    final role = targetRole.toLowerCase();
    String bankKey = 'generic';
    if (RegExp(r'nurs|doctor|medic|clinical|health|therap|pharma').hasMatch(role)) {
      bankKey = 'healthcare';
    } else if (RegExp(r'teach|educat|professor|instructor').hasMatch(role)) {
      bankKey = 'education';
    } else if (RegExp(r'sale|market|manage|business|finance|account').hasMatch(role)) {
      bankKey = 'business';
    } else if (RegExp(r'engineer|develop|software|program|data|it |tech|web|cloud').hasMatch(role)) {
      bankKey = 'tech';
    }
    return _questionBanks[bankKey]!;
  }

  /// A simple, clearly-labeled offline estimate — never presented as real
  /// AI feedback (the UI shows a "quick estimate" notice whenever
  /// [TextInterviewState.usedFallbackEvaluation] is true).
  InterviewEvaluationResult _fallbackEvaluation(List<InterviewAnswer> qaPairs) {
    final answered = qaPairs.where((p) => p.answer.trim().isNotEmpty).length;
    final avgLength = qaPairs.isEmpty
        ? 0
        : qaPairs.map((p) => p.answer.trim().length).reduce((a, b) => a + b) / qaPairs.length;
    final completeness = qaPairs.isEmpty ? 0 : (answered / qaPairs.length * 100).round();
    final depthBonus = avgLength > 200 ? 15 : (avgLength > 80 ? 5 : 0);
    final score = (completeness * 0.6 + 40 + depthBonus).clamp(0, 100).round();

    final strengths = [
      if (answered == qaPairs.length) 'Answered every question in the interview.',
      if (avgLength > 150) 'Gave detailed, thorough answers.',
    ];
    if (strengths.isEmpty) strengths.add('Completed the mock interview session.');

    return InterviewEvaluationResult(
      overallScore: score,
      strengths: strengths,
      weaknesses: [
        if (answered < qaPairs.length) 'Some questions were left unanswered.',
        if (avgLength < 80) 'Answers were quite short — more detail and examples would help.',
      ],
      communicationFeedback:
          'This is a quick offline estimate, not a full AI review — try again shortly for '
          'detailed, personalized feedback on your communication style.',
      improvementSuggestions: [
        'Use the STAR method (Situation, Task, Action, Result) to structure answers.',
        'Include specific, concrete examples from your own experience.',
        'Practice saying your answers out loud to build confidence and pacing.',
      ],
    );
  }
}

final textInterviewControllerProvider =
    NotifierProvider<TextInterviewController, TextInterviewState>(TextInterviewController.new);

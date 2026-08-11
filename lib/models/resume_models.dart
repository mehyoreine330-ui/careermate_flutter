/// Data classes mirroring the backend's ResumeAnalysisResult contract
/// (see careermate-backend/models/schemas.py). Field names below are
/// camelCase in Dart but map to the exact snake_case JSON keys Claude's
/// tool-use response produces — keep both sides in sync if either changes.

class FormattingIssue {
  const FormattingIssue({
    required this.severity,
    required this.issue,
    required this.recommendation,
  });

  final String severity; // low | medium | high
  final String issue;
  final String recommendation;

  factory FormattingIssue.fromJson(Map<String, dynamic> json) => FormattingIssue(
        severity: json['severity'] as String,
        issue: json['issue'] as String,
        recommendation: json['recommendation'] as String,
      );

  Map<String, dynamic> toJson() => {
        'severity': severity,
        'issue': issue,
        'recommendation': recommendation,
      };
}

class MissingKeyword {
  const MissingKeyword({
    required this.keyword,
    required this.importance,
    required this.foundInJobDescription,
    required this.foundInResume,
  });

  final String keyword;
  final String importance; // low | medium | high
  final bool foundInJobDescription;
  final bool foundInResume;

  factory MissingKeyword.fromJson(Map<String, dynamic> json) => MissingKeyword(
        keyword: json['keyword'] as String,
        importance: json['importance'] as String,
        foundInJobDescription: json['found_in_job_description'] as bool,
        foundInResume: json['found_in_resume'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'keyword': keyword,
        'importance': importance,
        'found_in_job_description': foundInJobDescription,
        'found_in_resume': foundInResume,
      };
}

class WeakBulletPoint {
  const WeakBulletPoint({
    required this.original,
    required this.issue,
    required this.suggestedRewrite,
  });

  final String original;
  final String issue;
  final String suggestedRewrite;

  factory WeakBulletPoint.fromJson(Map<String, dynamic> json) => WeakBulletPoint(
        original: json['original'] as String,
        issue: json['issue'] as String,
        suggestedRewrite: json['suggested_rewrite'] as String,
      );

  Map<String, dynamic> toJson() => {
        'original': original,
        'issue': issue,
        'suggested_rewrite': suggestedRewrite,
      };
}

class ATSAnalysis {
  const ATSAnalysis({
    required this.overallAtsScore,
    required this.scoreBreakdown,
    required this.formattingIssues,
    required this.missingKeywords,
    required this.weakBulletPoints,
    required this.strengths,
  });

  final int overallAtsScore;
  final Map<String, int> scoreBreakdown;
  final List<FormattingIssue> formattingIssues;
  final List<MissingKeyword> missingKeywords;
  final List<WeakBulletPoint> weakBulletPoints;
  final List<String> strengths;

  factory ATSAnalysis.fromJson(Map<String, dynamic> json) => ATSAnalysis(
        overallAtsScore: json['overall_ats_score'] as int,
        scoreBreakdown: Map<String, int>.from(json['score_breakdown'] as Map),
        formattingIssues: (json['formatting_issues'] as List)
            .map((e) => FormattingIssue.fromJson(e as Map<String, dynamic>))
            .toList(),
        missingKeywords: (json['missing_keywords'] as List)
            .map((e) => MissingKeyword.fromJson(e as Map<String, dynamic>))
            .toList(),
        weakBulletPoints: (json['weak_bullet_points'] as List)
            .map((e) => WeakBulletPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
        strengths: List<String>.from(json['strengths'] as List),
      );

  Map<String, dynamic> toJson() => {
        'overall_ats_score': overallAtsScore,
        'score_breakdown': scoreBreakdown,
        'formatting_issues': formattingIssues.map((e) => e.toJson()).toList(),
        'missing_keywords': missingKeywords.map((e) => e.toJson()).toList(),
        'weak_bullet_points': weakBulletPoints.map((e) => e.toJson()).toList(),
        'strengths': strengths,
      };
}

class MatchedSkill {
  const MatchedSkill({required this.skill, required this.proficiencyEvidence});

  final String skill;
  final String proficiencyEvidence;

  factory MatchedSkill.fromJson(Map<String, dynamic> json) => MatchedSkill(
        skill: json['skill'] as String,
        proficiencyEvidence: json['proficiency_evidence'] as String,
      );

  Map<String, dynamic> toJson() => {
        'skill': skill,
        'proficiency_evidence': proficiencyEvidence,
      };
}

class MissingSkill {
  const MissingSkill({
    required this.skill,
    required this.priority,
    required this.reason,
    required this.currentLevel,
    required this.targetLevel,
  });

  final String skill;
  final String priority; // low | medium | high | critical
  final String reason;
  final String currentLevel; // none | beginner | intermediate | advanced
  final String targetLevel;

  factory MissingSkill.fromJson(Map<String, dynamic> json) => MissingSkill(
        skill: json['skill'] as String,
        priority: json['priority'] as String,
        reason: json['reason'] as String,
        currentLevel: json['current_level'] as String,
        targetLevel: json['target_level'] as String,
      );

  Map<String, dynamic> toJson() => {
        'skill': skill,
        'priority': priority,
        'reason': reason,
        'current_level': currentLevel,
        'target_level': targetLevel,
      };
}

class TransferableSkill {
  const TransferableSkill({required this.skill, required this.note});

  final String skill;
  final String note;

  factory TransferableSkill.fromJson(Map<String, dynamic> json) => TransferableSkill(
        skill: json['skill'] as String,
        note: json['note'] as String,
      );

  Map<String, dynamic> toJson() => {'skill': skill, 'note': note};
}

class SkillGapAnalysis {
  const SkillGapAnalysis({
    required this.targetRole,
    required this.readinessScore,
    required this.matchedSkills,
    required this.missingSkills,
    required this.transferableSkills,
    required this.estimatedTimeToCloseGapWeeks,
  });

  final String targetRole;
  final int readinessScore;
  final List<MatchedSkill> matchedSkills;
  final List<MissingSkill> missingSkills;
  final List<TransferableSkill> transferableSkills;
  final int estimatedTimeToCloseGapWeeks;

  factory SkillGapAnalysis.fromJson(Map<String, dynamic> json) => SkillGapAnalysis(
        targetRole: json['target_role'] as String,
        readinessScore: json['readiness_score'] as int,
        matchedSkills: (json['matched_skills'] as List)
            .map((e) => MatchedSkill.fromJson(e as Map<String, dynamic>))
            .toList(),
        missingSkills: (json['missing_skills'] as List)
            .map((e) => MissingSkill.fromJson(e as Map<String, dynamic>))
            .toList(),
        transferableSkills: (json['transferable_skills'] as List)
            .map((e) => TransferableSkill.fromJson(e as Map<String, dynamic>))
            .toList(),
        estimatedTimeToCloseGapWeeks: json['estimated_time_to_close_gap_weeks'] as int,
      );

  Map<String, dynamic> toJson() => {
        'target_role': targetRole,
        'readiness_score': readinessScore,
        'matched_skills': matchedSkills.map((e) => e.toJson()).toList(),
        'missing_skills': missingSkills.map((e) => e.toJson()).toList(),
        'transferable_skills': transferableSkills.map((e) => e.toJson()).toList(),
        'estimated_time_to_close_gap_weeks': estimatedTimeToCloseGapWeeks,
      };
}

class ResumeAnalysisResult {
  const ResumeAnalysisResult({
    required this.atsAnalysis,
    required this.skillGapAnalysis,
    required this.recommendedNextAction,
    required this.language,
  });

  final ATSAnalysis atsAnalysis;
  final SkillGapAnalysis skillGapAnalysis;
  final String recommendedNextAction;
  final String language;

  factory ResumeAnalysisResult.fromJson(Map<String, dynamic> json) => ResumeAnalysisResult(
        atsAnalysis: ATSAnalysis.fromJson(json['ats_analysis'] as Map<String, dynamic>),
        skillGapAnalysis:
            SkillGapAnalysis.fromJson(json['skill_gap_analysis'] as Map<String, dynamic>),
        recommendedNextAction: json['recommended_next_action'] as String,
        language: json['language'] as String? ?? 'en',
      );

  /// Round-trips back to the exact shape the backend's Pydantic
  /// ResumeAnalysisResult expects — used to resend the analysis alongside
  /// the original PDF when calling the Auto-Fix with AI endpoint.
  Map<String, dynamic> toJson() => {
        'ats_analysis': atsAnalysis.toJson(),
        'skill_gap_analysis': skillGapAnalysis.toJson(),
        'recommended_next_action': recommendedNextAction,
        'language': language,
      };
}

/// Lightweight resume record for dashboard/profile display — no full
/// analysis payload, unlike [ResumeAnalysisResult].
class ResumeSummary {
  const ResumeSummary({
    required this.id,
    required this.title,
    required this.targetRole,
    required this.atsScore,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String targetRole;
  final int atsScore;
  final DateTime createdAt;

  factory ResumeSummary.fromJson(Map<String, dynamic> json) => ResumeSummary(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        targetRole: json['target_role'] as String? ?? '',
        atsScore: json['ats_score'] as int,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

// =====================================================================
// Auto-Fix with AI
// =====================================================================

class ResumeChange {
  const ResumeChange({
    required this.section,
    required this.original,
    required this.rewritten,
    required this.reason,
  });

  final String section;
  final String original;
  final String rewritten;
  final String reason;

  factory ResumeChange.fromJson(Map<String, dynamic> json) => ResumeChange(
        section: json['section'] as String,
        original: json['original'] as String,
        rewritten: json['rewritten'] as String,
        reason: json['reason'] as String,
      );
}

class AutoFixResult {
  const AutoFixResult({
    required this.optimizedResumeText,
    required this.changesMade,
    required this.estimatedNewAtsScore,
    required this.summary,
  });

  final String optimizedResumeText;
  final List<ResumeChange> changesMade;
  final int estimatedNewAtsScore;
  final String summary;

  factory AutoFixResult.fromJson(Map<String, dynamic> json) => AutoFixResult(
        optimizedResumeText: json['optimized_resume_text'] as String,
        changesMade: (json['changes_made'] as List)
            .map((e) => ResumeChange.fromJson(e as Map<String, dynamic>))
            .toList(),
        estimatedNewAtsScore: json['estimated_new_ats_score'] as int,
        summary: json['summary'] as String,
      );
}

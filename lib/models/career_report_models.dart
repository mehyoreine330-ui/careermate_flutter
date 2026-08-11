/// Mirrors the backend's CareerReport contract (see
/// careermate-backend/models/schemas.py). Most fields here are reused
/// straight from the linked resume's existing ATS/skill-gap analysis
/// (strengths, weaknesses, missing keywords, formatting feedback, career
/// readiness) — only the recommendations are genuinely new content.

class RoadmapWeek {
  const RoadmapWeek({required this.week, required this.focus});

  final String week;
  final String focus;

  factory RoadmapWeek.fromJson(Map<String, dynamic> json) => RoadmapWeek(
        week: json['week'] as String,
        focus: json['focus'] as String,
      );
}

class CareerReport {
  const CareerReport({
    required this.id,
    required this.resumeId,
    required this.targetRole,
    required this.atsScore,
    required this.careerReadiness,
    required this.estimatedHiringScore,
    required this.strengths,
    required this.weaknesses,
    required this.missingKeywords,
    required this.formattingFeedback,
    required this.recommendedCareerPaths,
    required this.recommendedCertifications,
    required this.recommendedCourses,
    required this.learningRoadmap,
    required this.nextSteps,
    required this.createdAt,
  });

  final String id;
  final String resumeId;
  final String targetRole;
  final int atsScore;
  final int careerReadiness;
  final int estimatedHiringScore;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> missingKeywords;
  final List<String> formattingFeedback;
  final List<String> recommendedCareerPaths;
  final List<String> recommendedCertifications;
  final List<String> recommendedCourses;
  final List<RoadmapWeek> learningRoadmap;
  final List<String> nextSteps;
  final DateTime createdAt;

  factory CareerReport.fromJson(Map<String, dynamic> json) => CareerReport(
        id: json['id'] as String,
        resumeId: json['resume_id'] as String,
        targetRole: json['target_role'] as String? ?? '',
        atsScore: json['ats_score'] as int,
        careerReadiness: json['career_readiness'] as int,
        estimatedHiringScore: json['estimated_hiring_score'] as int,
        strengths: List<String>.from(json['strengths'] as List),
        weaknesses: List<String>.from(json['weaknesses'] as List),
        missingKeywords: List<String>.from(json['missing_keywords'] as List),
        formattingFeedback: List<String>.from(json['formatting_feedback'] as List),
        recommendedCareerPaths: List<String>.from(json['recommended_career_paths'] as List),
        recommendedCertifications: List<String>.from(json['recommended_certifications'] as List),
        recommendedCourses: List<String>.from(json['recommended_courses'] as List),
        learningRoadmap: (json['learning_roadmap'] as List)
            .map((e) => RoadmapWeek.fromJson(e as Map<String, dynamic>))
            .toList(),
        nextSteps: List<String>.from(json['next_steps'] as List),
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

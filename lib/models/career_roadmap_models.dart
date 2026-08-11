/// Mirrors the backend's CareerRoadmap contract (see
/// careermate-backend/models/schemas.py). Distinct from CareerReport: a
/// report is a point-in-time readiness snapshot, a roadmap is an ongoing
/// plan tracked via `milestones` and regenerated whenever a newer resume
/// analysis exists (see providers/career_roadmap_provider.dart).

class RoadmapLearningStep {
  const RoadmapLearningStep({required this.phase, required this.focus});

  final String phase;
  final String focus;

  factory RoadmapLearningStep.fromJson(Map<String, dynamic> json) => RoadmapLearningStep(
        phase: json['phase'] as String,
        focus: json['focus'] as String,
      );
}

class RoadmapMilestone {
  const RoadmapMilestone({required this.id, required this.title, required this.completed});

  final String id;
  final String title;
  final bool completed;

  RoadmapMilestone copyWith({bool? completed}) => RoadmapMilestone(
        id: id,
        title: title,
        completed: completed ?? this.completed,
      );

  factory RoadmapMilestone.fromJson(Map<String, dynamic> json) => RoadmapMilestone(
        id: json['id'] as String,
        title: json['title'] as String,
        completed: json['completed'] as bool? ?? false,
      );
}

class CareerRoadmap {
  const CareerRoadmap({
    required this.id,
    required this.resumeId,
    required this.targetRole,
    required this.industry,
    required this.currentCareerLevel,
    required this.missingSkills,
    required this.learningPlan,
    required this.recommendedCertifications,
    required this.recommendedResources,
    required this.recommendedProjects,
    required this.estimatedTimeline,
    required this.milestones,
    required this.createdAt,
  });

  final String id;
  final String resumeId;
  final String targetRole;
  final String industry;
  final String currentCareerLevel;
  final List<String> missingSkills;
  final List<RoadmapLearningStep> learningPlan;
  final List<String> recommendedCertifications;
  final List<String> recommendedResources;
  final List<String> recommendedProjects;
  final String estimatedTimeline;
  final List<RoadmapMilestone> milestones;
  final DateTime createdAt;

  int get completedMilestoneCount => milestones.where((m) => m.completed).length;

  double get progress => milestones.isEmpty ? 0 : completedMilestoneCount / milestones.length;

  factory CareerRoadmap.fromJson(Map<String, dynamic> json) => CareerRoadmap(
        id: json['id'] as String,
        resumeId: json['resume_id'] as String,
        targetRole: json['target_role'] as String? ?? '',
        industry: json['industry'] as String? ?? '',
        currentCareerLevel: json['current_career_level'] as String? ?? '',
        missingSkills: List<String>.from(json['missing_skills'] as List),
        learningPlan: (json['learning_plan'] as List)
            .map((e) => RoadmapLearningStep.fromJson(e as Map<String, dynamic>))
            .toList(),
        recommendedCertifications: List<String>.from(json['recommended_certifications'] as List),
        recommendedResources: List<String>.from(json['recommended_resources'] as List),
        recommendedProjects: List<String>.from(json['recommended_projects'] as List),
        estimatedTimeline: json['estimated_timeline'] as String? ?? '',
        milestones: (json['milestones'] as List)
            .map((e) => RoadmapMilestone.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

/// Mirrors careermate-backend's Opportunity/OpportunityMatchAnalysis/
/// OpportunityRecommendation (see models/schemas.py). One unified,
/// source-agnostic shape covering both internships and graduate programs —
/// today served from a curated sample dataset, swappable for a real
/// internship/graduate-program API later without any shape changes.
class Opportunity {
  const Opportunity({
    required this.id,
    required this.kind,
    required this.company,
    required this.country,
    required this.field,
    required this.workArrangement,
    required this.isPaid,
    required this.requiredSkills,
    this.city,
    this.position,
    this.duration,
    this.programName,
    this.requirements,
  });

  final String id;
  final String kind; // internship | graduate_program
  final String company;
  final String country;
  final String field;
  final String workArrangement; // remote | hybrid | onsite
  final bool isPaid;
  final List<String> requiredSkills;
  final String? city;

  // Internship-only
  final String? position;
  final String? duration;

  // Graduate-program-only
  final String? programName;
  final List<String>? requirements;

  bool get isInternship => kind == 'internship';

  /// The headline title shown on the card, regardless of kind.
  String get title => position ?? programName ?? company;

  factory Opportunity.fromJson(Map<String, dynamic> json) => Opportunity(
        id: json['id'] as String,
        kind: json['kind'] as String,
        company: json['company'] as String,
        country: json['country'] as String,
        field: json['field'] as String,
        workArrangement: json['work_arrangement'] as String,
        isPaid: json['is_paid'] as bool,
        requiredSkills: List<String>.from(json['required_skills'] as List),
        city: json['city'] as String?,
        position: json['position'] as String?,
        duration: json['duration'] as String?,
        programName: json['program_name'] as String?,
        requirements:
            json['requirements'] == null ? null : List<String>.from(json['requirements'] as List),
      );
}

class OpportunityMatchAnalysis {
  const OpportunityMatchAnalysis({
    required this.opportunityId,
    required this.matchScore,
    required this.whyMatch,
    required this.strengths,
    required this.missingSkills,
    required this.recommendedCertifications,
    required this.suggestedImprovements,
  });

  final String opportunityId;
  final int matchScore;
  final String whyMatch;
  final List<String> strengths;
  final List<String> missingSkills;
  final List<String> recommendedCertifications;
  final List<String> suggestedImprovements;

  factory OpportunityMatchAnalysis.fromJson(Map<String, dynamic> json) => OpportunityMatchAnalysis(
        opportunityId: json['opportunity_id'] as String,
        matchScore: json['match_score'] as int,
        whyMatch: json['why_match'] as String,
        strengths: List<String>.from(json['strengths'] as List),
        missingSkills: List<String>.from(json['missing_skills'] as List),
        recommendedCertifications: List<String>.from(json['recommended_certifications'] as List),
        suggestedImprovements: List<String>.from(json['suggested_improvements'] as List),
      );
}

class OpportunityRecommendation {
  const OpportunityRecommendation({required this.opportunity, required this.analysis});

  final Opportunity opportunity;
  final OpportunityMatchAnalysis analysis;

  factory OpportunityRecommendation.fromJson(Map<String, dynamic> json) => OpportunityRecommendation(
        opportunity: Opportunity.fromJson(json['opportunity'] as Map<String, dynamic>),
        analysis: OpportunityMatchAnalysis.fromJson(json['analysis'] as Map<String, dynamic>),
      );
}

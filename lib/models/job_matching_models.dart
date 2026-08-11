/// Mirrors careermate-backend's JobPosting/JobMatchAnalysis/JobRecommendation
/// (see models/schemas.py). Source-agnostic on purpose — today the backend
/// serves these from a curated sample dataset; a future real job-board API
/// would return the exact same shape, so nothing here would need to change.
class JobPosting {
  const JobPosting({
    required this.id,
    required this.title,
    required this.company,
    required this.country,
    required this.location,
    required this.employmentType,
    required this.workArrangement,
    required this.experienceLevel,
    required this.field,
    required this.requiredSkills,
    this.salaryRange,
  });

  final String id;
  final String title;
  final String company;
  final String country;
  final String location;
  final String employmentType; // full_time | part_time | internship
  final String workArrangement; // remote | hybrid | onsite
  final String experienceLevel; // entry | mid | senior
  final String field;
  final List<String> requiredSkills;
  final String? salaryRange;

  factory JobPosting.fromJson(Map<String, dynamic> json) => JobPosting(
        id: json['id'] as String,
        title: json['title'] as String,
        company: json['company'] as String,
        country: json['country'] as String,
        location: json['location'] as String,
        employmentType: json['employment_type'] as String,
        workArrangement: json['work_arrangement'] as String,
        experienceLevel: json['experience_level'] as String,
        field: json['field'] as String,
        requiredSkills: List<String>.from(json['required_skills'] as List),
        salaryRange: json['salary_range'] as String?,
      );

  /// Used to store a self-contained snapshot when a candidate saves this
  /// job (see saved_jobs_provider.dart) — Job Matching results aren't
  /// persisted anywhere else, so Saved Jobs needs its own copy.
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'company': company,
        'country': country,
        'location': location,
        'employment_type': employmentType,
        'work_arrangement': workArrangement,
        'experience_level': experienceLevel,
        'field': field,
        'required_skills': requiredSkills,
        'salary_range': salaryRange,
      };
}

class JobMatchAnalysis {
  const JobMatchAnalysis({
    required this.jobId,
    required this.matchScore,
    required this.whyMatch,
    required this.strengths,
    required this.missingSkills,
    required this.suggestedImprovements,
    required this.certifications,
    required this.interviewTips,
  });

  final String jobId;
  final int matchScore;
  final String whyMatch;
  final List<String> strengths;
  final List<String> missingSkills;
  final List<String> suggestedImprovements;
  final List<String> certifications;
  final List<String> interviewTips;

  factory JobMatchAnalysis.fromJson(Map<String, dynamic> json) => JobMatchAnalysis(
        jobId: json['job_id'] as String,
        matchScore: json['match_score'] as int,
        whyMatch: json['why_match'] as String,
        strengths: List<String>.from(json['strengths'] as List),
        missingSkills: List<String>.from(json['missing_skills'] as List),
        suggestedImprovements: List<String>.from(json['suggested_improvements'] as List),
        certifications: List<String>.from(json['certifications'] as List),
        interviewTips: List<String>.from(json['interview_tips'] as List),
      );
}

class JobRecommendation {
  const JobRecommendation({required this.job, required this.analysis});

  final JobPosting job;
  final JobMatchAnalysis analysis;

  factory JobRecommendation.fromJson(Map<String, dynamic> json) => JobRecommendation(
        job: JobPosting.fromJson(json['job'] as Map<String, dynamic>),
        analysis: JobMatchAnalysis.fromJson(json['analysis'] as Map<String, dynamic>),
      );
}

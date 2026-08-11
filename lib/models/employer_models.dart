import 'career_report_models.dart';
import 'job_matching_models.dart';
import 'resume_models.dart';

/// Maps directly onto Supabase's `companies` table (see
/// careermate-backend's supabase/migrations/0006_employer_portal.sql) — an
/// account is an "employer" purely by having a row here, the same
/// implicit-typing convention `profiles` uses for candidates.
class Company {
  const Company({
    required this.id,
    required this.email,
    this.companyName = '',
    this.industry = '',
    this.website = '',
    this.description = '',
    this.country = '',
    this.city = '',
    this.companySize = '',
  });

  final String id;
  final String email;
  final String companyName;
  final String industry;
  final String website;
  final String description;
  final String country;
  final String city;
  final String companySize;

  factory Company.fromJson(Map<String, dynamic> json) => Company(
        id: json['id'] as String,
        email: json['email'] as String? ?? '',
        companyName: json['company_name'] as String? ?? '',
        industry: json['industry'] as String? ?? '',
        website: json['website'] as String? ?? '',
        description: json['description'] as String? ?? '',
        country: json['country'] as String? ?? '',
        city: json['city'] as String? ?? '',
        companySize: json['company_size'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'company_name': companyName,
        'industry': industry,
        'website': website,
        'description': description,
        'country': country,
        'city': city,
        'company_size': companySize,
      };
}

/// Maps directly onto Supabase's `employer_jobs` table. The backend
/// converts this same data into the existing `JobPosting` shape when
/// scoring applicants — see careermate-backend's
/// services/employer_applicant_service.py.
class EmployerJob {
  const EmployerJob({
    required this.id,
    required this.companyId,
    required this.title,
    required this.country,
    required this.location,
    required this.employmentType,
    required this.workArrangement,
    required this.experienceLevel,
    required this.field,
    required this.description,
    required this.requiredSkills,
    required this.education,
    required this.benefits,
    required this.status,
    required this.createdAt,
    this.salaryRange,
    this.closingDate,
  });

  final String id;
  final String companyId;
  final String title;
  final String country;
  final String location;
  final String employmentType; // full_time | part_time | internship
  final String workArrangement; // remote | hybrid | onsite
  final String experienceLevel; // entry | mid | senior
  final String field;
  final String description;
  final List<String> requiredSkills;
  final String education;
  final List<String> benefits;
  final String status; // active | archived | closed
  final DateTime createdAt;
  final String? salaryRange;
  final DateTime? closingDate;

  factory EmployerJob.fromJson(Map<String, dynamic> json) => EmployerJob(
        id: json['id'] as String,
        companyId: json['company_id'] as String,
        title: json['title'] as String? ?? '',
        country: json['country'] as String? ?? '',
        location: json['location'] as String? ?? '',
        employmentType: json['employment_type'] as String? ?? 'full_time',
        workArrangement: json['work_arrangement'] as String? ?? 'onsite',
        experienceLevel: json['experience_level'] as String? ?? 'entry',
        field: json['field'] as String? ?? '',
        description: json['description'] as String? ?? '',
        requiredSkills: List<String>.from(json['required_skills'] as List? ?? const []),
        education: json['education'] as String? ?? '',
        benefits: List<String>.from(json['benefits'] as List? ?? const []),
        status: json['status'] as String? ?? 'active',
        createdAt: DateTime.parse(json['created_at'] as String),
        salaryRange: json['salary_range'] as String?,
        closingDate: json['closing_date'] == null ? null : DateTime.parse(json['closing_date'] as String),
      );

  /// For inserts/updates — omits `id`/`created_at` (server-assigned) and
  /// includes only what a company can actually set.
  Map<String, dynamic> toUpsertJson() => {
        'company_id': companyId,
        'title': title,
        'country': country,
        'location': location,
        'employment_type': employmentType,
        'work_arrangement': workArrangement,
        'experience_level': experienceLevel,
        'field': field,
        'description': description,
        'required_skills': requiredSkills,
        'education': education,
        'benefits': benefits,
        'status': status,
        'salary_range': salaryRange,
        'closing_date': closingDate?.toIso8601String().split('T').first,
      };
}

class EmployerDashboardStats {
  const EmployerDashboardStats({
    required this.totalJobs,
    required this.activeJobs,
    required this.applicationsReceived,
    required this.interviewsScheduled,
  });

  final int totalJobs;
  final int activeJobs;
  final int applicationsReceived;
  final int interviewsScheduled;

  factory EmployerDashboardStats.fromJson(Map<String, dynamic> json) => EmployerDashboardStats(
        totalJobs: json['total_jobs'] as int,
        activeJobs: json['active_jobs'] as int,
        applicationsReceived: json['applications_received'] as int,
        interviewsScheduled: json['interviews_scheduled'] as int,
      );
}

/// One candidate's application to an employer job, bundled with everything
/// needed to evaluate them — resume/career report/AI match score reuse the
/// exact same models the candidate-facing features already use.
class ApplicantRecommendation {
  const ApplicantRecommendation({
    required this.applicationId,
    required this.candidateUserId,
    required this.fullName,
    required this.email,
    required this.status,
    required this.appliedAt,
    this.resume,
    this.careerReport,
    this.matchAnalysis,
  });

  final String applicationId;
  final String candidateUserId;
  final String fullName;
  final String email;
  final String status; // applied | shortlisted | interview | hired | rejected
  final DateTime appliedAt;
  final ResumeSummary? resume;
  final CareerReport? careerReport;
  final JobMatchAnalysis? matchAnalysis;

  factory ApplicantRecommendation.fromJson(Map<String, dynamic> json) => ApplicantRecommendation(
        applicationId: json['application_id'] as String,
        candidateUserId: json['candidate_user_id'] as String,
        fullName: json['full_name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        status: json['status'] as String,
        appliedAt: DateTime.parse(json['applied_at'] as String),
        resume: json['resume'] == null ? null : ResumeSummary.fromJson(json['resume'] as Map<String, dynamic>),
        careerReport: json['career_report'] == null
            ? null
            : CareerReport.fromJson(json['career_report'] as Map<String, dynamic>),
        matchAnalysis: json['match_analysis'] == null
            ? null
            : JobMatchAnalysis.fromJson(json['match_analysis'] as Map<String, dynamic>),
      );

  ApplicantRecommendation copyWithStatus(String newStatus) => ApplicantRecommendation(
        applicationId: applicationId,
        candidateUserId: candidateUserId,
        fullName: fullName,
        email: email,
        status: newStatus,
        appliedAt: appliedAt,
        resume: resume,
        careerReport: careerReport,
        matchAnalysis: matchAnalysis,
      );
}

import 'job_matching_models.dart';

/// A candidate's bookmarked job — wraps a full JobPosting snapshot (see
/// saved_jobs_provider.dart for why a snapshot rather than a reference)
/// plus the match score it had when saved.
class SavedJob {
  const SavedJob({
    required this.id,
    required this.jobPostingId,
    required this.job,
    required this.savedAt,
    this.matchScore,
  });

  final String id;
  final String jobPostingId;
  final JobPosting job;
  final DateTime savedAt;
  final int? matchScore;

  factory SavedJob.fromJson(Map<String, dynamic> json) => SavedJob(
        id: json['id'] as String,
        jobPostingId: json['job_posting_id'] as String,
        job: JobPosting.fromJson(json['job_snapshot'] as Map<String, dynamic>),
        savedAt: DateTime.parse(json['saved_at'] as String),
        matchScore: json['match_score'] as int?,
      );
}

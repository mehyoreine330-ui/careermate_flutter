import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/api_exception.dart';
import '../core/app_config.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/career_coach_models.dart';
import '../models/career_report_models.dart';
import '../models/career_roadmap_models.dart';
import '../models/employer_models.dart';
import '../models/job_matching_models.dart';
import '../models/opportunity_models.dart';
import '../models/onboarding_chat_models.dart';
import '../models/resume_models.dart';
import '../providers/locale_provider.dart';

/// Thin HTTP client for the CareerMate FastAPI backend.
///
/// Every authenticated call reads the current Supabase session's access
/// token and sends it as `Authorization: Bearer <token>` — the backend's
/// `get_current_user_id` dependency verifies it against Supabase. This
/// class never talks to Supabase's Postgres directly; that's the backend's
/// job. It only ever calls FastAPI routes.
class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    return Uri.parse('${AppConfig.apiBaseUrl}$path').replace(
      queryParameters: query?.map((key, value) => MapEntry(key, value.toString())),
    );
  }

  /// Builds the auth header from the active Supabase session.
  /// Throws [ApiException] (401) if the user isn't signed in — callers
  /// should never reach here without a session, but this keeps the
  /// error explicit instead of surfacing as a confusing 401 from FastAPI.
  Map<String, String> _authHeaders() {
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken;
    if (token == null) {
      throw ApiException(
        lookupAppLocalizations(currentAppLocale).commonSomethingWentWrong,
        statusCode: 401,
      );
    }
    return {'Authorization': 'Bearer $token'};
  }

  /// POST /api/v1/resumes/analyze
  /// Uploads a resume PDF + target role, returns the Claude-generated
  /// ATS + skill gap analysis.
  Future<ResumeAnalysisResult> analyzeResume({
    required PlatformFile file,
    required String targetRole,
    String language = 'en',
  }) async {
    final request = http.MultipartRequest(
      'POST',
      _uri('/api/v1/resumes/analyze', {'target_role': targetRole, 'language': language}),
    )
      ..headers.addAll(_authHeaders())
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          file.bytes!,
          filename: file.name,
          contentType: MediaType('application', 'pdf'),
        ),
      );

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw ApiException.fromResponse(response);
    }

    return ResumeAnalysisResult.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// POST /api/v1/resumes/auto-fix
  /// "Auto-Fix with AI" — resends the same PDF plus the analysis already
  /// returned by [analyzeResume] so the backend can rewrite the resume to
  /// address every weakness that analysis found.
  Future<AutoFixResult> autoFixResume({
    required PlatformFile file,
    required String targetRole,
    required ResumeAnalysisResult priorAnalysis,
    String language = 'en',
  }) async {
    final request = http.MultipartRequest(
      'POST',
      _uri('/api/v1/resumes/auto-fix'),
    )
      ..headers.addAll(_authHeaders())
      ..fields['target_role'] = targetRole
      ..fields['prior_analysis_json'] = jsonEncode(priorAnalysis.toJson())
      ..fields['language'] = language
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          file.bytes!,
          filename: file.name,
          contentType: MediaType('application', 'pdf'),
        ),
      );

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw ApiException.fromResponse(response);
    }

    return AutoFixResult.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// POST /api/v1/onboarding/respond
  /// One turn of the AI Welcome onboarding chat. Pass both null for the
  /// very first call of a session to get the opening welcome + question 1.
  Future<OnboardingChatResponse> onboardingRespond({
    String? fieldKey,
    String? answer,
    String language = 'en',
  }) async {
    final response = await _client.post(
      _uri('/api/v1/onboarding/respond'),
      headers: {..._authHeaders(), 'Content-Type': 'application/json'},
      body: jsonEncode({'field_key': fieldKey, 'answer': answer, 'language': language}),
    );

    if (response.statusCode != 200) {
      throw ApiException.fromResponse(response);
    }

    return OnboardingChatResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// POST /api/v1/career-report/generate
  /// Generates (and saves) a career report from the user's most recently
  /// analyzed resume — intended to be called right after a successful
  /// resume analysis.
  Future<CareerReport> generateCareerReport({String language = 'en'}) async {
    final response = await _client.post(
      _uri('/api/v1/career-report/generate', {'language': language}),
      headers: _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw ApiException.fromResponse(response);
    }

    return CareerReport.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// GET /api/v1/career-report/latest
  /// Returns the user's most recent career report, or null if none has
  /// been generated yet (backend returns 404 for that case).
  Future<CareerReport?> getLatestCareerReport() async {
    final response = await _client.get(
      _uri('/api/v1/career-report/latest'),
      headers: _authHeaders(),
    );

    if (response.statusCode == 404) {
      return null;
    }
    if (response.statusCode != 200) {
      throw ApiException.fromResponse(response);
    }

    return CareerReport.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// GET /api/v1/career-report/history
  /// Returns every career report the user has generated, most recent first.
  Future<List<CareerReport>> getCareerReportHistory() async {
    final response = await _client.get(
      _uri('/api/v1/career-report/history'),
      headers: _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw ApiException.fromResponse(response);
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((e) => CareerReport.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /api/v1/resumes/latest
  /// Returns a lightweight summary of the user's most recently analyzed
  /// resume, or null if none exists yet (backend returns 404 for that case).
  Future<ResumeSummary?> getLatestResumeSummary() async {
    final response = await _client.get(
      _uri('/api/v1/resumes/latest'),
      headers: _authHeaders(),
    );

    if (response.statusCode == 404) {
      return null;
    }
    if (response.statusCode != 200) {
      throw ApiException.fromResponse(response);
    }

    return ResumeSummary.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// POST /api/v1/career-coach/message
  /// Sends one chat message and returns the coach's personalized reply.
  /// Both the user's message and the reply are persisted server-side.
  Future<String> sendCoachMessage(String message, {String language = 'en'}) async {
    final response = await _client.post(
      _uri('/api/v1/career-coach/message'),
      headers: {..._authHeaders(), 'Content-Type': 'application/json'},
      body: jsonEncode({'message': message, 'language': language}),
    );

    if (response.statusCode != 200) {
      throw ApiException.fromResponse(response);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['reply'] as String;
  }

  /// GET /api/v1/career-coach/history
  /// Returns the user's full AI Career Coach conversation, oldest first.
  Future<List<CoachMessage>> getCoachHistory() async {
    final response = await _client.get(
      _uri('/api/v1/career-coach/history'),
      headers: _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw ApiException.fromResponse(response);
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((e) => CoachMessage.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Both Job Matching and Internships score a whole batch of listings in a
  /// single AI call — the slowest requests in the app, and the backend's own
  /// OpenAI client timeout (45s) plus live provider fan-out can approach a
  /// minute. Without a client-side cap, a genuinely stuck request hangs
  /// forever with no feedback; this fails fast with a message the screens'
  /// existing `error is ApiException` branch already knows how to display.
  static const _recommendationsTimeout = Duration(seconds: 60);

  Never _throwTimeout() => throw ApiException(
        lookupAppLocalizations(currentAppLocale).commonRequestTimedOut,
        statusCode: 408,
      );

  /// GET /api/v1/job-matching/recommendations
  /// Returns every scored job recommendation, sorted by match score
  /// descending. Filtering happens client-side over this one response.
  Future<List<JobRecommendation>> getJobRecommendations() async {
    final response = await _client
        .get(
          _uri('/api/v1/job-matching/recommendations'),
          headers: _authHeaders(),
        )
        .timeout(_recommendationsTimeout, onTimeout: _throwTimeout);

    if (response.statusCode != 200) {
      throw ApiException.fromResponse(response);
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((e) => JobRecommendation.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /api/v1/internships/recommendations
  /// Returns every scored internship/graduate-program recommendation,
  /// sorted by match score descending. Filtering happens client-side over
  /// this one response, same as Job Matching.
  Future<List<OpportunityRecommendation>> getInternshipRecommendations() async {
    final response = await _client
        .get(
          _uri('/api/v1/internships/recommendations'),
          headers: _authHeaders(),
        )
        .timeout(_recommendationsTimeout, onTimeout: _throwTimeout);

    if (response.statusCode != 200) {
      throw ApiException.fromResponse(response);
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((e) => OpportunityRecommendation.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /api/v1/employer-portal/dashboard
  /// Returns the calling company's job/application counts.
  Future<EmployerDashboardStats> getEmployerDashboard() async {
    final response = await _client.get(
      _uri('/api/v1/employer-portal/dashboard'),
      headers: _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw ApiException.fromResponse(response);
    }

    return EmployerDashboardStats.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// GET /api/v1/employer-portal/jobs/{jobId}/applicants
  /// Returns every applicant to a job the calling company owns, each with
  /// their resume/career report and an AI match score computed by the same
  /// engine that powers candidate-facing Job Matching.
  Future<List<ApplicantRecommendation>> getJobApplicants(String jobId) async {
    final response = await _client.get(
      _uri('/api/v1/employer-portal/jobs/$jobId/applicants'),
      headers: _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw ApiException.fromResponse(response);
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((e) => ApplicantRecommendation.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// PATCH /api/v1/employer-portal/applications/{applicationId}/status
  /// Shortlist / Reject / Mark Interview / Hire. Returns just the new
  /// status — callers already hold the rest of the applicant's data.
  Future<String> updateApplicationStatus(String applicationId, String status) async {
    final response = await _client.patch(
      _uri('/api/v1/employer-portal/applications/$applicationId/status'),
      headers: {..._authHeaders(), 'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode != 200) {
      throw ApiException.fromResponse(response);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['status'] as String;
  }

  /// POST /api/v1/career-roadmap/generate
  /// Generates (and saves) a Career Roadmap from the user's most recently
  /// analyzed resume — intended to be called automatically once a resume
  /// analysis exists and no up-to-date roadmap does yet.
  Future<CareerRoadmap> generateCareerRoadmap({String language = 'en'}) async {
    final response = await _client.post(
      _uri('/api/v1/career-roadmap/generate', {'language': language}),
      headers: _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw ApiException.fromResponse(response);
    }

    return CareerRoadmap.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// GET /api/v1/career-roadmap/latest
  /// Returns the user's most recent Career Roadmap, or null if none has
  /// been generated yet (backend returns 404 for that case).
  Future<CareerRoadmap?> getLatestCareerRoadmap() async {
    final response = await _client.get(
      _uri('/api/v1/career-roadmap/latest'),
      headers: _authHeaders(),
    );

    if (response.statusCode == 404) {
      return null;
    }
    if (response.statusCode != 200) {
      throw ApiException.fromResponse(response);
    }

    return CareerRoadmap.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// PATCH /api/v1/career-roadmap/{roadmapId}/progress
  /// Toggles a single milestone's completed state.
  Future<CareerRoadmap> updateRoadmapProgress({
    required String roadmapId,
    required String milestoneId,
    required bool completed,
  }) async {
    final response = await _client.patch(
      _uri('/api/v1/career-roadmap/$roadmapId/progress'),
      headers: {..._authHeaders(), 'Content-Type': 'application/json'},
      body: jsonEncode({'milestone_id': milestoneId, 'completed': completed}),
    );

    if (response.statusCode != 200) {
      throw ApiException.fromResponse(response);
    }

    return CareerRoadmap.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// GET /health — unauthenticated liveness check, useful for a
  /// "backend unreachable" banner on app start.
  Future<bool> checkHealth() async {
    try {
      final response = await _client.get(_uri('/health'));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  void dispose() => _client.close();
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sv.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('nl'),
    Locale('pl'),
    Locale('pt'),
    Locale('ru'),
    Locale('sv'),
    Locale('tr'),
    Locale('uk'),
    Locale('zh')
  ];

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get commonSaving;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get commonEditProfile;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get commonClearFilters;

  /// No description provided for @commonClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get commonClearAll;

  /// No description provided for @commonApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get commonApply;

  /// No description provided for @commonApplied.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get commonApplied;

  /// No description provided for @commonCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get commonCopy;

  /// No description provided for @commonMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get commonMenu;

  /// No description provided for @commonNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get commonNotifications;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get commonLoading;

  /// No description provided for @commonSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get commonSomethingWentWrong;

  /// No description provided for @commonRequestTimedOut.
  ///
  /// In en, this message translates to:
  /// **'This is taking longer than expected. Please check your connection and try again.'**
  String get commonRequestTimedOut;

  /// No description provided for @landingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your AI Career Assistant'**
  String get landingSubtitle;

  /// No description provided for @landingDescription.
  ///
  /// In en, this message translates to:
  /// **'CareerMate uses AI to analyze your resume, match you with the right jobs, and guide every step of your career — for any profession, in your language.'**
  String get landingDescription;

  /// No description provided for @landingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get landingGetStarted;

  /// No description provided for @landingFeatureResumeTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Resume Analysis'**
  String get landingFeatureResumeTitle;

  /// No description provided for @landingFeatureResumeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get instant, expert feedback to make your resume stand out.'**
  String get landingFeatureResumeSubtitle;

  /// No description provided for @landingFeatureJobMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Job Match Score'**
  String get landingFeatureJobMatchTitle;

  /// No description provided for @landingFeatureJobMatchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'See how well you fit each role before you apply.'**
  String get landingFeatureJobMatchSubtitle;

  /// No description provided for @landingFeatureInterviewTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Interview Practice'**
  String get landingFeatureInterviewTitle;

  /// No description provided for @landingFeatureInterviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Practice real interview questions and get instant feedback.'**
  String get landingFeatureInterviewSubtitle;

  /// No description provided for @landingFeatureRoadmapTitle.
  ///
  /// In en, this message translates to:
  /// **'Career Roadmap'**
  String get landingFeatureRoadmapTitle;

  /// No description provided for @landingFeatureRoadmapSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A personalized, step-by-step plan to reach your goals.'**
  String get landingFeatureRoadmapSubtitle;

  /// No description provided for @landingFeatureLearningTitle.
  ///
  /// In en, this message translates to:
  /// **'Learning Recommendations'**
  String get landingFeatureLearningTitle;

  /// No description provided for @landingFeatureLearningSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Courses and certifications tailored to your skill gaps.'**
  String get landingFeatureLearningSubtitle;

  /// No description provided for @landingFeatureLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Multi-language Support'**
  String get landingFeatureLanguageTitle;

  /// No description provided for @landingFeatureLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use CareerMate fluently in 18 languages, including Arabic.'**
  String get landingFeatureLanguageSubtitle;

  /// No description provided for @commonUnsave.
  ///
  /// In en, this message translates to:
  /// **'Unsave'**
  String get commonUnsave;

  /// No description provided for @commonNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get commonNotAvailable;

  /// No description provided for @commonUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get commonUnknown;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navResumeAnalyzer.
  ///
  /// In en, this message translates to:
  /// **'Resume Analyzer'**
  String get navResumeAnalyzer;

  /// No description provided for @navCareerReport.
  ///
  /// In en, this message translates to:
  /// **'Career Report'**
  String get navCareerReport;

  /// No description provided for @navCareerRoadmap.
  ///
  /// In en, this message translates to:
  /// **'AI Career Roadmap'**
  String get navCareerRoadmap;

  /// No description provided for @navJobMatching.
  ///
  /// In en, this message translates to:
  /// **'Job Matching'**
  String get navJobMatching;

  /// No description provided for @navSavedJobs.
  ///
  /// In en, this message translates to:
  /// **'Saved Jobs'**
  String get navSavedJobs;

  /// No description provided for @navInternships.
  ///
  /// In en, this message translates to:
  /// **'Internships & Graduate Opportunities'**
  String get navInternships;

  /// No description provided for @navAiCareerCoach.
  ///
  /// In en, this message translates to:
  /// **'AI Career Coach'**
  String get navAiCareerCoach;

  /// No description provided for @navLearningHub.
  ///
  /// In en, this message translates to:
  /// **'Learning Hub'**
  String get navLearningHub;

  /// No description provided for @navMockInterview.
  ///
  /// In en, this message translates to:
  /// **'Mock Interview'**
  String get navMockInterview;

  /// No description provided for @navAiAvatar.
  ///
  /// In en, this message translates to:
  /// **'AI Avatar'**
  String get navAiAvatar;

  /// No description provided for @navMyProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get navMyProfile;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get navLogout;

  /// No description provided for @navEmployerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navEmployerDashboard;

  /// No description provided for @navEmployerJobs.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get navEmployerJobs;

  /// No description provided for @navEmployerCompanyProfile.
  ///
  /// In en, this message translates to:
  /// **'Company Profile'**
  String get navEmployerCompanyProfile;

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authWelcomeBack;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get authCreateAccount;

  /// No description provided for @authStartOptimizing.
  ///
  /// In en, this message translates to:
  /// **'Start optimizing your career today.'**
  String get authStartOptimizing;

  /// No description provided for @authSignInContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your journey.'**
  String get authSignInContinue;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get authEmailHint;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get authPasswordHint;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get authSignUp;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSignIn;

  /// No description provided for @authAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get authAlreadyHaveAccount;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get authNoAccount;

  /// No description provided for @authHiringSignInAsEmployer.
  ///
  /// In en, this message translates to:
  /// **'Hiring? Sign in as an Employer'**
  String get authHiringSignInAsEmployer;

  /// No description provided for @authHeadlineCandidate.
  ///
  /// In en, this message translates to:
  /// **'Your AI-powered\ncareer coach.'**
  String get authHeadlineCandidate;

  /// No description provided for @authDescriptionCandidate.
  ///
  /// In en, this message translates to:
  /// **'ATS-ready resumes, live AI mock interviews, and\npersonalized skill roadmaps — built for job seekers\nacross the Arab region and beyond.'**
  String get authDescriptionCandidate;

  /// No description provided for @employerAuthCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your company account'**
  String get employerAuthCreateAccount;

  /// No description provided for @employerAuthSignIn.
  ///
  /// In en, this message translates to:
  /// **'Employer sign in'**
  String get employerAuthSignIn;

  /// No description provided for @employerAuthStartPosting.
  ///
  /// In en, this message translates to:
  /// **'Start posting jobs and reviewing applicants today.'**
  String get employerAuthStartPosting;

  /// No description provided for @employerAuthSignInToManage.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your jobs and applicants.'**
  String get employerAuthSignInToManage;

  /// No description provided for @employerAuthCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get employerAuthCompanyName;

  /// No description provided for @employerAuthCompanyNameHint.
  ///
  /// In en, this message translates to:
  /// **'Acme Corp'**
  String get employerAuthCompanyNameHint;

  /// No description provided for @employerAuthWorkEmail.
  ///
  /// In en, this message translates to:
  /// **'Work Email'**
  String get employerAuthWorkEmail;

  /// No description provided for @employerAuthWorkEmailHint.
  ///
  /// In en, this message translates to:
  /// **'you@company.com'**
  String get employerAuthWorkEmailHint;

  /// No description provided for @employerAuthCreateCompanyAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Company Account'**
  String get employerAuthCreateCompanyAccount;

  /// No description provided for @employerAuthAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have a company account? Sign in'**
  String get employerAuthAlreadyHaveAccount;

  /// No description provided for @employerAuthNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have a company account? Sign up'**
  String get employerAuthNoAccount;

  /// No description provided for @employerAuthCandidateSignIn.
  ///
  /// In en, this message translates to:
  /// **'Looking for a job? Go to candidate sign in'**
  String get employerAuthCandidateSignIn;

  /// No description provided for @employerAuthHeadline.
  ///
  /// In en, this message translates to:
  /// **'Hire smarter\nwith AI matching.'**
  String get employerAuthHeadline;

  /// No description provided for @employerAuthDescription.
  ///
  /// In en, this message translates to:
  /// **'Post roles, review AI-scored applicants, and manage\nyour hiring pipeline — powered by the same matching\nengine that helps candidates find you.'**
  String get employerAuthDescription;

  /// No description provided for @employerAuthEnterCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your company name.'**
  String get employerAuthEnterCompanyName;

  /// No description provided for @employerAuthProfileSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Account created, but we could not save your company profile. You can set it from Company Profile after signing in.'**
  String get employerAuthProfileSaveFailed;

  /// No description provided for @employerAuthNoAccountFound.
  ///
  /// In en, this message translates to:
  /// **'No employer account found for this email. Sign up as an employer, or use the candidate login.'**
  String get employerAuthNoAccountFound;

  /// No description provided for @employerAuthGenericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get employerAuthGenericError;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the email on your account and we\'ll send you a link to reset your password.'**
  String get forgotPasswordBody;

  /// No description provided for @forgotPasswordSendLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get forgotPasswordSendLink;

  /// No description provided for @forgotPasswordCheckEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get forgotPasswordCheckEmail;

  /// No description provided for @forgotPasswordSentBody.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for {email}, we\'ve sent a link to reset your password.'**
  String forgotPasswordSentBody(String email);

  /// No description provided for @forgotPasswordHeadline.
  ///
  /// In en, this message translates to:
  /// **'Forgot your\npassword?'**
  String get forgotPasswordHeadline;

  /// No description provided for @forgotPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'It happens. Enter your email and we\'ll help you get back in.'**
  String get forgotPasswordDescription;

  /// No description provided for @resetPasswordSetNew.
  ///
  /// In en, this message translates to:
  /// **'Set a new password'**
  String get resetPasswordSetNew;

  /// No description provided for @resetPasswordChooseNew.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password for your account.'**
  String get resetPasswordChooseNew;

  /// No description provided for @resetPasswordNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get resetPasswordNewPassword;

  /// No description provided for @resetPasswordConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get resetPasswordConfirmPassword;

  /// No description provided for @resetPasswordUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get resetPasswordUpdate;

  /// No description provided for @resetPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get resetPasswordTooShort;

  /// No description provided for @resetPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get resetPasswordMismatch;

  /// No description provided for @resetPasswordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated. Please sign in again.'**
  String get resetPasswordUpdated;

  /// No description provided for @resetPasswordHeadline.
  ///
  /// In en, this message translates to:
  /// **'Almost there.'**
  String get resetPasswordHeadline;

  /// No description provided for @resetPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Set a new password to finish resetting your account.'**
  String get resetPasswordDescription;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your career progress at a glance.'**
  String get dashboardSubtitle;

  /// No description provided for @dashboardQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get dashboardQuickActions;

  /// No description provided for @dashboardUploadResumeCta.
  ///
  /// In en, this message translates to:
  /// **'Upload your first resume to unlock your AI Career Report.'**
  String get dashboardUploadResumeCta;

  /// No description provided for @dashboardAnalyzeResume.
  ///
  /// In en, this message translates to:
  /// **'Analyze Resume'**
  String get dashboardAnalyzeResume;

  /// No description provided for @dashboardNoCareerReport.
  ///
  /// In en, this message translates to:
  /// **'No Career Report available yet.'**
  String get dashboardNoCareerReport;

  /// No description provided for @dashboardGenerateReport.
  ///
  /// In en, this message translates to:
  /// **'Generate Report'**
  String get dashboardGenerateReport;

  /// No description provided for @dashboardViewFullReport.
  ///
  /// In en, this message translates to:
  /// **'View Full Report'**
  String get dashboardViewFullReport;

  /// No description provided for @dashboardGenerateCareerReport.
  ///
  /// In en, this message translates to:
  /// **'Generate Career Report'**
  String get dashboardGenerateCareerReport;

  /// No description provided for @dashboardCareerReadiness.
  ///
  /// In en, this message translates to:
  /// **'Career Readiness'**
  String get dashboardCareerReadiness;

  /// No description provided for @dashboardHiringScore.
  ///
  /// In en, this message translates to:
  /// **'Hiring Score'**
  String get dashboardHiringScore;

  /// No description provided for @dashboardLatestAtsScore.
  ///
  /// In en, this message translates to:
  /// **'Latest Resume ATS Score'**
  String get dashboardLatestAtsScore;

  /// No description provided for @dashboardLatestCareerReport.
  ///
  /// In en, this message translates to:
  /// **'Latest Career Report'**
  String get dashboardLatestCareerReport;

  /// No description provided for @dashboardReportFor.
  ///
  /// In en, this message translates to:
  /// **'{role} report'**
  String dashboardReportFor(String role);

  /// No description provided for @dashboardGeneralRole.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get dashboardGeneralRole;

  /// No description provided for @dashboardTodaysMission.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Mission'**
  String get dashboardTodaysMission;

  /// No description provided for @dashboardTopRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Top Recommendation'**
  String get dashboardTopRecommendation;

  /// No description provided for @dashboardLatestRoadmapProgress.
  ///
  /// In en, this message translates to:
  /// **'Latest Roadmap Progress'**
  String get dashboardLatestRoadmapProgress;

  /// No description provided for @dashboardRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get dashboardRecentActivity;

  /// No description provided for @dashboardNoRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'No recent activity yet.'**
  String get dashboardNoRecentActivity;

  /// No description provided for @dashboardAnalyzedResume.
  ///
  /// In en, this message translates to:
  /// **'Analyzed resume \"{title}\"'**
  String dashboardAnalyzedResume(String title);

  /// No description provided for @dashboardGeneratedReport.
  ///
  /// In en, this message translates to:
  /// **'Generated AI Career Report'**
  String get dashboardGeneratedReport;

  /// No description provided for @dashboardTimeAgoLine.
  ///
  /// In en, this message translates to:
  /// **'{activity} — {time}'**
  String dashboardTimeAgoLine(String activity, String time);

  /// No description provided for @dashboardQaAnalyzeResumeLabel.
  ///
  /// In en, this message translates to:
  /// **'Analyze Resume'**
  String get dashboardQaAnalyzeResumeLabel;

  /// No description provided for @dashboardQaAnalyzeResumeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check ATS score & skill gaps'**
  String get dashboardQaAnalyzeResumeSubtitle;

  /// No description provided for @dashboardQaViewReportLabel.
  ///
  /// In en, this message translates to:
  /// **'View Career Report'**
  String get dashboardQaViewReportLabel;

  /// No description provided for @dashboardQaViewReportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your personalized roadmap'**
  String get dashboardQaViewReportSubtitle;

  /// No description provided for @dashboardQaFindInternshipsLabel.
  ///
  /// In en, this message translates to:
  /// **'Find Internships'**
  String get dashboardQaFindInternshipsLabel;

  /// No description provided for @dashboardQaFindInternshipsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore graduate opportunities'**
  String get dashboardQaFindInternshipsSubtitle;

  /// No description provided for @dashboardQaTalkToCoachLabel.
  ///
  /// In en, this message translates to:
  /// **'Talk to AI Coach'**
  String get dashboardQaTalkToCoachLabel;

  /// No description provided for @dashboardQaTalkToCoachSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get personalized guidance'**
  String get dashboardQaTalkToCoachSubtitle;

  /// No description provided for @dashboardQaUpdateProfileLabel.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get dashboardQaUpdateProfileLabel;

  /// No description provided for @dashboardQaUpdateProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep your details current'**
  String get dashboardQaUpdateProfileSubtitle;

  /// No description provided for @quickActionOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get quickActionOpen;

  /// No description provided for @timeAgoJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get timeAgoJustNow;

  /// No description provided for @timeAgoMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count}m ago} other{{count}m ago}}'**
  String timeAgoMinutes(num count);

  /// No description provided for @timeAgoHours.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count}h ago} other{{count}h ago}}'**
  String timeAgoHours(num count);

  /// No description provided for @timeAgoDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count}d ago} other{{count}d ago}}'**
  String timeAgoDays(num count);

  /// No description provided for @resumeAnalyzerTitle.
  ///
  /// In en, this message translates to:
  /// **'Resume Analyzer'**
  String get resumeAnalyzerTitle;

  /// No description provided for @resumeAnalyzerUploadTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload your resume'**
  String get resumeAnalyzerUploadTitle;

  /// No description provided for @resumeAnalyzerUploadSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll score it against your target role and flag exactly what to fix.'**
  String get resumeAnalyzerUploadSubtitle;

  /// No description provided for @resumeAnalyzerTargetRole.
  ///
  /// In en, this message translates to:
  /// **'Target Role'**
  String get resumeAnalyzerTargetRole;

  /// No description provided for @resumeAnalyzerTargetRoleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Senior Backend Engineer'**
  String get resumeAnalyzerTargetRoleHint;

  /// No description provided for @resumeAnalyzerChoosePdf.
  ///
  /// In en, this message translates to:
  /// **'Choose a PDF resume'**
  String get resumeAnalyzerChoosePdf;

  /// No description provided for @resumeAnalyzerBrowse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get resumeAnalyzerBrowse;

  /// No description provided for @resumeAnalyzerChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get resumeAnalyzerChange;

  /// No description provided for @resumeAnalyzerAnalyzeButton.
  ///
  /// In en, this message translates to:
  /// **'Analyze Resume'**
  String get resumeAnalyzerAnalyzeButton;

  /// No description provided for @resumeAnalyzerMissingInput.
  ///
  /// In en, this message translates to:
  /// **'Choose a PDF and enter a target role first.'**
  String get resumeAnalyzerMissingInput;

  /// No description provided for @resumeAnalyzerAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your resume with AI…'**
  String get resumeAnalyzerAnalyzing;

  /// No description provided for @resumeAnalyzerCouldNotAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Could not analyze your resume.'**
  String get resumeAnalyzerCouldNotAnalyze;

  /// No description provided for @resumeAnalyzerReadinessScore.
  ///
  /// In en, this message translates to:
  /// **'CAREER READINESS SCORE'**
  String get resumeAnalyzerReadinessScore;

  /// No description provided for @resumeAnalyzerAtsCompatibility.
  ///
  /// In en, this message translates to:
  /// **'ATS Compatibility'**
  String get resumeAnalyzerAtsCompatibility;

  /// No description provided for @resumeAnalyzerMissingKeywords.
  ///
  /// In en, this message translates to:
  /// **'Missing Keywords'**
  String get resumeAnalyzerMissingKeywords;

  /// No description provided for @resumeAnalyzerNoMissingKeywords.
  ///
  /// In en, this message translates to:
  /// **'No missing keywords found — nice work!'**
  String get resumeAnalyzerNoMissingKeywords;

  /// No description provided for @resumeAnalyzerFormattingCheck.
  ///
  /// In en, this message translates to:
  /// **'Formatting Check'**
  String get resumeAnalyzerFormattingCheck;

  /// No description provided for @resumeAnalyzerNoFormattingIssues.
  ///
  /// In en, this message translates to:
  /// **'No formatting issues detected.'**
  String get resumeAnalyzerNoFormattingIssues;

  /// No description provided for @resumeAnalyzerStrengths.
  ///
  /// In en, this message translates to:
  /// **'Strengths'**
  String get resumeAnalyzerStrengths;

  /// No description provided for @resumeAnalyzerNoStrengths.
  ///
  /// In en, this message translates to:
  /// **'No standout strengths identified yet.'**
  String get resumeAnalyzerNoStrengths;

  /// No description provided for @resumeAnalyzerWeakBulletPoints.
  ///
  /// In en, this message translates to:
  /// **'Weak Bullet Points'**
  String get resumeAnalyzerWeakBulletPoints;

  /// No description provided for @resumeAnalyzerNoWeakBulletPoints.
  ///
  /// In en, this message translates to:
  /// **'No weak bullet points found — nice work!'**
  String get resumeAnalyzerNoWeakBulletPoints;

  /// No description provided for @resumeAnalyzerAutoFix.
  ///
  /// In en, this message translates to:
  /// **'Auto-Fix with AI'**
  String get resumeAnalyzerAutoFix;

  /// No description provided for @resumeAnalyzerAutoFixFailed.
  ///
  /// In en, this message translates to:
  /// **'Auto-Fix failed. Please try again.'**
  String get resumeAnalyzerAutoFixFailed;

  /// No description provided for @resumeAnalyzerOptimizedResume.
  ///
  /// In en, this message translates to:
  /// **'Optimized Resume'**
  String get resumeAnalyzerOptimizedResume;

  /// No description provided for @resumeAnalyzerEstScore.
  ///
  /// In en, this message translates to:
  /// **'Est. {score}/100'**
  String resumeAnalyzerEstScore(num score);

  /// No description provided for @resumeAnalyzerWhatChanged.
  ///
  /// In en, this message translates to:
  /// **'What changed'**
  String get resumeAnalyzerWhatChanged;

  /// No description provided for @resumeAnalyzerFullOptimizedText.
  ///
  /// In en, this message translates to:
  /// **'Full optimized text'**
  String get resumeAnalyzerFullOptimizedText;

  /// No description provided for @resumeAnalyzerCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard.'**
  String get resumeAnalyzerCopiedToClipboard;

  /// No description provided for @resumeAnalyzerAiCareerReport.
  ///
  /// In en, this message translates to:
  /// **'AI Career Report'**
  String get resumeAnalyzerAiCareerReport;

  /// No description provided for @resumeAnalyzerGeneratingReport.
  ///
  /// In en, this message translates to:
  /// **'Generating your personalized career report…'**
  String get resumeAnalyzerGeneratingReport;

  /// No description provided for @resumeAnalyzerCouldNotGenerateReport.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t generate your career report — try again.'**
  String get resumeAnalyzerCouldNotGenerateReport;

  /// No description provided for @resumeAnalyzerReportTeaser.
  ///
  /// In en, this message translates to:
  /// **'Career paths, courses, certifications, and a learning roadmap tailored to this resume.'**
  String get resumeAnalyzerReportTeaser;

  /// No description provided for @resumeAnalyzerViewReport.
  ///
  /// In en, this message translates to:
  /// **'View Report'**
  String get resumeAnalyzerViewReport;

  /// No description provided for @careerReportTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Career Report'**
  String get careerReportTitle;

  /// No description provided for @careerReportNoneYetTitle.
  ///
  /// In en, this message translates to:
  /// **'No career report yet'**
  String get careerReportNoneYetTitle;

  /// No description provided for @careerReportNoneYetBody.
  ///
  /// In en, this message translates to:
  /// **'Analyze a resume first, then generate a personalized career report from it.'**
  String get careerReportNoneYetBody;

  /// No description provided for @careerReportGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate Career Report'**
  String get careerReportGenerate;

  /// No description provided for @careerReportLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading your career report…'**
  String get careerReportLoading;

  /// No description provided for @careerReportCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load your career report.'**
  String get careerReportCouldNotLoad;

  /// No description provided for @careerReportCouldNotGenerate.
  ///
  /// In en, this message translates to:
  /// **'Could not generate your career report. Please try again.'**
  String get careerReportCouldNotGenerate;

  /// No description provided for @careerReportCareerReadiness.
  ///
  /// In en, this message translates to:
  /// **'CAREER READINESS'**
  String get careerReportCareerReadiness;

  /// No description provided for @careerReportReadinessDesc.
  ///
  /// In en, this message translates to:
  /// **'How ready your profile is for the target role.'**
  String get careerReportReadinessDesc;

  /// No description provided for @careerReportHiringScore.
  ///
  /// In en, this message translates to:
  /// **'ESTIMATED HIRING SCORE'**
  String get careerReportHiringScore;

  /// No description provided for @careerReportHiringScoreDesc.
  ///
  /// In en, this message translates to:
  /// **'Overall hireability right now, beyond just ATS.'**
  String get careerReportHiringScoreDesc;

  /// No description provided for @careerReportStrengths.
  ///
  /// In en, this message translates to:
  /// **'Strengths'**
  String get careerReportStrengths;

  /// No description provided for @careerReportAreasToImprove.
  ///
  /// In en, this message translates to:
  /// **'Areas to Improve'**
  String get careerReportAreasToImprove;

  /// No description provided for @careerReportNoSkillGaps.
  ///
  /// In en, this message translates to:
  /// **'No skill gaps found — nice work!'**
  String get careerReportNoSkillGaps;

  /// No description provided for @careerReportRecommendedPaths.
  ///
  /// In en, this message translates to:
  /// **'Recommended Career Paths'**
  String get careerReportRecommendedPaths;

  /// No description provided for @careerReportRecommendedCerts.
  ///
  /// In en, this message translates to:
  /// **'Recommended Certifications'**
  String get careerReportRecommendedCerts;

  /// No description provided for @careerReportRecommendedCourses.
  ///
  /// In en, this message translates to:
  /// **'Recommended Courses'**
  String get careerReportRecommendedCourses;

  /// No description provided for @careerReportLearningRoadmap.
  ///
  /// In en, this message translates to:
  /// **'Personalized Learning Roadmap'**
  String get careerReportLearningRoadmap;

  /// No description provided for @careerReportNoRoadmap.
  ///
  /// In en, this message translates to:
  /// **'No roadmap generated yet.'**
  String get careerReportNoRoadmap;

  /// No description provided for @careerReportNextSteps.
  ///
  /// In en, this message translates to:
  /// **'Next Steps'**
  String get careerReportNextSteps;

  /// No description provided for @careerReportNothingToShow.
  ///
  /// In en, this message translates to:
  /// **'Nothing to show yet.'**
  String get careerReportNothingToShow;

  /// No description provided for @careerRoadmapTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Career Roadmap'**
  String get careerRoadmapTitle;

  /// No description provided for @careerRoadmapRegenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get careerRoadmapRegenerate;

  /// No description provided for @careerRoadmapCouldNotRegenerate.
  ///
  /// In en, this message translates to:
  /// **'Could not regenerate your roadmap. Please try again.'**
  String get careerRoadmapCouldNotRegenerate;

  /// No description provided for @careerRoadmapNoneYetTitle.
  ///
  /// In en, this message translates to:
  /// **'No roadmap yet'**
  String get careerRoadmapNoneYetTitle;

  /// No description provided for @careerRoadmapNoneYetBody.
  ///
  /// In en, this message translates to:
  /// **'Analyze a resume first — your personalized Career Roadmap is generated automatically as soon as one exists.'**
  String get careerRoadmapNoneYetBody;

  /// No description provided for @careerRoadmapBuilding.
  ///
  /// In en, this message translates to:
  /// **'Building your career roadmap…'**
  String get careerRoadmapBuilding;

  /// No description provided for @careerRoadmapCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load your career roadmap.'**
  String get careerRoadmapCouldNotLoad;

  /// No description provided for @careerRoadmapCurrentLevel.
  ///
  /// In en, this message translates to:
  /// **'CURRENT CAREER LEVEL'**
  String get careerRoadmapCurrentLevel;

  /// No description provided for @careerRoadmapNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get careerRoadmapNotAvailable;

  /// No description provided for @careerRoadmapTimelineNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Estimated timeline not available.'**
  String get careerRoadmapTimelineNotAvailable;

  /// No description provided for @careerRoadmapEstimatedTimeline.
  ///
  /// In en, this message translates to:
  /// **'Estimated timeline: {timeline}'**
  String careerRoadmapEstimatedTimeline(String timeline);

  /// No description provided for @careerRoadmapProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get careerRoadmapProgress;

  /// No description provided for @careerRoadmapNoMilestones.
  ///
  /// In en, this message translates to:
  /// **'No milestones yet.'**
  String get careerRoadmapNoMilestones;

  /// No description provided for @careerRoadmapMissingSkills.
  ///
  /// In en, this message translates to:
  /// **'Missing Skills'**
  String get careerRoadmapMissingSkills;

  /// No description provided for @careerRoadmapNoMissingSkills.
  ///
  /// In en, this message translates to:
  /// **'No missing skills identified.'**
  String get careerRoadmapNoMissingSkills;

  /// No description provided for @careerRoadmapLearningPlan.
  ///
  /// In en, this message translates to:
  /// **'Personalized Learning Plan'**
  String get careerRoadmapLearningPlan;

  /// No description provided for @careerRoadmapNoLearningPlan.
  ///
  /// In en, this message translates to:
  /// **'No learning plan available.'**
  String get careerRoadmapNoLearningPlan;

  /// No description provided for @careerRoadmapRecommendedCerts.
  ///
  /// In en, this message translates to:
  /// **'Recommended Certifications'**
  String get careerRoadmapRecommendedCerts;

  /// No description provided for @careerRoadmapNoCerts.
  ///
  /// In en, this message translates to:
  /// **'No certifications recommended right now.'**
  String get careerRoadmapNoCerts;

  /// No description provided for @careerRoadmapRecommendedResources.
  ///
  /// In en, this message translates to:
  /// **'Recommended Resources'**
  String get careerRoadmapRecommendedResources;

  /// No description provided for @careerRoadmapNoResources.
  ///
  /// In en, this message translates to:
  /// **'No resources recommended right now.'**
  String get careerRoadmapNoResources;

  /// No description provided for @careerRoadmapProjects.
  ///
  /// In en, this message translates to:
  /// **'Projects & Practical Experience'**
  String get careerRoadmapProjects;

  /// No description provided for @careerRoadmapNoProjects.
  ///
  /// In en, this message translates to:
  /// **'No specific projects or practical experience recommended for this role.'**
  String get careerRoadmapNoProjects;

  /// No description provided for @careerCoachTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Career Coach'**
  String get careerCoachTitle;

  /// No description provided for @careerCoachSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Personalized guidance based on your resume, career report, and goals.'**
  String get careerCoachSubtitle;

  /// No description provided for @careerCoachTryAsking.
  ///
  /// In en, this message translates to:
  /// **'TRY ASKING'**
  String get careerCoachTryAsking;

  /// No description provided for @careerCoachQ1.
  ///
  /// In en, this message translates to:
  /// **'What should I learn next?'**
  String get careerCoachQ1;

  /// No description provided for @careerCoachQ2.
  ///
  /// In en, this message translates to:
  /// **'How can I improve my ATS score?'**
  String get careerCoachQ2;

  /// No description provided for @careerCoachQ3.
  ///
  /// In en, this message translates to:
  /// **'What certifications should I get?'**
  String get careerCoachQ3;

  /// No description provided for @careerCoachQ4.
  ///
  /// In en, this message translates to:
  /// **'How can I become more employable?'**
  String get careerCoachQ4;

  /// No description provided for @careerCoachQ5.
  ///
  /// In en, this message translates to:
  /// **'What jobs fit my profile?'**
  String get careerCoachQ5;

  /// No description provided for @careerCoachQ6.
  ///
  /// In en, this message translates to:
  /// **'What skills am I missing?'**
  String get careerCoachQ6;

  /// No description provided for @careerCoachQ7.
  ///
  /// In en, this message translates to:
  /// **'Should I study abroad?'**
  String get careerCoachQ7;

  /// No description provided for @careerCoachQ8.
  ///
  /// In en, this message translates to:
  /// **'How do I prepare for interviews?'**
  String get careerCoachQ8;

  /// No description provided for @careerCoachComposerHint.
  ///
  /// In en, this message translates to:
  /// **'Ask your career coach anything...'**
  String get careerCoachComposerHint;

  /// No description provided for @careerCoachErrorRespond.
  ///
  /// In en, this message translates to:
  /// **'The career coach couldn\'t respond just now. Please try again.'**
  String get careerCoachErrorRespond;

  /// No description provided for @aiWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your AI Career Coach'**
  String get aiWelcomeTitle;

  /// No description provided for @aiWelcomeComposerHint.
  ///
  /// In en, this message translates to:
  /// **'Type your answer...'**
  String get aiWelcomeComposerHint;

  /// No description provided for @comingSoonLabel.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoonLabel;

  /// No description provided for @learningHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Learning Hub'**
  String get learningHubTitle;

  /// No description provided for @learningHubDescription.
  ///
  /// In en, this message translates to:
  /// **'Discipline-specific courses, certifications, and learning resources are coming soon.'**
  String get learningHubDescription;

  /// No description provided for @aiAvatarTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Avatar'**
  String get aiAvatarTitle;

  /// No description provided for @aiAvatarDescription.
  ///
  /// In en, this message translates to:
  /// **'A lifelike AI avatar for interactive coaching sessions is coming soon.'**
  String get aiAvatarDescription;

  /// No description provided for @internshipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Internships & Graduate Opportunities'**
  String get internshipsTitle;

  /// No description provided for @internshipsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Internships and graduate programs matched to your field of study, resume, and goals.'**
  String get internshipsSubtitle;

  /// No description provided for @internshipsCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load internship recommendations.'**
  String get internshipsCouldNotLoad;

  /// No description provided for @internshipsNoMatchesTitle.
  ///
  /// In en, this message translates to:
  /// **'No strong matches yet'**
  String get internshipsNoMatchesTitle;

  /// No description provided for @internshipsNoMatchesBody.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find internships or graduate programs that fit your profile well right now. Uploading a resume, generating a Career Report, or adding more skills to your profile will sharpen your matches — or ask the AI Career Coach what to improve next.'**
  String get internshipsNoMatchesBody;

  /// No description provided for @internshipsNoFilterMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'No opportunities match these filters'**
  String get internshipsNoFilterMatchTitle;

  /// No description provided for @internshipsNoFilterMatchBody.
  ///
  /// In en, this message translates to:
  /// **'Try removing a filter to see more recommendations.'**
  String get internshipsNoFilterMatchBody;

  /// No description provided for @filtersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersTitle;

  /// No description provided for @filtersAllCountries.
  ///
  /// In en, this message translates to:
  /// **'All Countries'**
  String get filtersAllCountries;

  /// No description provided for @filtersAllFieldsOfStudy.
  ///
  /// In en, this message translates to:
  /// **'All Fields of Study'**
  String get filtersAllFieldsOfStudy;

  /// No description provided for @filtersInternship.
  ///
  /// In en, this message translates to:
  /// **'Internship'**
  String get filtersInternship;

  /// No description provided for @filtersGraduateProgram.
  ///
  /// In en, this message translates to:
  /// **'Graduate Program'**
  String get filtersGraduateProgram;

  /// No description provided for @filtersRemote.
  ///
  /// In en, this message translates to:
  /// **'Remote'**
  String get filtersRemote;

  /// No description provided for @filtersHybrid.
  ///
  /// In en, this message translates to:
  /// **'Hybrid'**
  String get filtersHybrid;

  /// No description provided for @filtersOnsite.
  ///
  /// In en, this message translates to:
  /// **'On-site'**
  String get filtersOnsite;

  /// No description provided for @filtersPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get filtersPaid;

  /// No description provided for @filtersUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get filtersUnpaid;

  /// No description provided for @filtersFullTime.
  ///
  /// In en, this message translates to:
  /// **'Full-time'**
  String get filtersFullTime;

  /// No description provided for @filtersPartTime.
  ///
  /// In en, this message translates to:
  /// **'Part-time'**
  String get filtersPartTime;

  /// No description provided for @filtersEntryLevel.
  ///
  /// In en, this message translates to:
  /// **'Entry Level'**
  String get filtersEntryLevel;

  /// No description provided for @internshipsRequirements.
  ///
  /// In en, this message translates to:
  /// **'REQUIREMENTS'**
  String get internshipsRequirements;

  /// No description provided for @internshipsViewAiInsights.
  ///
  /// In en, this message translates to:
  /// **'View AI Insights'**
  String get internshipsViewAiInsights;

  /// No description provided for @internshipsHideAiInsights.
  ///
  /// In en, this message translates to:
  /// **'Hide AI Insights'**
  String get internshipsHideAiInsights;

  /// No description provided for @insightWhyMatch.
  ///
  /// In en, this message translates to:
  /// **'Why You Match'**
  String get insightWhyMatch;

  /// No description provided for @insightStrengths.
  ///
  /// In en, this message translates to:
  /// **'Strengths'**
  String get insightStrengths;

  /// No description provided for @insightMissingSkills.
  ///
  /// In en, this message translates to:
  /// **'Missing Skills'**
  String get insightMissingSkills;

  /// No description provided for @insightRecommendedCerts.
  ///
  /// In en, this message translates to:
  /// **'Recommended Certifications'**
  String get insightRecommendedCerts;

  /// No description provided for @insightSuggestedImprovementsBeforeApplying.
  ///
  /// In en, this message translates to:
  /// **'Suggested Improvements Before Applying'**
  String get insightSuggestedImprovementsBeforeApplying;

  /// No description provided for @internshipsApplyPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Applying to \"{title}\" will connect to a real internship/graduate-program board soon — this sample listing isn\'t a live posting yet.'**
  String internshipsApplyPlaceholder(String title);

  /// No description provided for @jobMatchingTitle.
  ///
  /// In en, this message translates to:
  /// **'Job Matching'**
  String get jobMatchingTitle;

  /// No description provided for @jobMatchingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Jobs matched to your resume, skills, and career goals.'**
  String get jobMatchingSubtitle;

  /// No description provided for @jobMatchingCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load job recommendations.'**
  String get jobMatchingCouldNotLoad;

  /// No description provided for @jobMatchingNoMatchesTitle.
  ///
  /// In en, this message translates to:
  /// **'No strong matches yet'**
  String get jobMatchingNoMatchesTitle;

  /// No description provided for @jobMatchingNoMatchesBody.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find jobs that fit your profile well right now. Uploading a resume, generating a Career Report, or adding more skills to your profile will sharpen your matches — or ask the AI Career Coach what to improve next.'**
  String get jobMatchingNoMatchesBody;

  /// No description provided for @jobMatchingNoFilterMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'No jobs match these filters'**
  String get jobMatchingNoFilterMatchTitle;

  /// No description provided for @jobMatchingCareerMateEmployer.
  ///
  /// In en, this message translates to:
  /// **'CareerMate Employer'**
  String get jobMatchingCareerMateEmployer;

  /// No description provided for @jobMatchingViewInsights.
  ///
  /// In en, this message translates to:
  /// **'View AI Insights'**
  String get jobMatchingViewInsights;

  /// No description provided for @jobMatchingHideInsights.
  ///
  /// In en, this message translates to:
  /// **'Hide AI Insights'**
  String get jobMatchingHideInsights;

  /// No description provided for @insightSuggestedImprovements.
  ///
  /// In en, this message translates to:
  /// **'Suggested Improvements'**
  String get insightSuggestedImprovements;

  /// No description provided for @insightCertsToObtain.
  ///
  /// In en, this message translates to:
  /// **'Certifications to Obtain'**
  String get insightCertsToObtain;

  /// No description provided for @insightInterviewTips.
  ///
  /// In en, this message translates to:
  /// **'Interview Preparation Tips'**
  String get insightInterviewTips;

  /// No description provided for @jobMatchingApplyPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Applying to \"{title}\" will connect to a real job board soon — this sample listing isn\'t a live posting yet.'**
  String jobMatchingApplyPlaceholder(String title);

  /// No description provided for @jobMatchingSaveJob.
  ///
  /// In en, this message translates to:
  /// **'Save job'**
  String get jobMatchingSaveJob;

  /// No description provided for @jobMatchingUnsaveJob.
  ///
  /// In en, this message translates to:
  /// **'Unsave job'**
  String get jobMatchingUnsaveJob;

  /// No description provided for @candidateApplyFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not submit your application. Please try again.'**
  String get candidateApplyFailed;

  /// No description provided for @candidateApplySuccess.
  ///
  /// In en, this message translates to:
  /// **'Application submitted!'**
  String get candidateApplySuccess;

  /// No description provided for @savedJobsTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved Jobs'**
  String get savedJobsTitle;

  /// No description provided for @savedJobsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Jobs you\'ve bookmarked from Job Matching.'**
  String get savedJobsSubtitle;

  /// No description provided for @savedJobsCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load your saved jobs.'**
  String get savedJobsCouldNotLoad;

  /// No description provided for @savedJobsNoneYetTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved jobs yet'**
  String get savedJobsNoneYetTitle;

  /// No description provided for @savedJobsNoneYetBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the bookmark icon on any job in Job Matching to save it here for later.'**
  String get savedJobsNoneYetBody;

  /// No description provided for @savedJobsViewInMatching.
  ///
  /// In en, this message translates to:
  /// **'View in Job Matching'**
  String get savedJobsViewInMatching;

  /// No description provided for @savedJobsViewInMatchingSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Head to Job Matching to view this listing\'s full details.'**
  String get savedJobsViewInMatchingSnackbar;

  /// No description provided for @mockInterviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Mock Interview'**
  String get mockInterviewTitle;

  /// No description provided for @mockInterviewPressHold.
  ///
  /// In en, this message translates to:
  /// **'Press and hold the mic to answer.'**
  String get mockInterviewPressHold;

  /// No description provided for @mockInterviewConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get mockInterviewConnecting;

  /// No description provided for @mockInterviewThinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking…'**
  String get mockInterviewThinking;

  /// No description provided for @mockInterviewComplete.
  ///
  /// In en, this message translates to:
  /// **'Interview complete'**
  String get mockInterviewComplete;

  /// No description provided for @mockInterviewConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error'**
  String get mockInterviewConnectionError;

  /// No description provided for @mockInterviewReleaseToSend.
  ///
  /// In en, this message translates to:
  /// **'Release to send'**
  String get mockInterviewReleaseToSend;

  /// No description provided for @mockInterviewPressAndHold.
  ///
  /// In en, this message translates to:
  /// **'Press and hold to answer'**
  String get mockInterviewPressAndHold;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load your notifications.'**
  String get notificationsCouldNotLoad;

  /// No description provided for @notificationsNoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing yet'**
  String get notificationsNoneTitle;

  /// No description provided for @notificationsNoneBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll see updates here when something changes — like a new applicant, or your application moving to a new stage.'**
  String get notificationsNoneBody;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profileTitle;

  /// No description provided for @profileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your details, field of study, and career goals.'**
  String get profileSubtitle;

  /// No description provided for @profileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Profile not found.'**
  String get profileNotFound;

  /// No description provided for @profileCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load profile: {error}'**
  String profileCouldNotLoad(String error);

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated.'**
  String get profileUpdated;

  /// No description provided for @profileCouldNotUpdate.
  ///
  /// In en, this message translates to:
  /// **'Could not update your profile. Please try again.'**
  String get profileCouldNotUpdate;

  /// No description provided for @profileFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get profileFullName;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmail;

  /// No description provided for @profileCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get profileCountry;

  /// No description provided for @profileFieldOfStudy.
  ///
  /// In en, this message translates to:
  /// **'Field of Study'**
  String get profileFieldOfStudy;

  /// No description provided for @profileUniversity.
  ///
  /// In en, this message translates to:
  /// **'University'**
  String get profileUniversity;

  /// No description provided for @profileGraduationYear.
  ///
  /// In en, this message translates to:
  /// **'Graduation Year'**
  String get profileGraduationYear;

  /// No description provided for @profileDreamJob.
  ///
  /// In en, this message translates to:
  /// **'Dream Job'**
  String get profileDreamJob;

  /// No description provided for @profileTargetCountry.
  ///
  /// In en, this message translates to:
  /// **'Target Country'**
  String get profileTargetCountry;

  /// No description provided for @profileSkills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get profileSkills;

  /// No description provided for @profileResumeStatus.
  ///
  /// In en, this message translates to:
  /// **'Uploaded Resume Status'**
  String get profileResumeStatus;

  /// No description provided for @profileNoResumeUploaded.
  ///
  /// In en, this message translates to:
  /// **'No resume uploaded yet'**
  String get profileNoResumeUploaded;

  /// No description provided for @profileResumeUploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded — ATS score {score}'**
  String profileResumeUploaded(num score);

  /// No description provided for @profileChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get profileChecking;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance, notifications, and account preferences.'**
  String get settingsSubtitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsDarkModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'CareerMate is dark-themed by design — light mode is not available yet.'**
  String get settingsDarkModeSubtitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsEmailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email notifications'**
  String get settingsEmailNotifications;

  /// No description provided for @settingsEmailNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Product updates and career report reminders.'**
  String get settingsEmailNotificationsSubtitle;

  /// No description provided for @settingsPushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get settingsPushNotifications;

  /// No description provided for @settingsPushNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Not available on web yet.'**
  String get settingsPushNotificationsSubtitle;

  /// No description provided for @settingsChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get settingsChangePassword;

  /// No description provided for @settingsUpdatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get settingsUpdatePassword;

  /// No description provided for @settingsPasswordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated.'**
  String get settingsPasswordUpdated;

  /// No description provided for @settingsPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get settingsPasswordTooShort;

  /// No description provided for @settingsPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get settingsPasswordMismatch;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsDeleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account and all associated data. This cannot be undone.'**
  String get settingsDeleteAccountBody;

  /// No description provided for @settingsDeleteMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete My Account'**
  String get settingsDeleteMyAccount;

  /// No description provided for @settingsDeleteAccountConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get settingsDeleteAccountConfirmTitle;

  /// No description provided for @settingsDeleteAccountConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your account, resumes, and career reports. This action cannot be undone.'**
  String get settingsDeleteAccountConfirmBody;

  /// No description provided for @settingsDeleteAccountUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Account deletion isn\'t available yet — contact support to delete your account.'**
  String get settingsDeleteAccountUnavailable;

  /// No description provided for @employerDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get employerDashboardTitle;

  /// No description provided for @employerDashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your hiring pipeline at a glance.'**
  String get employerDashboardSubtitle;

  /// No description provided for @employerDashboardCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load dashboard stats.'**
  String get employerDashboardCouldNotLoad;

  /// No description provided for @employerDashboardTotalJobs.
  ///
  /// In en, this message translates to:
  /// **'Total Jobs'**
  String get employerDashboardTotalJobs;

  /// No description provided for @employerDashboardActiveJobs.
  ///
  /// In en, this message translates to:
  /// **'Active Jobs'**
  String get employerDashboardActiveJobs;

  /// No description provided for @employerDashboardApplicationsReceived.
  ///
  /// In en, this message translates to:
  /// **'Applications Received'**
  String get employerDashboardApplicationsReceived;

  /// No description provided for @employerDashboardInterviewsScheduled.
  ///
  /// In en, this message translates to:
  /// **'Interviews Scheduled'**
  String get employerDashboardInterviewsScheduled;

  /// No description provided for @employerDashboardPostFirstJob.
  ///
  /// In en, this message translates to:
  /// **'Post your first job to start receiving AI-matched applicants.'**
  String get employerDashboardPostFirstJob;

  /// No description provided for @employerDashboardPostAJob.
  ///
  /// In en, this message translates to:
  /// **'Post a Job'**
  String get employerDashboardPostAJob;

  /// No description provided for @employerJobsTitle.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get employerJobsTitle;

  /// No description provided for @employerJobsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create, edit, and manage every role you\'ve posted.'**
  String get employerJobsSubtitle;

  /// No description provided for @employerJobsCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load your jobs.'**
  String get employerJobsCouldNotLoad;

  /// No description provided for @employerJobsNoneYetTitle.
  ///
  /// In en, this message translates to:
  /// **'No jobs posted yet'**
  String get employerJobsNoneYetTitle;

  /// No description provided for @employerJobsNoneYetBody.
  ///
  /// In en, this message translates to:
  /// **'Post your first job to start receiving applications — candidates will be scored against it using the same AI matching engine that powers Job Matching.'**
  String get employerJobsNoneYetBody;

  /// No description provided for @employerJobsUntitledRole.
  ///
  /// In en, this message translates to:
  /// **'Untitled role'**
  String get employerJobsUntitledRole;

  /// No description provided for @employerJobsViewApplicants.
  ///
  /// In en, this message translates to:
  /// **'View Applicants'**
  String get employerJobsViewApplicants;

  /// No description provided for @employerJobsArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get employerJobsArchive;

  /// No description provided for @employerJobsReactivate.
  ///
  /// In en, this message translates to:
  /// **'Reactivate'**
  String get employerJobsReactivate;

  /// No description provided for @employerJobsDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this job?'**
  String get employerJobsDeleteConfirmTitle;

  /// No description provided for @employerJobsDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete \"{title}\" and all of its applications. This cannot be undone.'**
  String employerJobsDeleteConfirmBody(String title);

  /// No description provided for @employerJobsApplicantCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} applicant} other{{count} applicants}}'**
  String employerJobsApplicantCount(num count);

  /// No description provided for @employerJobsApplicantCountLoading.
  ///
  /// In en, this message translates to:
  /// **'… applicants'**
  String get employerJobsApplicantCountLoading;

  /// No description provided for @employerJobsApplicantCountError.
  ///
  /// In en, this message translates to:
  /// **'— applicants'**
  String get employerJobsApplicantCountError;

  /// No description provided for @employerJobFormPostTitle.
  ///
  /// In en, this message translates to:
  /// **'Post a Job'**
  String get employerJobFormPostTitle;

  /// No description provided for @employerJobFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Job'**
  String get employerJobFormEditTitle;

  /// No description provided for @employerJobFormJobTitle.
  ///
  /// In en, this message translates to:
  /// **'Job Title'**
  String get employerJobFormJobTitle;

  /// No description provided for @employerJobFormJobTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Backend Engineer'**
  String get employerJobFormJobTitleHint;

  /// No description provided for @employerJobFormCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get employerJobFormCountry;

  /// No description provided for @employerJobFormCountryHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. United Arab Emirates'**
  String get employerJobFormCountryHint;

  /// No description provided for @employerJobFormLocation.
  ///
  /// In en, this message translates to:
  /// **'Location / City'**
  String get employerJobFormLocation;

  /// No description provided for @employerJobFormLocationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Dubai'**
  String get employerJobFormLocationHint;

  /// No description provided for @employerJobFormEmploymentType.
  ///
  /// In en, this message translates to:
  /// **'Employment Type'**
  String get employerJobFormEmploymentType;

  /// No description provided for @employerJobFormWorkArrangement.
  ///
  /// In en, this message translates to:
  /// **'Work Arrangement'**
  String get employerJobFormWorkArrangement;

  /// No description provided for @employerJobFormExperienceLevel.
  ///
  /// In en, this message translates to:
  /// **'Experience Level'**
  String get employerJobFormExperienceLevel;

  /// No description provided for @employerJobFormFieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Field / Category'**
  String get employerJobFormFieldCategory;

  /// No description provided for @employerJobFormSalaryRange.
  ///
  /// In en, this message translates to:
  /// **'Salary Range (optional)'**
  String get employerJobFormSalaryRange;

  /// No description provided for @employerJobFormSalaryRangeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. AED 15,000 - 20,000 / month'**
  String get employerJobFormSalaryRangeHint;

  /// No description provided for @employerJobFormClosingDate.
  ///
  /// In en, this message translates to:
  /// **'Closing Date (optional)'**
  String get employerJobFormClosingDate;

  /// No description provided for @employerJobFormNoDeadline.
  ///
  /// In en, this message translates to:
  /// **'No deadline'**
  String get employerJobFormNoDeadline;

  /// No description provided for @employerJobFormDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get employerJobFormDescription;

  /// No description provided for @employerJobFormDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the role, responsibilities, and team.'**
  String get employerJobFormDescriptionHint;

  /// No description provided for @employerJobFormRequiredSkills.
  ///
  /// In en, this message translates to:
  /// **'Required Skills (comma-separated)'**
  String get employerJobFormRequiredSkills;

  /// No description provided for @employerJobFormRequiredSkillsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Python, FastAPI, PostgreSQL'**
  String get employerJobFormRequiredSkillsHint;

  /// No description provided for @employerJobFormEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get employerJobFormEducation;

  /// No description provided for @employerJobFormEducationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Bachelor\'s degree in Computer Science'**
  String get employerJobFormEducationHint;

  /// No description provided for @employerJobFormBenefits.
  ///
  /// In en, this message translates to:
  /// **'Benefits (comma-separated)'**
  String get employerJobFormBenefits;

  /// No description provided for @employerJobFormBenefitsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Health insurance, Remote work, Annual bonus'**
  String get employerJobFormBenefitsHint;

  /// No description provided for @employerJobFormSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get employerJobFormSaveChanges;

  /// No description provided for @employerJobFormPostJob.
  ///
  /// In en, this message translates to:
  /// **'Post Job'**
  String get employerJobFormPostJob;

  /// No description provided for @employerJobFormEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a job title.'**
  String get employerJobFormEnterTitle;

  /// No description provided for @employerJobFormCouldNotSave.
  ///
  /// In en, this message translates to:
  /// **'Could not save this job. Please try again.'**
  String get employerJobFormCouldNotSave;

  /// No description provided for @employerApplicantsTitle.
  ///
  /// In en, this message translates to:
  /// **'Applicants'**
  String get employerApplicantsTitle;

  /// No description provided for @employerApplicantsCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load applicants.'**
  String get employerApplicantsCouldNotLoad;

  /// No description provided for @employerApplicantsNoneYetTitle.
  ///
  /// In en, this message translates to:
  /// **'No applicants yet'**
  String get employerApplicantsNoneYetTitle;

  /// No description provided for @employerApplicantsNoneYetBody.
  ///
  /// In en, this message translates to:
  /// **'Once candidates apply to this job, they\'ll show up here with an AI-computed match score, resume, and career report.'**
  String get employerApplicantsNoneYetBody;

  /// No description provided for @employerApplicantsCandidate.
  ///
  /// In en, this message translates to:
  /// **'Candidate'**
  String get employerApplicantsCandidate;

  /// No description provided for @employerApplicantsResumeAts.
  ///
  /// In en, this message translates to:
  /// **'Resume ATS {score}'**
  String employerApplicantsResumeAts(num score);

  /// No description provided for @employerApplicantsNoResume.
  ///
  /// In en, this message translates to:
  /// **'No resume on file'**
  String get employerApplicantsNoResume;

  /// No description provided for @employerApplicantsHiringScore.
  ///
  /// In en, this message translates to:
  /// **'Hiring Score {score}'**
  String employerApplicantsHiringScore(num score);

  /// No description provided for @employerApplicantsNoCareerReport.
  ///
  /// In en, this message translates to:
  /// **'No career report on file'**
  String get employerApplicantsNoCareerReport;

  /// No description provided for @employerApplicantsViewMatchAnalysis.
  ///
  /// In en, this message translates to:
  /// **'View AI Match Analysis'**
  String get employerApplicantsViewMatchAnalysis;

  /// No description provided for @employerApplicantsHideMatchAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Hide AI Match Analysis'**
  String get employerApplicantsHideMatchAnalysis;

  /// No description provided for @employerApplicantsAnalysisUnavailable.
  ///
  /// In en, this message translates to:
  /// **'AI match analysis is unavailable for this applicant right now.'**
  String get employerApplicantsAnalysisUnavailable;

  /// No description provided for @employerApplicantsWhyMatch.
  ///
  /// In en, this message translates to:
  /// **'Why This Match'**
  String get employerApplicantsWhyMatch;

  /// No description provided for @employerApplicantsRelevantCerts.
  ///
  /// In en, this message translates to:
  /// **'Relevant Certifications'**
  String get employerApplicantsRelevantCerts;

  /// No description provided for @employerApplicantsInterviewTips.
  ///
  /// In en, this message translates to:
  /// **'Interview Tips'**
  String get employerApplicantsInterviewTips;

  /// No description provided for @employerApplicantsShortlist.
  ///
  /// In en, this message translates to:
  /// **'Shortlist'**
  String get employerApplicantsShortlist;

  /// No description provided for @employerApplicantsMarkInterview.
  ///
  /// In en, this message translates to:
  /// **'Mark Interview'**
  String get employerApplicantsMarkInterview;

  /// No description provided for @employerApplicantsHire.
  ///
  /// In en, this message translates to:
  /// **'Hire'**
  String get employerApplicantsHire;

  /// No description provided for @employerApplicantsReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get employerApplicantsReject;

  /// No description provided for @employerApplicantsStatusApplied.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get employerApplicantsStatusApplied;

  /// No description provided for @employerApplicantsStatusShortlisted.
  ///
  /// In en, this message translates to:
  /// **'Shortlisted'**
  String get employerApplicantsStatusShortlisted;

  /// No description provided for @employerApplicantsStatusInterview.
  ///
  /// In en, this message translates to:
  /// **'Interview'**
  String get employerApplicantsStatusInterview;

  /// No description provided for @employerApplicantsStatusHired.
  ///
  /// In en, this message translates to:
  /// **'Hired'**
  String get employerApplicantsStatusHired;

  /// No description provided for @employerApplicantsStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get employerApplicantsStatusRejected;

  /// No description provided for @employerApplicantsCouldNotUpdateStatus.
  ///
  /// In en, this message translates to:
  /// **'Could not update this applicant\'s status.'**
  String get employerApplicantsCouldNotUpdateStatus;

  /// No description provided for @companyProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Company Profile'**
  String get companyProfileTitle;

  /// No description provided for @companyProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How your company appears to candidates.'**
  String get companyProfileSubtitle;

  /// No description provided for @companyProfileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Company profile not found.'**
  String get companyProfileNotFound;

  /// No description provided for @companyProfileCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load company profile: {error}'**
  String companyProfileCouldNotLoad(String error);

  /// No description provided for @companyProfileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Company profile updated.'**
  String get companyProfileUpdated;

  /// No description provided for @companyProfileCouldNotUpdate.
  ///
  /// In en, this message translates to:
  /// **'Could not update your company profile. Please try again.'**
  String get companyProfileCouldNotUpdate;

  /// No description provided for @companyProfileCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get companyProfileCompanyName;

  /// No description provided for @companyProfileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get companyProfileEmail;

  /// No description provided for @companyProfileIndustry.
  ///
  /// In en, this message translates to:
  /// **'Industry'**
  String get companyProfileIndustry;

  /// No description provided for @companyProfileWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get companyProfileWebsite;

  /// No description provided for @companyProfileCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get companyProfileCountry;

  /// No description provided for @companyProfileCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get companyProfileCity;

  /// No description provided for @companyProfileCompanySize.
  ///
  /// In en, this message translates to:
  /// **'Company Size'**
  String get companyProfileCompanySize;

  /// No description provided for @companyProfileCompanySizeHint.
  ///
  /// In en, this message translates to:
  /// **'Company Size (e.g. 11-50)'**
  String get companyProfileCompanySizeHint;

  /// No description provided for @companyProfileDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get companyProfileDescription;

  /// No description provided for @legalLinksTitle.
  ///
  /// In en, this message translates to:
  /// **'Legal & Support'**
  String get legalLinksTitle;

  /// No description provided for @legalLinksPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get legalLinksPrivacyPolicy;

  /// No description provided for @legalLinksTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get legalLinksTermsOfService;

  /// No description provided for @legalLinksContactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get legalLinksContactUs;

  /// No description provided for @legalLinksAbout.
  ///
  /// In en, this message translates to:
  /// **'About CareerMate'**
  String get legalLinksAbout;

  /// No description provided for @aboutFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'What you can do'**
  String get aboutFeaturesTitle;

  /// No description provided for @aboutFeature1.
  ///
  /// In en, this message translates to:
  /// **'AI Resume Analyzer with ATS scoring'**
  String get aboutFeature1;

  /// No description provided for @aboutFeature2.
  ///
  /// In en, this message translates to:
  /// **'Personalized AI Career Report'**
  String get aboutFeature2;

  /// No description provided for @aboutFeature3.
  ///
  /// In en, this message translates to:
  /// **'AI Career Coach chat'**
  String get aboutFeature3;

  /// No description provided for @aboutFeature4.
  ///
  /// In en, this message translates to:
  /// **'Live AI Mock Interviews'**
  String get aboutFeature4;

  /// No description provided for @aboutFeature5.
  ///
  /// In en, this message translates to:
  /// **'AI-matched Job & Internship recommendations'**
  String get aboutFeature5;

  /// No description provided for @aboutFeature6.
  ///
  /// In en, this message translates to:
  /// **'Employer Portal for posting jobs and reviewing applicants'**
  String get aboutFeature6;

  /// No description provided for @aboutTagline.
  ///
  /// In en, this message translates to:
  /// **'Your AI-powered career coach — ATS-ready resumes, personalized skill roadmaps, live mock interviews, and AI-matched jobs and internships, all in one place. CareerMate also connects candidates directly with employers hiring on the platform, scored by the same AI matching engine on both sides.'**
  String get aboutTagline;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutVersion;

  /// No description provided for @aboutCopyright.
  ///
  /// In en, this message translates to:
  /// **'© 2026 CareerMate. All rights reserved.'**
  String get aboutCopyright;

  /// No description provided for @contactUsTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUsTitle;

  /// No description provided for @contactUsHeading.
  ///
  /// In en, this message translates to:
  /// **'We\'re here to help'**
  String get contactUsHeading;

  /// No description provided for @contactUsBody.
  ///
  /// In en, this message translates to:
  /// **'Whether you\'ve found a bug, have a question about your account or a job application, or want to request your data be deleted, reach out and we\'ll get back to you as soon as we can.'**
  String get contactUsBody;

  /// No description provided for @contactUsEmailSupport.
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get contactUsEmailSupport;

  /// No description provided for @contactUsCouldNotOpenMail.
  ///
  /// In en, this message translates to:
  /// **'Could not open your mail app — please email {email} directly.'**
  String contactUsCouldNotOpenMail(String email);

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @termsOfServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfServiceTitle;

  /// No description provided for @legalLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: July 2026'**
  String get legalLastUpdated;

  /// No description provided for @privacyHeading1.
  ///
  /// In en, this message translates to:
  /// **'1. Information We Collect'**
  String get privacyHeading1;

  /// No description provided for @privacyBody1.
  ///
  /// In en, this message translates to:
  /// **'When you create an account, we collect your email address and the profile details you provide during onboarding (field of study, university, career goals, target country, and similar information). If you upload a resume, we store its text content and the analysis we generate from it. If you create a company account, we collect your company name and any profile details or job postings you add. We do not collect payment information — CareerMate does not currently process payments.'**
  String get privacyBody1;

  /// No description provided for @privacyHeading2.
  ///
  /// In en, this message translates to:
  /// **'2. How We Use Your Information'**
  String get privacyHeading2;

  /// No description provided for @privacyBody2.
  ///
  /// In en, this message translates to:
  /// **'We use your information to power the features you use directly: resume analysis and ATS scoring, AI-generated career reports and coaching replies, job and internship matching and match scoring, and mock interview feedback. Your profile and resume content are sent to our AI processing provider (OpenAI) solely to generate these results — they are not used to train OpenAI\'s models. Employer accounts see only the candidate information relevant to their own job postings\' applicants (name, email, resume summary, career report summary, and AI match analysis).'**
  String get privacyBody2;

  /// No description provided for @privacyHeading3.
  ///
  /// In en, this message translates to:
  /// **'3. Third-Party Services We Use'**
  String get privacyHeading3;

  /// No description provided for @privacyBody3.
  ///
  /// In en, this message translates to:
  /// **'CareerMate is built on a small number of trusted infrastructure providers: Supabase (authentication and database storage), OpenAI (AI-generated analysis, coaching, and transcription), and — only for job listings, and only when configured — external job-board APIs such as Adzuna, Jooble, or JSearch. None of these providers may use your data for purposes beyond providing their service to us.'**
  String get privacyBody3;

  /// No description provided for @privacyHeading4.
  ///
  /// In en, this message translates to:
  /// **'4. Data Retention & Deletion'**
  String get privacyHeading4;

  /// No description provided for @privacyBody4.
  ///
  /// In en, this message translates to:
  /// **'We retain your account data for as long as your account is active. You can update or remove most profile information yourself at any time from My Profile or Company Profile. To request full deletion of your account and associated data, contact us using the details on the Contact Us page — we will process deletion requests promptly.'**
  String get privacyBody4;

  /// No description provided for @privacyHeading5.
  ///
  /// In en, this message translates to:
  /// **'5. Your Rights'**
  String get privacyHeading5;

  /// No description provided for @privacyBody5.
  ///
  /// In en, this message translates to:
  /// **'Depending on where you live, you may have the right to access, correct, export, or delete your personal data, and to object to certain processing. You can exercise these rights at any time by contacting us.'**
  String get privacyBody5;

  /// No description provided for @privacyHeading6.
  ///
  /// In en, this message translates to:
  /// **'6. Data Security'**
  String get privacyHeading6;

  /// No description provided for @privacyBody6.
  ///
  /// In en, this message translates to:
  /// **'We use industry-standard measures to protect your data, including encrypted connections (HTTPS/TLS) for all traffic and Row Level Security on our database so that, by default, no user can read another user\'s private data.'**
  String get privacyBody6;

  /// No description provided for @privacyHeading7.
  ///
  /// In en, this message translates to:
  /// **'7. Children\'s Privacy'**
  String get privacyHeading7;

  /// No description provided for @privacyBody7.
  ///
  /// In en, this message translates to:
  /// **'CareerMate is intended for users who are at least 16 years old. We do not knowingly collect personal information from children under 16.'**
  String get privacyBody7;

  /// No description provided for @privacyHeading8.
  ///
  /// In en, this message translates to:
  /// **'8. Changes to This Policy'**
  String get privacyHeading8;

  /// No description provided for @privacyBody8.
  ///
  /// In en, this message translates to:
  /// **'We may update this policy from time to time. If we make material changes, we will let you know via the app or by email.'**
  String get privacyBody8;

  /// No description provided for @privacyHeading9.
  ///
  /// In en, this message translates to:
  /// **'9. Contact Us'**
  String get privacyHeading9;

  /// No description provided for @privacyBody9.
  ///
  /// In en, this message translates to:
  /// **'If you have questions about this Privacy Policy or how your data is handled, please reach out via the Contact Us page.'**
  String get privacyBody9;

  /// No description provided for @termsHeading1.
  ///
  /// In en, this message translates to:
  /// **'1. Acceptance of Terms'**
  String get termsHeading1;

  /// No description provided for @termsBody1.
  ///
  /// In en, this message translates to:
  /// **'By creating an account or using CareerMate, you agree to these Terms of Service and our Privacy Policy. If you do not agree, please do not use the app.'**
  String get termsBody1;

  /// No description provided for @termsHeading2.
  ///
  /// In en, this message translates to:
  /// **'2. Description of Service'**
  String get termsHeading2;

  /// No description provided for @termsBody2.
  ///
  /// In en, this message translates to:
  /// **'CareerMate is an AI-powered career platform that provides resume analysis, career reports, an AI career coach, mock interviews, and job/internship matching — combining a curated dataset, external job-board listings, and jobs posted directly by employer accounts on the platform.'**
  String get termsBody2;

  /// No description provided for @termsHeading3.
  ///
  /// In en, this message translates to:
  /// **'3. Accounts'**
  String get termsHeading3;

  /// No description provided for @termsBody3.
  ///
  /// In en, this message translates to:
  /// **'You must provide accurate information when creating an account and are responsible for keeping your login credentials secure. You may hold either a candidate account or a company (employer) account — these are separate experiences within the same app.'**
  String get termsBody3;

  /// No description provided for @termsHeading4.
  ///
  /// In en, this message translates to:
  /// **'4. Acceptable Use'**
  String get termsHeading4;

  /// No description provided for @termsBody4.
  ///
  /// In en, this message translates to:
  /// **'You agree not to misuse the platform: no impersonation, no uploading of content you don\'t have the right to share, no attempting to access another user\'s data, and no using the service to post discriminatory, fraudulent, or otherwise unlawful job listings.'**
  String get termsBody4;

  /// No description provided for @termsHeading5.
  ///
  /// In en, this message translates to:
  /// **'5. Employer Accounts'**
  String get termsHeading5;

  /// No description provided for @termsBody5.
  ///
  /// In en, this message translates to:
  /// **'If you create a company account, you represent that you are authorized to post jobs on behalf of that company. Job postings must be accurate, current, and comply with applicable employment and anti-discrimination law in the countries where they are posted. We may remove any listing that violates these terms.'**
  String get termsBody5;

  /// No description provided for @termsHeading6.
  ///
  /// In en, this message translates to:
  /// **'6. AI-Generated Content'**
  String get termsHeading6;

  /// No description provided for @termsBody6.
  ///
  /// In en, this message translates to:
  /// **'Career reports, coaching replies, resume feedback, interview feedback, and job/applicant match scores are generated by AI models and are provided as guidance only. They are not a guarantee of employment, hiring outcome, or professional advice, and should be used alongside your own judgment.'**
  String get termsBody6;

  /// No description provided for @termsHeading7.
  ///
  /// In en, this message translates to:
  /// **'7. Intellectual Property'**
  String get termsHeading7;

  /// No description provided for @termsBody7.
  ///
  /// In en, this message translates to:
  /// **'CareerMate\'s branding, design, and underlying software are owned by us. You retain ownership of the content you upload (such as your resume) and grant us a limited license to process it solely to provide the service to you.'**
  String get termsBody7;

  /// No description provided for @termsHeading8.
  ///
  /// In en, this message translates to:
  /// **'8. Termination'**
  String get termsHeading8;

  /// No description provided for @termsBody8.
  ///
  /// In en, this message translates to:
  /// **'You may stop using CareerMate and request account deletion at any time. We may suspend or terminate accounts that violate these terms.'**
  String get termsBody8;

  /// No description provided for @termsHeading9.
  ///
  /// In en, this message translates to:
  /// **'9. Disclaimer & Limitation of Liability'**
  String get termsHeading9;

  /// No description provided for @termsBody9.
  ///
  /// In en, this message translates to:
  /// **'CareerMate is provided \"as is\" without warranties of any kind. To the fullest extent permitted by law, we are not liable for indirect or consequential damages arising from your use of the service, including hiring or employment decisions made using information from the platform.'**
  String get termsBody9;

  /// No description provided for @termsHeading10.
  ///
  /// In en, this message translates to:
  /// **'10. Changes to These Terms'**
  String get termsHeading10;

  /// No description provided for @termsBody10.
  ///
  /// In en, this message translates to:
  /// **'We may update these Terms from time to time. Continued use of CareerMate after a change means you accept the updated Terms.'**
  String get termsBody10;

  /// No description provided for @termsHeading11.
  ///
  /// In en, this message translates to:
  /// **'11. Contact'**
  String get termsHeading11;

  /// No description provided for @termsBody11.
  ///
  /// In en, this message translates to:
  /// **'Questions about these Terms can be sent to us via the Contact Us page.'**
  String get termsBody11;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'de',
        'en',
        'es',
        'fr',
        'hi',
        'id',
        'it',
        'ja',
        'ko',
        'nl',
        'pl',
        'pt',
        'ru',
        'sv',
        'tr',
        'uk',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'nl':
      return AppLocalizationsNl();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'sv':
      return AppLocalizationsSv();
    case 'tr':
      return AppLocalizationsTr();
    case 'uk':
      return AppLocalizationsUk();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

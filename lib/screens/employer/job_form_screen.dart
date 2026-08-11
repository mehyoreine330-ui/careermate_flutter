import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_exception.dart';
import '../../core/responsive.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/employer_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/employer_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glow_button.dart';
import '../../widgets/sleek_text_field.dart';

const _kEmploymentTypes = ['full_time', 'part_time', 'internship'];
const _kWorkArrangements = ['remote', 'hybrid', 'onsite'];
const _kExperienceLevels = ['entry', 'mid', 'senior'];
const _kFields = [
  'Software & IT',
  'Data & AI',
  'Business & Finance',
  'Marketing',
  'Nursing',
  'Education',
  'Law',
  'Civil Engineering',
  'Architecture',
  'Graphic Design',
  'Psychology',
  'Accounting',
  'Journalism',
  'Other',
];

String _titleCaseWord(String snakeCase) {
  return snakeCase
      .split('_')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

/// Create or edit a job posting. Passing [existingJob] switches this into
/// edit mode (fields pre-filled, "Save Changes" instead of "Post Job").
/// All fields required for the backend's JobPosting conversion (used by
/// the AI matching engine) are collected here — see
/// services/employer_applicant_service.py on the backend.
class JobFormScreen extends ConsumerStatefulWidget {
  const JobFormScreen({super.key, this.existingJob});

  final EmployerJob? existingJob;

  @override
  ConsumerState<JobFormScreen> createState() => _JobFormScreenState();
}

class _JobFormScreenState extends ConsumerState<JobFormScreen> {
  late final TextEditingController _title;
  late final TextEditingController _country;
  late final TextEditingController _location;
  late final TextEditingController _salaryRange;
  late final TextEditingController _description;
  late final TextEditingController _requiredSkills;
  late final TextEditingController _education;
  late final TextEditingController _benefits;

  late String _employmentType;
  late String _workArrangement;
  late String _experienceLevel;
  late String _field;
  DateTime? _closingDate;
  bool _saving = false;

  bool get _isEditing => widget.existingJob != null;

  @override
  void initState() {
    super.initState();
    final job = widget.existingJob;
    _title = TextEditingController(text: job?.title ?? '');
    _country = TextEditingController(text: job?.country ?? '');
    _location = TextEditingController(text: job?.location ?? '');
    _salaryRange = TextEditingController(text: job?.salaryRange ?? '');
    _description = TextEditingController(text: job?.description ?? '');
    _requiredSkills = TextEditingController(text: job?.requiredSkills.join(', ') ?? '');
    _education = TextEditingController(text: job?.education ?? '');
    _benefits = TextEditingController(text: job?.benefits.join(', ') ?? '');
    _employmentType = job?.employmentType ?? _kEmploymentTypes.first;
    _workArrangement = job?.workArrangement ?? _kWorkArrangements.first;
    _experienceLevel = job?.experienceLevel ?? _kExperienceLevels.first;
    _field = _kFields.contains(job?.field) ? job!.field : _kFields.first;
    _closingDate = job?.closingDate;
  }

  @override
  void dispose() {
    _title.dispose();
    _country.dispose();
    _location.dispose();
    _salaryRange.dispose();
    _description.dispose();
    _requiredSkills.dispose();
    _education.dispose();
    _benefits.dispose();
    super.dispose();
  }

  List<String> _parseCommaList(String text) {
    return text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Future<void> _pickClosingDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _closingDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _closingDate = picked);
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (_title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.employerJobFormEnterTitle)),
      );
      return;
    }

    setState(() => _saving = true);
    final companyId = ref.read(currentUserProvider)?.id ?? '';
    final controller = ref.read(employerJobControllerProvider.notifier);

    final job = EmployerJob(
      id: widget.existingJob?.id ?? '',
      companyId: companyId,
      title: _title.text.trim(),
      country: _country.text.trim(),
      location: _location.text.trim(),
      employmentType: _employmentType,
      workArrangement: _workArrangement,
      experienceLevel: _experienceLevel,
      field: _field,
      description: _description.text.trim(),
      requiredSkills: _parseCommaList(_requiredSkills.text),
      education: _education.text.trim(),
      benefits: _parseCommaList(_benefits.text),
      status: widget.existingJob?.status ?? 'active',
      createdAt: widget.existingJob?.createdAt ?? DateTime.now(),
      salaryRange: _salaryRange.text.trim().isEmpty ? null : _salaryRange.text.trim(),
      closingDate: _closingDate,
    );

    if (_isEditing) {
      await controller.updateJob(job.id, job.toUpsertJson());
    } else {
      await controller.createJob(job);
    }

    if (!mounted) return;

    final state = ref.read(employerJobControllerProvider);
    setState(() => _saving = false);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.error is ApiException
                ? (state.error as ApiException).message
                : l10n.employerJobFormCouldNotSave,
          ),
        ),
      );
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 20, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      _isEditing ? l10n.employerJobFormEditTitle : l10n.employerJobFormPostTitle,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 18, vertical: 8),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SleekTextField(controller: _title, label: l10n.employerJobFormJobTitle, hint: l10n.employerJobFormJobTitleHint),
                          const SizedBox(height: 16),
                          _Row(isDesktop: isDesktop, children: [
                            SleekTextField(controller: _country, label: l10n.employerJobFormCountry, hint: l10n.employerJobFormCountryHint),
                            SleekTextField(controller: _location, label: l10n.employerJobFormLocation, hint: l10n.employerJobFormLocationHint),
                          ]),
                          const SizedBox(height: 16),
                          _Row(isDesktop: isDesktop, children: [
                            _Dropdown(
                              label: l10n.employerJobFormEmploymentType,
                              value: _employmentType,
                              options: _kEmploymentTypes,
                              onChanged: (v) => setState(() => _employmentType = v),
                            ),
                            _Dropdown(
                              label: l10n.employerJobFormWorkArrangement,
                              value: _workArrangement,
                              options: _kWorkArrangements,
                              onChanged: (v) => setState(() => _workArrangement = v),
                            ),
                          ]),
                          const SizedBox(height: 16),
                          _Row(isDesktop: isDesktop, children: [
                            _Dropdown(
                              label: l10n.employerJobFormExperienceLevel,
                              value: _experienceLevel,
                              options: _kExperienceLevels,
                              onChanged: (v) => setState(() => _experienceLevel = v),
                            ),
                            _Dropdown(
                              label: l10n.employerJobFormFieldCategory,
                              value: _field,
                              options: _kFields,
                              onChanged: (v) => setState(() => _field = v),
                              formatLabel: (s) => s,
                            ),
                          ]),
                          const SizedBox(height: 16),
                          _Row(isDesktop: isDesktop, children: [
                            SleekTextField(
                              controller: _salaryRange,
                              label: l10n.employerJobFormSalaryRange,
                              hint: l10n.employerJobFormSalaryRangeHint,
                            ),
                            _ClosingDatePicker(date: _closingDate, onTap: _pickClosingDate),
                          ]),
                          const SizedBox(height: 16),
                          SleekTextField(
                            controller: _description,
                            label: l10n.employerJobFormDescription,
                            hint: l10n.employerJobFormDescriptionHint,
                            maxLines: 5,
                          ),
                          const SizedBox(height: 16),
                          SleekTextField(
                            controller: _requiredSkills,
                            label: l10n.employerJobFormRequiredSkills,
                            hint: l10n.employerJobFormRequiredSkillsHint,
                          ),
                          const SizedBox(height: 16),
                          SleekTextField(
                            controller: _education,
                            label: l10n.employerJobFormEducation,
                            hint: l10n.employerJobFormEducationHint,
                          ),
                          const SizedBox(height: 16),
                          SleekTextField(
                            controller: _benefits,
                            label: l10n.employerJobFormBenefits,
                            hint: l10n.employerJobFormBenefitsHint,
                          ),
                          const SizedBox(height: 26),
                          GlowButton(
                            label: _isEditing ? l10n.employerJobFormSaveChanges : l10n.employerJobFormPostJob,
                            isLoading: _saving,
                            onPressed: _saving ? null : _submit,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.isDesktop, required this.children});

  final bool isDesktop;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (!isDesktop) {
      return Column(
        children: [
          for (final child in children) ...[child, const SizedBox(height: 16)],
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: 16),
          Expanded(child: children[i]),
        ],
      ],
    );
  }
}

class _Dropdown extends StatelessWidget {
  const _Dropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.formatLabel,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final String Function(String)? formatLabel;

  @override
  Widget build(BuildContext context) {
    final format = formatLabel ?? _titleCaseWord;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white.withValues(alpha: 0.04),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.surface,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              icon: const Icon(Icons.expand_more_rounded, color: AppColors.textSecondary),
              items: [
                for (final option in options)
                  DropdownMenuItem<String>(value: option, child: Text(format(option))),
              ],
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ClosingDatePicker extends StatelessWidget {
  const _ClosingDatePicker({required this.date, required this.onTap});

  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.employerJobFormClosingDate,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white.withValues(alpha: 0.04),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, color: Colors.white54, size: 18),
                const SizedBox(width: 10),
                Text(
                  date == null ? l10n.employerJobFormNoDeadline : '${date!.year}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

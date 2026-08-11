import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_exception.dart';
import '../../core/responsive.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/employer_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/employer_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glow_button.dart';
import '../../widgets/legal_links_card.dart';
import '../../widgets/sleek_text_field.dart';

/// Company Profile: view + edit the company's public-facing details.
/// Mirrors ProfileContent (candidate My Profile) exactly — same
/// view/edit-toggle pattern, saves go straight to Supabase's `companies`
/// table via the same RLS-protected upsert pattern.
class CompanyProfileContent extends ConsumerStatefulWidget {
  const CompanyProfileContent({super.key});

  @override
  ConsumerState<CompanyProfileContent> createState() => _CompanyProfileContentState();
}

class _CompanyProfileContentState extends ConsumerState<CompanyProfileContent> {
  bool _editing = false;

  late final TextEditingController _companyName;
  late final TextEditingController _industry;
  late final TextEditingController _website;
  late final TextEditingController _description;
  late final TextEditingController _country;
  late final TextEditingController _city;
  late final TextEditingController _companySize;

  bool _controllersReady = false;

  void _initControllers(Company company) {
    if (_controllersReady) return;
    _companyName = TextEditingController(text: company.companyName);
    _industry = TextEditingController(text: company.industry);
    _website = TextEditingController(text: company.website);
    _description = TextEditingController(text: company.description);
    _country = TextEditingController(text: company.country);
    _city = TextEditingController(text: company.city);
    _companySize = TextEditingController(text: company.companySize);
    _controllersReady = true;
  }

  @override
  void dispose() {
    if (_controllersReady) {
      _companyName.dispose();
      _industry.dispose();
      _website.dispose();
      _description.dispose();
      _country.dispose();
      _city.dispose();
      _companySize.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    await ref.read(companyProfileControllerProvider.notifier).updateFields({
      'company_name': _companyName.text.trim(),
      'industry': _industry.text.trim(),
      'website': _website.text.trim(),
      'description': _description.text.trim(),
      'country': _country.text.trim(),
      'city': _city.text.trim(),
      'company_size': _companySize.text.trim(),
    });

    if (!mounted) return;
    final editState = ref.read(companyProfileControllerProvider);
    if (editState.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            editState.error is ApiException
                ? (editState.error as ApiException).message
                : l10n.companyProfileCouldNotUpdate,
          ),
        ),
      );
      return;
    }
    setState(() => _editing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.companyProfileUpdated)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final companyAsync = ref.watch(companyProfileProvider);
    final user = ref.watch(currentUserProvider);
    final isDesktop = Responsive.isDesktop(context);
    final saving = ref.watch(companyProfileControllerProvider).isLoading;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.accentGradient),
                child: const Icon(Icons.apartment_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(l10n.companyProfileTitle, style: Theme.of(context).textTheme.headlineSmall),
              ),
              companyAsync.maybeWhen(
                data: (company) => company == null
                    ? const SizedBox.shrink()
                    : (_editing
                        ? Row(
                            children: [
                              TextButton(
                                onPressed: saving ? null : () => setState(() => _editing = false),
                                child: Text(l10n.commonCancel),
                              ),
                              const SizedBox(width: 8),
                              GlowButton(
                                label: l10n.commonSave,
                                expand: false,
                                isLoading: saving,
                                onPressed: saving ? null : _save,
                              ),
                            ],
                          )
                        : GlowButton(
                            label: l10n.commonEditProfile,
                            icon: Icons.edit_outlined,
                            expand: false,
                            onPressed: () => setState(() => _editing = true),
                          )),
                orElse: () => const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 54),
            child: Text(
              l10n.companyProfileSubtitle,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          const SizedBox(height: 22),
          companyAsync.when(
            data: (company) {
              if (company == null) {
                return GlassCard(
                  child: Text(
                    l10n.companyProfileNotFound,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                );
              }
              _initControllers(company);
              return _editing
                  ? _EditForm(
                      isDesktop: isDesktop,
                      companyName: _companyName,
                      industry: _industry,
                      website: _website,
                      description: _description,
                      country: _country,
                      city: _city,
                      companySize: _companySize,
                    )
                  : _ViewGrid(isDesktop: isDesktop, company: company, email: user?.email ?? '');
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (error, _) => GlassCard(
              glowColor: AppColors.danger,
              child: Text(l10n.companyProfileCouldNotLoad(error.toString()), style: const TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 16),
          const LegalLinksCard(),
        ],
      ),
    );
  }
}

class _ViewGrid extends StatelessWidget {
  const _ViewGrid({required this.isDesktop, required this.company, required this.email});

  final bool isDesktop;
  final Company company;
  final String email;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fields = <MapEntry<String, String>>[
      MapEntry(l10n.companyProfileCompanyName, company.companyName.isEmpty ? l10n.commonNotAvailable : company.companyName),
      MapEntry(l10n.companyProfileEmail, email.isEmpty ? l10n.commonNotAvailable : email),
      MapEntry(l10n.companyProfileIndustry, company.industry.isEmpty ? l10n.commonNotAvailable : company.industry),
      MapEntry(l10n.companyProfileWebsite, company.website.isEmpty ? l10n.commonNotAvailable : company.website),
      MapEntry(l10n.companyProfileCountry, company.country.isEmpty ? l10n.commonNotAvailable : company.country),
      MapEntry(l10n.companyProfileCity, company.city.isEmpty ? l10n.commonNotAvailable : company.city),
      MapEntry(l10n.companyProfileCompanySize, company.companySize.isEmpty ? l10n.commonNotAvailable : company.companySize),
      MapEntry(l10n.companyProfileDescription, company.description.isEmpty ? l10n.commonNotAvailable : company.description),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = isDesktop ? 2 : 1;
        const spacing = 16.0;
        final itemWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final field in fields)
              SizedBox(
                width: itemWidth,
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        field.key.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(field.value, style: const TextStyle(color: Colors.white, fontSize: 14.5)),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _EditForm extends StatelessWidget {
  const _EditForm({
    required this.isDesktop,
    required this.companyName,
    required this.industry,
    required this.website,
    required this.description,
    required this.country,
    required this.city,
    required this.companySize,
  });

  final bool isDesktop;
  final TextEditingController companyName;
  final TextEditingController industry;
  final TextEditingController website;
  final TextEditingController description;
  final TextEditingController country;
  final TextEditingController city;
  final TextEditingController companySize;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldRow(isDesktop: isDesktop, children: [
            SleekTextField(controller: companyName, label: l10n.companyProfileCompanyName),
            SleekTextField(controller: industry, label: l10n.companyProfileIndustry),
          ]),
          const SizedBox(height: 16),
          _FieldRow(isDesktop: isDesktop, children: [
            SleekTextField(controller: country, label: l10n.companyProfileCountry),
            SleekTextField(controller: city, label: l10n.companyProfileCity),
          ]),
          const SizedBox(height: 16),
          _FieldRow(isDesktop: isDesktop, children: [
            SleekTextField(controller: website, label: l10n.companyProfileWebsite),
            SleekTextField(controller: companySize, label: l10n.companyProfileCompanySizeHint),
          ]),
          const SizedBox(height: 16),
          SleekTextField(controller: description, label: l10n.companyProfileDescription, maxLines: 4),
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.isDesktop, required this.children});

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
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: 16),
          Expanded(child: children[i]),
        ],
      ],
    );
  }
}

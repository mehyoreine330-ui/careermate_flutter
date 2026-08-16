import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/responsive.dart';
import '../theme/app_colors.dart';
import '../widgets/fade_in.dart';
import '../widgets/glass_card.dart';
import '../widgets/pill_tag.dart';

/// A resource (course, certification, tool) with a real, working URL —
/// curated, not backend-driven. There is no learning-content API in this
/// project yet; this is the frontend-only functional experience called
/// for in that case, clearly isolated to this one file.
class _Resource {
  const _Resource(this.title, this.provider, this.url);
  final String title;
  final String provider;
  final String url;
}

class _LearningCategory {
  const _LearningCategory({
    required this.icon,
    required this.title,
    required this.skills,
    required this.courses,
    required this.certifications,
  });

  final IconData icon;
  final String title;
  final List<String> skills;
  final List<_Resource> courses;
  final List<_Resource> certifications;
}

const List<_LearningCategory> _categories = [
  _LearningCategory(
    icon: Icons.cloud_outlined,
    title: 'Cloud & DevOps',
    skills: ['AWS', 'Azure', 'GCP', 'Docker', 'Kubernetes', 'CI/CD'],
    courses: [
      _Resource('AWS Skill Builder — free digital training', 'AWS', 'https://skillbuilder.aws/'),
      _Resource('Google Cloud Training & Certification', 'Google Cloud', 'https://cloud.google.com/learn/training'),
      _Resource('Microsoft Learn — Azure Fundamentals', 'Microsoft', 'https://learn.microsoft.com/training/azure/'),
    ],
    certifications: [
      _Resource('AWS Certified Cloud Practitioner', 'AWS', 'https://aws.amazon.com/certification/certified-cloud-practitioner/'),
      _Resource('AWS Certified Solutions Architect', 'AWS', 'https://aws.amazon.com/certification/certified-solutions-architect-associate/'),
    ],
  ),
  _LearningCategory(
    icon: Icons.code_rounded,
    title: 'Software Engineering',
    skills: ['Python', 'JavaScript', 'System Design', 'APIs', 'Testing', 'Git'],
    courses: [
      _Resource('freeCodeCamp — full curriculum, free', 'freeCodeCamp', 'https://www.freecodecamp.org/'),
      _Resource('The Odin Project — full-stack path', 'The Odin Project', 'https://www.theodinproject.com/'),
      _Resource('Codecademy — interactive courses', 'Codecademy', 'https://www.codecademy.com/'),
    ],
    certifications: [
      _Resource('Meta Back-End Developer Certificate', 'Coursera', 'https://www.coursera.org/professional-certificates/meta-back-end-developer'),
    ],
  ),
  _LearningCategory(
    icon: Icons.auto_awesome_outlined,
    title: 'Data & AI',
    skills: ['Machine Learning', 'SQL', 'Data Analysis', 'Deep Learning', 'Statistics'],
    courses: [
      _Resource('Kaggle Learn — free, hands-on', 'Kaggle', 'https://www.kaggle.com/learn'),
      _Resource('DeepLearning.AI — AI courses & specializations', 'DeepLearning.AI', 'https://www.deeplearning.ai/'),
      _Resource('Google Digital Garage — Data Analytics', 'Google', 'https://learndigital.withgoogle.com/digitalgarage'),
    ],
    certifications: [
      _Resource('Google Data Analytics Certificate', 'Coursera', 'https://www.coursera.org/professional-certificates/google-data-analytics'),
    ],
  ),
  _LearningCategory(
    icon: Icons.design_services_outlined,
    title: 'Design & UX',
    skills: ['UX Research', 'Figma', 'Prototyping', 'Visual Design'],
    courses: [
      _Resource('Google UX Design Certificate', 'Coursera', 'https://www.coursera.org/professional-certificates/google-ux-design'),
      _Resource('Figma — official tutorials', 'Figma', 'https://www.figma.com/resources/learn-design/'),
    ],
    certifications: [
      _Resource('Google UX Design Professional Certificate', 'Coursera', 'https://www.coursera.org/professional-certificates/google-ux-design'),
    ],
  ),
  _LearningCategory(
    icon: Icons.trending_up_rounded,
    title: 'Business & Marketing',
    skills: ['Digital Marketing', 'Project Management', 'SEO', 'Analytics'],
    courses: [
      _Resource('HubSpot Academy — free certifications', 'HubSpot', 'https://academy.hubspot.com/'),
      _Resource('Google Digital Garage — Digital Marketing', 'Google', 'https://learndigital.withgoogle.com/digitalgarage'),
    ],
    certifications: [
      _Resource('Project Management Professional (PMP)', 'PMI', 'https://www.pmi.org/certifications/project-management-pmp'),
      _Resource('HubSpot Content Marketing Certification', 'HubSpot', 'https://academy.hubspot.com/courses/content-marketing'),
    ],
  ),
  _LearningCategory(
    icon: Icons.favorite_border_rounded,
    title: 'Healthcare & Life Sciences',
    skills: ['Patient Care', 'Clinical Documentation', 'Licensure Prep'],
    courses: [
      _Resource('Khan Academy — Health & Medicine', 'Khan Academy', 'https://www.khanacademy.org/science/health-and-medicine'),
      _Resource('Coursera — Health & Medicine courses', 'Coursera', 'https://www.coursera.org/browse/health'),
    ],
    certifications: [
      _Resource('ANCC Certification (nursing specialties)', 'ANCC', 'https://www.nursingworld.org/ancc/'),
    ],
  ),
];

/// Real, functional Learning Hub: curated categories, courses, and
/// certifications with genuine external links, plus a lightweight
/// session-local "started" tracker (no backend endpoint exists for
/// learning progress yet, so nothing here is persisted between visits —
/// clearly scoped to this widget's own State).
class LearningHubContent extends StatefulWidget {
  const LearningHubContent({super.key});

  @override
  State<LearningHubContent> createState() => _LearningHubContentState();
}

class _LearningHubContentState extends State<LearningHubContent> {
  final Set<String> _started = {};

  Future<void> _openResource(_Resource resource) async {
    final uri = Uri.parse(resource.url);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open ${resource.url}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    return SingleChildScrollView(
      child: FadeSlideIn(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Learning Hub', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(
              'Curated skills, courses, and certifications across career paths — tap any '
              'resource to open it.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            for (final category in _categories) ...[
              _CategoryCard(
                category: category,
                isDesktop: isDesktop,
                started: _started,
                onToggleStarted: (key) => setState(() {
                  _started.contains(key) ? _started.remove(key) : _started.add(key);
                }),
                onOpen: _openResource,
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.isDesktop,
    required this.started,
    required this.onToggleStarted,
    required this.onOpen,
  });

  final _LearningCategory category;
  final bool isDesktop;
  final Set<String> started;
  final void Function(String key) onToggleStarted;
  final void Function(_Resource resource) onOpen;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accentIndigo.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(category.icon, color: AppColors.accentCyan),
              ),
              const SizedBox(width: 14),
              Text(category.title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final skill in category.skills) PillTag(label: skill)],
          ),
          const SizedBox(height: 16),
          Text('Courses', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          for (final course in category.courses)
            _ResourceRow(
              resource: course,
              started: started.contains(course.url),
              onToggleStarted: () => onToggleStarted(course.url),
              onOpen: () => onOpen(course),
            ),
          const SizedBox(height: 12),
          Text('Certifications', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          for (final cert in category.certifications)
            _ResourceRow(
              resource: cert,
              started: started.contains(cert.url),
              onToggleStarted: () => onToggleStarted(cert.url),
              onOpen: () => onOpen(cert),
            ),
        ],
      ),
    );
  }
}

class _ResourceRow extends StatelessWidget {
  const _ResourceRow({
    required this.resource,
    required this.started,
    required this.onToggleStarted,
    required this.onOpen,
  });

  final _Resource resource;
  final bool started;
  final VoidCallback onToggleStarted;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(resource.title, style: Theme.of(context).textTheme.bodyMedium),
                      Text(resource.provider, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: started ? 'Marked as started' : 'Mark as started',
                  icon: Icon(
                    started ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    color: started ? AppColors.accentCyan : Colors.white38,
                    size: 20,
                  ),
                  onPressed: onToggleStarted,
                ),
                const Icon(Icons.open_in_new_rounded, size: 16, color: Colors.white38),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

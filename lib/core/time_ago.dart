import '../l10n/generated/app_localizations.dart';

/// Shared relative-time formatter ("2m ago", "3h ago", "1d ago") used by the
/// Dashboard's Recent Activity card and the Notifications list — kept in one
/// place so both stay in sync and both go through the localized plural
/// strings in AppLocalizations rather than hardcoded English.
String timeAgo(AppLocalizations l10n, DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return l10n.timeAgoJustNow;
  if (diff.inMinutes < 60) return l10n.timeAgoMinutes(diff.inMinutes);
  if (diff.inHours < 24) return l10n.timeAgoHours(diff.inHours);
  return l10n.timeAgoDays(diff.inDays);
}

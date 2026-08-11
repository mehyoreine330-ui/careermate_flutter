import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_exception.dart';
import '../core/time_ago.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/notification_models.dart';
import '../providers/notifications_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_card.dart';

const _kindIcons = {
  'application_status': Icons.assignment_turned_in_outlined,
  'new_applicant': Icons.person_add_alt_1_outlined,
};

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notificationsAsync = ref.watch(notificationsProvider);
    final hasUnread = ref.watch(unreadNotificationCountProvider) > 0;

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
                    Expanded(
                      child: Text(
                        l10n.notificationsTitle,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                    ),
                    if (hasUnread)
                      TextButton(
                        onPressed: () => ref.read(notificationsControllerProvider.notifier).markAllAsRead(),
                        child: Text(l10n.notificationsMarkAllRead, style: const TextStyle(color: AppColors.accentCyan)),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: notificationsAsync.when(
                    data: (notifications) {
                      if (notifications.isEmpty) {
                        return const _NoNotificationsState();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final notification in notifications) ...[
                            _NotificationTile(notification: notification),
                            const SizedBox(height: 10),
                          ],
                        ],
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    error: (error, _) => GlassCard(
                      glowColor: AppColors.danger,
                      child: Text(
                        error is ApiException ? error.message : l10n.notificationsCouldNotLoad,
                        style: const TextStyle(color: Colors.white),
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

class _NoNotificationsState extends StatelessWidget {
  const _NoNotificationsState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GlassCard(
      glowColor: AppColors.accentIndigo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.notificationsNoneTitle,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.notificationsNoneBody,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: notification.read
          ? null
          : () => ref.read(notificationsControllerProvider.notifier).markAsRead(notification.id),
      child: GlassCard(
        glowColor: notification.read ? null : AppColors.accentCyan,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (notification.read ? AppColors.textMuted : AppColors.accentCyan).withValues(alpha: 0.14),
              ),
              child: Icon(
                _kindIcons[notification.kind] ?? Icons.notifications_none_rounded,
                size: 18,
                color: notification.read ? AppColors.textMuted : AppColors.accentCyan,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: notification.read ? FontWeight.w500 : FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.body,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.35),
                  ),
                  const SizedBox(height: 6),
                  Text(timeAgo(l10n, notification.createdAt), style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
            ),
            if (!notification.read)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.accentCyan),
              ),
          ],
        ),
      ),
    );
  }
}

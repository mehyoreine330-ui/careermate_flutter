import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/generated/app_localizations.dart';
import '../providers/notifications_provider.dart';
import '../screens/notifications_screen.dart';
import '../theme/app_colors.dart';
import 'icon_glow_button.dart';

/// Bell icon with an unread-count badge, shared by both the candidate and
/// employer shells. Notifications are keyed by plain user_id, so the same
/// widget works identically for either account type.
class NotificationBellButton extends ConsumerWidget {
  const NotificationBellButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconGlowButton(
          icon: Icons.notifications_outlined,
          tooltip: AppLocalizations.of(context).commonNotifications,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          ),
        ),
        if (unreadCount > 0)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              constraints: const BoxConstraints(minWidth: 16),
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.bgTop, width: 1.5),
              ),
              child: Text(
                unreadCount > 9 ? '9+' : '$unreadCount',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800),
              ),
            ),
          ),
      ],
    );
  }
}

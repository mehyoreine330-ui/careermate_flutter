import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification_models.dart';
import 'auth_provider.dart';

/// The current user's notifications, most recent first — works identically
/// for candidate and employer accounts, since notifications are keyed by
/// plain user_id (see careermate-backend's 0008_notifications.sql triggers).
/// Plain CRUD, RLS-protected, direct-to-Supabase.
final notificationsProvider = FutureProvider.autoDispose<List<AppNotification>>((ref) async {
  final userId = ref.watch(currentUserProvider)?.id;
  if (userId == null) return [];

  final supabase = ref.watch(supabaseClientProvider);
  final rows = await supabase
      .from('notifications')
      .select()
      .eq('user_id', userId)
      .order('created_at', ascending: false)
      .limit(50);

  return (rows as List).map((row) => AppNotification.fromJson(row as Map<String, dynamic>)).toList();
});

final unreadNotificationCountProvider = Provider.autoDispose<int>((ref) {
  final notifications = ref.watch(notificationsProvider).valueOrNull ?? const [];
  return notifications.where((n) => !n.read).length;
});

class NotificationsController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> markAsRead(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final supabase = ref.read(supabaseClientProvider);
      await supabase.from('notifications').update({'read': true}).eq('id', id);
      ref.invalidate(notificationsProvider);
    });
  }

  Future<void> markAllAsRead() async {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final supabase = ref.read(supabaseClientProvider);
      await supabase.from('notifications').update({'read': true}).eq('user_id', userId).eq('read', false);
      ref.invalidate(notificationsProvider);
    });
  }
}

final notificationsControllerProvider =
    AsyncNotifierProvider<NotificationsController, void>(NotificationsController.new);

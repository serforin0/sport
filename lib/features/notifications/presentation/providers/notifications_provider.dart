import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/core/providers/shared_preferences_provider.dart';
import 'package:sport/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:sport/features/notifications/domain/entities/notification.dart';

final notificationsRemoteDataSourceProvider = Provider<NotificationsRemoteDataSource>((ref) {
  return NotificationsRemoteDataSource(
    ref.watch(apiClientProvider),
    ref.watch(sharedPreferencesProvider),
  );
});

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<AppNotification>>(NotificationsNotifier.new);

class NotificationsNotifier extends AsyncNotifier<List<AppNotification>> {
  NotificationsRemoteDataSource get _ds => ref.read(notificationsRemoteDataSourceProvider);

  @override
  Future<List<AppNotification>> build() => _ds.fetchNotifications();

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_ds.fetchNotifications);
  }

  Future<void> markAllAsRead() async {
    final oldState = state;
    state.whenData((list) {
      state = AsyncValue.data(list.map((n) => n.copyWith(isRead: true)).toList());
    });
    try {
      await _ds.markAllAsRead();
    } catch (e) {
      state = oldState; // Rollback
    }
  }

  Future<void> markAsRead(String id) async {
    final oldState = state;
    state.whenData((list) {
      state = AsyncValue.data(
        list.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList(),
      );
    });
    try {
      await _ds.markAsRead(id);
    } catch (e) {
      state = oldState; // Rollback
    }
  }
}

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final async = ref.watch(notificationsProvider);
  return async.maybeWhen(
    data: (list) => list.where((AppNotification n) => !n.isRead).length,
    orElse: () => 0,
  );
});

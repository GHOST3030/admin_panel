import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../data/notifications_datasource.dart';

final notificationsDataSourceProvider = Provider<NotificationsDataSource>(
  (ref) => NotificationsDataSource(ref.watch(supabaseClientProvider)),
);

/// Call this after every order status update.
final notificationsTriggerProvider =
    Provider<NotificationsTrigger>((ref) {
  return NotificationsTrigger(ref.watch(notificationsDataSourceProvider));
});

class NotificationsTrigger {
  const NotificationsTrigger(this._dataSource);
  final NotificationsDataSource _dataSource;

  Future<void> onOrderStatusChanged({
    required String orderId,
    required String userId,
    required String newStatus,
  }) =>
      _dataSource.triggerOrderStatusNotification(
        orderId: orderId,
        userId: userId,
        newStatus: newStatus,
      );
}

import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/exceptions.dart';
import '../../../core/logging/app_logger.dart';

final _log = AppLogger.getLogger('NotificationsDataSource');

class NotificationsDataSource {
  const NotificationsDataSource(this._client);
  final SupabaseClient _client;

  /// Called when admin updates an order status.
  /// Creates a notification row for the order owner.
  Future<void> triggerOrderStatusNotification({
    required String orderId,
    required String userId,
    required String newStatus,
  }) async {
    _log.info(
        'Triggering notification: orderId=$orderId, userId=$userId, status=$newStatus');
    try {
      final titleMap = {
        'processing': 'Order Confirmed',
        'shipped':    'Order Shipped',
        'delivered':  'Order Delivered',
        'cancelled':  'Order Cancelled',
      };
      final bodyMap = {
        'processing': 'Your order is being processed.',
        'shipped':    'Your order is on the way!',
        'delivered':  'Your order has been delivered.',
        'cancelled':  'Your order has been cancelled.',
      };

      await _client.from('notifications').insert({
        'user_id':   userId,
        'order_id':  orderId,
        'title':     titleMap[newStatus] ?? 'Order Update',
        'body':      bodyMap[newStatus]  ?? 'Your order status changed to $newStatus.',
        'type':      'order_status',
        'is_read':   false,
      });
      _log.info('Notification created: orderId=$orderId, type=order_status');
    } on PostgrestException catch (e) {
      _log.severe(
          'Failed to create notification: orderId=$orderId, error=${e.message}', e);
      throw ServerException(message: e.message, statusCode: e.code);
    } catch (e, st) {
      _log.severe('Unexpected error creating notification: orderId=$orderId', e, st);
      throw ServerException(message: e.toString());
    }
  }
}

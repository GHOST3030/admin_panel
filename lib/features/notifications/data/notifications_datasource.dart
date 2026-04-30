import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/errors/exceptions.dart';

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
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, statusCode: e.code);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}

import 'package:equatable/equatable.dart';

sealed class OrdersState extends Equatable {
  const OrdersState();
  @override List<Object?> get props => [];
}
final class OrdersInitial extends OrdersState { const OrdersInitial(); }
final class OrdersLoading extends OrdersState { const OrdersLoading(); }
final class OrdersLoaded  extends OrdersState {
  const OrdersLoaded(this.orders);
  final List<Map<String, dynamic>> orders;
  @override List<Object?> get props => [orders];
}
final class OrdersError extends OrdersState {
  const OrdersError(this.message);
  final String message;
  @override List<Object?> get props => [message];
}

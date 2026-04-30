import 'package:equatable/equatable.dart';

/// Base sealed state shared across all admin Notifiers.
sealed class BaseState<T> extends Equatable {
  const BaseState();
  @override List<Object?> get props => [];
}

final class StateInitial<T>  extends BaseState<T> { const StateInitial(); }
final class StateLoading<T>  extends BaseState<T> { const StateLoading(); }
final class StateLoaded<T>   extends BaseState<T> {
  const StateLoaded(this.data);
  final T data;
  @override List<Object?> get props => [data];
}
final class StateError<T> extends BaseState<T> {
  const StateError(this.message);
  final String message;
  @override List<Object?> get props => [message];
}

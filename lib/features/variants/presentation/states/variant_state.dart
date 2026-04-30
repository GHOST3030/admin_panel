import 'package:equatable/equatable.dart';

sealed class VariantState extends Equatable {
  const VariantState();
  @override List<Object?> get props => [];
}
final class VariantInitial extends VariantState { const VariantInitial(); }
final class VariantLoading extends VariantState { const VariantLoading(); }
final class VariantLoaded  extends VariantState {
  const VariantLoaded(this.variants);
  final List<Map<String, dynamic>> variants;
  @override List<Object?> get props => [variants];
}
final class VariantError extends VariantState {
  const VariantError(this.message);
  final String message;
  @override List<Object?> get props => [message];
}

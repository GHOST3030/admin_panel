import 'package:equatable/equatable.dart';

sealed class ProductState extends Equatable {
  const ProductState();
  @override List<Object?> get props => [];
}
final class ProductInitial extends ProductState { const ProductInitial(); }
final class ProductLoading extends ProductState { const ProductLoading(); }
final class ProductLoaded  extends ProductState {
  const ProductLoaded(this.products);
  final List<Map<String, dynamic>> products;
  @override List<Object?> get props => [products];
}
final class ProductError extends ProductState {
  const ProductError(this.message);
  final String message;
  @override List<Object?> get props => [message];
}

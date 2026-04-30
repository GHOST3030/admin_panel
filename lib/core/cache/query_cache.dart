// import 'package:flutter_riverpod/flutter_riverpod.dart';

// /// Keeps provider alive for [duration] after last listener is removed.
// /// Use on providers whose data rarely changes (categories, product list).
// AutoDisposeProviderBase<T> withKeepAlive<T>(
//   AutoDisposeProviderBase<T> provider,
//   Ref ref, {
//   Duration duration = const Duration(minutes: 5),
// }) {
//   final link = ref.keepAlive();
//   Future<void>.delayed(duration, link.close);
//   return provider;
// }

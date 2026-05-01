import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../di/providers.dart';
import '../logging/app_logger.dart';

final _log = AppLogger.getLogger('PaginatedQuery');

/// Generic paginated Supabase query provider factory.
/// Usage:
///   final provider = paginatedQueryProvider('products', pageSize: 20);
Provider<PaginatedQuery> paginatedQueryProvider(
  String table, {
  int pageSize = 20,
}) {
  return Provider<PaginatedQuery>(
    (ref) => PaginatedQuery(
      client: ref.watch(supabaseClientProvider),
      table: table,
      pageSize: pageSize,
    ),
  );
}

class PaginatedQuery {
  const PaginatedQuery({
    required this.client,
    required this.table,
    required this.pageSize,
  });

  final SupabaseClient client;
  final String table;
  final int pageSize;

  Future<List<Map<String, dynamic>>> fetch({
    int page = 0,
    String? select,
    Map<String, dynamic>? filters,
    String orderBy = 'created_at',
    bool ascending = false,
  }) async {
    final start = page * pageSize;
    final end   = start + pageSize - 1;

    _log.fine(
        'Query table=$table, page=$page, range=$start-$end, '
        'filters=${filters?.keys.join(",") ?? "none"}');

    dynamic query = client
        .from(table)
        .select(select ?? '*')
        .order(orderBy, ascending: ascending)
        .range(start, end);

    if (filters != null) {
      for (final entry in filters.entries) {
        query = query.eq(entry.key, entry.value);
      }
    }

    final res = await query;
    final rows = List<Map<String, dynamic>>.from(res as List);

    _log.fine('Query table=$table returned ${rows.length} rows');
    return rows;
  }
}

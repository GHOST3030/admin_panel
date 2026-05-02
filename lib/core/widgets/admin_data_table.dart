import 'package:flutter/material.dart';

/// Reusable paginated, sortable data table for all admin list pages.
class AdminDataTable<T> extends StatefulWidget {
  const AdminDataTable({
    super.key,
    required this.columns,
    required this.rows,
    required this.rowsPerPage,
    this.onSort,
    this.searchable = false,
    this.onSearch,
  });

  final List<AdminColumn> columns;
  final List<DataRow> rows;
  final int rowsPerPage;
  final void Function(int columnIndex, bool ascending)? onSort;
  final bool searchable;
  final void Function(String query)? onSearch;

  @override
  State<AdminDataTable<T>> createState() => _AdminDataTableState<T>();
}

class _AdminDataTableState<T> extends State<AdminDataTable<T>> {
  int _currentPage = 0;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  int get _totalPages =>
      (widget.rows.length / widget.rowsPerPage).ceil().clamp(1, 9999);

  List<DataRow> get _pageRows {
    final start = _currentPage * widget.rowsPerPage;
    final end   = (start + widget.rowsPerPage).clamp(0, widget.rows.length);
    return widget.rows.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.searchable)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SizedBox(
              width: 280,
              child: TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                  hintText: 'Search…',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: widget.onSearch,
              ),
            ),
          ),

        Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _sortAscending,
              columns: widget.columns.map((c) => DataColumn(
                label: Text(c.label),
                numeric: c.numeric,
                onSort: widget.onSort == null
                    ? null
                    : (i, asc) {
                        setState(() {
                          _sortColumnIndex = i;
                          _sortAscending   = asc;
                        });
                        widget.onSort!(i, asc);
                      },
              ),).toList(),
              rows: _pageRows,
            ),
          ),
        ),

        // Pagination bar
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('${_currentPage + 1} / $_totalPages',
                  style: Theme.of(context).textTheme.bodySmall,),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _currentPage > 0
                    ? () => setState(() => _currentPage--)
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _currentPage < _totalPages - 1
                    ? () => setState(() => _currentPage++)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AdminColumn {
  const AdminColumn(this.label, {this.numeric = false});
  final String label;
  final bool numeric;
}

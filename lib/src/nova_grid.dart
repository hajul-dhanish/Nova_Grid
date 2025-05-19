part of '../nova_grid.dart';

class _RowData {
  final String id;
  final List<Widget> cells;
  final List<dynamic> dropdownValues;

  _RowData({
    required this.id,
    required this.cells,
    required this.dropdownValues,
  });
}

class _TablePagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const _TablePagination({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.first_page),
          onPressed: currentPage > 0 ? () => onPageChanged(0) : null,
        ),
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed:
              currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Page ${currentPage + 1} of $totalPages',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: currentPage < totalPages - 1
              ? () => onPageChanged(currentPage + 1)
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.last_page),
          onPressed: currentPage < totalPages - 1
              ? () => onPageChanged(totalPages - 1)
              : null,
        ),
      ],
    );
  }
}

class NovaGrid extends StatefulWidget {
  final List<TableColumn> columns;
  final List<List<Widget>> rows;
  final double rowHeight;
  final int? rowsPerPage;
  final bool showPagination;
  final Color? headerColor;
  final double? columnSpacing;
  final bool sortable;
  final Widget? emptyStateWidget;
  final List<StackedHeader>? stackedHeaders;

  const NovaGrid({
    super.key,
    required this.columns,
    required this.rows,
    this.rowHeight = 56.0,
    this.rowsPerPage,
    this.showPagination = true,
    this.headerColor,
    this.columnSpacing,
    this.stackedHeaders,
    this.sortable = true,
    this.emptyStateWidget,
  });

  @override
  State<NovaGrid> createState() => _NovaGridState();
}

class _NovaGridState extends State<NovaGrid> {
  late List<_RowData> _rowData;
  late List<_RowData> _filteredRows;
  final Map<int, bool> _selectionStates = {};
  int _currentPage = 0;
  bool _isLoading = false;
  List<StackedHeader> stackedHeaders = [];
  List<StackedHeader> stackedMainHeaders = [];

  @override
  void initState() {
    super.initState();
    _initializeData();

    if (widget.stackedHeaders?.isNotEmpty ?? false) {
      _mapStackedHeadersToColumns(
        columns: widget.columns,
        headers: widget.stackedHeaders ?? [],
      );
    }
  }

  void _initializeData() {
    _rowData =
        widget.rows.map((row) {
          return _RowData(
            id: UniqueKey().toString(),
            cells: List<Widget>.from(row),
            dropdownValues: List.filled(widget.columns.length, null),
          );
        }).toList();

    _filteredRows = List.from(_rowData);

    _initializeTable();
  }

  void _initializeTable() {
    for (int i = 0; i < _filteredRows.length; i++) {
      _selectionStates[i] = false;
    }
  }

  Widget _cellWidget(Widget cell, int rowIndex, int colIndex) {
    return cell;
  }

  void _goToPage(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  List<StackedHeader> _removeStackedHeaderDuplicates(
    List<StackedHeader> stackedHeaders,
  ) {
    final Set<String> seen = <String>{};
    final List<StackedHeader> result = <StackedHeader>[];

    for (final StackedHeader header in stackedHeaders) {
      if (header.startIndex == -1) {
        result.add(header);
      } else {
        final String key = '${header.startIndex}-${header.endIndex}';
        if (seen.add(key)) {
          result.add(header);
        }
      }
    }

    return result;
  }

  bool ascending = true;
  void _sortColumn(int columnIndex) {
    setState(() {
      _isLoading = true;
      ascending = !ascending;
      _filteredRows.sort((_RowData firstRowData, _RowData secondRowData) {
        final aWidget = firstRowData.cells[columnIndex];
        final bWidget = secondRowData.cells[columnIndex];

        if (aWidget is Text && bWidget is Text) {
          return ascending
              ? (aWidget.data ?? '').compareTo(bWidget.data ?? '')
              : (bWidget.data ?? '').compareTo(aWidget.data ?? '');
        }
        return 0;
      });
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _mapStackedHeadersToColumns({
    required List<TableColumn> columns,
    required List<StackedHeader> headers,
  }) {
    stackedHeaders = List.generate(columns.length, (index) {
      return headers.firstWhere(
        (header) => index >= header.startIndex && index <= header.endIndex,
        orElse: () => StackedHeader(width: columns[index].width),
      );
    });
    stackedHeaders = _removeStackedHeaderDuplicates(stackedHeaders);
  }

  Widget _buildEmptyState() {
    return widget.emptyStateWidget ?? const SizedBox();
  }

  final int defaultRowPerPage = 20;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final int totalPages =
        (_filteredRows.length / (widget.rowsPerPage ?? defaultRowPerPage))
            .ceil();
    final int adjustedTotalPages = totalPages == 0 ? 1 : totalPages;
    final int adjustedCurrentPage = _currentPage.clamp(
      0,
      adjustedTotalPages - 1,
    );

    final int startIndex =
        adjustedCurrentPage * (widget.rowsPerPage ?? defaultRowPerPage);
    final int endIndex = (startIndex +
            (widget.rowsPerPage ?? defaultRowPerPage))
        .clamp(0, _filteredRows.length);
    final List<_RowData> visibleRows =
        widget.rowsPerPage != null
            ? _filteredRows.sublist(
              startIndex,
              endIndex > _filteredRows.length ? _filteredRows.length : endIndex,
            )
            : _filteredRows;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _filteredRows.isEmpty
            ? _buildEmptyState()
            : ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
              ),
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                trackVisibility: true,
                interactive: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.stackedHeaders?.isNotEmpty ?? false)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: List.generate(stackedHeaders.length, (
                            int index,
                          ) {
                            final bool isStackedHeader =
                                stackedHeaders[index].startIndex != -1;
                            Color? bordorColor = Color(0xFFE3E3E3);
                            return Container(
                              width: stackedHeaders[index].width,
                              height: widget.rowHeight / 1.5,
                              decoration: BoxDecoration(
                                color: widget.headerColor ?? Color(0xFFF4F5F7),
                                border: Border.symmetric(
                                  vertical: BorderSide(
                                    color: bordorColor,
                                    width: 0.5,
                                  ),
                                  horizontal:
                                      !isStackedHeader
                                          ? BorderSide.none
                                          : BorderSide(color: bordorColor),
                                ),
                              ),
                              child: Center(
                                child: stackedHeaders[index].widget,
                              ),
                            );
                          }),
                        ),
                      DataTable(
                        border:
                            (widget.stackedHeaders?.isEmpty ?? true)
                                ? TableBorder.all(color: Color(0xFFE3E3E3))
                                : const TableBorder.symmetric(
                                  inside: BorderSide(color: Color(0xFFE3E3E3)),
                                ),
                        dataRowMaxHeight: widget.rowHeight,
                        // headingRowHeight:
                        //     (widget.stackedHeaders?.isNotEmpty ?? false)
                        //         ? widget.rowHeight / 1.5
                        //         : null,
                        headingRowColor: WidgetStatePropertyAll(
                          widget.headerColor ?? Color(0xFFF4F5F7),
                        ),
                        columns: [
                          ...widget.columns.asMap().entries.map((entry) {
                            final int index = entry.key;
                            final TableColumn column = entry.value;
                            final bool hasStackedHeaders =
                                widget.stackedHeaders?.isNotEmpty ?? false;
                            return TableColumn(
                              headingRowAlignment: MainAxisAlignment.center,
                              label: Column(
                                mainAxisAlignment:
                                    hasStackedHeaders
                                        ? (column.isStacked
                                            ? MainAxisAlignment.center
                                            : MainAxisAlignment.start)
                                        : MainAxisAlignment.center,
                                children: [column.label],
                              ),
                              columnWidth:
                                  column.width != null
                                      ? FixedColumnWidth(column.width!)
                                      : widget.columnSpacing != null
                                      ? FixedColumnWidth(widget.columnSpacing!)
                                      : column.columnWidth,
                              onSort:
                                  widget.sortable
                                      ? (columnIndex, ascending) {
                                        _sortColumn(index);
                                        if (column.onSort != null) {
                                          column.onSort!(
                                            columnIndex,
                                            ascending,
                                          );
                                        }
                                      }
                                      : null,
                              tooltip: column.tooltip,
                            );
                          }),
                        ],
                        rows:
                            visibleRows.asMap().entries.map((entry) {
                              final int displayIndex = entry.key;
                              final int actualIndex = startIndex + displayIndex;
                              final _RowData row = entry.value;
                              return DataRow(
                                selected:
                                    _selectionStates[actualIndex] ?? false,
                                cells: [
                                  ...row.cells.asMap().entries.map((cellEntry) {
                                    final cellIndex = cellEntry.key;
                                    final cell = cellEntry.value;
                                    return DataCell(
                                      _cellWidget(
                                        cell,
                                        _rowData.indexWhere(
                                          (r) => r.id == row.id,
                                        ),
                                        cellIndex,
                                      ),
                                    );
                                  }),
                                ],
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        if (widget.showPagination &&
            _filteredRows.isNotEmpty &&
            widget.rowsPerPage != null)
          if (widget.showPagination &&
              !(_filteredRows.length <=
                  (widget.rowsPerPage ?? defaultRowPerPage)))
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 10,
                children: [
                  _TablePagination(
                    currentPage: adjustedCurrentPage,
                    totalPages: adjustedTotalPages,
                    onPageChanged: _goToPage,
                  ),
                  Text(
                    'Showing ${startIndex + 1}-${endIndex > _filteredRows.length ? _filteredRows.length : endIndex} of ${_filteredRows.length}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

part of '../nova_grid.dart';

/// A private class to hold row data for the NovaGrid.
///
/// This class stores:
/// - A unique identifier for each row
/// - The list of widgets that make up the row's cells
/// - Dropdown values for any dropdown cells in the row
class _RowData {
  /// Unique identifier for the row
  final String id;

  /// List of widgets representing each cell in the row
  final List<Widget> cells;

  /// List of values for any dropdown widgets in the row
  final List<dynamic> dropdownValues;

  /// Creates a new _RowData instance
  _RowData({
    required this.id,
    required this.cells,
    required this.dropdownValues,
  });
}

/// A pagination control widget for the NovaGrid.
///
/// This widget provides navigation controls including:
/// - First page button
/// - Previous page button
/// - Current page indicator
/// - Next page button
/// - Last page button
class _TablePagination extends StatelessWidget {
  /// The current page index (0-based)
  final int currentPage;

  /// The total number of pages
  final int totalPages;

  /// Callback function when page changes
  final Function(int) onPageChanged;

  /// Creates a new _TablePagination instance
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
        // First page button
        IconButton(
          icon: const Icon(Icons.first_page),
          onPressed: currentPage > 0 ? () => onPageChanged(0) : null,
        ),
        // Previous page button
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed:
              currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
        ),
        // Current page indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Page ${currentPage + 1} of $totalPages',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        // Next page button
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed:
              currentPage < totalPages - 1
                  ? () => onPageChanged(currentPage + 1)
                  : null,
        ),
        // Last page button
        IconButton(
          icon: const Icon(Icons.last_page),
          onPressed:
              currentPage < totalPages - 1
                  ? () => onPageChanged(totalPages - 1)
                  : null,
        ),
      ],
    );
  }
}

/// A customizable data grid widget with features like:
/// - Pagination
/// - Sorting
/// - Stacked headers
/// - Customizable appearance
class NovaGrid extends StatefulWidget {
  /// List of column definitions for the grid
  final List<TableColumn> columns;

  /// List of rows where each row is a list of widgets
  final List<List<Widget>> rows;

  /// Height of each row in the grid
  final double rowHeight;

  /// Number of rows to display per page (null for no pagination)
  final int? rowsPerPage;

  /// Whether to show pagination controls
  final bool showPagination;

  /// Background color for the header row
  final Color? headerColor;

  /// Spacing between columns
  final double? columnSpacing;

  /// Whether columns are sortable
  final bool sortable;

  /// List of stacked headers for column grouping
  final List<StackedHeader>? stackedHeaders;

  /// Creates a new NovaGrid instance
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
  });

  @override
  State<NovaGrid> createState() => _NovaGridState();
}

/// The state class for the NovaGrid widget
class _NovaGridState extends State<NovaGrid> {
  /// Internal list of all row data
  late List<_RowData> _rowData;

  /// Filtered/sorted list of rows to display
  late List<_RowData> _filteredRows;

  /// Tracks which rows are selected
  final Map<int, bool> _selectionStates = {};

  /// Current page index (0-based)
  int _currentPage = 0;

  /// Loading state indicator
  bool _isLoading = false;

  /// List of stacked headers mapped to columns
  List<StackedHeader> stackedHeaders = [];

  /// List of main stacked headers
  List<StackedHeader> stackedMainHeaders = [];

  /// Default number of rows per page
  final int defaultRowPerPage = 20;

  /// Scroll controller for horizontal scrolling
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeData();

    // Initialize stacked headers if provided
    if (widget.stackedHeaders?.isNotEmpty ?? false) {
      _mapStackedHeadersToColumns(
        columns: widget.columns,
        headers: widget.stackedHeaders ?? [],
      );
    }
  }

  /// Initializes the grid data by converting rows to _RowData objects
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

  /// Initializes the table selection states
  void _initializeTable() {
    for (int i = 0; i < _filteredRows.length; i++) {
      _selectionStates[i] = false;
    }
  }

  /// Builds an individual cell widget
  Widget _cellWidget(Widget cell, int rowIndex, int colIndex) {
    return cell;
  }

  /// Navigates to a specific page
  void _goToPage(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  /// Removes duplicate stacked headers
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

  /// Tracks sort direction
  bool ascending = true;

  /// Sorts the grid by the specified column
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

  /// Maps stacked headers to their corresponding columns
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

  @override
  Widget build(BuildContext context) {
    // Calculate pagination values
    final int totalPages =
        (_filteredRows.length / (widget.rowsPerPage ?? defaultRowPerPage))
            .ceil();
    final int adjustedTotalPages = totalPages == 0 ? 1 : totalPages;
    final int adjustedCurrentPage = _currentPage.clamp(
      0,
      adjustedTotalPages - 1,
    );

    // Calculate visible rows range
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
        // Loading indicator or content
        _isLoading
            ? const Center(child: CircularProgressIndicator())
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
                      // Stacked headers row if provided
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
                      // Main data table
                      DataTable(
                        border:
                            (widget.stackedHeaders?.isEmpty ?? true)
                                ? TableBorder.all(color: Color(0xFFE3E3E3))
                                : const TableBorder.symmetric(
                                  inside: BorderSide(color: Color(0xFFE3E3E3)),
                                ),
                        dataRowMaxHeight: widget.rowHeight,
                        headingRowColor: WidgetStatePropertyAll(
                          widget.headerColor ?? Color(0xFFF4F5F7),
                        ),
                        columns: [
                          // Generate columns from widget.columns
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
                            //If rows are empty then
                            //Empty cells return by matching with column length
                            visibleRows.isEmpty
                                ? [
                                  DataRow(
                                    cells: List.generate(
                                      widget.columns.length,
                                      (index) {
                                        return DataCell(SizedBox());
                                      },
                                    ),
                                  ),
                                ]
                                // Generate rows from visibleRows
                                : visibleRows.asMap().entries.map((entry) {
                                  final int displayIndex = entry.key;
                                  final int actualIndex =
                                      startIndex + displayIndex;
                                  final _RowData row = entry.value;
                                  return DataRow(
                                    selected:
                                        _selectionStates[actualIndex] ?? false,
                                    cells: [
                                      ...row.cells.asMap().entries.map((
                                        cellEntry,
                                      ) {
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
        // Pagination controls
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

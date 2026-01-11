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

  /// Map of column index to calculated auto-fit width
  final Map<int, double> _autoFitWidths = {};

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void didUpdateWidget(NovaGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.columns != widget.columns || oldWidget.rows != widget.rows) {
      _initializeData();
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

    // Calculate auto-fit widths before mapping headers
    _calculateAutoFitWidths();

    // Initialize stacked headers if provided
    _mapStackedHeadersToColumns(
      columns: widget.columns,
      headers: widget.stackedHeaders ?? [],
    );
  }

  /// Calculates widths for columns that have autoFit set to true
  void _calculateAutoFitWidths() {
    _autoFitWidths.clear();
    for (int i = 0; i < widget.columns.length; i++) {
      if (widget.columns[i].autoFit) {
        double maxWidth = _measureWidget(widget.columns[i].label);

        for (var row in _rowData) {
          double cellWidth = _measureWidget(row.cells[i]);
          if (cellWidth > maxWidth) maxWidth = cellWidth;
        }

        // Add padding: 24 for cell margins + 20 for sort icon space + 8 buffer
        _autoFitWidths[i] = maxWidth + (widget.sortable ? 52 : 32);
      }
    }
  }

  /// Measures the width of a widget as accurately as possible without rendering it.
  /// Handles Text, Icons, and common layout widgets recursively.
  double _measureWidget(Widget widget) {
    if (widget is Text) {
      return _measureText(widget.data ?? '', widget.style);
    }

    if (widget is Icon) {
      return widget.size ?? 24.0;
    }

    if (widget is PreferredSizeWidget) {
      return widget.preferredSize.width;
    }

    if (widget is Padding) {
      return _measureWidget(widget.child!) + widget.padding.horizontal;
    }

    if (widget is Center) {
      return widget.child != null ? _measureWidget(widget.child!) : 0.0;
    }

    if (widget is Container) {
      if (widget.constraints != null && widget.constraints!.hasTightWidth) {
        return widget.constraints!.minWidth;
      }
      return widget.child != null ? _measureWidget(widget.child!) : 0.0;
    }

    if (widget is SizedBox) {
      if (widget.width != null) return widget.width!;
      return widget.child != null ? _measureWidget(widget.child!) : 0.0;
    }

    if (widget is Row) {
      double width = 0;
      for (var child in widget.children) {
        width += _measureWidget(child);
      }
      return width;
    }

    if (widget is Column) {
      double maxWidth = 0;
      for (var child in widget.children) {
        double w = _measureWidget(child);
        if (w > maxWidth) maxWidth = w;
      }
      return maxWidth;
    }

    // Fallback for unknown widgets
    return 100.0;
  }

  /// Helper to measure text width using TextPainter
  double _measureText(String text, TextStyle? style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
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

  double _getColumnWidth(int index) {
    if (index < 0 || index >= widget.columns.length) return 0.0;
    final col = widget.columns[index];
    if (col.autoFit) {
      return _autoFitWidths[index] ?? 100.0;
    }
    if (col.width != null) {
      return col.width!;
    }
    return 100.0; // Default width
  }

  /// Maps stacked headers to their corresponding columns
  void _mapStackedHeadersToColumns({
    required List<TableColumn> columns,
    required List<StackedHeader> headers,
  }) {
    final List<StackedHeader> finalHeaders = [];
    final Map<int, StackedHeader> indexToHeader = {};

    // Map user-defined headers to their indices
    for (var header in headers) {
      if (header.startIndex != -1 && header.endIndex != -1) {
        double totalWidth = 0;
        for (int i = header.startIndex; i <= header.endIndex; i++) {
          totalWidth += _getColumnWidth(i);
          indexToHeader[i] = header;
        }
        header.width = totalWidth;
      }
    }

    // Fill gaps and build final ordered list
    int i = 0;
    while (i < columns.length) {
      if (indexToHeader.containsKey(i)) {
        final header = indexToHeader[i]!;
        finalHeaders.add(header);
        i = header.endIndex + 1;
      } else {
        finalHeaders.add(
          StackedHeader(
            startIndex: -1,
            width: _getColumnWidth(i),
            widget: const SizedBox.shrink(),
          ),
        );
        i++;
      }
    }
    stackedHeaders = finalHeaders;
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
                        columnSpacing: 0,
                        horizontalMargin: 0,
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

                            double calculatedWidth = _getColumnWidth(index);

                            return TableColumn(
                              headingRowAlignment: MainAxisAlignment.center,
                              label:
                                  hasStackedHeaders
                                      ? Column(
                                        mainAxisAlignment:
                                            column.isStacked
                                                ? MainAxisAlignment.center
                                                : MainAxisAlignment.start,
                                        children: [column.label],
                                      )
                                      : Center(child: column.label),
                              columnWidth: FixedColumnWidth(calculatedWidth),
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
                                          SizedBox(
                                            width: _getColumnWidth(cellIndex),
                                            child: _cellWidget(
                                              cell,
                                              _rowData.indexWhere(
                                                (r) => r.id == row.id,
                                              ),
                                              cellIndex,
                                            ),
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
            widget.rowsPerPage != null &&
            _filteredRows.length > (widget.rowsPerPage ?? defaultRowPerPage))
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
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

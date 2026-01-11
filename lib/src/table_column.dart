part of '../nova_grid.dart';

class TableColumn extends DataColumn {
  final bool isStacked;
  final double? width;
  final bool autoFit;
  const TableColumn({
    this.width,
    this.isStacked = false,
    this.autoFit = false,
    required super.label,
    super.columnWidth,
    super.headingRowAlignment,
    super.mouseCursor,
    super.numeric,
    super.onSort,
    super.tooltip,
  });
}

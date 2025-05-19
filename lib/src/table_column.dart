part of '../nova_grid.dart';

class TableColumn extends DataColumn {
  final bool isStacked;
  final double? width;
  const TableColumn({
    this.width,
    this.isStacked = false,
    required super.label,
    super.columnWidth,
    super.headingRowAlignment,
    super.mouseCursor,
    super.numeric,
    super.onSort,
    super.tooltip,
  });
}

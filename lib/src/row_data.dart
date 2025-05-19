part of '../nova_grid.dart';

class RowData {
  final String id;
  final List<Widget> cells;
  final List<dynamic> dropdownValues;

  RowData({
    required this.id,
    required this.cells,
    required this.dropdownValues,
  });
}
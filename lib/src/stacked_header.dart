part of '../nova_grid.dart';

class StackedHeader {
  final int startIndex;
  final int endIndex;
  double? width;
  final Widget? widget;

  /// Creates a stacked header for a range of columns.
  /// [startIndex] and [endIndex] are 0-based column indices.
  StackedHeader({
    this.startIndex = -1,
    this.endIndex = -1,
    this.width,
    this.widget,
  });
}

import 'package:flutter/material.dart';
import 'package:nova_grid/nova_grid.dart';

class GridWithEmptyRows extends StatelessWidget {
  const GridWithEmptyRows({super.key});

  @override
  Widget build(BuildContext context) {
    List<TableColumn> columns = [
      TableColumn(label: Text("Name")),
      TableColumn(label: Text("Age")),
      TableColumn(label: Text("Gender")),
    ];

    List<List<Widget>> rows = [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Table with Empty Rows"),
        NovaGrid(columns: columns, rows: rows),
      ],
    );
  }
}

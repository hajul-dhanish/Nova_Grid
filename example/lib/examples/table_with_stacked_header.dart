import 'package:flutter/material.dart';
import 'package:nova_grid/nova_grid.dart';

class TableWithStackedHeader extends StatelessWidget {
  const TableWithStackedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    List<StackedHeader> stackedHeaders = [
      StackedHeader(
        startIndex: 1,
        endIndex: 2,
        width: 300,
        widget: Center(child: Text("Personal Details")),
      ),
      StackedHeader(
        startIndex: 3,
        endIndex: 4,
        width: 330,
        widget: Center(child: Text("Academic Performance")),
      ),
    ];
    List<TableColumn> columns = [
      TableColumn(
        label: Checkbox(value: false, onChanged: (value) {}),
        width: 150,
      ),
      TableColumn(label: Text("Name"), width: 150, isStacked: true),
      TableColumn(label: Text("Gender"), width: 150, isStacked: true),
      TableColumn(label: Text("Attendance %"), width: 180, isStacked: true),
      TableColumn(label: Text("Score %"), width: 150, isStacked: true),
      TableColumn(label: Text("Overall"), width: 150),
    ];

    List<List<Widget>> rows = [
      [
        Center(child: Checkbox(value: false, onChanged: (value) {})),
        Center(child: Text("Bob")),
        Center(child: Text("Male")),
        Center(child: Text("90%")),
        Center(child: Text("92%")),
        Center(child: Text("92%")),
      ],
      [
        Center(child: Checkbox(value: false, onChanged: (value) {})),
        Center(child: Text("Roxsy")),
        Center(child: Text("Female")),
        Center(child: Text("96%")),
        Center(child: Text("94%")),
        Center(child: Text("81%")),
      ],
      [
        Center(child: Checkbox(value: false, onChanged: (value) {})),
        Center(child: Text("Russle")),
        Center(child: Text("Male")),
        Center(child: Text("92%")),
        Center(child: Text("80%")),
        Center(child: Text("90%")),
      ],
    ];

    return NovaGrid(
      stackedHeaders: stackedHeaders,
      columns: columns,
      rows: rows,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:nova_grid/nova_grid.dart';

class AutoFitExample extends StatelessWidget {
  const AutoFitExample({super.key});

  @override
  Widget build(BuildContext context) {
    List<TableColumn> columns = [
      const TableColumn(label: Text("ID"), width: 50),
      const TableColumn(label: Text("Name (AutoFit)"), autoFit: true),
      const TableColumn(
        label: Text("Long Description (AutoFit)"),
        autoFit: true,
      ),
      const TableColumn(label: Text("Rating"), width: 80),
    ];

    List<List<Widget>> rows = [
      [
        const Center(child: Text("1")),
        const Center(child: Text("Alice")),
        const Center(child: Text("Short desc")),
        const Center(child: Text("5.0")),
      ],
      [
        const Center(child: Text("2")),
        const Center(child: Text("Bob")),
        const Center(
          child: Text(
            "This is a much longer description that should trigger auto-fit to expand this column.",
          ),
        ),
        const Center(child: Text("4.2")),
      ],
      [
        const Center(child: Text("3")),
        const Center(child: Text("Charlie De Longname")),
        const Center(child: Text("Normal desc")),
        const Center(child: Text("4.8")),
      ],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Table with Auto-fit Columns"),
        const SizedBox(height: 10),
        NovaGrid(columns: columns, rows: rows),
      ],
    );
  }
}

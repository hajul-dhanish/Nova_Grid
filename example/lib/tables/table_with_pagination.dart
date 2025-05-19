import 'package:flutter/material.dart';
import 'package:nova_grid/nova_grid.dart';

class TableWithPagination extends StatelessWidget {
  const TableWithPagination({super.key});

  @override
  Widget build(BuildContext context) {
    List<TableColumn> columns = [
      TableColumn(label: Text("Name")),
      TableColumn(label: Text("Age")),
      TableColumn(label: Text("Gender")),
      TableColumn(label: Text("Action")),
    ];

    List<List<Widget>> rows = [
      [
        Center(child: Text("Bob")),
        Center(child: Text("22")),
        Center(child: Text("Male")),
        Center(child: Icon(Icons.delete)),
      ],
      [
        Center(child: Text("Roxsy")),
        Center(child: Text("21")),
        Center(child: Text("Female")),
        Center(child: Icon(Icons.delete)),
      ],
      [
        Center(child: Text("Russle")),
        Center(child: Text("25")),
        Center(child: Text("Male")),
        Center(child: Icon(Icons.delete)),
      ],
      [
        Center(child: Text("Mart")),
        Center(child: Text("22")),
        Center(child: Text("Male")),
        Center(child: Icon(Icons.delete)),
      ],
      [
        Center(child: Text("Alex")),
        Center(child: Text("20")),
        Center(child: Text("Male")),
        Center(child: Icon(Icons.delete)),
      ],
      [
        Center(child: Text("Ronald")),
        Center(child: Text("23")),
        Center(child: Text("Male")),
        Center(child: Icon(Icons.delete)),
      ],
    ];

    return NovaGrid(
      rowsPerPage: 5,
      showPagination: true,
      columns: columns,
      rows: rows,
    );
  }
}

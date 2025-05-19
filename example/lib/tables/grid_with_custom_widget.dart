import 'package:flutter/material.dart';
import 'package:nova_grid/nova_grid.dart';

class GridWithCustomWidget extends StatelessWidget {
  const GridWithCustomWidget({super.key});

  @override
  Widget build(BuildContext context) {
    List<TableColumn> columns = [
      TableColumn(label: Checkbox(value: false, onChanged: (value) {})),
      TableColumn(label: Text("Name")),
      TableColumn(label: Text("Gender")),
      TableColumn(label: Text("Action")),
    ];

    List<List<Widget>> rows = [
      [
        Center(child: Checkbox(value: false, onChanged: (value) {})),
        Center(child: Text("Bob")),
        Center(
          child: DropdownButton<String>(
            isDense: true,
            value: "male",
            items: [
              DropdownMenuItem(value: "male", child: Text("Male")),
              DropdownMenuItem(value: "female", child: Text("Female")),
            ],
            onChanged: (value) {},
          ),
        ),
        Center(child: Icon(Icons.edit)),
      ],
      [
        Center(child: Checkbox(value: false, onChanged: (value) {})),
        Center(child: Text("Roxsy")),
        Center(
          child: DropdownButton(
            isDense: true,
            value: "female",
            items: [
              DropdownMenuItem(value: "male", child: Text("Male")),
              DropdownMenuItem(value: "female", child: Text("Female")),
            ],
            onChanged: (value) {},
          ),
        ),
        Center(child: Icon(Icons.edit)),
      ],
      [
        Center(child: Checkbox(value: false, onChanged: (value) {})),
        Center(child: Text("Russle")),
        Center(
          child: DropdownButton(
            isDense: true,
            value: "male",
            items: [
              DropdownMenuItem(value: "male", child: Text("Male")),
              DropdownMenuItem(value: "female", child: Text("Female")),
            ],
            onChanged: (value) {},
          ),
        ),
        Center(child: Icon(Icons.edit)),
      ],
    ];

    return NovaGrid(columns: columns, rows: rows);
  }
}

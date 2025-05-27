import 'package:example/tables/basic_grid.dart';
import 'package:example/tables/grid_with_custom_widget.dart';
import 'package:example/tables/grid_with_empty_rows.dart';
import 'package:example/tables/table_with_pagination.dart';
import 'package:example/tables/table_with_stacked_header.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: NovaGridExamples());
  }
}

class NovaGridExamples extends StatelessWidget {
  const NovaGridExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              BasicGrid(),
              GridWithCustomWidget(),
              TableWithStackedHeader(),
              TableWithPagination(),
              GridWithEmptyRows(),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
class DatasetTable extends StatelessWidget {
  final List<List<dynamic>> data;

  DatasetTable({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columnSpacing: 20,
            columns: data.first
                .map((e) => DataColumn(
                    label: Text(e.toString(), style: const TextStyle(fontWeight: FontWeight.bold))))
                .toList(),
            rows: data.skip(1).map(
              (row) {
                return DataRow(
                  cells: row.map((cell) => DataCell(Text(cell.toString()))).toList(),
                );
              },
            ).toList(),
          ),
        ),
      ),
    );
  }
}

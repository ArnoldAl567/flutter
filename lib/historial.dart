import 'package:flutter/material.dart';
import 'db_helper.dart';

class HistorialDiagnosticos extends StatefulWidget {
  const HistorialDiagnosticos({super.key});

  @override
  State<HistorialDiagnosticos> createState() => _HistorialDiagnosticosState();
}

class _HistorialDiagnosticosState extends State<HistorialDiagnosticos> {
  List<Map<String, dynamic>> _diagnosticos = [];

  @override
  void initState() {
    super.initState();
    _cargarDiagnosticos();
  }

Future<void> _cargarDiagnosticos() async {
  final db = await DBHelper.getDatabase();
  final resultados = await db.query('diagnosticos'); // ← SIN orderBy
  setState(() {
    _diagnosticos = resultados;
  });
}

  @override
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text("Historial de Diagnósticos")),
    body: _diagnosticos.isEmpty
        ? const Center(child: Text("No hay diagnósticos registrados."))
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.blue.shade100),
              columns: const [
                DataColumn(label: Text('Nivel', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Hora', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Riesgo 1 (%)', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Riesgo 2 (%)', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Riesgo 3 (%)', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Tratamiento', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: _diagnosticos.map((diag) {
                return DataRow(cells: [
                  DataCell(Center(child: Text(diag['nivel_riesgo'].toString()))),
                  DataCell(Center(child: Text(diag['fecha'].toString()))),
                  DataCell(Center(child: Text(diag['hora'].toString()))),
                  DataCell(Center(child: Text('${(diag['riesgo_1'] as double).toStringAsFixed(2)}%'))),
                  DataCell(Center(child: Text('${(diag['riesgo_2'] as double).toStringAsFixed(2)}%'))),
                  DataCell(Center(child: Text('${(diag['riesgo_3'] as double).toStringAsFixed(2)}%'))),
                  DataCell(Center(child: Text(diag['tratamiento'].toString()))),
                ]);
              }).toList(),
            ),
          ),
  );
}

}

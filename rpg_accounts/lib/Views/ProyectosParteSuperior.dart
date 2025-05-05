import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ProyectosParteSuperior extends StatelessWidget {
  final int totalProjects;
  final int completedProjects;
  final int inProgressProjects;
  final int pendingProjects;

  ProyectosParteSuperior({
    required this.totalProjects,
    required this.completedProjects,
    required this.inProgressProjects,
    required this.pendingProjects,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 📊 Gráfica de Barras
        Expanded(flex: 3, child: _buildBarChart()),

        // 📊 Gráfica de Pie
        Expanded(flex: 2, child: _buildPieChart()),

        // 🟩 Indicadores (2 filas x 2 columnas)
        Expanded(flex: 2, child: _buildIndicators()),
      ],
    );
  }

  // 📊 Gráfica de Barras
  Widget _buildBarChart() {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      title: ChartTitle(text: 'Ingresos vs Gastos'),
      legend: Legend(isVisible: true),
      series: <CartesianSeries>[
        ColumnSeries<_ChartData, String>(
          dataSource: _getChartData(),
          xValueMapper: (data, _) => data.month,
          yValueMapper: (data, _) => data.income,
          name: 'Ingresos',
          color: Colors.green,
        ),
        ColumnSeries<_ChartData, String>(
          dataSource: _getChartData(),
          xValueMapper: (data, _) => data.month,
          yValueMapper: (data, _) => data.expenses,
          name: 'Gastos',
          color: Colors.red,
        ),
      ],
    );
  }

  // 📊 Gráfica de Pie
  Widget _buildPieChart() {
    return SfCircularChart(
      legend: Legend(isVisible: true, position: LegendPosition.bottom),
      series: <CircularSeries>[
        PieSeries<_ChartData, String>(
          dataSource: [
            _ChartData("Completados", completedProjects.toDouble(), 0, Colors.green),
            _ChartData("En Progreso", inProgressProjects.toDouble(), 0, Colors.orange),
            _ChartData("Pendientes", pendingProjects.toDouble(), 0, Colors.red),
          ],
          xValueMapper: (data, _) => data.month,
          yValueMapper: (data, _) => data.income,
          pointColorMapper: (data, _) => data.color,
          dataLabelSettings: DataLabelSettings(isVisible: true),
        ),
      ],
    );
  }

  // 📌 Indicadores en 2 filas x 2 columnas
  Widget _buildIndicators() {
    List<Map<String, dynamic>> indicadores = [
      {"label": "Total", "value": totalProjects, "color": Colors.blue, "icon": Icons.layers},
      {"label": "Completados", "value": completedProjects, "color": Colors.green, "icon": Icons.check_circle},
      {"label": "En Progreso", "value": inProgressProjects, "color": Colors.orange, "icon": Icons.build},
      {"label": "Pendientes", "value": pendingProjects, "color": Colors.red, "icon": Icons.pending},
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _indicator(indicadores[0]["label"], indicadores[0]["value"], indicadores[0]["color"], indicadores[0]["icon"]),
            _indicator(indicadores[1]["label"], indicadores[1]["value"], indicadores[1]["color"], indicadores[1]["icon"]),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _indicator(indicadores[2]["label"], indicadores[2]["value"], indicadores[2]["color"], indicadores[2]["icon"]),
            _indicator(indicadores[3]["label"], indicadores[3]["value"], indicadores[3]["color"], indicadores[3]["icon"]),
          ],
        ),
      ],
    );
  }

  Widget _indicator(String label, int value, Color color, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              SizedBox(height: 6),
              Text("$value", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  List<_ChartData> _getChartData() {
    return [
      _ChartData("Enero", 5000, 3000, Colors.green),
      _ChartData("Febrero", 6000, 4000, Colors.blue),
      _ChartData("Marzo", 7000, 3500, Colors.orange),
      _ChartData("Abril", 8000, 5000, Colors.red),
    ];
  }
}

class _ChartData {
  final String month;
  final double income;
  final double expenses;
  final Color color;

  _ChartData(this.month, this.income, this.expenses, this.color);
}

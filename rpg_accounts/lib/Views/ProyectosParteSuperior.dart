import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rpg_accounts/Provider/ProyectosProvider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:provider/provider.dart';



class ProyectosParteSuperior extends StatefulWidget {
  @override
  _ProyectosParteSuperiorState createState() => _ProyectosParteSuperiorState();
}

class _ProyectosParteSuperiorState extends State<ProyectosParteSuperior> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      Provider.of<ProyectoProvider>(context, listen: false).fetchProjectSummary()
    );
  }

  @override
  Widget build(BuildContext context) {
    final resumen = Provider.of<ProyectoProvider>(context).projectSummary;

    if (resumen == null) {
      return Center(child: CircularProgressIndicator());
    }

    // Mapear estados con la data recibida
    int totalProjects = resumen.totalProyectos;
    int activos = resumen.totalActivos ?? 0;
    int suspendidos = resumen.totalSuspendidos ?? 0;
    int cancelados =resumen.totalCancelados ?? 0;
    int terminados = resumen.totalTerminados ?? 0;

    return Row(
      children: [
        Expanded(flex: 3, child: _buildBarChart()), // aquí adapta si quieres datos reales para barras
        Expanded(
          flex: 2,
          child: _buildPieChart(activos, suspendidos, cancelados, terminados),
        ),
        Expanded(
          flex: 2,
          child: _buildIndicators(totalProjects, activos, suspendidos, cancelados, terminados),
        ),
      ],
    );
  }
Widget _buildBarChart() {
  return Flexible(
    flex: 5,
    child: Consumer<ProyectoProvider>(
      builder: (context, provider, child) {
        final data = provider.projectData; // Asegúrate que tu provider tenga estos datos

        return SfCartesianChart(
          tooltipBehavior: TooltipBehavior(enable: true),
          primaryXAxis: CategoryAxis(title: AxisTitle(text: 'Meses')),
          primaryYAxis: NumericAxis(
            title: AxisTitle(text: 'Montos en USD'),
            numberFormat: NumberFormat.simpleCurrency(decimalDigits: 0, ),
          ),
          title: ChartTitle(text: 'Ingresos vs Gastos'),
          legend: Legend(isVisible: true),
          series: <CartesianSeries>[
            ColumnSeries<ProjectData, String>(
              dataSource: data,
              xValueMapper: (data, _) => data.projectName, // O usa data.month si tienes ese campo
              yValueMapper: (data, _) => data.profit, // Asegúrate que tu modelo tenga este campo
              name: 'Ingresos',
              color: Colors.green,
            ),
            ColumnSeries<ProjectData, String>(
              dataSource: data,
              xValueMapper: (data, _) => data.projectName,
              yValueMapper: (data, _) => data.projectCost, // Asegúrate que tu modelo tenga este campo
              name: 'Gastos',
              color: Colors.red,
            ),
          ],
        );
      },
    ),
  );
}
  // Widget _buildBarChart() {
  //   // Datos dummy, adapta si quieres mostrar info real
  //   final data = [
  //     _ChartData("Enero", 5000, 3000, Colors.green),
  //     _ChartData("Febrero", 6000, 4000, Colors.blue),
  //     _ChartData("Marzo", 7000, 3500, Colors.orange),
  //     _ChartData("Abril", 8000, 5000, Colors.red),
  //   ];

  //   return SfCartesianChart(
  //     primaryXAxis: CategoryAxis(),
  //     title: ChartTitle(text: 'Ingresos vs Gastos'),
  //     legend: Legend(isVisible: true),
  //     series: <CartesianSeries>[
  //       ColumnSeries<_ChartData, String>(
  //         dataSource: data,
  //         xValueMapper: (data, _) => data.month,
  //         yValueMapper: (data, _) => data.income,
  //         name: 'Ingresos',
  //         color: Colors.green,
  //       ),
  //       ColumnSeries<_ChartData, String>(
  //         dataSource: data,
  //         xValueMapper: (data, _) => data.month,
  //         yValueMapper: (data, _) => data.expenses,
  //         name: 'Gastos',
  //         color: Colors.red,
  //       ),
  //     ],
  //   );
  // }

  Widget _buildPieChart(int activos, int suspendidos, int cancelados, int terminados) {
    return SfCircularChart(
      legend: Legend(isVisible: true, position: LegendPosition.bottom),
      series: <CircularSeries>[
        PieSeries<_ChartData, String>(
          dataSource: [
            _ChartData("Activo", activos.toDouble(), 0, Colors.green),
            //_ChartData("Suspendido", suspendidos.toDouble(), 0, Colors.amber),
            _ChartData("Cancelado", cancelados.toDouble(), 0, Colors.red),
            _ChartData("Terminado", terminados.toDouble(), 0, Colors.blue),
          ],
          xValueMapper: (data, _) => data.month,
          yValueMapper: (data, _) => data.income,
          pointColorMapper: (data, _) => data.color,
          dataLabelSettings: DataLabelSettings(isVisible: true),
        ),
      ],
    );
  }

  Widget _buildIndicators(int total, int activos, int suspendidos, int cancelados, int terminados) {
    List<Map<String, dynamic>> indicadores = [
      {"label": "Total", "value": total, "color": Colors.blue, "icon": Icons.layers},
      {"label": "Activo", "value": activos, "color": Colors.green, "icon": Icons.check_circle},
     // {"label": "Suspendido", "value": suspendidos, "color": Colors.amber, "icon": Icons.pause_circle_filled},
      {"label": "Cancelado", "value": cancelados, "color": Colors.red, "icon": Icons.cancel},
      {"label": "Terminado", "value": terminados, "color": Colors.blueAccent, "icon": Icons.done_all},
    ];

    // Para mostrar en dos filas o más, aquí un ejemplo simple:
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _indicator(indicadores[0]["label"], indicadores[0]["value"], indicadores[0]["color"], indicadores[0]["icon"]),
            _indicator(indicadores[1]["label"], indicadores[1]["value"], indicadores[1]["color"], indicadores[1]["icon"]),
           // _indicator(indicadores[2]["label"], indicadores[2]["value"], indicadores[2]["color"], indicadores[2]["icon"]),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _indicator(indicadores[3]["label"], indicadores[3]["value"], indicadores[3]["color"], indicadores[3]["icon"]),
            _indicator(indicadores[2]["label"], indicadores[2]["value"], indicadores[2]["color"], indicadores[2]["icon"]),

         
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
}

class _ChartData {
  final String month;
  final double income;
  final double expenses;
  final Color color;

  _ChartData(this.month, this.income, this.expenses, this.color);
}



// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';

// class ProyectosParteSuperior extends StatelessWidget {
//   final int totalProjects;
//   final int completedProjects;
//   final int inProgressProjects;
//   final int pendingProjects;

//   ProyectosParteSuperior({
//     required this.totalProjects,
//     required this.completedProjects,
//     required this.inProgressProjects,
//     required this.pendingProjects,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         // 📊 Gráfica de Barras
//         Expanded(flex: 3, child: _buildBarChart()),

//         // 📊 Gráfica de Pie
//         Expanded(flex: 2, child: _buildPieChart()),

//         // 🟩 Indicadores (2 filas x 2 columnas)
//         Expanded(flex: 2, child: _buildIndicators()),
//       ],
//     );
//   }

//   // 📊 Gráfica de Barras
//   Widget _buildBarChart() {
//     return SfCartesianChart(
//       primaryXAxis: CategoryAxis(),
//       title: ChartTitle(text: 'Ingresos vs Gastos'),
//       legend: Legend(isVisible: true),
//       series: <CartesianSeries>[
//         ColumnSeries<_ChartData, String>(
//           dataSource: _getChartData(),
//           xValueMapper: (data, _) => data.month,
//           yValueMapper: (data, _) => data.income,
//           name: 'Ingresos',
//           color: Colors.green,
//         ),
//         ColumnSeries<_ChartData, String>(
//           dataSource: _getChartData(),
//           xValueMapper: (data, _) => data.month,
//           yValueMapper: (data, _) => data.expenses,
//           name: 'Gastos',
//           color: Colors.red,
//         ),
//       ],
//     );
//   }

//   // 📊 Gráfica de Pie
//   Widget _buildPieChart() {
//     return SfCircularChart(
//       legend: Legend(isVisible: true, position: LegendPosition.bottom),
//       series: <CircularSeries>[
//         PieSeries<_ChartData, String>(
//           dataSource: [
//             _ChartData("Completados", completedProjects.toDouble(), 0, Colors.green),
//             _ChartData("En Progreso", inProgressProjects.toDouble(), 0, Colors.orange),
//             _ChartData("Pendientes", pendingProjects.toDouble(), 0, Colors.red),
//           ],
//           xValueMapper: (data, _) => data.month,
//           yValueMapper: (data, _) => data.income,
//           pointColorMapper: (data, _) => data.color,
//           dataLabelSettings: DataLabelSettings(isVisible: true),
//         ),
//       ],
//     );
//   }

//   // 📌 Indicadores en 2 filas x 2 columnas
//   Widget _buildIndicators() {
//     List<Map<String, dynamic>> indicadores = [
//       {"label": "Total", "value": totalProjects, "color": Colors.blue, "icon": Icons.layers},
//       {"label": "Completados", "value": completedProjects, "color": Colors.green, "icon": Icons.check_circle},
//       {"label": "En Progreso", "value": inProgressProjects, "color": Colors.orange, "icon": Icons.build},
//       {"label": "Pendientes", "value": pendingProjects, "color": Colors.red, "icon": Icons.pending},
//     ];

//     return Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch,  
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             _indicator(indicadores[0]["label"], indicadores[0]["value"], indicadores[0]["color"], indicadores[0]["icon"]),
//             _indicator(indicadores[1]["label"], indicadores[1]["value"], indicadores[1]["color"], indicadores[1]["icon"]),
//           ],
//         ),
//         SizedBox(height: 8),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             _indicator(indicadores[2]["label"], indicadores[2]["value"], indicadores[2]["color"], indicadores[2]["icon"]),
//             _indicator(indicadores[3]["label"], indicadores[3]["value"], indicadores[3]["color"], indicadores[3]["icon"]),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _indicator(String label, int value, Color color, IconData icon) {
//     return Expanded(
//       child: Card(
//         elevation: 4,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         child: Padding(
//           padding: EdgeInsets.all(12),
//           child: Column(
//             children: [
//               Icon(icon, color: color, size: 26),
//               SizedBox(height: 6),
//               Text("$value", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
//               Text(label, style: TextStyle(fontSize: 12)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   List<_ChartData> _getChartData() {
//     return [
//       _ChartData("Enero", 5000, 3000, Colors.green),
//       _ChartData("Febrero", 6000, 4000, Colors.blue),
//       _ChartData("Marzo", 7000, 3500, Colors.orange),
//       _ChartData("Abril", 8000, 5000, Colors.red),
//     ];
//   }
// }

// class _ChartData {
//   final String month;
//   final double income;
//   final double expenses;
//   final Color color;

//   _ChartData(this.month, this.income, this.expenses, this.color);
// }

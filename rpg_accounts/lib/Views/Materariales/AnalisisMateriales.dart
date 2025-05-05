import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // Lista de materiales de ejemplo
  final List<Map<String, String>> materiales = [
    {'nombre': 'Cemento', 'categoria': 'Bases', 'descripcion': 'Bolsa de cemento Portland 50kg'},
    {'nombre': 'Arena', 'categoria': 'Bases', 'descripcion': 'Saco de arena fina para construcción'},
    {'nombre': 'Ladrillo', 'categoria': 'Estructura', 'descripcion': 'Ladrillo rojo de alta resistencia'},
    {'nombre': 'Madera', 'categoria': 'Acabados', 'descripcion': 'Tablón de madera tratada 2m'},
    {'nombre': 'Pintura', 'categoria': 'Acabados', 'descripcion': 'Galón de pintura blanca mate'},
    {'nombre': 'Yeso', 'categoria': 'Bases', 'descripcion': 'Saco de yeso para construcción'},
    {'nombre': 'Pegamento', 'categoria': 'Acabados', 'descripcion': 'Botella de pegamento para madera'},
    {'nombre': 'Clavos', 'categoria': 'Estructura', 'descripcion': 'Caja de clavos galvanizados'},
    {'nombre': 'Tejas', 'categoria': 'Estructura', 'descripcion': 'Tejas de barro para techado'},
    // Puedes agregar más materiales según necesites
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Análisis de Materiales',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Análisis de Materiales'),
          backgroundColor: Colors.black,
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: MaterialesAnalysisWidget(materiales: materiales),
        ),
      ),
    );
  }
}

/// Datos para la gráfica de distribución de materiales
class ChartData {
  final String category;
  final int count;
  ChartData(this.category, this.count);
}

/// Datos para la gráfica de tendencias de costos mensuales
class MonthlyCostData {
  final String month;
  final double cost;
  MonthlyCostData(this.month, this.cost);
}

/// Widget para mostrar un indicador individual con ícono, título y valor
class AnalysisIndicator extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const AnalysisIndicator({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 30, color: iconColor),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget que integra el análisis de materiales en una sola fila,
/// mostrando primero las gráficas y a la derecha un recuadro de indicadores.
class MaterialesAnalysisWidget extends StatelessWidget {
  final List<Map<String, String>> materiales;

  const MaterialesAnalysisWidget({Key? key, required this.materiales})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // --- Análisis de categorías de materiales ---
    int total = materiales.length;
    int countBases = materiales.where((m) => m['categoria'] == 'Bases').length;
    int countEstructura = materiales.where((m) => m['categoria'] == 'Estructura').length;
    int countAcabados = materiales.where((m) => m['categoria'] == 'Acabados').length;

    // Determinar la categoría predominante
    String mayorCategoria = 'N/A';
    int mayorCount = 0;
    if (countBases >= countEstructura && countBases >= countAcabados) {
      mayorCategoria = 'Bases';
      mayorCount = countBases;
    } else if (countEstructura >= countBases && countEstructura >= countAcabados) {
      mayorCategoria = 'Estructura';
      mayorCount = countEstructura;
    } else {
      mayorCategoria = 'Acabados';
      mayorCount = countAcabados;
    }

    // Datos para la gráfica circular (distribución por categorías)
    final List<ChartData> pieChartData = [
      ChartData('Bases', countBases),
      ChartData('Estructura', countEstructura),
      ChartData('Acabados', countAcabados),
    ];

    // --- Datos simulados para tendencias mensuales de costos ---
    final List<MonthlyCostData> monthlyCostData = [
      MonthlyCostData('Ene', 1200),
      MonthlyCostData('Feb', 1500),
      MonthlyCostData('Mar', 1800),
      MonthlyCostData('Abr', 1600),
      MonthlyCostData('May', 2100),
      MonthlyCostData('Jun', 1900),
      MonthlyCostData('Jul', 2200),
      MonthlyCostData('Ago', 2000),
      MonthlyCostData('Sep', 1700),
      MonthlyCostData('Oct', 2300),
      MonthlyCostData('Nov', 2400),
      MonthlyCostData('Dic', 2500),
    ];
    // Calcular costo total y mes con mayor gasto
    double costoTotal = monthlyCostData.fold(0, (sum, item) => sum + item.cost);
    MonthlyCostData mesMayorGasto = monthlyCostData.reduce((a, b) => a.cost >= b.cost ? a : b);
    // Costo promedio
    double costoPromedio = costoTotal / monthlyCostData.length;
    // Tendencia de compras: Compara diciembre con noviembre
    String tendencia = monthlyCostData.last.cost > monthlyCostData[monthlyCostData.length - 2].cost
        ? "Al alza"
        : "Baja";

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gráfica de barras de tendencias de costos mensuales
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Container(
              width: 300,
              height: 300,
              padding: const EdgeInsets.all(8),
              child: SfCartesianChart(
                title: ChartTitle(text: 'Costos Mensuales'),
                primaryXAxis: CategoryAxis(),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries<MonthlyCostData, String>>[
                  ColumnSeries<MonthlyCostData, String>(
                    dataSource: monthlyCostData,
                    xValueMapper: (MonthlyCostData data, _) => data.month,
                    yValueMapper: (MonthlyCostData data, _) => data.cost,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                    color: Colors.teal,
                  )
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Gráfica circular de distribución de materiales
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Container(
              width: 300,
              height: 300,
              padding: const EdgeInsets.all(8),
              child: SfCircularChart(
                title: ChartTitle(text: 'Distribución de Materiales'),
                legend: Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
                series: <CircularSeries>[
                  PieSeries<ChartData, String>(
                    dataSource: pieChartData,
                    xValueMapper: (ChartData data, _) => data.category,
                    yValueMapper: (ChartData data, _) => data.count,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Recuadro de indicadores dispuestos en grid (Wrap)
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  AnalysisIndicator(
                    title: 'Total Materiales',
                    value: total.toString(),
                    icon: Icons.dashboard,
                    iconColor: Colors.deepPurple,
                  ),
                  AnalysisIndicator(
                    title: 'Categoría Mayor',
                    value: '$mayorCategoria ($mayorCount)',
                    icon: Icons.trending_up,
                    iconColor: Colors.green,
                  ),
                  AnalysisIndicator(
                    title: 'Costo Total',
                    value: '\$${costoTotal.toStringAsFixed(0)}',
                    icon: Icons.attach_money,
                    iconColor: Colors.orange,
                  ),
                  AnalysisIndicator(
                    title: 'Costo Promedio',
                    value: '\$${costoPromedio.toStringAsFixed(0)}',
                    icon: Icons.monetization_on,
                    iconColor: Colors.blue,
                  ),
                  AnalysisIndicator(
                    title: 'Mes Mayor Gasto',
                    value: '${mesMayorGasto.month} (\$${mesMayorGasto.cost.toStringAsFixed(0)})',
                    icon: Icons.bar_chart,
                    iconColor: Colors.red,
                  ),
                  AnalysisIndicator(
                    title: 'Tendencia',
                    value: tendencia,
                    icon: tendencia == "Al alza" ? Icons.arrow_upward : Icons.arrow_downward,
                    iconColor: tendencia == "Al alza" ? Colors.green : Colors.red,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

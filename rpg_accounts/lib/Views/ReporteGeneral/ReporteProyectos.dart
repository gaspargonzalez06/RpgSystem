import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'dart:html' as html;
import 'package:provider/provider.dart';
import 'package:rpg_accounts/Models/ProyectosReporteria.dart';
import 'package:rpg_accounts/Provider/ProyectosProvider.dart';

class PdfAssets {
  static pw.Font? _roboto;
  static Uint8List? _logo;
  static bool _initialized = false;
  
  static Future<void> initialize() async {
    if (!_initialized) {
      try {
        _roboto = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
        _logo = (await rootBundle.load('assets/images/Logo_RPG.png')).buffer.asUint8List();
        _initialized = true;
      } catch (e) {
        print('Error cargando assets del PDF: $e');
      }
    }
  }
  
  static pw.Font? get roboto => _roboto;
  static Uint8List? get logo => _logo;
}

class ReporteriaProyectosButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.black, width: 1.0),
        ),
      ),
      icon: Icon(Icons.receipt_long),
      label: Text("Reporteria General"),
      onPressed: () => _mostrarModalReporteria(context),
    );
  }

  void _mostrarModalReporteria(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ChangeNotifierProvider(
        create: (context) => ProyectoProvider(),
        child: ReporteriaProyectosModal(),
      ),
    );
  }
}

class ReporteriaProyectosModal extends StatefulWidget {
  @override
  _ReporteriaProyectosModalState createState() => _ReporteriaProyectosModalState();
}

class _ReporteriaProyectosModalState extends State<ReporteriaProyectosModal> {
  String filtroBusqueda = '';
  DateTimeRange? rangoFechas;
  Set<int> selectedIds = {};
  bool selectAll = true;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  bool _generatingPdf = false;
  bool _cargandoProyectos = false;

  Map<String, bool> columnasVisibles = {
    'Nombre Proyecto': true,
    'Presupuesto': true,
    'Adelantos': true,
    'Gastos': true,
    'Rentabilidad': true,
    'Ganancias': true,
    'Por Cobrar': true,
  };

  final formatoNumero = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
    locale: 'es',
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ProyectoProvider>(context, listen: false);
      _cargarProyectosConFiltro(provider);
    });
  }

  Map<String, double> _calcularTotales(List<ProyectoReporteria> proyectos) {
    final proyectosSeleccionados = selectAll 
        ? proyectos 
        : proyectos.where((p) => selectedIds.contains(p.id)).toList();
    
    return {
      'presupuesto': proyectosSeleccionados.fold(0.0, (sum, p) => sum + p.presupuesto),
      'adelantos': proyectosSeleccionados.fold(0.0, (sum, p) => sum + p.adelantos),
      'gastos': proyectosSeleccionados.fold(0.0, (sum, p) => sum + p.gastos),
      'rentabilidad': proyectosSeleccionados.fold(0.0, (sum, p) => sum + p.rentabilidad),
      'ganancias': proyectosSeleccionados.fold(0.0, (sum, p) => sum + p.ganancias),
      'porCobrar': proyectosSeleccionados.fold(0.0, (sum, p) => sum + p.porCobrar),
    };
  }

  void _cargarProyectosConFiltro(ProyectoProvider provider) async {
    setState(() => _cargandoProyectos = true);
    
    try {
      if (rangoFechas != null) {
        await provider.fetchProyectosReporteriaFiltrados(
          fechaInicio: rangoFechas!.start,
          fechaFin: rangoFechas!.end,
        );
      } else {
        await provider.fetchProyectosReporteria();
      }
      
      _actualizarEstadoDespuesDeCarga(provider);
    } catch (e) {
      print('Error al cargar proyectos con filtro: $e');
    } finally {
      setState(() => _cargandoProyectos = false);
    }
  }

  void _actualizarEstadoDespuesDeCarga(ProyectoProvider provider) {
    if (provider.proyectosReporteria.isNotEmpty && mounted) {
      setState(() {
        if (rangoFechas == null) {
          final fechaMin = provider.proyectosReporteria
              .map((p) => p.fechaInicio)
              .reduce((a, b) => a.isBefore(b) ? a : b);
          final fechaMax = DateTime.now();
          rangoFechas = DateTimeRange(start: fechaMin, end: fechaMax);
        }
        
        selectedIds = Set.from(provider.proyectosReporteria.map((p) => p.id));
        selectAll = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProyectoProvider>(context);
    
    if (provider.loadingReporteria || _cargandoProyectos) {
      return Dialog(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando proyectos...'),
            ],
          ),
        ),
      );
    }
    
    if (provider.errorMessageReporteria != null) {
      return Dialog(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error, color: Colors.red, size: 48),
              SizedBox(height: 16),
              Text('Error al cargar proyectos'),
              SizedBox(height: 8),
              Text(provider.errorMessageReporteria!, style: TextStyle(color: Colors.red)),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final provider = Provider.of<ProyectoProvider>(context, listen: false);
                  _cargarProyectosConFiltro(provider);
                },
                child: Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }
    
    final proyectosFiltrados = _filtrarProyectos(provider.proyectosReporteria);
    
    return Dialog(
      insetPadding: EdgeInsets.all(20),
      child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reportería de Proyectos',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Divider(),
                
                _buildFiltros(),
                SizedBox(height: 16),
                
                _buildSelectorColumnas(),
                SizedBox(height: 16),
                
                _buildControles(proyectosFiltrados),
                SizedBox(height: 16),
                
                Expanded(
                  child: _buildTabla(proyectosFiltrados),
                ),
              ],
            ),
          ),
          
          if (_generatingPdf)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      strokeWidth: 5,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Generando PDF...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        SizedBox(
          width: 250,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Buscar proyectos',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => filtroBusqueda = value),
            enabled: !_cargandoProyectos,
          ),
        ),
        
        OutlinedButton.icon(
          icon: Icon(Icons.date_range),
          label: Text(_formatoRangoFechas()),
          onPressed: _cargandoProyectos ? null : _seleccionarRangoFechas,
        ),
        
        if (rangoFechas != null)
          ElevatedButton.icon(
            icon: Icon(Icons.filter_alt),
            label: Text('Filtrar movimientos'),
            onPressed: _cargandoProyectos ? null : () {
              final provider = Provider.of<ProyectoProvider>(context, listen: false);
              _cargarProyectosConFiltro(provider);
            },
          ),
        
        OutlinedButton.icon(
          icon: Icon(Icons.refresh),
          label: Text('Resetear'),
          onPressed: _cargandoProyectos ? null : _resetearFiltros,
        ),
      ],
    );
  }

  Widget _buildSelectorColumnas() {
    return ExpansionTile(
      title: Text('Columnas visibles'),
      initiallyExpanded: true,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: columnasVisibles.entries.map((e) {
            return FilterChip(
              label: Text(e.key),
              selected: e.value,
              onSelected: _cargandoProyectos ? null : (v) => setState(() => columnasVisibles[e.key] = v),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildControles(List<ProyectoReporteria> proyectos) {
    final selectedIdsFiltrados = selectedIds.where((id) => 
      proyectos.any((p) => p.id == id)
    ).toSet();

    if (selectedIdsFiltrados.length != selectedIds.length) {
      Future.microtask(() {
        if (mounted) {
          setState(() {
            selectedIds = selectedIdsFiltrados;
            selectAll = selectedIds.length == proyectos.length;
          });
        }
      });
    }

    return Row(
      children: [
        Checkbox(
          value: selectAll,
          onChanged: _cargandoProyectos ? null : (value) {
            setState(() {
              selectAll = value ?? false;
              selectedIds = selectAll 
                  ? Set.from(proyectos.map((p) => p.id)) 
                  : {};
            });
          },
        ),
        Text(selectAll ? 'Deseleccionar todos' : 'Seleccionar todos'),
        Spacer(),
        Text('${selectedIds.length}/${proyectos.length} seleccionados'),
        SizedBox(width: 16),
        ElevatedButton.icon(
          icon: Icon(Icons.picture_as_pdf),
          label: Text('Generar PDF'),
          onPressed: (_generatingPdf || _cargandoProyectos) 
              ? null 
              : () => _generatePdfWeb(
                selectAll ? proyectos : proyectos.where((p) => selectedIds.contains(p.id)).toList()
              ),
        ),
      ],
    );
  }

  Widget _buildTabla(List<ProyectoReporteria> proyectos) {
    return Scrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20,
            columns: _buildColumnas(),
            rows: [
              ...proyectos.map((p) => DataRow(
                selected: selectedIds.contains(p.id),
                cells: _buildCeldas(p),
              )),
              DataRow(
                color: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) => Colors.grey[200],
                ),
                cells: _buildCeldasTotales(proyectos),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<DataColumn> _buildColumnas() {
    final columnas = <DataColumn>[];
    
    columnas.add(DataColumn(
      label: SizedBox(width: 40, child: Text('Sel.')),
    ));
    
    if (columnasVisibles['Nombre Proyecto']!) {
      columnas.add(DataColumn(label: Text('Proyecto')));
    }
    if (columnasVisibles['Presupuesto']!) {
      columnas.add(DataColumn(label: Text('Presupuesto'), numeric: true));
    }
    if (columnasVisibles['Adelantos']!) {
      columnas.add(DataColumn(label: Text('Adelantos'), numeric: true));
    }
    if (columnasVisibles['Gastos']!) {
      columnas.add(DataColumn(label: Text('Gastos'), numeric: true));
    }
    if (columnasVisibles['Rentabilidad']!) {
      columnas.add(DataColumn(label: Text('Rentabilidad'), numeric: true));
    }
    if (columnasVisibles['Ganancias']!) {
      columnas.add(DataColumn(label: Text('Ganancias'), numeric: true));
    }
    if (columnasVisibles['Por Cobrar']!) {
      columnas.add(DataColumn(label: Text('Por Cobrar'), numeric: true));
    }
    
    return columnas;
  }

  List<DataCell> _buildCeldas(ProyectoReporteria p) {
    final celdas = <DataCell>[];
    
    celdas.add(DataCell(
      Checkbox(
        value: selectedIds.contains(p.id),
        onChanged: _cargandoProyectos ? null : (value) {
          setState(() {
            if (value ?? false) {
              selectedIds.add(p.id);
              final provider = Provider.of<ProyectoProvider>(context, listen: false);
              final proyectosFiltrados = _filtrarProyectos(provider.proyectosReporteria);
              selectAll = selectedIds.length == proyectosFiltrados.length;
            } else {
              selectedIds.remove(p.id);
              selectAll = false;
            }
          });
        },
      ),
    ));
    
    if (columnasVisibles['Nombre Proyecto']!) {
      celdas.add(DataCell(Text(p.nombre)));
    }
    if (columnasVisibles['Presupuesto']!) {
      celdas.add(DataCell(Text(_formatoNumero(p.presupuesto))));
    }
    if (columnasVisibles['Adelantos']!) {
      celdas.add(DataCell(Text(_formatoNumero(p.adelantos))));
    }
    if (columnasVisibles['Gastos']!) {
      celdas.add(DataCell(Text(_formatoNumero(p.gastos))));
    }
    if (columnasVisibles['Rentabilidad']!) {
      celdas.add(DataCell(Text(_formatoNumero(p.rentabilidad))));
    }
    if (columnasVisibles['Ganancias']!) {
      celdas.add(DataCell(Text(_formatoNumero(p.ganancias))));
    }
    if (columnasVisibles['Por Cobrar']!) {
      celdas.add(DataCell(Text(_formatoNumero(p.porCobrar))));
    }
    
    return celdas;
  }

  List<DataCell> _buildCeldasTotales(List<ProyectoReporteria> proyectos) {
    final celdas = <DataCell>[];
    final totales = _calcularTotales(proyectos);
    
    celdas.add(DataCell(Container()));
    
    if (columnasVisibles['Nombre Proyecto']!) {
      final texto = selectAll ? 'TOTALES (Todos)' : 'TOTALES (${selectedIds.length} seleccionados)';
      celdas.add(DataCell(Text(texto, style: TextStyle(fontWeight: FontWeight.bold))));
    }
    if (columnasVisibles['Presupuesto']!) {
      celdas.add(DataCell(Text(
        _formatoNumero(totales['presupuesto']!),
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800]),
      )));
    }
    if (columnasVisibles['Adelantos']!) {
      celdas.add(DataCell(Text(
        _formatoNumero(totales['adelantos']!),
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800]),
      )));
    }
    if (columnasVisibles['Gastos']!) {
      celdas.add(DataCell(Text(
        _formatoNumero(totales['gastos']!),
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800]),
      )));
    }
    if (columnasVisibles['Rentabilidad']!) {
      celdas.add(DataCell(Text(
        _formatoNumero(totales['rentabilidad']!),
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800]),
      )));
    }
    if (columnasVisibles['Ganancias']!) {
      celdas.add(DataCell(Text(
        _formatoNumero(totales['ganancias']!),
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800]),
      )));
    }
    if (columnasVisibles['Por Cobrar']!) {
      celdas.add(DataCell(Text(
        _formatoNumero(totales['porCobrar']!),
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800]),
      )));
    }
    
    return celdas;
  }

  String _formatoNumero(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '\$$integerPart.${parts[1]}';
  }

  Future<void> _generatePdfWeb(List<ProyectoReporteria> proyectosSeleccionados) async {
    setState(() => _generatingPdf = true);
    
    try {
      await PdfAssets.initialize();
      
      final pdf = pw.Document();
      final roboto = PdfAssets.roboto;
      final logo = PdfAssets.logo;
      
      if (roboto == null || logo == null) {
        throw Exception('No se pudieron cargar los recursos del PDF');
      }

      final totales = _calcularTotales(proyectosSeleccionados);
      final columnasActivas = columnasVisibles.entries.where((e) => e.value).toList();
      
      const proyectosPorPagina = 25;
      final paginas = <List<ProyectoReporteria>>[];
      
      for (var i = 0; i < proyectosSeleccionados.length; i += proyectosPorPagina) {
        final fin = (i + proyectosPorPagina < proyectosSeleccionados.length) ? i + proyectosPorPagina : proyectosSeleccionados.length;
        paginas.add(proyectosSeleccionados.sublist(i, fin));
      }

      for (var i = 0; i < paginas.length; i++) {
        final paginaProyectos = paginas[i];
        
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(32),
            build: (context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (i == 0) ..._buildPdfHeader(roboto, logo),
                  
                  pw.Text('Reporte de Proyectos - Página ${i + 1}/${paginas.length}', 
                      style: pw.TextStyle(font: roboto, fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Generado: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}', 
                      style: pw.TextStyle(font: roboto, fontSize: 10)),
                  pw.SizedBox(height: 10),
                  
                  pw.Table(
                    border: pw.TableBorder.all(),
                    columnWidths: _getPdfColumnWidths(columnasActivas),
                    children: [
                      _buildPdfTableHeader(columnasActivas, roboto),
                      ...paginaProyectos.map((p) => pw.TableRow(
                        children: _getPdfRowData(p, columnasActivas, roboto),
                      )),
                      if (i == paginas.length - 1) 
                        _buildPdfTableTotales(totales, columnasActivas, roboto),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      }

      final bytes = await pdf.save();
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "reporte_proyectos_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf")
        ..click();
      html.Url.revokeObjectUrl(url);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al generar PDF: ${e.toString()}'))
      );
    } finally {
      if (mounted) {
        setState(() => _generatingPdf = false);
      }
    }
  }

  List<pw.Widget> _buildPdfHeader(pw.Font roboto, Uint8List logo) {
    return [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Container(
            height: 70,
            child: pw.Image(pw.MemoryImage(logo), fit: pw.BoxFit.contain),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Grupo RPG S.A.', style: pw.TextStyle(font: roboto, fontSize: 18)),
              pw.Text('R.U.C 155651266-2-2017 D.V. 42', style: pw.TextStyle(font: roboto, fontSize: 10)),
              pw.Text('gerenciagruporpg@gmail.com', style: pw.TextStyle(font: roboto, fontSize: 10)),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 20),
    ];
  }

  pw.TableRow _buildPdfTableHeader(List<MapEntry<String, bool>> columnasActivas, pw.Font roboto) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: PdfColors.grey300),
      children: columnasActivas.map((columna) {
        return pw.Padding(
          padding: pw.EdgeInsets.all(4),
          child: pw.Text(
            columna.key, 
            style: pw.TextStyle(font: roboto, fontWeight: pw.FontWeight.bold, fontSize: 10)
          ),
        );
      }).toList(),
    );
  }

  pw.TableRow _buildPdfTableTotales(Map<String, double> totales, List<MapEntry<String, bool>> columnasActivas, pw.Font roboto) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: PdfColors.grey200),
      children: columnasActivas.map((columna) {
        String texto = '';
        
        switch (columna.key) {
          case 'Nombre Proyecto':
            texto = selectAll ? 'TOTALES (Todos)' : 'TOTALES (${selectedIds.length} seleccionados)';
            break;
          case 'Presupuesto':
            texto = _formatoNumeroPdf(totales['presupuesto']!);
            break;
          case 'Adelantos':
            texto = _formatoNumeroPdf(totales['adelantos']!);
            break;
          case 'Gastos':
            texto = _formatoNumeroPdf(totales['gastos']!);
            break;
          case 'Rentabilidad':
            texto = _formatoNumeroPdf(totales['rentabilidad']!);
            break;
          case 'Ganancias':
            texto = _formatoNumeroPdf(totales['ganancias']!);
            break;
          case 'Por Cobrar':
            texto = _formatoNumeroPdf(totales['porCobrar']!);
            break;
          default:
            texto = '';
        }
        
        return pw.Padding(
          padding: pw.EdgeInsets.all(4),
          child: pw.Text(
            texto,
            style: pw.TextStyle(
              font: roboto,
              fontWeight: pw.FontWeight.bold,
              color: columna.key == 'Nombre Proyecto' ? PdfColors.black : PdfColors.blue800,
              fontSize: 10
            ),
          ),
        );
      }).toList(),
    );
  }
  String _formatoNumeroPdf(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '\$$integerPart.${parts[1]}';
  }

  Map<int, pw.FlexColumnWidth> _getPdfColumnWidths(List<MapEntry<String, bool>> columnasActivas) {
    final widths = <int, pw.FlexColumnWidth>{};
    for (var i = 0; i < columnasActivas.length; i++) {
      widths[i] = pw.FlexColumnWidth(columnasActivas[i].key == 'Nombre Proyecto' ? 3 : 2);
    }
    return widths;
  }

  List<pw.Widget> _getPdfRowData(ProyectoReporteria p, List<MapEntry<String, bool>> columnasActivas, pw.Font roboto) {
    return columnasActivas.map((columna) {
      String texto = '';
      
      switch (columna.key) {
        case 'Nombre Proyecto':
          texto = p.nombre;
          break;
        case 'Presupuesto':
          texto = _formatoNumeroPdf(p.presupuesto);
          break;
        case 'Adelantos':
          texto = _formatoNumeroPdf(p.adelantos);
          break;
        case 'Gastos':
          texto = _formatoNumeroPdf(p.gastos);
          break;
        case 'Rentabilidad':
          texto = _formatoNumeroPdf(p.rentabilidad);
          break;
        case 'Ganancias':
          texto = _formatoNumeroPdf(p.ganancias);
          break;
        case 'Por Cobrar':
          texto = _formatoNumeroPdf(p.porCobrar);
          break;
      }
      
      return pw.Padding(
        padding: pw.EdgeInsets.all(4),
        child: pw.Text(
          texto, 
          style: pw.TextStyle(font: roboto, fontSize: 10)
        ),
      );
    }).toList();
  }

  List<ProyectoReporteria> _filtrarProyectos(List<ProyectoReporteria> proyectos) {
    return proyectos.where((p) {
      final busquedaMatch = filtroBusqueda.isEmpty ||
          p.nombre.toLowerCase().contains(filtroBusqueda.toLowerCase());
      
      final fechaMatch = rangoFechas == null ||
          (p.fechaInicio.isAfter(rangoFechas!.start.subtract(Duration(days: 1))) &&
           p.fechaInicio.isBefore(rangoFechas!.end.add(Duration(days: 1))));
      
      return busquedaMatch && fechaMatch;
    }).toList();
  }

  // Future<void> _seleccionarRangoFechas() async {
  //   final provider = Provider.of<ProyectoProvider>(context, listen: false);
    
  //   DateTime fechaMin;
  //   if (provider.proyectosReporteria.isNotEmpty) {
  //     fechaMin = provider.proyectosReporteria
  //         .map((p) => p.fechaInicio)
  //         .reduce((a, b) => a.isBefore(b) ? a : b);
  //   } else {
  //     fechaMin = DateTime.now().subtract(Duration(days: 365));
  //   }
    
  //   final fechaMax = DateTime.now();
    
  //   final picked = await showDateRangePicker(
  //     context: context,
  //     firstDate: fechaMin.subtract(Duration(days: 365)),
  //     lastDate: fechaMax.add(Duration(days: 365)),
  //     initialDateRange: rangoFechas,
  //   );
    
  //   if (picked != null) {
  //     setState(() => rangoFechas = picked);
  //   }
  // }
Future<void> _seleccionarRangoFechas() async {
  final fechaMax = DateTime.now();
  final fechaMin = DateTime.now(); // 2 años atrás
  
  // SIEMPRE usar un rango reciente por defecto, ignorando el rango guardado
  final DateTimeRange rangoPorDefecto = DateTimeRange(
    start: fechaMax.subtract(Duration(days: 30)), // Últimos 30 días
    end: fechaMax
  );
  
  final picked = await showDateRangePicker(
    context: context,
    firstDate: fechaMin,
    lastDate: fechaMax,
    initialDateRange: rangoPorDefecto, // ✅ SIEMPRE usar rango reciente
    initialEntryMode: DatePickerEntryMode.calendarOnly,
  );
  
  if (picked != null) {
    setState(() => rangoFechas = picked);
  }
}
  void _resetearFiltros() {
    final provider = Provider.of<ProyectoProvider>(context, listen: false);
    
    setState(() {
      _searchController.clear();
      filtroBusqueda = '';
      selectedIds = {};
      selectAll = false;
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => rangoFechas = null);
      
      await provider.fetchProyectosReporteria();
      
      if (mounted && provider.proyectosReporteria.isNotEmpty) {
        setState(() {
          final fechaMin = provider.proyectosReporteria
              .map((p) => p.fechaInicio)
              .reduce((a, b) => a.isBefore(b) ? a : b);
          final fechaMax = DateTime.now();
          rangoFechas = DateTimeRange(start: fechaMin, end: fechaMax);
          selectedIds = Set.from(provider.proyectosReporteria.map((p) => p.id));
          selectAll = true;
        });
      }
    });
  }

  String _formatoRangoFechas() {
    if (rangoFechas == null) return 'Seleccionar fechas';
    return '${DateFormat('dd/MM/yyyy').format(rangoFechas!.start)} - ${DateFormat('dd/MM/yyyy').format(rangoFechas!.end)}';
  }
}
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:flutter/services.dart';
// import 'dart:html' as html;
// import 'package:provider/provider.dart';
// import 'package:rpg_accounts/Models/ProyectosReporteria.dart';
// import 'package:rpg_accounts/Provider/ProyectosProvider.dart';

// // Clase para manejar assets del PDF (Optimización)
// class PdfAssets {
//   static pw.Font? _roboto;
//   static Uint8List? _logo;
//   static bool _initialized = false;
  
//   static Future<void> initialize() async {
//     if (!_initialized) {
//       try {
//         _roboto = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
//         _logo = (await rootBundle.load('assets/images/Logo_RPG.png')).buffer.asUint8List();
//         _initialized = true;
//       } catch (e) {
//         print('Error cargando assets del PDF: $e');
//       }
//     }
//   }
  
//   static pw.Font? get roboto => _roboto;
//   static Uint8List? get logo => _logo;
// }

// class ReporteriaProyectosButton extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton.icon(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         padding: EdgeInsets.symmetric(horizontal: 5, vertical: 6),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//           side: BorderSide(color: Colors.black, width: 1.0),
//         ),
//       ),
//       icon: Icon(Icons.receipt_long),
//       label: Text("Reporteria General"),
//       onPressed: () => _mostrarModalReporteria(context),
//     );
//   }

//   void _mostrarModalReporteria(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => ChangeNotifierProvider(
//         create: (context) => ProyectoProvider(),
//         child: ReporteriaProyectosModal(),
//       ),
//     );
//   }
// }

// class ReporteriaProyectosModal extends StatefulWidget {
//   @override
//   _ReporteriaProyectosModalState createState() => _ReporteriaProyectosModalState();
// }

// class _ReporteriaProyectosModalState extends State<ReporteriaProyectosModal> {
//   // Filtros
//   String filtroBusqueda = '';
//   DateTimeRange? rangoFechas;
//   Set<int> selectedIds = {};
//   bool selectAll = true;
//   final _searchController = TextEditingController();
//   final _scrollController = ScrollController();
//   bool _generatingPdf = false;

//   // Columnas visibles
//   Map<String, bool> columnasVisibles = {
//     'Nombre Proyecto': true,
//     'Presupuesto': true,
//     'Adelantos': true,
//     'Gastos': true,
//     'Rentabilidad': true,
//     'Ganancias': true,
//     'Por Cobrar': true,
//   };

//   // Formateador de números para miles (coma) y decimales (punto)
//   final formatoNumero = NumberFormat.currency(
//     symbol: '\$',
//     decimalDigits: 2,
//     locale: 'es',
//   );

//   @override
//   void initState() {
//     super.initState();
    
//     // Cargar proyectos al inicializar
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final provider = Provider.of<ProyectoProvider>(context, listen: false);
//       provider.fetchProyectosReporteria().then((_) {
//         // Establecer rango de fechas después de cargar los proyectos
//         if (provider.proyectosReporteria.isNotEmpty) {
//           setState(() {
//             final fechaMin = provider.proyectosReporteria
//                 .map((p) => p.fechaInicio)
//                 .reduce((a, b) => a.isBefore(b) ? a : b);
//             final fechaMax = DateTime.now();
//             rangoFechas = DateTimeRange(start: fechaMin, end: fechaMax);
            
//             // Seleccionar todos los proyectos por defecto
//             selectedIds = Set.from(provider.proyectosReporteria.map((p) => p.id));
//           });
//         }
//       });
//     });
//   }

//   // Método para calcular totales (Refactorización)
//   Map<String, double> _calcularTotales(List<ProyectoReporteria> proyectos) {
//     // Filtrar solo los proyectos seleccionados para calcular totales
//     final proyectosSeleccionados = selectAll 
//         ? proyectos 
//         : proyectos.where((p) => selectedIds.contains(p.id)).toList();
    
//     return {
//       'presupuesto': proyectosSeleccionados.fold(0.0, (sum, p) => sum + p.presupuesto),
//       'adelantos': proyectosSeleccionados.fold(0.0, (sum, p) => sum + p.adelantos),
//       'gastos': proyectosSeleccionados.fold(0.0, (sum, p) => sum + p.gastos),
//       'rentabilidad': proyectosSeleccionados.fold(0.0, (sum, p) => sum + p.rentabilidad),
//       'ganancias': proyectosSeleccionados.fold(0.0, (sum, p) => sum + p.ganancias),
//       'porCobrar': proyectosSeleccionados.fold(0.0, (sum, p) => sum + p.porCobrar),
//     };
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<ProyectoProvider>(context);
    
//     if (provider.loadingReporteria) {
//       return Dialog(
//         child: Container(
//           padding: EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CircularProgressIndicator(),
//               SizedBox(height: 16),
//               Text('Cargando proyectos...'),
//             ],
//           ),
//         ),
//       );
//     }
    
//     if (provider.errorMessageReporteria != null) {
//       return Dialog(
//         child: Container(
//           padding: EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(Icons.error, color: Colors.red, size: 48),
//               SizedBox(height: 16),
//               Text('Error al cargar proyectos'),
//               SizedBox(height: 8),
//               Text(provider.errorMessageReporteria!, style: TextStyle(color: Colors.red)),
//               SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () {
//                   provider.fetchProyectosReporteria();
//                 },
//                 child: Text('Reintentar'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
    
//     final proyectosFiltrados = _filtrarProyectos(provider.proyectosReporteria);
    
//     return Dialog(
//       insetPadding: EdgeInsets.all(20),
//       child: Stack(
//         children: [
//           Container(
//             width: MediaQuery.of(context).size.width * 0.9,
//             height: MediaQuery.of(context).size.height * 0.8,
//             padding: EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 // Header
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Reportería de Proyectos',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.close),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ],
//                 ),
//                 Divider(),
                
//                 // Filtros
//                 _buildFiltros(),
//                 SizedBox(height: 16),
                
//                 // Selector de columnas
//                 _buildSelectorColumnas(),
//                 SizedBox(height: 16),
                
//                 // Controles
//                 _buildControles(proyectosFiltrados),
//                 SizedBox(height: 16),
                
//                 // Tabla
//                 Expanded(
//                   child: _buildTabla(proyectosFiltrados),
//                 ),
//               ],
//             ),
//           ),
          
//           // Indicador de carga al generar PDF
//           if (_generatingPdf)
//             Container(
//               color: Colors.black.withOpacity(0.5),
//               child: Center(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
//                       strokeWidth: 5,
//                     ),
//                     SizedBox(height: 20),
//                     Text(
//                       'Generando PDF...',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFiltros() {
//     return Wrap(
//       spacing: 10,
//       runSpacing: 10,
//       children: [
//         // Buscador
//         SizedBox(
//           width: 250,
//           child: TextField(
//             controller: _searchController,
//             decoration: InputDecoration(
//               labelText: 'Buscar proyectos',
//               prefixIcon: Icon(Icons.search),
//               border: OutlineInputBorder(),
//             ),
//             onChanged: (value) => setState(() => filtroBusqueda = value),
//           ),
//         ),
        
//         // Rango de fechas
//         OutlinedButton.icon(
//           icon: Icon(Icons.date_range),
//           label: Text(_formatoRangoFechas()),
//           onPressed: _seleccionarRangoFechas,
//         ),
        
//         // Resetear
//         OutlinedButton.icon(
//           icon: Icon(Icons.refresh),
//           label: Text('Resetear'),
//           onPressed: _resetearFiltros,
//         ),
//       ],
//     );
//   }

//   Widget _buildSelectorColumnas() {
//     return ExpansionTile(
//       title: Text('Columnas visibles'),
//       initiallyExpanded: true,
//       children: [
//         Wrap(
//           spacing: 8,
//           runSpacing: 8,
//           children: columnasVisibles.entries.map((e) {
//             return FilterChip(
//               label: Text(e.key),
//               selected: e.value,
//               onSelected: (v) => setState(() => columnasVisibles[e.key] = v),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }

//   Widget _buildControles(List<ProyectoReporteria> proyectos) {
//     // Filtrar selectedIds para que solo contenga IDs que existen en proyectos
//     final selectedIdsFiltrados = selectedIds.where((id) => 
//       proyectos.any((p) => p.id == id)
//     ).toSet();

//     // Si hay discrepancia, actualizar selectedIds
//     if (selectedIdsFiltrados.length != selectedIds.length) {
//       Future.microtask(() {
//         if (mounted) {
//           setState(() {
//             selectedIds = selectedIdsFiltrados;
//             selectAll = selectedIds.length == proyectos.length;
//           });
//         }
//       });
//     }

//     return Row(
//       children: [
//         Checkbox(
//           value: selectAll,
//           onChanged: (value) {
//             setState(() {
//               selectAll = value ?? false;
//               selectedIds = selectAll 
//                   ? Set.from(proyectos.map((p) => p.id)) 
//                   : {};
//             });
//           },
//         ),
//         Text(selectAll ? 'Deseleccionar todos' : 'Seleccionar todos'),
//         Spacer(),
//         Text('${selectedIds.length}/${proyectos.length} seleccionados'),
//         SizedBox(width: 16),
//         ElevatedButton.icon(
//           icon: Icon(Icons.picture_as_pdf),
//           label: Text('Generar PDF'),
//           onPressed: _generatingPdf 
//               ? null 
//               : () => _generatePdfWeb(
//                 selectAll ? proyectos : proyectos.where((p) => selectedIds.contains(p.id)).toList()
//               ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTabla(List<ProyectoReporteria> proyectos) {
//     return Scrollbar(
//       controller: _scrollController,
//       child: SingleChildScrollView(
//         controller: _scrollController,
//         scrollDirection: Axis.vertical,
//         child: SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: DataTable(
//             columnSpacing: 20,
//             columns: _buildColumnas(),
//             rows: [
//               ...proyectos.map((p) => DataRow(
//                 selected: selectedIds.contains(p.id),
//                 cells: _buildCeldas(p),
//               )),
//               // Fila de totales
//               DataRow(
//                 color: MaterialStateProperty.resolveWith<Color?>(
//                   (Set<MaterialState> states) => Colors.grey[200],
//                 ),
//                 cells: _buildCeldasTotales(proyectos),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   List<DataColumn> _buildColumnas() {
//     final columnas = <DataColumn>[];
    
//     // Columna de selección
//     columnas.add(DataColumn(
//       label: SizedBox(width: 40, child: Text('Sel.')),
//     ));
    
//     // Columnas dinámicas basadas en las visibles
//     if (columnasVisibles['Nombre Proyecto']!) {
//       columnas.add(DataColumn(label: Text('Proyecto')));
//     }
//     if (columnasVisibles['Presupuesto']!) {
//       columnas.add(DataColumn(label: Text('Presupuesto'), numeric: true));
//     }
//     if (columnasVisibles['Adelantos']!) {
//       columnas.add(DataColumn(label: Text('Adelantos'), numeric: true));
//     }
//     if (columnasVisibles['Gastos']!) {
//       columnas.add(DataColumn(label: Text('Gastos'), numeric: true));
//     }
//     if (columnasVisibles['Rentabilidad']!) {
//       columnas.add(DataColumn(label: Text('Rentabilidad'), numeric: true));
//     }
//     if (columnasVisibles['Ganancias']!) {
//       columnas.add(DataColumn(label: Text('Ganancias'), numeric: true));
//     }
//     if (columnasVisibles['Por Cobrar']!) {
//       columnas.add(DataColumn(label: Text('Por Cobrar'), numeric: true));
//     }
    
//     return columnas;
//   }

//   List<DataCell> _buildCeldas(ProyectoReporteria p) {
//     final celdas = <DataCell>[];
    
//     // Celda de selección
//     celdas.add(DataCell(
//       Checkbox(
//         value: selectedIds.contains(p.id),
//         onChanged: (value) {
//           setState(() {
//             if (value ?? false) {
//               selectedIds.add(p.id);
//               final provider = Provider.of<ProyectoProvider>(context, listen: false);
//               final proyectosFiltrados = _filtrarProyectos(provider.proyectosReporteria);
//               selectAll = selectedIds.length == proyectosFiltrados.length;
//             } else {
//               selectedIds.remove(p.id);
//               selectAll = false;
//             }
//           });
//         },
//       ),
//     ));
    
//     // Columnas dinámicas basadas en las visibles
//     if (columnasVisibles['Nombre Proyecto']!) {
//       celdas.add(DataCell(Text(p.nombre)));
//     }
//     if (columnasVisibles['Presupuesto']!) {
//       celdas.add(DataCell(Text(_formatoNumero(p.presupuesto))));
//     }
//     if (columnasVisibles['Adelantos']!) {
//       celdas.add(DataCell(Text(_formatoNumero(p.adelantos))));
//     }
//     if (columnasVisibles['Gastos']!) {
//       celdas.add(DataCell(Text(_formatoNumero(p.gastos))));
//     }
//     if (columnasVisibles['Rentabilidad']!) {
//       celdas.add(DataCell(Text(_formatoNumero(p.rentabilidad))));
//     }
//     if (columnasVisibles['Ganancias']!) {
//       celdas.add(DataCell(Text(_formatoNumero(p.ganancias))));
//     }
//     if (columnasVisibles['Por Cobrar']!) {
//       celdas.add(DataCell(Text(_formatoNumero(p.porCobrar))));
//     }
    
//     return celdas;
//   }

//   List<DataCell> _buildCeldasTotales(List<ProyectoReporteria> proyectos) {
//     final celdas = <DataCell>[];
//     final totales = _calcularTotales(proyectos);
    
//     // Celda de selección vacía
//     celdas.add(DataCell(Container()));
    
//     // Columnas dinámicas basadas en las visibles
//     if (columnasVisibles['Nombre Proyecto']!) {
//       final texto = selectAll ? 'TOTALES (Todos)' : 'TOTALES (${selectedIds.length} seleccionados)';
//       celdas.add(DataCell(Text(texto, style: TextStyle(fontWeight: FontWeight.bold))));
//     }
//     if (columnasVisibles['Presupuesto']!) {
//       celdas.add(DataCell(Text(
//         _formatoNumero(totales['presupuesto']!),
//         style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800]),
//       )));
//     }
//     if (columnasVisibles['Adelantos']!) {
//       celdas.add(DataCell(Text(
//         _formatoNumero(totales['adelantos']!),
//         style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800]),
//       )));
//     }
//     if (columnasVisibles['Gastos']!) {
//       celdas.add(DataCell(Text(
//         _formatoNumero(totales['gastos']!),
//         style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800]),
//       )));
//     }
//     if (columnasVisibles['Rentabilidad']!) {
//       celdas.add(DataCell(Text(
//         _formatoNumero(totales['rentabilidad']!),
//         style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800]),
//       )));
//     }
//     if (columnasVisibles['Ganancias']!) {
//       celdas.add(DataCell(Text(
//         _formatoNumero(totales['ganancias']!),
//         style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800]),
//       )));
//     }
//     if (columnasVisibles['Por Cobrar']!) {
//       celdas.add(DataCell(Text(
//         _formatoNumero(totales['porCobrar']!),
//         style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800]),
//       )));
//     }
    
//     return celdas;
//   }

//   // Formateador personalizado para mostrar comas en miles y punto en decimales
//   String _formatoNumero(double value) {
//     // Formatear con comas para miles y punto para decimales
//     final parts = value.toStringAsFixed(2).split('.');
//     final integerPart = parts[0].replaceAllMapped(
//       RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
//       (Match m) => '${m[1]},',
//     );
//     return '\$$integerPart.${parts[1]}';
//   }

//   Future<void> _generatePdfWeb(List<ProyectoReporteria> proyectosSeleccionados) async {
//     setState(() => _generatingPdf = true);
    
//     try {
//       // Inicializar assets del PDF
//       await PdfAssets.initialize();
      
//       final pdf = pw.Document();
//       final roboto = PdfAssets.roboto;
//       final logo = PdfAssets.logo;
      
//       if (roboto == null || logo == null) {
//         throw Exception('No se pudieron cargar los recursos del PDF');
//       }

//       // Calcular totales
//       final totales = _calcularTotales(proyectosSeleccionados);
//       final columnasActivas = columnasVisibles.entries.where((e) => e.value).toList();
      
//       // Dividir proyectos en páginas (máximo 25 por página)
//       const proyectosPorPagina = 25;
//       final paginas = <List<ProyectoReporteria>>[];
      
//       for (var i = 0; i < proyectosSeleccionados.length; i += proyectosPorPagina) {
//         final fin = (i + proyectosPorPagina < proyectosSeleccionados.length) ? i + proyectosPorPagina : proyectosSeleccionados.length;
//         paginas.add(proyectosSeleccionados.sublist(i, fin));
//       }

//       for (var i = 0; i < paginas.length; i++) {
//         final paginaProyectos = paginas[i];
        
//         pdf.addPage(
//           pw.Page(
//             pageFormat: PdfPageFormat.a4,
//             margin: const pw.EdgeInsets.all(32),
//             build: (context) {
//               return pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//                 children: [
//                   // Header (solo en primera página)
//                   if (i == 0) ..._buildPdfHeader(roboto, logo),
                  
//                   // Título con número de página
//                   pw.Text('Reporte de Proyectos - Página ${i + 1}/${paginas.length}', 
//                       style: pw.TextStyle(font: roboto, fontSize: 16, fontWeight: pw.FontWeight.bold)),
//                   pw.Text('Generado: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}', 
//                       style: pw.TextStyle(font: roboto, fontSize: 10)),
//                   pw.SizedBox(height: 10),
                  
//                   // Tabla de proyectos
//                   pw.Table(
//                     border: pw.TableBorder.all(),
//                     columnWidths: _getPdfColumnWidths(columnasActivas),
//                     children: [
//                       // Encabezados (en cada página)
//                       _buildPdfTableHeader(columnasActivas, roboto),
//                       // Datos
//                       ...paginaProyectos.map((p) => pw.TableRow(
//                         children: _getPdfRowData(p, columnasActivas, roboto),
//                       )),
//                       // Totales (solo en la última página)
//                       if (i == paginas.length - 1) 
//                         _buildPdfTableTotales(totales, columnasActivas, roboto),
//                     ],
//                   ),
//                 ],
//               );
//             },
//           ),
//         );
//       }

//       // Descargar PDF
//       final bytes = await pdf.save();
//       final blob = html.Blob([bytes]);
//       final url = html.Url.createObjectUrlFromBlob(blob);
//       final anchor = html.AnchorElement(href: url)
//         ..setAttribute("download", "reporte_proyectos_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf")
//         ..click();
//       html.Url.revokeObjectUrl(url);
      
//     } catch (e) {
//       // Mostrar error al usuario
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error al generar PDF: ${e.toString()}'))
//       );
//     } finally {
//       if (mounted) {
//         setState(() => _generatingPdf = false);
//       }
//     }
//   }

//   // Métodos auxiliares para construir el PDF
//   List<pw.Widget> _buildPdfHeader(pw.Font roboto, Uint8List logo) {
//     return [
//       pw.Row(
//         mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//         children: [
//           pw.Container(
//             height: 70,
//             child: pw.Image(pw.MemoryImage(logo), fit: pw.BoxFit.contain),
//           ),
//           pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.end,
//             children: [
//               pw.Text('Grupo RPG S.A.', style: pw.TextStyle(font: roboto, fontSize: 18)),
//               pw.Text('R.U.C 155651266-2-2017 D.V. 42', style: pw.TextStyle(font: roboto, fontSize: 10)),
//               pw.Text('gerenciagruporpg@gmail.com', style: pw.TextStyle(font: roboto, fontSize: 10)),
//             ],
//           ),
//         ],
//       ),
//       pw.SizedBox(height: 20),
//     ];
//   }

//   pw.TableRow _buildPdfTableHeader(List<MapEntry<String, bool>> columnasActivas, pw.Font roboto) {
//     return pw.TableRow(
//       decoration: pw.BoxDecoration(color: PdfColors.grey300),
//       children: columnasActivas.map((columna) {
//         return pw.Padding(
//           padding: pw.EdgeInsets.all(4),
//           child: pw.Text(
//             columna.key, 
//             style: pw.TextStyle(font: roboto, fontWeight: pw.FontWeight.bold, fontSize: 10)
//           ),
//         );
//       }).toList(),
//     );
//   }

//   pw.TableRow _buildPdfTableTotales(Map<String, double> totales, List<MapEntry<String, bool>> columnasActivas, pw.Font roboto) {
//     return pw.TableRow(
//       decoration: pw.BoxDecoration(color: PdfColors.grey200),
//       children: columnasActivas.map((columna) {
//         String texto = '';
        
//         switch (columna.key) {
//           case 'Nombre Proyecto':
//             texto = selectAll ? 'TOTALES (Todos)' : 'TOTALES (${selectedIds.length} seleccionados)';
//             break;
//           case 'Presupuesto':
//             texto = _formatoNumeroPdf(totales['presupuesto']!);
//             break;
//           case 'Adelantos':
//             texto = _formatoNumeroPdf(totales['adelantos']!);
//             break;
//           case 'Gastos':
//             texto = _formatoNumeroPdf(totales['gastos']!);
//             break;
//           case 'Rentabilidad':
//             texto = _formatoNumeroPdf(totales['rentabilidad']!);
//             break;
//           case 'Ganancias':
//             texto = _formatoNumeroPdf(totales['ganancias']!);
//             break;
//           case 'Por Cobrar':
//             texto = _formatoNumeroPdf(totales['porCobrar']!);
//             break;
//           default:
//             texto = '';
//         }
        
//         return pw.Padding(
//           padding: pw.EdgeInsets.all(4),
//           child: pw.Text(
//             texto,
//             style: pw.TextStyle(
//               font: roboto,
//               fontWeight: pw.FontWeight.bold,
//               color: columna.key == 'Nombre Proyecto' ? PdfColors.black : PdfColors.blue800,
//               fontSize: 10
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   String _formatoNumeroPdf(double value) {
//     // Formatear con comas para miles y punto para decimales para el PDF
//     final parts = value.toStringAsFixed(2).split('.');
//     final integerPart = parts[0].replaceAllMapped(
//       RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
//       (Match m) => '${m[1]},',
//     );
//     return '\$$integerPart.${parts[1]}';
//   }

//   Map<int, pw.FlexColumnWidth> _getPdfColumnWidths(List<MapEntry<String, bool>> columnasActivas) {
//     final widths = <int, pw.FlexColumnWidth>{};
//     for (var i = 0; i < columnasActivas.length; i++) {
//       widths[i] = pw.FlexColumnWidth(columnasActivas[i].key == 'Nombre Proyecto' ? 3 : 2);
//     }
//     return widths;
//   }

//   List<pw.Widget> _getPdfRowData(ProyectoReporteria p, List<MapEntry<String, bool>> columnasActivas, pw.Font roboto) {
//     return columnasActivas.map((columna) {
//       String texto = '';
      
//       switch (columna.key) {
//         case 'Nombre Proyecto':
//           texto = p.nombre;
//           break;
//         case 'Presupuesto':
//           texto = _formatoNumeroPdf(p.presupuesto);
//           break;
//         case 'Adelantos':
//           texto = _formatoNumeroPdf(p.adelantos);
//           break;
//         case 'Gastos':
//           texto = _formatoNumeroPdf(p.gastos);
//           break;
//         case 'Rentabilidad':
//           texto = _formatoNumeroPdf(p.rentabilidad);
//           break;
//         case 'Ganancias':
//           texto = _formatoNumeroPdf(p.ganancias);
//           break;
//         case 'Por Cobrar':
//           texto = _formatoNumeroPdf(p.porCobrar);
//           break;
//       }
      
//       return pw.Padding(
//         padding: pw.EdgeInsets.all(4),
//         child: pw.Text(
//           texto, 
//           style: pw.TextStyle(font: roboto, fontSize: 10)
//         ),
//       );
//     }).toList();
//   }

//   List<ProyectoReporteria> _filtrarProyectos(List<ProyectoReporteria> proyectos) {
//     return proyectos.where((p) {
//       final busquedaMatch = filtroBusqueda.isEmpty ||
//           p.nombre.toLowerCase().contains(filtroBusqueda.toLowerCase());
      
//       final fechaMatch = rangoFechas == null ||
//           (p.fechaInicio.isAfter(rangoFechas!.start.subtract(Duration(days: 1))) &&
//            p.fechaInicio.isBefore(rangoFechas!.end.add(Duration(days: 1))));
      
//       return busquedaMatch && fechaMatch;
//     }).toList();
//   }

//   Future<void> _seleccionarRangoFechas() async {
//     final provider = Provider.of<ProyectoProvider>(context, listen: false);
//     final fechaMin = provider.proyectosReporteria
//         .map((p) => p.fechaInicio)
//         .reduce((a, b) => a.isBefore(b) ? a : b);
//     final fechaMax = DateTime.now();
    
//     final picked = await showDateRangePicker(
//       context: context,
//       firstDate: fechaMin.subtract(Duration(days: 365)),
//       lastDate: fechaMax.add(Duration(days: 365)),
//       initialDateRange: rangoFechas,
//     );
    
//     if (picked != null) {
//       setState(() => rangoFechas = picked);
//     }
//   }

//   void _resetearFiltros() {
//     final provider = Provider.of<ProyectoProvider>(context, listen: false);
//     setState(() {
//       _searchController.clear();
//       filtroBusqueda = '';
//       final fechaMin = provider.proyectosReporteria
//           .map((p) => p.fechaInicio)
//           .reduce((a, b) => a.isBefore(b) ? a : b);
//       final fechaMax = DateTime.now();
//       rangoFechas = DateTimeRange(start: fechaMin, end: fechaMax);
//       selectedIds = Set.from(provider.proyectosReporteria.map((p) => p.id));
//       selectAll = true;
//     });
//   }

//   String _formatoRangoFechas() {
//     if (rangoFechas == null) return 'Todas las fechas';
//     return '${DateFormat('dd/MM/yyyy').format(rangoFechas!.start)} - ${DateFormat('dd/MM/yyyy').format(rangoFechas!.end)}';
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:flutter/services.dart';
// import 'dart:html' as html;
// import 'package:provider/provider.dart';
// import 'package:rpg_accounts/Models/ProyectosReporteria.dart';
// import 'package:rpg_accounts/Provider/ProyectosProvider.dart';

// class ReporteriaProyectosButton extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return
// ElevatedButton.icon(
//   style: ElevatedButton.styleFrom(
//     backgroundColor: Colors.white,
//     foregroundColor: Colors.black,
//     padding: EdgeInsets.symmetric(horizontal: 5, vertical: 6),
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(8),
//       side: BorderSide(color: Colors.black, width: 1.0),
//     ),
//   ),
//   icon: Icon(Icons.receipt_long),
//   label: Text("Reporteria General"),
//   onPressed: () => _mostrarModalReporteria(context),
// );
//     //  FloatingActionButton(
//     //   onPressed: () => _mostrarModalReporteria(context),
//     //   tooltip: 'Generar reporte',
//     //   backgroundColor: Colors.blue,
//     //   child: Icon(Icons.insert_chart),
//     // );
//   }

//   void _mostrarModalReporteria(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => ChangeNotifierProvider(
//         create: (context) => ProyectoProvider(),
//         child: ReporteriaProyectosModal(),
//       ),
//     );
//   }
// }

// class ReporteriaProyectosModal extends StatefulWidget {
//   @override
//   _ReporteriaProyectosModalState createState() => _ReporteriaProyectosModalState();
// }

// class _ReporteriaProyectosModalState extends State<ReporteriaProyectosModal> {
//   // Filtros
//   String filtroBusqueda = '';
//   DateTimeRange? rangoFechas;
//   Set<int> selectedIds = {};
//   bool selectAll = true;
//   final _searchController = TextEditingController();
//   final _scrollController = ScrollController();
//   bool _generatingPdf = false;

//   // Columnas visibles
//   Map<String, bool> columnasVisibles = {
//     'Nombre Proyecto': true,
//     'Presupuesto': true,
//     'Adelantos': true,
//     'Gastos': true,
//     'Rentabilidad': true,
//     'Ganancias': true,
//     'Por Cobrar': true,
//   };

//   // Formateador de números para miles (coma) y decimales (punto)
//   final formatoNumero = NumberFormat.currency(
//     symbol: '\$',
//     decimalDigits: 2,
//     locale: 'es',
//   );

//   @override
//   void initState() {
//     super.initState();
    
//     // Cargar proyectos al inicializar
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final provider = Provider.of<ProyectoProvider>(context, listen: false);
//       provider.fetchProyectosReporteria().then((_) {
//         // Establecer rango de fechas después de cargar los proyectos
//         if (provider.proyectosReporteria.isNotEmpty) {
//           setState(() {
//             final fechaMin = provider.proyectosReporteria
//                 .map((p) => p.fechaInicio)
//                 .reduce((a, b) => a.isBefore(b) ? a : b);
//             final fechaMax = DateTime.now();
//             rangoFechas = DateTimeRange(start: fechaMin, end: fechaMax);
            
//             // Seleccionar todos los proyectos por defecto
//             selectedIds = Set.from(provider.proyectosReporteria.map((p) => p.id));
//           });
//         }
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<ProyectoProvider>(context);
    
//     if (provider.loadingReporteria) {
//       return Dialog(
//         child: Container(
//           padding: EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CircularProgressIndicator(),
//               SizedBox(height: 16),
//               Text('Cargando proyectos...'),
//             ],
//           ),
//         ),
//       );
//     }
    
//     if (provider.errorMessageReporteria != null) {
//       return Dialog(
//         child: Container(
//           padding: EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(Icons.error, color: Colors.red, size: 48),
//               SizedBox(height: 16),
//               Text('Error al cargar proyectos'),
//               SizedBox(height: 8),
//               Text(provider.errorMessageReporteria!, style: TextStyle(color: Colors.red)),
//               SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () {
//                   provider.fetchProyectosReporteria();
//                 },
//                 child: Text('Reintentar'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
    
//     final proyectosFiltrados = _filtrarProyectos(provider.proyectosReporteria);
    
//     return Dialog(
//       insetPadding: EdgeInsets.all(20),
//       child: Stack(
//         children: [
//           Container(
//             width: MediaQuery.of(context).size.width * 0.9,
//             height: MediaQuery.of(context).size.height * 0.8,
//             padding: EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 // Header
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Reportería de Proyectos',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.close),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ],
//                 ),
//                 Divider(),
                
//                 // Filtros
//                 _buildFiltros(),
//                 SizedBox(height: 16),
                
//                 // Selector de columnas
//                 _buildSelectorColumnas(),
//                 SizedBox(height: 16),
                
//                 // Controles
//                 _buildControles(proyectosFiltrados),
//                 SizedBox(height: 16),
                
//                 // Tabla
//                 Expanded(
//                   child: _buildTabla(proyectosFiltrados),
//                 ),
//               ],
//             ),
//           ),
          
//           // Indicador de carga al generar PDF
//           if (_generatingPdf)
//             Container(
//               color: Colors.black.withOpacity(0.5),
//               child: Center(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
//                       strokeWidth: 5,
//                     ),
//                     SizedBox(height: 20),
//                     Text(
//                       'Generando PDF...',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFiltros() {
//     return Wrap(
//       spacing: 10,
//       runSpacing: 10,
//       children: [
//         // Buscador
//         SizedBox(
//           width: 250,
//           child: TextField(
//             controller: _searchController,
//             decoration: InputDecoration(
//               labelText: 'Buscar proyectos',
//               prefixIcon: Icon(Icons.search),
//               border: OutlineInputBorder(),
//             ),
//             onChanged: (value) => setState(() => filtroBusqueda = value),
//           ),
//         ),
        
//         // Rango de fechas
//         OutlinedButton.icon(
//           icon: Icon(Icons.date_range),
//           label: Text(_formatoRangoFechas()),
//           onPressed: _seleccionarRangoFechas,
//         ),
        
//         // Resetear
//         OutlinedButton.icon(
//           icon: Icon(Icons.refresh),
//           label: Text('Resetear'),
//           onPressed: _resetearFiltros,
//         ),
//       ],
//     );
//   }

//   Widget _buildSelectorColumnas() {
//     return ExpansionTile(
//       title: Text('Columnas visibles'),
//       initiallyExpanded: true,
//       children: [
//         Wrap(
//           spacing: 8,
//           runSpacing: 8,
//           children: columnasVisibles.entries.map((e) {
//             return FilterChip(
//               label: Text(e.key),
//               selected: e.value,
//               onSelected: (v) => setState(() => columnasVisibles[e.key] = v),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }

//   Widget _buildControles(List<ProyectoReporteria> proyectos) {

//       // Filtrar selectedIds para que solo contenga IDs que existen en proyectos
//   final selectedIdsFiltrados = selectedIds.where((id) => 
//     proyectos.any((p) => p.id == id)
//   ).toSet();

//   // Si hay discrepancia, actualizar selectedIds
//   if (selectedIdsFiltrados.length != selectedIds.length) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       setState(() {
//         selectedIds = selectedIdsFiltrados;
//         selectAll = selectedIds.length == proyectos.length;
//       });
//     });
//   }

//     return Row(
//       children: [
//         Checkbox(
//           value: selectAll,
//           onChanged: (value) {
//             setState(() {
//               selectAll = value ?? false;
//               selectedIds = selectAll 
//                   ? Set.from(proyectos.map((p) => p.id)) 
//                   : {};
//             });
//           },
//         ),
//         Text(selectAll ? 'Deseleccionar todos' : 'Seleccionar todos'),
//         Spacer(),
//         Text('${selectedIds.length}/${proyectos.length} seleccionados'),
//         SizedBox(width: 16),
//         ElevatedButton.icon(
//           icon: Icon(Icons.picture_as_pdf),
//           label: Text('Generar PDF'),
//           onPressed: _generatingPdf 
//               ? null 
//               : () => _generatePdfWeb(
//                 selectAll ? proyectos : proyectos.where((p) => selectedIds.contains(p.id)).toList()
//               ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTabla(List<ProyectoReporteria> proyectos) {
//     return Scrollbar(
//       controller: _scrollController,
//       child: SingleChildScrollView(
//         controller: _scrollController,
//         scrollDirection: Axis.vertical,
//         child: SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: DataTable(
//             columnSpacing: 20,
//             columns: _buildColumnas(),
//             rows: [
//               ...proyectos.map((p) => DataRow(
//                 selected: selectedIds.contains(p.id),
//                 cells: _buildCeldas(p),
//               )),
//               // Fila de totales
//               DataRow(
//                 color: MaterialStateProperty.resolveWith<Color?>(
//                   (Set<MaterialState> states) => Colors.grey[200],
//                 ),
//                 cells: _buildCeldasTotales(proyectos),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   List<DataColumn> _buildColumnas() {
//     final columnas = <DataColumn>[];
    
//     // Columna de selección
//     columnas.add(DataColumn(
//       label: SizedBox(width: 40, child: Text('Sel.')),
//     ));
    
//     // Columnas dinámicas basadas en las visibles
//     if (columnasVisibles['Nombre Proyecto']!) {
//       columnas.add(DataColumn(label: Text('Proyecto')));
//     }
//     if (columnasVisibles['Presupuesto']!) {
//       columnas.add(DataColumn(label: Text('Presupuesto'), numeric: true));
//     }
//     if (columnasVisibles['Adelantos']!) {
//       columnas.add(DataColumn(label: Text('Adelantos'), numeric: true));
//     }
//     if (columnasVisibles['Gastos']!) {
//       columnas.add(DataColumn(label: Text('Gastos'), numeric: true));
//     }
//     if (columnasVisibles['Rentabilidad']!) {
//       columnas.add(DataColumn(label: Text('Rentabilidad'), numeric: true));
//     }
//     if (columnasVisibles['Ganancias']!) {
//       columnas.add(DataColumn(label: Text('Ganancias'), numeric: true));
//     }
//     if (columnasVisibles['Por Cobrar']!) {
//       columnas.add(DataColumn(label: Text('Por Cobrar'), numeric: true));
//     }
    
//     return columnas;
//   }

//   List<DataCell> _buildCeldas(ProyectoReporteria p) {
//     final celdas = <DataCell>[];
    
//     // Celda de selección
//     celdas.add(DataCell(
//       Checkbox(
//         value: selectedIds.contains(p.id),
//         onChanged: (value) {
//           setState(() {
//             if (value ?? false) {
//               selectedIds.add(p.id);
//               final provider = Provider.of<ProyectoProvider>(context, listen: false);
//               final proyectosFiltrados = _filtrarProyectos(provider.proyectosReporteria);
//               selectAll = selectedIds.length == proyectosFiltrados.length;
//             } else {
//               selectedIds.remove(p.id);
//               selectAll = false;
//             }
//           });
//         },
//       ),
//     ));
    
//     // Columnas dinámicas basadas en las visibles
//     if (columnasVisibles['Nombre Proyecto']!) {
//       celdas.add(DataCell(Text(p.nombre)));
//     }
//     if (columnasVisibles['Presupuesto']!) {
//       celdas.add(DataCell(Text(_formatoNumero(p.presupuesto))));
//     }
//     if (columnasVisibles['Adelantos']!) {
//       celdas.add(DataCell(Text(_formatoNumero(p.adelantos))));
//     }
//     if (columnasVisibles['Gastos']!) {
//       celdas.add(DataCell(Text(_formatoNumero(p.gastos))));
//     }
//     if (columnasVisibles['Rentabilidad']!) {
//       celdas.add(DataCell(Text(_formatoNumero(p.rentabilidad))));
//     }
//     if (columnasVisibles['Ganancias']!) {
//       celdas.add(DataCell(Text(_formatoNumero(p.ganancias))));
//     }
//     if (columnasVisibles['Por Cobrar']!) {
//       celdas.add(DataCell(Text(_formatoNumero(p.porCobrar))));
//     }
    
//     return celdas;
//   }

//   List<DataCell> _buildCeldasTotales(List<ProyectoReporteria> proyectos) {
//     final celdas = <DataCell>[];
    
//     // Celda de selección vacía
//     celdas.add(DataCell(Container()));
    
//     // Calcular totales
//     double totalPresupuesto = 0;
//     double totalAdelantos = 0;
//     double totalGastos = 0;
//     double totalRentabilidad = 0;
//     double totalGanancias = 0;
//     double totalPorCobrar = 0;

//     for (var p in proyectos) {
//       totalPresupuesto += p.presupuesto;
//       totalAdelantos += p.adelantos;
//       totalGastos += p.gastos;
//       totalRentabilidad += p.rentabilidad;
//       totalGanancias += p.ganancias;
//       totalPorCobrar += p.porCobrar;
//     }

//     // Columnas dinámicas basadas en las visibles
//     if (columnasVisibles['Nombre Proyecto']!) {
//       celdas.add(DataCell(Text('TOTALES', style: TextStyle(fontWeight: FontWeight.bold))));
//     }
//     if (columnasVisibles['Presupuesto']!) {
//       celdas.add(DataCell(Text(
//         _formatoNumero(totalPresupuesto),
//         style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800]),
//       )));
//     }
//     if (columnasVisibles['Adelantos']!) {
//       celdas.add(DataCell(Text(
//         _formatoNumero(totalAdelantos),
//         style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800]),
//       )));
//     }
//     if (columnasVisibles['Gastos']!) {
//       celdas.add(DataCell(Text(
//         _formatoNumero(totalGastos),
//         style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800]),
//       )));
//     }
//     if (columnasVisibles['Rentabilidad']!) {
//       celdas.add(DataCell(Text(
//         _formatoNumero(totalRentabilidad),
//         style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800]),
//       )));
//     }
//     if (columnasVisibles['Ganancias']!) {
//       celdas.add(DataCell(Text(
//         _formatoNumero(totalGanancias),
//         style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800]),
//       )));
//     }
//     if (columnasVisibles['Por Cobrar']!) {
//       celdas.add(DataCell(Text(
//         _formatoNumero(totalPorCobrar),
//         style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800]),
//       )));
//     }
    
//     return celdas;
//   }

//   // Formateador personalizado para mostrar comas en miles y punto en decimales
//   String _formatoNumero(double value) {
//     // Formatear con comas para miles y punto para decimales
//     final parts = value.toStringAsFixed(2).split('.');
//     final integerPart = parts[0].replaceAllMapped(
//       RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
//       (Match m) => '${m[1]},',
//     );
//     return '\$$integerPart.${parts[1]}';
//   }

//   Future<void> _generatePdfWeb(List<ProyectoReporteria> proyectos) async {
//     setState(() => _generatingPdf = true);
    
//     try {
//       final pdf = pw.Document();
//       final roboto = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
//       final logoBytes = await rootBundle.load('assets/images/Logo_RPG.png');
//       final logo = logoBytes.buffer.asUint8List();

//       // Calcular totales
//       double totalPresupuesto = 0;
//       double totalAdelantos = 0;
//       double totalGastos = 0;
//       double totalRentabilidad = 0;
//       double totalGanancias = 0;
//       double totalPorCobrar = 0;

//       for (var p in proyectos) {
//         totalPresupuesto += p.presupuesto;
//         totalAdelantos += p.adelantos;
//         totalGastos += p.gastos;
//         totalRentabilidad += p.rentabilidad;
//         totalGanancias += p.ganancias;
//         totalPorCobrar += p.porCobrar;
//       }

//       pdf.addPage(
//         pw.Page(
//           pageFormat: PdfPageFormat.a4,
//           margin: const pw.EdgeInsets.all(32),
//           build: (context) {
//             // Determinar qué columnas incluir en el PDF
//             final columnasActivas = columnasVisibles.entries.where((e) => e.value).toList();
            
//             return pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 // Header
//                 pw.Row(
//                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                   children: [
//                     pw.Container(
//                       height: 70,
//                       child: pw.Image(pw.MemoryImage(logo), fit: pw.BoxFit.contain),
//                     ),
//                     pw.Column(
//                       crossAxisAlignment: pw.CrossAxisAlignment.end,
//                       children: [
//                         pw.Text('Grupo RPG S.A.', style: pw.TextStyle(font: roboto, fontSize: 18)),
//                         pw.Text('R.U.C 155651266-2-2017 D.V. 42', style: pw.TextStyle(font: roboto, fontSize: 10)),
//                         pw.Text('gerenciagruporpg@gmail.com', style: pw.TextStyle(font: roboto, fontSize: 10)),
//                       ],
//                     ),
//                   ],
//                 ),
                
//                 pw.SizedBox(height: 20),
                
//                 // Título
//                 pw.Text('Reporte de Proyectos', style: pw.TextStyle(font: roboto, fontSize: 20, fontWeight: pw.FontWeight.bold)),
//                 pw.Text('Generado: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}', style: pw.TextStyle(font: roboto, fontSize: 12)),
//                 pw.SizedBox(height: 20),
                
//                 // Tabla de proyectos
//                 pw.Table(
//                   border: pw.TableBorder.all(),
//                   columnWidths: _getPdfColumnWidths(columnasActivas),
//                   children: [
//                     // Encabezados
//                     pw.TableRow(
//                       decoration: pw.BoxDecoration(color: PdfColors.grey300),
//                       children: columnasActivas.map((columna) {
//                         return pw.Padding(
//                           padding: pw.EdgeInsets.all(4),
//                           child: pw.Text(
//                             columna.key, 
//                             style: pw.TextStyle(font: roboto, fontWeight: pw.FontWeight.bold, fontSize: 10)
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                     // Datos
//                     ...proyectos.map((p) => pw.TableRow(
//                       children: _getPdfRowData(p, columnasActivas, roboto),
//                     )),
//                     // Fila de totales
//                     pw.TableRow(
//                       decoration: pw.BoxDecoration(color: PdfColors.grey200),
//                       children: columnasActivas.map((columna) {
//                         String texto = '';
                        
//                         switch (columna.key) {
//                           case 'Nombre Proyecto':
//                             texto = 'TOTALES';
//                             break;
//                           case 'Presupuesto':
//                             texto = _formatoNumeroPdf(totalPresupuesto);
//                             break;
//                           case 'Adelantos':
//                             texto = _formatoNumeroPdf(totalAdelantos);
//                             break;
//                           case 'Gastos':
//                             texto = _formatoNumeroPdf(totalGastos);
//                             break;
//                           case 'Rentabilidad':
//                             texto = _formatoNumeroPdf(totalRentabilidad);
//                             break;
//                           case 'Ganancias':
//                             texto = _formatoNumeroPdf(totalGanancias);
//                             break;
//                           case 'Por Cobrar':
//                             texto = _formatoNumeroPdf(totalPorCobrar);
//                             break;
//                           default:
//                             texto = '';
//                         }
                        
//                         return pw.Padding(
//                           padding: pw.EdgeInsets.all(4),
//                           child: pw.Text(
//                             texto,
//                             style: pw.TextStyle(
//                               font: roboto,
//                               fontWeight: pw.FontWeight.bold,
//                               color: columna.key == 'Nombre Proyecto' ? PdfColors.black : PdfColors.blue800,
//                               fontSize: 10
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   ],
//                 ),
//               ],
//             );
//           },
//         ),
//       );

//       // Descargar PDF
//       final bytes = await pdf.save();
//       final blob = html.Blob([bytes]);
//       final url = html.Url.createObjectUrlFromBlob(blob);
//       final anchor = html.AnchorElement(href: url)
//         ..setAttribute("download", "reporte_proyectos_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf")
//         ..click();
//       html.Url.revokeObjectUrl(url);
//     } finally {
//       setState(() => _generatingPdf = false);
//     }
//   }

//   String _formatoNumeroPdf(double value) {
//     // Formatear con comas para miles y punto para decimales para el PDF
//     final parts = value.toStringAsFixed(2).split('.');
//     final integerPart = parts[0].replaceAllMapped(
//       RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
//       (Match m) => '${m[1]},',
//     );
//     return '\$$integerPart.${parts[1]}';
//   }

//   Map<int, pw.FlexColumnWidth> _getPdfColumnWidths(List<MapEntry<String, bool>> columnasActivas) {
//     final widths = <int, pw.FlexColumnWidth>{};
//     for (var i = 0; i < columnasActivas.length; i++) {
//       widths[i] = pw.FlexColumnWidth(columnasActivas[i].key == 'Nombre Proyecto' ? 3 : 2);
//     }
//     return widths;
//   }

//   List<pw.Widget> _getPdfRowData(ProyectoReporteria p, List<MapEntry<String, bool>> columnasActivas, pw.Font roboto) {
//     return columnasActivas.map((columna) {
//       String texto = '';
      
//       switch (columna.key) {
//         case 'Nombre Proyecto':
//           texto = p.nombre;
//           break;
//         case 'Presupuesto':
//           texto = _formatoNumeroPdf(p.presupuesto);
//           break;
//         case 'Adelantos':
//           texto = _formatoNumeroPdf(p.adelantos);
//           break;
//         case 'Gastos':
//           texto = _formatoNumeroPdf(p.gastos);
//           break;
//         case 'Rentabilidad':
//           texto = _formatoNumeroPdf(p.rentabilidad);
//           break;
//         case 'Ganancias':
//           texto = _formatoNumeroPdf(p.ganancias);
//           break;
//         case 'Por Cobrar':
//           texto = _formatoNumeroPdf(p.porCobrar);
//           break;
//       }
      
//       return pw.Padding(
//         padding: pw.EdgeInsets.all(4),
//         child: pw.Text(
//           texto, 
//           style: pw.TextStyle(font: roboto, fontSize: 10)
//         ),
//       );
//     }).toList();
//   }

//   List<ProyectoReporteria> _filtrarProyectos(List<ProyectoReporteria> proyectos) {
//     return proyectos.where((p) {
//       final busquedaMatch = filtroBusqueda.isEmpty ||
//           p.nombre.toLowerCase().contains(filtroBusqueda.toLowerCase());
      
//       final fechaMatch = rangoFechas == null ||
//           (p.fechaInicio.isAfter(rangoFechas!.start.subtract(Duration(days: 1))) &&
//            p.fechaInicio.isBefore(rangoFechas!.end.add(Duration(days: 1))));
      
//       return busquedaMatch && fechaMatch;
//     }).toList();
//   }

//   Future<void> _seleccionarRangoFechas() async {
//     final provider = Provider.of<ProyectoProvider>(context, listen: false);
//     final fechaMin = provider.proyectosReporteria
//         .map((p) => p.fechaInicio)
//         .reduce((a, b) => a.isBefore(b) ? a : b);
//     final fechaMax = DateTime.now();
    
//     final picked = await showDateRangePicker(
//       context: context,
//       firstDate: fechaMin.subtract(Duration(days: 365)),
//       lastDate: fechaMax.add(Duration(days: 365)),
//       initialDateRange: rangoFechas,
//     );
    
//     if (picked != null) {
//       setState(() => rangoFechas = picked);
//     }
//   }

//   void _resetearFiltros() {
//     final provider = Provider.of<ProyectoProvider>(context, listen: false);
//     setState(() {
//       _searchController.clear();
//       filtroBusqueda = '';
//       final fechaMin = provider.proyectosReporteria
//           .map((p) => p.fechaInicio)
//           .reduce((a, b) => a.isBefore(b) ? a : b);
//       final fechaMax = DateTime.now();
//       rangoFechas = DateTimeRange(start: fechaMin, end: fechaMax);
//       selectedIds = Set.from(provider.proyectosReporteria.map((p) => p.id));
//       selectAll = true;
//     });
//   }

//   String _formatoRangoFechas() {
//     if (rangoFechas == null) return 'Todas las fechas';
//     return '${DateFormat('dd/MM/yyyy').format(rangoFechas!.start)} - ${DateFormat('dd/MM/yyyy').format(rangoFechas!.end)}';
//   }
// }
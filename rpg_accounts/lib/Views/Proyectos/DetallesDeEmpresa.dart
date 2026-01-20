import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:rpg_accounts/Models/MovimientosContablesProyecto.dart';
import 'package:rpg_accounts/Models/Proveedores.dart';
import 'package:rpg_accounts/Models/Proyectos/Comentarios.dart';
import 'package:rpg_accounts/Provider/ComentariosProvider.dart';
import 'package:rpg_accounts/Provider/MovimientosProvider.dart';
import 'package:rpg_accounts/Provider/ProyectosProvider.dart';
import 'package:rpg_accounts/Widgets/Gauge_Indicator.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/services.dart' show rootBundle;
class ProjectProfileCompactSection extends StatefulWidget {
  final String projectName;
  final String client;
  final String budget;
  final String advances; // Adelantos
  final String location;
  final String startDate;
  final String comentario; 
  final String endDate;
  final String type;
  final String phone;
  final String estado;
   final String cedula;
  final String licencia;  
  final bool isActive;
  final String imageUrl;
  final int idProyecto;

  const ProjectProfileCompactSection({
    Key? key,
    required this.projectName,
    required this.client,
    required this.budget,
    required this.comentario, 
    required this.advances,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.phone,
    required this.type,
    required this.estado,
   // required this.ruc,
    required this.cedula,
     required this.licencia,
    required this.isActive,
    required this.imageUrl,
     required this.idProyecto,
  }) : super(key: key);

  @override
  _ProjectProfileCompactSectionState createState() =>
      _ProjectProfileCompactSectionState();
}

class _ProjectProfileCompactSectionState
    extends State<ProjectProfileCompactSection> {
  late TextEditingController _projectNameCtrl;
  late TextEditingController _clientCtrl;
  late TextEditingController _budgetCtrl;
  late TextEditingController _advancesCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _startDateCtrl;
  late TextEditingController _endDateCtrl;
    late TextEditingController _prhoneCtrl; 
   // late TextEditingController _rucCtrl; 
    late TextEditingController _cedulaCtrl; 
     late TextEditingController _licenciaCtrl; 
  late TextEditingController _typeCtrl;
  late ScrollController _scrollController;
late TextEditingController _comentariosController;

  late String selectedEstado;
  final List<String> estadosDisponibles = [
    'En Progreso',
    'Completado',
    'Pendiente'
  ];

  // Lista interna para manejar los adelantos
  List<Map<String, dynamic>> listaAdelantos = [];
  double totalAdelantos = 0.0;

  final ProveedorMovimientoProvider proveedorProvider = ProveedorMovimientoProvider();
List<ProveedorModel> proveedoresList = [];  

  // Función que obtiene los proveedores según el tipo de usuario
 Future<void> getProveedores() async {
  await proveedorProvider.fetchProveedores(); // Llama al provider para obtener los proveedores

  // Filtra los proveedores con tipo 3
  setState(() {
      proveedoresList=  proveedorProvider.proveedores;

  }); // Actualiza la UI después de obtener los proveedores
}

bool _isEditing = false;

 // Controla el modo edición/visualización
void _toggleEditing() {
  setState(() {
    _isEditing = !_isEditing;
    
    // Si estamos saliendo del modo edición, guardar los cambios
    if (!_isEditing) {
      _guardarCambiosProyecto();
    }
  });
}

// Future<void> _guardarCambiosProyecto() async {
//   try {
//   final data = {
//   'id_proyecto': widget.idProyecto,
//   'nombre_proyecto': _projectNameCtrl.text, // Corregido
//   'comentario': _comentariosController.text, // Corregido (RUC)
//   'ubicacion': _locationCtrl.text, // Corregido
//   'fecha_inicio': _startDateCtrl.text, // Corregido
//   'fecha_fin': _endDateCtrl.text, // Corregido
// };
//     final response = await http.post(
//       Uri.parse('http://localhost:3002/ModificarProyecto'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode(data),
//     );

//     if (response.statusCode == 200) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Proyecto actualizado correctamente'))
//       );
//       // Opcional: recargar datos
//       //await _cargarDatosProyecto();
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error al actualizar proyecto'))
//       );
//     }
//   } catch (error) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Error de conexión: $error'))
//     );
//   }
// }
Future<void> _guardarCambiosProyecto() async {
  try {
    // Función para formatear fechas para MySQL
    String formatDateForMySQL(DateTime date) {
      return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}";
    }

    // Convertir los textos de los controladores a DateTime y luego formatear
    final fechaInicio = DateTime.parse(_startDateCtrl.text);
    final fechaFin = DateTime.parse(_endDateCtrl.text);

    final data = {
      'id_proyecto': widget.idProyecto,
      'nombre_proyecto': _projectNameCtrl.text,
      'comentario': _comentariosController.text,
      'ubicacion': _locationCtrl.text,
      'fecha_inicio': formatDateForMySQL(fechaInicio), // Formateado para MySQL
      'fecha_fin': formatDateForMySQL(fechaFin),       // Formateado para MySQL
    };

    final response = await http.post(
      Uri.parse('http://localhost:3002/ModificarProyecto'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Proyecto actualizado correctamente'))
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar proyecto'))
      );
    }
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error de conexión: $error'))
    );
  }
}

  @override
  void initState() {
    super.initState();
     getProveedores(); 
    _projectNameCtrl = TextEditingController(text: widget.projectName);
    _clientCtrl = TextEditingController(text: widget.client);
    _budgetCtrl = TextEditingController(text: widget.budget);
    _advancesCtrl = TextEditingController(text: widget.advances);
    _locationCtrl = TextEditingController(text: widget.location);
    _startDateCtrl = TextEditingController(text: widget.startDate);
    _endDateCtrl = TextEditingController(text: widget.endDate);
    _typeCtrl = TextEditingController(text: widget.type);
    _prhoneCtrl = TextEditingController(text: widget.phone);    
    _cedulaCtrl = TextEditingController(text: widget.cedula); 
    _comentariosController = TextEditingController(text: widget.comentario);  
    _licenciaCtrl = TextEditingController(text: widget.licencia); 
 //   _rucCtrl = TextEditingController(text: widget.ruc); 
    selectedEstado = widget.estado;
 _scrollController = ScrollController();
    // Inicializa lista de adelantos y total con el valor inicial (parseado)
    totalAdelantos = double.tryParse(widget.advances.replaceAll(',', '')) ?? 0.0;
    // Si tienes datos previos de adelantos, inicialízalos aquí:
    // Por ejemplo: listaAdelantos = [{'monto': totalAdelantos, 'detalle': 'Inicial'}];
  }




double totalMateriales = 0.0;
double totalManoObra = 0.0;     
double totalPagado = 0.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchData();
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    // Actualiza los totales cada vez que se llama a setState
    _fetchData();
  } 
  
Future<void> _fetchData() async {
  final provider = Provider.of<ProveedorMovimientoProvider>(context, listen: false);
  await provider.fetchMovimientos(widget.idProyecto);

  totalMateriales = 0.0;
  totalManoObra = 0.0;
  totalPagado = 0.0;

  for (var usuario in provider.movimientosPorUsuario) {
    final materiales = usuario.movimientos.where((m) => m.idProveedor != null).toList();
    final manoObra = usuario.movimientos.where((m) => m.idTrabajador != null).toList();

    totalMateriales += materiales.fold(0.0, (sum, m) =>
        sum + (m.tipoMovimiento == 1 ? m.monto : m.tipoMovimiento == 2 ? -m.monto : 0));

    totalManoObra += manoObra.fold(0.0, (sum, m) =>
        sum + (m.tipoMovimiento == 1 ? m.monto : m.tipoMovimiento == 2 ? -m.monto : 0));

    totalPagado += manoObra
        .where((m) => m.tipoMovimiento == 2)
        .fold(0.0, (sum, m) => sum + m.monto);
  }
}


  @override
  void dispose() {
    _projectNameCtrl.dispose();
    _clientCtrl.dispose();
    _budgetCtrl.dispose();
    _advancesCtrl.dispose();
    _locationCtrl.dispose();
    _startDateCtrl.dispose();
      _scrollController.dispose();
    _endDateCtrl.dispose();
    _typeCtrl.dispose();
    super.dispose();
  }

// Widget _field(String label, IconData icon, TextEditingController ctrl,
//     {bool readOnly = false}) {
//   // Función para formatear fechas si el label contiene "fecha" (case-insensitive)
//   String _formatDateIfNeeded(String text, String label) {
//     if (label.toLowerCase().contains("fecha")) {
//       try {
//         final date = DateTime.parse(text);
//         return DateFormat('dd/MM/yyyy').format(date);
//       } catch (e) {
//         return text; // Si no es fecha válida, retorna el texto original
//       }
//     }
//     return text;
//   }

//   return Flexible(
//     child: Padding(
//       padding: const EdgeInsets.only(bottom: 7, right: 4),
//       child: TextField(
//         controller: TextEditingController(
//           text: _formatDateIfNeeded(ctrl.text, label), // Aplica formato aquí
//         ),
//         readOnly: readOnly,
//         decoration: InputDecoration(
//           labelText: label,
//           prefixIcon: Icon(icon, size: 16),
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
//           isDense: true,
//           contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
//         ),
//         onChanged: (value) {
//           // Actualiza el controlador original si el campo es editable
//           if (!readOnly) ctrl.text = value;
//         },
//       ),
//     ),
//   );
// }
Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );
  
  if (picked != null) {
    setState(() {
      controller.text = picked.toIso8601String().split('T')[0];
    });
  }
}
// Función _field modificada manteniendo el estilo original
Widget _field(String label, IconData icon, TextEditingController ctrl) {
  // Función para formatear fechas si el label contiene "fecha" (case-insensitive)
  String _formatDateIfNeeded(String text, String label) {
    if (label.toLowerCase().contains("fecha")) {
      try {
        final date = DateTime.parse(text);
        return DateFormat('dd/MM/yyyy').format(date);
      } catch (e) {
        return text; // Si no es fecha válida, retorna el texto original
      }
    }
    return text;
  }

  // Lista de campos que se pueden editar
  final List<String> editableFields = [
    "Nombre del Proyecto",
    "Ubicación",
    "Ruc",
    "Fecha Inicio",
    "Fecha Fin"
  ];
  
  final bool isDateField = label.toLowerCase().contains("fecha");
  final bool isEditableField = editableFields.contains(label);
  
  return Flexible(
    child: Padding(
      padding: const EdgeInsets.only(bottom: 7, right: 4),
      child: TextField(
        controller: TextEditingController(
          text: _formatDateIfNeeded(ctrl.text, label), // Aplica formato aquí
        ),
        readOnly: !_isEditing || isDateField || !isEditableField,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          suffixIcon: isDateField && _isEditing && isEditableField
              ? IconButton(
                  icon: const Icon(Icons.calendar_today, size: 16),
                  onPressed: () => _selectDate(context, ctrl),
                )
              : null,
        ),
        onTap: isDateField && _isEditing && isEditableField
            ? () => _selectDate(context, ctrl)
            : null,
        onChanged: (value) {
          // Actualiza el controlador original si el campo es editable
          if (_isEditing && !isDateField && isEditableField) ctrl.text = value;
        },
      ),
    ),
  );
}
  /// Campo especial para Adelantos con botón para abrir modal
  Widget _adelantosField() {
  return MultiBarVerticalGauge(idProyecto :widget.idProyecto);
  
  }
// Formato fecha corto
String _formatoFecha(DateTime fecha) {
  return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
}

Map<String, dynamic> _getTipoEstilo(int tipo) {
  switch (tipo) {
    case 1:
      return {'color': Colors.red, 'icon': Icons.warning, 'texto': 'Deuda'};
    case 2:
      return {'color': Colors.green, 'icon': Icons.check_circle, 'texto': 'Pago'};
    case 3:
      return {'color': Colors.amber, 'icon': Icons.trending_up, 'texto': 'Adelanto'};
    case 4:
      return {'color': Colors.blueAccent, 'icon': Icons.add_circle, 'texto': 'Extra'};
    default:
      return {'color': Colors.grey, 'icon': Icons.help_outline, 'texto': 'Otro'};
  }
}

String _getTipoTexto(int tipo) {
  return _getTipoEstilo(tipo)['texto'];
}

// Filtro reusable
Widget _filtroCampo(String label, Function(String) onChanged) {
  return SizedBox(
    width: 180,
    child: TextField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      onChanged: onChanged,
    ),
  );
}

Future<void> _generatePdfWeb(List<MovimientoContable> resultados) async {
  final pdf = pw.Document();

   final provider = Provider.of<ProyectoProvider>(context, listen: false);
      await provider.fetchProyectos();
  final proyecto = provider.proyectos.firstWhere((p) => p.id == widget.idProyecto);
  // Ordenar por fecha ascendente
  resultados.sort((a, b) => DateTime.parse(a.fecha).compareTo(DateTime.parse(b.fecha)));

  // Calcular total y rango de fechas
  double total = resultados.fold(0, (sum, item) => sum + item.monto);
  final inicio = DateTime.parse(resultados.first.fecha);
  final fin = DateTime.parse(resultados.last.fecha);
  final fechaInicio = '${inicio.day}/${inicio.month}/${inicio.year}';
  final fechaFin = '${fin.day}/${fin.month}/${fin.year}';

  // Cargar logo y fuente
  final ByteData logoBytes = await rootBundle.load('assets/images/Logo_RPG.png');
  final Uint8List logo = logoBytes.buffer.asUint8List();
  final roboto = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header con tabla sin bordes
            pw.Table(
              border: null,
              columnWidths: {
                0: pw.FlexColumnWidth(3),
                1: pw.FlexColumnWidth(6),
                2: pw.FlexColumnWidth(1),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Container(
                      height: 70,
                      alignment: pw.Alignment.centerLeft,
                      child: pw.ClipRect(
                        child: pw.Image(pw.MemoryImage(logo), fit: pw.BoxFit.contain),
                      ),
                    ),
                    pw.Container(
  alignment: pw.Alignment.centerLeft,
  padding: pw.EdgeInsets.only(left: 10),
  child: pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        'Grupo RPG S.A.',
        style: pw.TextStyle(font: roboto, fontSize: 26, fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 4),
      pw.Text(
        'R.U.C 155651266-2-2017 D.V. 42',
        style: pw.TextStyle(font: roboto, fontSize: 12, color: PdfColors.grey700),
      ),
      pw.SizedBox(height: 2),
      pw.UrlLink(
        destination: 'mailto:gerenciagruporpg@gmail.com',
        child: pw.Text(
          'gerenciagruporpg@gmail.com',
          style: pw.TextStyle(font: roboto, fontSize: 13, color: PdfColors.blue),
        ),
      ),
      pw.SizedBox(height: 2),
      pw.Text(
        'Tel: 388-7601',
        style: pw.TextStyle(font: roboto, fontSize: 12),
      ),
    ],
  ),
),

                    pw.Container(), // espacio vacío
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            // Proyecto y fechas
            // pw.Text('Proyecto: Torre Central', style: pw.TextStyle(font: roboto)),
            // pw.Text('Ubicación: Ciudad de Panamá', style: pw.TextStyle(font: roboto)),
            pw.Text('Proyecto: ${proyecto.nombre}', style: pw.TextStyle(font: roboto)),
            pw.Text('Ubicación: ${proyecto.ubicacion}', style: pw.TextStyle(font: roboto)),
            pw.Text('Reporte del $fechaInicio al $fechaFin', style: pw.TextStyle(font: roboto)),
            pw.SizedBox(height: 20),

            // Título
            pw.Text('Reporte de Transacciones',
                style: pw.TextStyle(font: roboto, fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),

            // Tabla de movimientos
            pw.Table(
              columnWidths: {
                0: pw.FlexColumnWidth(2),
                1: pw.FlexColumnWidth(2),
                2: pw.FlexColumnWidth(6),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text('Fecha', style: pw.TextStyle(font: roboto))),
                    pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text('Monto', style: pw.TextStyle(font: roboto))),
                    pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text('Descripción', style: pw.TextStyle(font: roboto))),
                  ],
                ),
                ...resultados.map((m) {
                  final fecha = DateTime.parse(m.fecha);
                  final fechaTexto = '${fecha.day}/${fecha.month}/${fecha.year}';
                  return pw.TableRow(
                    children: [
                      pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text(fechaTexto, style: pw.TextStyle(font: roboto))),
                      pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text('\$${m.monto.toStringAsFixed(2)}', style: pw.TextStyle(font: roboto))),
                      pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text(m.comentario ?? '', style: pw.TextStyle(font: roboto))),
                    ],
                  );
                }),
              ],
            ),

            pw.SizedBox(height: 20),

            // Total
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Total: \$${total.toStringAsFixed(2)}',
                style: pw.TextStyle(font: roboto, fontSize: 14),
              ),
            ),
          ],
        );
      },
    ),
  );

  // Descargar
  final Uint8List bytes = await pdf.save();
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", "reporte.pdf")
    ..click();
  html.Url.revokeObjectUrl(url);
}


String obtenerNombre(dynamic m) {
  if (m.idProveedor != null) {
    return proveedoresList
        .firstWhere((x) => x.id == m.idProveedor,
            )
        ?.nombre ?? 'N/A';
  } else if (m.idTrabajador != null) {
    return proveedoresList
        .firstWhere((x) => x.id == m.idTrabajador,
           ) 
        ?.nombre ?? 'N/A';
  } else {
    return 'N/A';
  }
}

void _Reporteria(BuildContext context, List<MovimientoContable> movimientos) {
  // Variables de estado





  String? filtroTipo;
  String filtroDescripcion = '';
  DateTimeRange? rangoFechas;
  Set<int> selectedIds = {};
  bool selectAll = true;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  // Inicialización de datos
  final tipos = movimientos.map((m) => _getTipoTexto(m.tipoMovimiento)).toSet();
  final fechaMin = movimientos.map((m) => DateTime.parse(m.fecha)).reduce((a, b) => a.isBefore(b) ? a : b);
  final fechaMax = movimientos.map((m) => DateTime.parse(m.fecha)).reduce((a, b) => a.isAfter(b) ? a : b);
  rangoFechas ??= DateTimeRange(start: fechaMin, end: fechaMax);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          // Filtrar movimientos
          final resultados = movimientos.where((m) {
            final tipoMatch = filtroTipo == null || _getTipoTexto(m.tipoMovimiento) == filtroTipo;
            final descMatch = filtroDescripcion.isEmpty || 
                (m.comentario?.toLowerCase().contains(filtroDescripcion.toLowerCase()) ?? false);
            
            DateTime fechaMovimiento;
            try {
              fechaMovimiento = DateTime.parse(m.fecha);
            } catch (e) {
              return false;
            }

            final fechaMatch = rangoFechas == null ||
                (fechaMovimiento.isAfter(rangoFechas!.start.subtract(const Duration(days: 1))) &&
                fechaMovimiento.isBefore(rangoFechas!.end.add(const Duration(days: 1))));

            return tipoMatch && descMatch && fechaMatch;
          }).toList();

          // Sincronizar selección
          if (selectAll) {
            selectedIds.addAll(resultados.map((m) => m.id));
          } else if (selectedIds.length == resultados.length) {
            selectAll = true;
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Center(child: Text('Reportería del Proyecto', style: TextStyle(fontWeight: FontWeight.bold))),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Filtros
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      // Filtro por tipo
                      SizedBox(
                        width: 160,
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Tipo',
                            border: OutlineInputBorder(),
                          ),
                          value: filtroTipo,
                          items: [
                            const DropdownMenuItem(value: null, child: Text('Todos')),
                            ...tipos.map((t) => DropdownMenuItem(value: t, child: Text(t)))
                          ],
                          onChanged: (value) => setState(() => filtroTipo = value),
                        ),
                      ),
                      
                      // Buscador de descripción
                      SizedBox(
                        width: 200,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Buscar en descripción',
                            border: const OutlineInputBorder(),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_searchController.text.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => filtroDescripcion = '');
                                    },
                                  ),
                                const Padding(
                                  padding: EdgeInsets.only(right: 8.0),
                                  child: Icon(Icons.search, size: 18),
                                ),
                              ],
                            ),
                          ),
                          onChanged: (value) => setState(() => filtroDescripcion = value),
                        ),
                      ),
                      
                      // Selector de rango de fechas
                      OutlinedButton.icon(
                        icon: const Icon(Icons.date_range),
                        label: const Text('Rango de fechas'),
                        onPressed: () async {
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: fechaMin.subtract(const Duration(days: 365)),
                            lastDate: fechaMax.add(const Duration(days: 365)),
                            initialDateRange: rangoFechas,
                          );
                          if (picked != null) {
                            setState(() => rangoFechas = picked);
                          }
                        },
                      ),
                    ],
                  ),
                  
                  // Controles de selección
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Checkbox(
                          value: selectAll,
                          onChanged: (value) {
                            setState(() {
                              selectAll = value ?? false;
                              selectedIds = selectAll 
                                  ? Set.from(resultados.map((m) => m.id)) 
                                  : {};
                            });
                          },
                        ),
                        Text(selectAll ? 'Deseleccionar todos' : 'Seleccionar todos'),
                        const Spacer(),
                        Text('${selectedIds.length}/${resultados.length} seleccionados'),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.picture_as_pdf, size: 18),
                          label: const Text('Generar PDF'),
                          onPressed: () => _generatePdfWeb(
                            selectAll ? resultados : 
                                resultados.where((m) => selectedIds.contains(m.id)).toList()
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Tabla de resultados
                  SizedBox(
                    height: 400,
                    child: Scrollbar(
                      controller: _scrollController,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 20,
                            columns: const [
                              DataColumn(label: Text('Selección')), // Solo este checkbox
                              DataColumn(label: Text('Fecha')),
                              DataColumn(label: Text('Tipo')),
                              DataColumn(label: Text('Monto'), numeric: true),
                              DataColumn(label: Text('Descripción')),
                              DataColumn(label: Text('Proveedor/Trabajador')),
                            ],
                            rows: resultados.map((m) {
                              final data = _getTipoEstilo(m.tipoMovimiento);
             final proveedorInfo = obtenerNombre(m);

                              
                              return DataRow(
                                selected: selectedIds.contains(m.id),
                                cells: [
                                  DataCell(
                                    Checkbox(
                                      value: selectedIds.contains(m.id),
                                      onChanged: (value) {
                                        setState(() {
                                          if (value ?? false) {
                                            selectedIds.add(m.id);
                                          } else {
                                            selectedIds.remove(m.id);
                                            selectAll = false;
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                  DataCell(Text(_formatoFecha(DateTime.parse(m.fecha)))),
                                  DataCell(Row(
                                    children: [
                                      Icon(data['icon'], color: data['color'], size: 18),
                                      const SizedBox(width: 5),
                                      Text(data['texto']),
                                    ],
                                  )),
                                  DataCell(Text('\$${m.monto.toStringAsFixed(2)}')),
                                  DataCell(Text(m.comentario ?? '')),
                                  DataCell(Text(proveedorInfo)),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          );
        },
      );
    },
  );
}
  void _mostrarModalAdelantos() {
    final _montoCtrl = TextEditingController();
    final _detalleCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          void eliminarAdelanto(int index) {
            setModalState(() {
              totalAdelantos -= listaAdelantos[index]['monto'];
              listaAdelantos.removeAt(index);
            });
            setState(() {
              _advancesCtrl.text = totalAdelantos.toStringAsFixed(2);
            });
          }

          void agregarAdelanto() {
            final monto = double.tryParse(_montoCtrl.text);
            final detalle = _detalleCtrl.text.trim();
            if (monto == null || monto <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Ingrese un monto válido.")),
              );
              return;
            }
            if (detalle.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Ingrese un detalle.")),
              );
              return;
            }
            setModalState(() {
              listaAdelantos.add({'monto': monto, 'detalle': detalle});
              totalAdelantos += monto;
            });
            setState(() {
              _advancesCtrl.text = totalAdelantos.toStringAsFixed(2);
            });
            _montoCtrl.clear();
            _detalleCtrl.clear();
          }

          return AlertDialog(
            title: const Text("Adelantos del Cliente"),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (listaAdelantos.isEmpty)
                    const Text("No hay adelantos registrados.")
                  else
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: listaAdelantos.length,
                        itemBuilder: (context, index) {
                          final item = listaAdelantos[index];
                          return ListTile(
                            title: Text(
                                "Monto: \$${item['monto'].toStringAsFixed(2)}"),
                            subtitle: Text("Detalle: ${item['detalle']}"),
                            trailing: IconButton(
                              icon:
                                  const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => eliminarAdelanto(index),
                            ),
                          );
                        },
                      ),
                    ),
                  const Divider(),
                  TextField(
                    controller: _montoCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: "Monto",
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                  ),
                  TextField(
                    controller: _detalleCtrl,
                    decoration: const InputDecoration(
                      labelText: "Detalle",
                      prefixIcon: Icon(Icons.description),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cerrar")),
              ElevatedButton(
                  onPressed: agregarAdelanto, child: const Text("Agregar")),
            ],
          );
        });
      },
    );
  }




Widget _comentariosFlotantes(BuildContext context, int idProyecto) {
  final _nuevoComentarioCtrl = TextEditingController();
  final _asuntoComentarioCtrl = TextEditingController();
  final _comentariosExpandidos = <int, bool>{};
  final _comentariosEditando = <int, bool>{};
  final _editandoComentarioCtrl = TextEditingController();

  void _mostrarDialogo(BuildContext context) {
    final provider = Provider.of<ComentarioProvider>(context, listen: false);
    provider.cargarComentarios(idProyecto);
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Consumer<ComentarioProvider>(
              builder: (context, provider, child) {
                return Dialog(
                  insetPadding: EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                      maxHeight: MediaQuery.of(context).size.height * 0.8,
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Comentarios del Proyecto',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        Divider(height: 20),
                        
                        if (provider.cargando)
                          Center(child: CircularProgressIndicator())
                        else if (provider.error != null)
                          Text(provider.error!, style: TextStyle(color: Colors.red))
                        else
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: provider.comentarios.map((comentario) {
                                  final isExpanded = _comentariosExpandidos[comentario.idComentario] ?? false;
                                  final isEditando = _comentariosEditando[comentario.idComentario] ?? false;
                                  
                                  return Card(
                                    margin: EdgeInsets.only(bottom: 12),
                                    elevation: 2,
                                    child: Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Header del comentario
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  comentario.asunto,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  if (!isEditando) ...[
                                                    IconButton(
                                                      icon: Icon(Icons.edit, size: 20),
                                                      onPressed: () {
                                                        _editandoComentarioCtrl.text = comentario.comentario;
                                                        setState(() {
                                                          _comentariosEditando[comentario.idComentario] = true;
                                                        });
                                                      },
                                                    ),
                                                    IconButton(
                                                      icon: Icon(Icons.delete, size: 20, color: Colors.red),
                                                      onPressed: () async {
                                                        final confirm = await showDialog(
                                                          context: context,
                                                          builder: (ctx) => AlertDialog(
                                                            title: Text('Eliminar comentario'),
                                                            content: Text('¿Estás seguro de eliminar este comentario?'),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () => Navigator.pop(ctx, false),
                                                                child: Text('Cancelar'),
                                                              ),
                                                              TextButton(
                                                                onPressed: () => Navigator.pop(ctx, true),
                                                                child: Text('Eliminar', style: TextStyle(color: Colors.red)),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                        
                                                        if (confirm == true) {
                                                          await provider.eliminarComentario(comentario.idComentario, idProyecto);
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(content: Text('Comentario eliminado')),
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  ] else ...[
                                                    IconButton(
                                                      icon: Icon(Icons.check, size: 20, color: Colors.green),
                                                      onPressed: () async {
                                                        await provider.actualizarComentario(
                                                          Comentario(
                                                            idComentario: comentario.idComentario,
                                                            asunto: comentario.asunto,
                                                            comentario: _editandoComentarioCtrl.text,
                                                            idProyecto: idProyecto,
                                                            fechaComentario: comentario.fechaComentario,
                                                          ),
                                                        );
                                                        setState(() {
                                                          _comentariosEditando.remove(comentario.idComentario);
                                                        });
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(content: Text('Comentario actualizado')),
                                                        );
                                                      },
                                                    ),
                                                    IconButton(
                                                      icon: Icon(Icons.close, size: 20),
                                                      onPressed: () {
                                                        setState(() {
                                                          _comentariosEditando.remove(comentario.idComentario);
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                  IconButton(
                                                    icon: Icon(
                                                      isExpanded ? Icons.expand_less : Icons.expand_more,
                                                      size: 20,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        _comentariosExpandidos[comentario.idComentario] = !isExpanded;
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          
                                          // Fecha y usuario
                                          Padding(
                                            padding: EdgeInsets.only(top: 4),
                                            child: Text(
                                              '${DateFormat('dd/MM/yyyy HH:mm').format(comentario.fechaComentario)} ',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                          
                                          // Contenido del comentario
                                          if (isExpanded) ...[
                                            SizedBox(height: 10),
                                            Divider(height: 1),
                                            SizedBox(height: 10),
                                            isEditando
                                                ? TextField(
                                                    controller: _editandoComentarioCtrl,
                                                    maxLines: 4,
                                                    decoration: InputDecoration(
                                                      border: OutlineInputBorder(),
                                                      contentPadding: EdgeInsets.all(8),
                                                    ),
                                                  )
                                                : Text(
                                                    comentario.comentario,
                                                    style: TextStyle(fontSize: 14),
                                                  ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        
                        SizedBox(height: 16),
                        
                        // Formulario para nuevo comentario
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Agregar Comentario',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            TextField(
                              controller: _asuntoComentarioCtrl,
                              decoration: InputDecoration(
                                labelText: 'Asunto',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 8),
                            TextField(
                              controller: _nuevoComentarioCtrl,
                              maxLines: 4,
                              decoration: InputDecoration(
                                labelText: 'Comentario',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () async {
                                if (_asuntoComentarioCtrl.text.trim().isEmpty || 
                                    _nuevoComentarioCtrl.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Por favor completa todos los campos')),
                                  );
                                  return;
                                }
                                
                                final nuevoComentario = Comentario(
                                  idComentario: 0,
                                  asunto: _asuntoComentarioCtrl.text,
                                  comentario: _nuevoComentarioCtrl.text,
                                  idProyecto: idProyecto,
                                  fechaComentario: DateTime.now(),
                                );
                                
                                final success = await provider.agregarComentario(nuevoComentario);
                                if (success) {
                                  _asuntoComentarioCtrl.clear();
                                  _nuevoComentarioCtrl.clear();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Comentario agregado')),
                                  );
                                }
                              },
                              child: Text('Guardar Comentario'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, 50),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  return FloatingActionButton(
    onPressed: () => _mostrarDialogo(context),
    tooltip: 'Comentarios',
    child: Icon(Icons.comment),
    backgroundColor: Colors.blue,
  );
}


  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
         
          Flexible(flex:3,
            child: Row(
              children: [
                Flexible(flex:20,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(flex:1,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: widget.imageUrl.isNotEmpty
                              ? NetworkImage(widget.imageUrl)
                              : const AssetImage("assets/images/placeholder_project.jpg")
                                  as ImageProvider,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                        Flexible(flex:6,
                    
                          child: Column(
                            children: [
                              // Primera fila: Nombre, Cliente, Tipo
                              Row(
                                children: [
                                  _field("Nombre del Proyecto", Icons.title, _projectNameCtrl),
                                  const SizedBox(width: 12),
                                  _field("Cliente", Icons.person, _clientCtrl),
                                _field("Telefono", Icons.phone, _prhoneCtrl),
                              _field("Cedula", Icons.badge_outlined, _cedulaCtrl),
                            
                                ],
                              ),
                              // Segunda fila: Ubicación, Fechas
                              Row(
                                children: [
                                  _field("Ubicación", Icons.location_on, _locationCtrl),
                                  const SizedBox(width: 12),
                                                 _field("Ruc", Icons.badge_outlined, _comentariosController),
                                                                     const SizedBox(width: 12),
                                  _field("Fecha Inicio", Icons.date_range, _startDateCtrl),
                                  const SizedBox(width: 12),
                                  _field("Fecha Fin", Icons.event, _endDateCtrl),
                      
                                    // _field("Licencia", Icons.drive_eta_outlined, _licenciaCtrl),
                            
                                ],
                              ),
                            
                            ],
                          ),
                        
                      ), 
   FilledButton.tonalIcon(
  onPressed: _toggleEditing,
  icon: Icon(
    _isEditing ? Icons.save : Icons.edit,
    size: 20,
  ),
  label: Text(_isEditing ? 'Guardar' : 'Editar'),
  style: FilledButton.styleFrom(
    backgroundColor: _isEditing ? Colors.green : Colors.blue,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
)         
                    ],
                  ),
                ),
  Flexible(
  flex: 2,
  child: Container(
    width: double.infinity,
    height: double.infinity,
    alignment: Alignment.center,
    child: Column(
      children: [ _comentariosFlotantes(context,widget.idProyecto),  SizedBox(height: 5),  
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 5, vertical:6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          icon: Icon(Icons.receipt_long), // ícono representando reporte
          label: Text("Reporteria"),
         
            onPressed: () {
            final provider = Provider.of<ProveedorMovimientoProvider>(context, listen: false);
            final allMovimientos = provider.movimientosPorUsuario.expand((u) => u.movimientos).toList();
            _Reporteria(context, allMovimientos);
          },
         
         
          // Llama al showDialog
        ),
      ],
    ),
  ),
)

              ],
            ),
          ),



                    Flexible(flex:3,child: Container(width: double.infinity,height: double.infinity,
                    child:      
                          _adelantosField(),
                    
                    
                    ))
        ],
      
    );
  }
}
    





// void mostrarEditorComentario(BuildContext context, TextEditingController controller) {
//   final _editingController = TextEditingController(text: controller.text);

//   showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: Text('Comentarios del Proyecto'),
//         content: SizedBox(
//                   width: MediaQuery.of(context).size.width * 0.4,  // 50% de ancho
//           height: MediaQuery.of(context).size.height * 0.2, // 60% de alto
          
//           child: TextField(
//             controller: _editingController,
//             maxLines: null,
//             expands: true,
//             keyboardType: TextInputType.multiline,
//             decoration: InputDecoration(
//               border: OutlineInputBorder(),
//               hintText: 'Escribe tu comentario aquí...',
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancelar'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               controller.text = _editingController.text;
//               Navigator.pop(context);
//             },
//             child: Text('Guardar'),
//           ),
//         ],
//       );
//     },
//   );
// }

// Widget comentarioFlotante(BuildContext context, TextEditingController controller) {
//   return FloatingActionButton(
//     onPressed: () => mostrarEditorComentario(context, controller),
//     tooltip: 'Editar comentario',
//     child: Icon(Icons.edit_note,size: 20,),
//   );
// }


// void mostrarEditorComentario(BuildContext context, TextEditingController controller, int idProyecto) {
//   final _editingController = TextEditingController(text: controller.text);
//   bool _guardando = false;

//   showDialog(
//     context: context,
//     builder: (context) {
//       return StatefulBuilder(
//         builder: (context, setState) {
//           return Dialog(
//             child: Container(
//               width: MediaQuery.of(context).size.width * 0.5,
//               height: MediaQuery.of(context).size.height * 0.6,
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'Comentario del Proyecto',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   Expanded(
//                     child: TextField(
//                       controller: _editingController,
//                       maxLines: null,
//                       expands: true,
//                       decoration: InputDecoration(
//                         border: OutlineInputBorder(),
//                         hintText: 'Escribe tu comentario aquí...',
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       TextButton(
//                         onPressed: _guardando ? null : () => Navigator.pop(context),
//                         child: Text('Cancelar'),
//                       ),
//                       SizedBox(width: 8),
//                       ElevatedButton(
//                         onPressed: _guardando ? null : () async {
//                           setState(() => _guardando = true);
//                           try {
//                             final provider = Provider.of<ProveedorMovimientoProvider>(context, listen: false);
//                             await provider.actualizarComentarioProyecto(idProyecto, _editingController.text);
                       
//                             controller.text = _editingController.text;
//                             Navigator.pop(context);
                            
//                             // Mostrar SnackBar de confirmación
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text('Comentario guardado exitosamente'),
//                                 duration: Duration(seconds: 2),
//                                 behavior: SnackBarBehavior.floating,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                               ),
//                             );


//                           } catch (e) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(content: Text('Error al guardar: $e')),
//                             );
//                             setState(() => _guardando = false);
//                           }
//                         },
//                         child: _guardando 
//                             ? CircularProgressIndicator()
//                             : Text('Guardar'),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       );
//     },
//   );
// }

// Widget comentarioFlotante(BuildContext context, TextEditingController controller, int idProyecto) {
//   return FloatingActionButton(
//     onPressed: () => mostrarEditorComentario(context, controller, idProyecto),
//     tooltip: 'Editar comentario',
//     child: Icon(Icons.edit_note),
//   );
// }


// Future<void> _generatePdfWeb(List<MovimientoContable> resultados) async {
//   final pdf = pw.Document();
// Logo_RPG.png
//   pdf.addPage(
//     pw.Page(
//       build: (context) {
//         return pw.Column(
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             pw.Text('Reporte de Transacciones', style: pw.TextStyle(fontSize: 20)),
//             pw.SizedBox(height: 20),
//             pw.Table.fromTextArray(
//               headers: ['Fecha', 'Tipo', 'Monto', 'Descripción'],
//    data: resultados.map((m) => [
//   (m.fecha is DateTime) ? DateFormat('dd/MM/yyyy').format(DateTime.parse(m.fecha)) : (m.fecha is String ? DateFormat('dd/MM/yyyy').format(DateTime.parse(m.fecha)) : ''),
//   _getTipoTexto(m.tipoMovimiento),
//   m.monto.toStringAsFixed(2),
//   m.comentario ?? '',
// ]).toList(),

//             ),
//           ],
//         );
//       },
//     ),
//   );

//   final Uint8List bytes = await pdf.save();

//   final blob = html.Blob([bytes]);
//   final url = html.Url.createObjectUrlFromBlob(blob);
//   final anchor = html.AnchorElement(href: url)
//     ..setAttribute("download", "reporte.pdf")
//     ..click();
//   html.Url.revokeObjectUrl(url);
// }

// void _Reporteria(BuildContext context, List<MovimientoContable> movimientos) {
//   List<MovimientoContable> movimientosFiltrados = List.from(movimientos);


//   Set<String> tipos = movimientos
//       .map((m) => _getTipoTexto(m.tipoMovimiento))
//       .toSet();

//   Set<String> descripciones = movimientos
//       .map((m) => m.comentario ?? '')
//       .toSet();

//  DateTime fechaMin = movimientos
//     .map((m) => DateTime.parse(m.fecha))
//     .reduce((a, b) => a.isBefore(b) ? a : b);

// DateTime fechaMax = movimientos
//     .map((m) => DateTime.parse(m.fecha))
//     .reduce((a, b) => a.isAfter(b) ? a : b);

//   String? filtroTipo;
//   String? filtroDescripcion;
//   DateTimeRange? rangoFechas = DateTimeRange(start: fechaMin, end: fechaMax);

//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
// return StatefulBuilder(
//   builder: (context, setState) {
//     List<MovimientoContable> resultados = movimientos.where((m) {
//       final tipoMatch = filtroTipo == null || _getTipoTexto(m.tipoMovimiento) == filtroTipo;
//       final descMatch = filtroDescripcion == null || m.comentario == filtroDescripcion;

//       // Parsear m.fecha que es String a DateTime
//       DateTime? fechaMovimiento;
//       try {
//         fechaMovimiento = DateTime.parse(m.fecha);
//       } catch (e) {
//         return false; // Si la fecha es inválida, se excluye
//       }

//       final fechaMatch = rangoFechas == null ||
//           (fechaMovimiento.isAfter(rangoFechas!.start.subtract(Duration(days: 1))) &&
//            fechaMovimiento.isBefore(rangoFechas!.end.add(Duration(days: 1))));

//       return tipoMatch && descMatch && fechaMatch;
//     }).toList();


//           return AlertDialog(
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//             title: Center(
//               child: Text('Reportería del Proyecto',
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//             ),
//             content: SizedBox(
//               width: double.maxFinite,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Filtros
//                   Wrap(
//                     spacing: 10,
//                     runSpacing: 10,
//                     children: [
//                       SizedBox(
//                         width: 160,
//                         child: DropdownButtonFormField<String>(
//                           decoration: InputDecoration(
//                             labelText: 'Tipo',
//                             border: OutlineInputBorder(),
//                           ),
//                           isExpanded: true,
//                           value: filtroTipo,
//                           items: [
//                             DropdownMenuItem(value: null, child: Text('Todos')),
//                             ...tipos.map((t) => DropdownMenuItem(value: t, child: Text(t)))
//                           ],
//                           onChanged: (value) => setState(() => filtroTipo = value),
//                         ),
//                       ),
//                       SizedBox(
//                         width: 160,
//                         child: DropdownButtonFormField<String>(
//                           decoration: InputDecoration(
//                             labelText: 'Descripción',
//                             border: OutlineInputBorder(),
//                           ),
//                           isExpanded: true,
//                           value: filtroDescripcion,
//                           items: [
//                             DropdownMenuItem(value: null, child: Text('Todas')),
//                             ...descripciones.map((d) => DropdownMenuItem(value: d, child: Text(d)))
//                           ],
//                           onChanged: (value) => setState(() => filtroDescripcion = value),
//                         ),
//                       ),
//                       OutlinedButton.icon(
//                         icon: Icon(Icons.date_range),
//                         label: Text('Rango de Fechas'),
//                         onPressed: () async {
//                           final picked = await showDateRangePicker(
//                             context: context,
//                             firstDate: fechaMin.subtract(Duration(days: 30)),
//                             lastDate: fechaMax.add(Duration(days: 30)),
//                             initialDateRange: rangoFechas,
//                           );
//                           if (picked != null) {
//                             setState(() => rangoFechas = picked);
//                           }
//                         },
//                       ),

// ElevatedButton.icon(
//   onPressed: () async {
//     // Usa la lista filtrada si hay datos, si no usa todos los movimientos
//     final listaParaReporte = resultados.isNotEmpty ? resultados : movimientos;

//     await _generatePdfWeb(listaParaReporte);
//   },
//   icon: Icon(Icons.picture_as_pdf),
//   label: Text("Generar PDF"),
// ),
           
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                   Divider(),
//                   const SizedBox(height: 5),
//                   // Tabla con scroll limitado en altura
//            SizedBox(
//   height: 400,
//   child: Scrollbar(
//     controller: _scrollController, // controlador vertical
//     thumbVisibility: true,
//     child: SingleChildScrollView(
//       controller: _scrollController, // <- asigna aquí también el controlador vertical
//       scrollDirection: Axis.vertical,
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: DataTable(
//           columnSpacing: 20,
//           columns: const [
//             DataColumn(label: Text('Fecha')),
//             DataColumn(label: Text('Tipo')),
//             DataColumn(label: Text('Monto')),
//             DataColumn(label: Text('Descripción')),
//           ],
//           rows: resultados.map((m) {
//             final data = _getTipoEstilo(m.tipoMovimiento);
//             return DataRow(
//               cells: [
//                 DataCell(Text(_formatoFecha(DateTime.parse(m.fecha)))),
//                 DataCell(Row(
//                   children: [
//                     Icon(data['icon'], color: data['color'], size: 18),
//                     SizedBox(width: 5),
//                     Text(data['texto']),
//                   ],
//                 )),
//                 DataCell(Text('\$${m.monto.toStringAsFixed(2)}')),
//                 DataCell(Text(m.comentario ?? '')),
//               ],
//             );
//           }).toList(),
//         ),
//       ),
//     ),
//   ),
// )



//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: Text('Cerrar'),
//               ),
//             ],
//           );
//         },
//       );
//     },
//   );
// }
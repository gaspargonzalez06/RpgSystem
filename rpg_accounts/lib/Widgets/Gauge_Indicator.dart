import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rpg_accounts/Models/MovimientosContablesProyecto.dart';
import 'package:rpg_accounts/Models/ProyectosModel.dart';
import 'package:rpg_accounts/Provider/MovimientosProvider.dart';
import 'package:rpg_accounts/Provider/ProyectosProvider.dart';
import 'package:rpg_accounts/Views/Proyectos.dart';
import 'package:rpg_accounts/Widgets/Utils.dart';

class MultiBarVerticalGauge extends StatefulWidget {
  final int idProyecto;

  const MultiBarVerticalGauge({super.key, required this.idProyecto});

  @override
  State<MultiBarVerticalGauge> createState() => _MultiBarVerticalGaugeState();
}
class _MultiBarVerticalGaugeState extends State<MultiBarVerticalGauge> {
  late Proyecto project;
  String estadoProyecto = 'Activo';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProject();
  }

Future<void> _loadProject() async {
  setState(() {
    _isLoading = true;

  });

  final projectProvider = Provider.of<ProyectoProvider>(context, listen: false);

  // 🔴 Espera a que termine la carga antes de buscar el proyecto
  await projectProvider.fetchProyectos();

  // ✅ Ahora los datos están actualizados
  final Proyecto foundProject = projectProvider.getProjectById(widget.idProyecto);

  setState(() {
    project = foundProject;
    estadoProyecto = foundProject.estado;
    _isLoading = false;
  });
}


  void _abrirDialogoAdelanto() {
    double monto = 0;
    String comentario = '';
    final TextEditingController montoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Row(
              children: const [
                Icon(Icons.attach_money, color: Colors.orange),
                SizedBox(width: 10),
                Text('Agregar Adelanto'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
            TextFormField(
  controller: montoController,
  keyboardType: TextInputType.numberWithOptions(decimal: true), // Teclado con decimales
  inputFormatters: [
    MoneyInputFormatter(
      allowDecimal: true, // Permite decimales
      currencySymbol: '\$', // Símbolo de moneda
    ),
  ],
  decoration: InputDecoration(
    labelText: '💰 Monto',
    hintText: 'Ej: 1,250.50', // Muestra ejemplo de formato
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    prefixIcon: const Icon(Icons.monetization_on),
    prefixText: '\$ ', // Símbolo fijo
  ),
  onChanged: (value) {
    // Convierte el texto formateado a número
    monto = MoneyInputFormatter.parseFormattedMoney(value);
  },
),
                  const SizedBox(height: 12),
                  TextFormField(
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: '📝 Comentario',
                      hintText: 'Motivo del adelanto',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.comment),
                    ),
                    onChanged: (val) => comentario = val,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (monto <= 0) return;

                  final provider = Provider.of<ProveedorMovimientoProvider>(context, listen: false);

                  try {
                    await provider.agregarMovimientoContable(
                      idCliente: project.clienteId,
                      idServicio: 1,
                      idTipoMovimiento: 3,
                      monto: monto,
                      esPagoDirecto:false ,
                      comentario: comentario,
                      idProyecto: project.id,
                      idAdmin: 1,
                    );

                    Navigator.pop(context);
                    _loadProject(); // recarga automáticamente

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Adelanto guardado exitosamente'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ Error al guardar adelanto: $e'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }

final Map<String, Color> coloresEstado = {
  'Activo': Colors.green,
  //'Suspendido': Colors.amber,
  'Cancelado': Colors.red,
  'Terminado': Colors.blueGrey, // ✅ Nuevo estado
};

final Map<String, IconData> iconosEstado = {
  'Activo': Icons.check_circle,
  //'Suspendido': Icons.pause_circle_filled,
  'Cancelado': Icons.cancel,
  'Terminado': Icons.flag, // ✅ Nuevo icono para "Terminado"
};


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final double presupuesto = project.presupuesto;
    final double gastos = project.gastos;
    final double adelantos = project.adelantos;
    final double ganancia = presupuesto - gastos;
    final double rentabilidad = adelantos - gastos;
    final double porCobrar = presupuesto - adelantos;
    return Padding(
      padding: const EdgeInsets.all(8.0), 
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: _buildResumenCard('Presupuesto', presupuesto, Colors.blue, Icons.account_balance_wallet,context)),
          Expanded(child: _buildResumenCard('Gastos', gastos, Colors.red, Icons.trending_down,context)),
          Expanded(child: _buildResumenCard('Adelantos', adelantos, Colors.orange, Icons.payments,context)),


          Expanded(child: _buildGananciasCard(ganancia,presupuesto, context)),

            Expanded(child: _buildResumenCard('Rentabilidad', rentabilidad, Colors.purple, Icons.show_chart,context)),
          Expanded(child: _buildResumenCard('Por Cobrar', porCobrar, Colors.teal, Icons.credit_card, context),),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: coloresEstado[estadoProyecto],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconosEstado[estadoProyecto],
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                DropdownButton<String>(
                  value: estadoProyecto,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  items: coloresEstado.keys.map((String estado) {
                    return DropdownMenuItem<String>(
                      value: estado,
                      child: Text(estado),
                    );
                  }).toList(),
                  onChanged: (String? nuevoEstado) async {
                    if (nuevoEstado != null && nuevoEstado != estadoProyecto) {
                      final proyectoProvider = Provider.of<ProyectoProvider>(context, listen: false);

                      try {
                        await proyectoProvider.modificarEstadoProyecto(project.id, nuevoEstado);

                        setState(() {
                          estadoProyecto = nuevoEstado;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('✅ Estado actualizado a $nuevoEstado')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('❌ Error al cambiar el estado')),
                        );
                      }
                    }
                  },
                ),
                // const SizedBox(width: 15),
                // IconButton(
                //   icon: const Icon(Icons.add_circle, size: 35, color: Colors.orange),
                //   tooltip: 'Agregar Adelanto',
                //   onPressed: _abrirDialogoAdelanto,
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildGananciasCard(double ganancias, double presupuesto, BuildContext context) {
  // Calcular el porcentaje de ganancias
  final double porcentaje = presupuesto > 0 ? (ganancias / presupuesto) * 100 : 0;
  final Color color = ganancias >= 0 ? Colors.green : Colors.red;
  
  return SizedBox(
    child: Card(
      elevation: 7,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.trending_up, color: color, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Ganancias',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
         
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    NumberFormatter.formatCurrency(ganancias),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                Text(
                  '${porcentaje.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
Future<List<MovimientoContable>> obtenerExtras(BuildContext context, Proyecto project) async {
  // Usamos el contexto de la página (siempre válido)
  final provider = Provider.of<ProveedorMovimientoProvider>(context, listen: false);
  await provider.fetchMovimientos(project.id);

  // Procesamos y retornamos solo las extras
  final todos = provider.movimientosPorUsuario
      .expand<MovimientoContable>((u) => u.movimientos)
      .toList();

  return todos.where((mov) => mov.tipoMovimiento == 4).toList();
}

Future<List<MovimientoContable>> obtenerAdelantos(BuildContext context, Proyecto project) async {
  // Usamos el contexto de la página (siempre válido)
  final provider = Provider.of<ProveedorMovimientoProvider>(context, listen: false);
  await provider.fetchMovimientos(project.id);

  // Procesamos y retornamos solo las extras
  final todos = provider.movimientosPorUsuario
      .expand<MovimientoContable>((u) => u.movimientos)
      .toList();

  return todos.where((mov) => mov.tipoMovimiento == 3).toList();
}

Widget _buildResumenCard(String titulo, double valor, Color color, IconData icono, BuildContext context) {
  return SizedBox(
  
    child: Card(
      elevation: 7,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icono, color: color, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (titulo == 'Presupuesto') ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                 IconButton(
  icon: const Icon(Icons.add_circle_outline, color: Colors.green),
  iconSize: 18,
  padding: EdgeInsets.zero,
  constraints: const BoxConstraints(),
  tooltip: 'Agregar extra',
  onPressed: () {
    abrirDialogoExtraPresupuesto(context, project); // ← Solo llama la función aquí
  },
),

                      SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.info_outline, color: Colors.blue),
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Ver detalles',
                         onPressed: () async {
// 1) Obtén el provider y asegúrate de haber cargado los movimientos:
// final provider = Provider.of<ProveedorMovimientoProvider>(context, listen: false);
//  provider.fetchMovimientos(project.id);

// // 2) Aplana la lista de MovimientosPorUsuario → MovimientoContable
// final todos = provider.movimientosPorUsuario
//     .expand<MovimientoContable>((u) => u.movimientos)
//     .toList();


// final extras = todos.where((mov) => mov.tipoMovimiento == 4).toList();


    final extras = await obtenerExtras(context, project);

  showDialog(
    context: context,
  builder: (_) => detallesPresupuestoModal(context, extras),
);

                      },
                      ),
                    ],
                  )
                ]
else if (titulo == 'Adelantos') ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Agregar adelanto',
                        onPressed: () {
                          _abrirDialogoAdelanto();
                          // Lógica para agregar nuevo adelanto
                        },
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.info_outline, color: Colors.blue),
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Ver detalles',
                        onPressed: () async{
                 
                          // final provider = Provider.of<ProveedorMovimientoProvider>(context, listen: false);
                          // final todos = provider.movimientosPorUsuario
                          //     .expand<MovimientoContable>((u) => u.movimientos)
                          //     .toList();


                          // final adelantos = todos.where((mov) => mov.tipoMovimiento == 3).toList(); // Suponiendo que 3 es el tipo para adelantos

                              final adelantos = await obtenerAdelantos(context, project);   



                          showDialog(
                            context: context,
                            builder: (_) => detallesAdelantosModal(context, adelantos),
                          );
                        },
                      ),
                    ],
                  )
                ]
              ],
            ),
            const Spacer(),
        Text(
  NumberFormatter.formatCurrency(valor), // Usando el formateador
  style: TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: color,
  ),
),
          ],
        ),
      ),
    ),
  );
}


Widget detallesAdelantosModal(
  BuildContext context,
  List<MovimientoContable> adelantos,
) {




    adelantos.sort((a, b) => DateTime.parse(b.fecha).compareTo(DateTime.parse(a.fecha)));
  
  // Controladores para la edición
  final List<TextEditingController> _montoControllers = [];
  final List<TextEditingController> _comentarioControllers = [];
  final List<bool> _isEditingList = List.generate(adelantos.length, (_) => false);

  // Inicializar controladores
  for (var adelanto in adelantos) {
    _montoControllers.add(TextEditingController(text: adelanto.monto.toString()));
    _comentarioControllers.add(TextEditingController(text: adelanto.comentario));
  }

  return StatefulBuilder(
    builder: (context, setState) {
      return AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.account_balance_wallet, color: Colors.orange),
            SizedBox(width: 10),
            Text('Detalles de Adelantos'),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 20,
                    columns: const [
                      DataColumn(label: Text('Monto', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Comentario', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: List<DataRow>.generate(adelantos.length, (index) {
                      final mov = adelantos[index];
                      final isEditing = _isEditingList[index];
                      
                      return DataRow(
                        cells: [
                          DataCell(
                            isEditing
                              ? SizedBox(
                                  width: 150,
                                  child: 
                                        _buildBudgetField(_montoControllers[index])
                                  // TextField(
                                  //   controller: _montoControllers[index],
                                  //   keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  //   decoration: const InputDecoration(
                                  //     border: OutlineInputBorder(),
                                  //     contentPadding: EdgeInsets.all(8),
                                  //   ),
                                  // ),
                                )
                              :Text('\$${NumberFormatter.format(mov.monto)}'),
                          ),
                          DataCell(
                            isEditing
                              ? SizedBox(
                                  width: 200,
                                  child: TextField(
                                    controller: _comentarioControllers[index],
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.all(8),
                                    ),
                                  ),
                                )
                              : Text(mov.comentario),
                          ),
                          DataCell(
                            Text(DateFormat('d MMMM yyyy').format(DateTime.parse(mov.fecha))),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isEditing ? Icons.save : Icons.edit,
                                    color: isEditing ? Colors.green : Colors.blue,
                                    size: 20,
                                  ),
                                  onPressed: () async {
                                    if (isEditing) {
                                      try {
                                        // Lógica para guardar los cambios
                                      // final nuevoMonto = double.tryParse(_montoControllers[index].text) ?? mov.monto
                                     final nuevoMonto = double.tryParse(
  _montoControllers[index].text
    .replaceAll('\$', '')  // Elimina símbolo de moneda
    .replaceAll(',', '')   // Elimina comas (separadores de miles)
    .trim()
) ?? mov.monto;
                      
                                        final nuevoComentario = _comentarioControllers[index].text;
                                        
                                        // Aquí llamarías a tu provider para actualizar en el servidor
                                        await Provider.of<ProveedorMovimientoProvider>(context, listen: false)
                                          .editarMovimientoContable(
                                            idMovimiento: mov.id,
                                          
                                            monto: nuevoMonto,
                                            comentario: nuevoComentario,
                                          );

final provider = Provider.of<ProveedorMovimientoProvider>(context, listen: false);
 provider.fetchMovimientos(project.id);

  setState(() {
                                         
                                          _isEditingList[index] = false;
                                        });
 Navigator.pop(context);
                    _loadProject(); // recarga automáticamente


                                      

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Adelanto actualizado correctamente'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Error al actualizar: ${e.toString()}'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    } else {
                                      setState(() {
                                        _isEditingList[index] = true;
                                      });
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                  onPressed: () async {
                                    final confirmado = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Confirmar eliminación'),
                                        content: const Text('¿Estás seguro de eliminar este adelanto?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: (){
                                      
                                              Navigator.pop(context, true);
                                                       _loadProject();
                                            },
                                            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirmado == true) {
                                      try {
                                        // Lógica para eliminar el adelanto
                                        await Provider.of<ProveedorMovimientoProvider>(context, listen: false)
                                          .eliminarMovimientoContable(idMovimiento: mov.id);




                                        setState(() {
                                          adelantos.removeAt(index);
                                          _montoControllers.removeAt(index);
                                          _comentarioControllers.removeAt(index);
                                          _isEditingList.removeAt(index);
                                        });

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Adelanto eliminado correctamente'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Error al eliminar: ${e.toString()}'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cerrar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
}

// Widget detallesPresupuestoModal(
//   BuildContext context,
//   List<MovimientoContable> extras,
// ) {
//   final double totalExtras = extras.fold(0.0, (sum, mov) => sum + mov.monto);
//   final double presupuestoInicial = project.presupuesto - totalExtras;
//   final DateFormat formatoFecha = DateFormat('d MMMM yyyy'); // Ej: 7 julio 2025

//   return AlertDialog(
//     title: const Text('Detalles del Presupuesto'),
//     content: ConstrainedBox(
//       constraints: const BoxConstraints(
//         maxWidth: 600, // Más ancho que antes
//       ),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.vertical,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Presupuesto inicial
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Padding(
//                 padding: const EdgeInsets.only(bottom: 12),
//                 child: Text(
//                   'Presupuesto Inicial: \$${presupuestoInicial.toStringAsFixed(2)}',
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Colors.blueAccent,
//                   ),
//                 ),
//               ),
//             ),

//             // Tabla de extras
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: DataTable(
//                 columns: const [
//                   DataColumn(label: Text('Monto')),
//                   DataColumn(label: Text('Comentario')),
//                   DataColumn(label: Text('Fecha')),
//                 ],
//                 rows: extras.map((mov) {
//                   return DataRow(cells: [
//                     DataCell(Text('\$${mov.monto.toStringAsFixed(2)}')),
//                     DataCell(Text(mov.comentario)),
// DataCell(Text(formatoFecha.format(DateTime.parse(mov.fecha)))),

//                   ]);
//                 }).toList(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//     actions: [
//       TextButton(
//         child: const Text('Cerrar'),
//         onPressed: () => Navigator.of(context).pop(),
//       ),
//     ],
//   );
// }

Widget _buildBudgetField(TextEditingController controller) {
  return SizedBox(
    width: 300,
    child: TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        MoneyInputFormatter(
          allowDecimal: true,
          currencySymbol: '\$',
        ),
      ],
      decoration: InputDecoration(
        labelText: '💰 Presupuesto',
        hintText: 'Ej: 1,250.50',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.monetization_on),
        contentPadding: const EdgeInsets.all(12),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ingrese el presupuesto';
        }
        final amount = MoneyInputFormatter.parseFormattedMoney(value);
        if (amount <= 0) {
          return 'El monto debe ser mayor a cero';
        }
        return null;
      },
      onChanged: (value) {
        final budgetAmount = MoneyInputFormatter.parseFormattedMoney(value);
        debugPrint('Presupuesto actualizado: $budgetAmount');
        // Aquí actualiza el valor en tu estado/bloc/modelo
      },
    ),
  );
}

Widget detallesPresupuestoModal(
  BuildContext context,
  List<MovimientoContable> extras,
) {

  
  // Controla
  //
  //dores para la edición
   extras.sort((a, b) => DateTime.parse(b.fecha).compareTo(DateTime.parse(a.fecha)));
  
  final List<TextEditingController> _montoControllers = [];
  final List<TextEditingController> _comentarioControllers = [];
  final List<bool> _isEditingList = List.generate(extras.length, (_) => false);

  // Inicializar controladores
  for (var extra in extras) {
    _montoControllers.add(TextEditingController(text: extra.monto.toString()));
    _comentarioControllers.add(TextEditingController(text: extra.comentario));
  }


  final double totalExtras = extras.fold(0.0, (sum, mov) => sum + mov.monto);
final double presupuestoCalculado = project.presupuesto + totalExtras;


  final double presupuestoInicial = presupuestoCalculado - totalExtras;
  final DateFormat formatoFecha = DateFormat('d MMMM yyyy');

  return StatefulBuilder(
    builder: (context, setState) {
      return AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.attach_money, color: Colors.green),
            SizedBox(width: 10),
            Text('Detalles del Presupuesto'),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Presupuesto inicial
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
               'Presupuesto Inicial: \$${NumberFormatter.format(presupuestoInicial)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                ),

                // Tabla de extras
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 20,
                    columns: const [
                      DataColumn(label: Text('Monto', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Comentario', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: List<DataRow>.generate(extras.length, (index) {
                      final mov = extras[index];
                      final isEditing = _isEditingList[index];
                      
                      return DataRow(
                        cells: [
                          DataCell(
                            isEditing
                              ? SizedBox(
                                  width: 150,
                                  child: 
                                  
                                  _buildBudgetField(_montoControllers[index])
                                  // TextField(
                                  //   controller: ,
                                  //   keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  //   decoration: const InputDecoration(
                                  //     border: OutlineInputBorder(),
                                  //     contentPadding: EdgeInsets.all(8),
                                  //   ),
                                  // ),
                                )
                              : Text('\$${NumberFormatter.format(mov.monto)}'),
                          ),
                          DataCell(
                            isEditing
                              ? SizedBox(
                                  width: 200,
                                  child: TextField(
                                    controller: _comentarioControllers[index],
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.all(8),
                                    ),
                                  ),
                                )
                              : Text(mov.comentario),
                          ),
                          DataCell(Text(formatoFecha.format(DateTime.parse(mov.fecha)))),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isEditing ? Icons.save : Icons.edit,
                                    color: isEditing ? Colors.green : Colors.blue,
                                    size: 20,
                                  ),
                                  onPressed: () async {
                                    if (isEditing) {
                                      try {
                                        // final nuevoMonto = double.tryParse(_montoControllers[index].text) ?? mov.monto;
                                        final nuevoMonto = double.tryParse(
  _montoControllers[index].text
    .replaceAll('\$', '')  // Elimina símbolo de moneda
    .replaceAll(',', '')   // Elimina comas (separadores de miles)
    .trim()
) ?? mov.monto;
                                        final nuevoComentario = _comentarioControllers[index].text;
                                        
                                        await Provider.of<ProveedorMovimientoProvider>(context, listen: false)
                                          .editarMovimientoContable(
                                            idMovimiento: mov.id,
                                            monto: nuevoMonto,
                                            comentario: nuevoComentario,
                                          );



final provider = Provider.of<ProveedorMovimientoProvider>(context, listen: false);
 provider.fetchMovimientos(project.id);




                                        setState(() {
                                    
                                          _isEditingList[index] = false;
                                        });
                                                                                                            
 Navigator.pop(context);


                    _loadProject(); // recarga automáticamente

 Navigator.pop(context);

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Movimiento actualizado correctamente'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Error al actualizar: ${e.toString()}'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    } else {
                                      setState(() {
                                        _isEditingList[index] = true;
                                      });
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                  onPressed: () async {
                                    final confirmado = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Confirmar eliminación'),
                                        content: const Text('¿Estás seguro de eliminar este movimiento?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: (){
                                            _loadProject();
                                             Navigator.pop(context, true);
                                            },
                                            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirmado == true) {
                                      try {
                                        await Provider.of<ProveedorMovimientoProvider>(context, listen: false)
                                          .eliminarMovimientoContable(idMovimiento: mov.id);

                                        setState(() {
                                          extras.removeAt(index);
                                          _montoControllers.removeAt(index);
                                          _comentarioControllers.removeAt(index);
                                          _isEditingList.removeAt(index);
                                        });
 Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Movimiento eliminado correctamente'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Error al eliminar: ${e.toString()}'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cerrar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
}

void abrirDialogoExtraPresupuesto(BuildContext context, Proyecto project) {
  double monto = 0;
  String comentario = '';
  final TextEditingController montoController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setStateDialog) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: const [
              Icon(Icons.add_circle_outline, color: Colors.green),
              SizedBox(width: 10),
              Text('Agregar Extra a Presupuesto'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
             TextFormField(
  controller: montoController,
  keyboardType: TextInputType.numberWithOptions(decimal: true), // Teclado numérico con decimales
  inputFormatters: [
    MoneyInputFormatter(
      allowDecimal: true, // Permite decimales
      currencySymbol: '\$', // Símbolo de moneda
    ),
  ],
  decoration: InputDecoration(
    labelText: '💰 Monto',
    hintText: 'Ej: 1,250.50', // Ejemplo de formato
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    prefixIcon: const Icon(Icons.monetization_on),
  ),
  onChanged: (value) {
    // Usa el método parseFormattedMoney para obtener el valor numérico
    monto = MoneyInputFormatter.parseFormattedMoney(value);
    print('Valor numérico: $monto'); // Para depuración
  },
),
                const SizedBox(height: 12),
                TextFormField(
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: '📝 Comentario',
                    hintText: 'Motivo del extra',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.comment),
                  ),
                  onChanged: (val) => comentario = val,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                // if (monto <= 0) return;

                final provider = Provider.of<ProveedorMovimientoProvider>(context, listen: false);

                try {
                  await provider.agregarMovimientoContable(
                    idCliente: project.clienteId,
                    idServicio: 1,          // servicio asociado al presupuesto
                    idTipoMovimiento: 4,    // tipo 4 para "extra presupuesto"
                    monto: monto,
                    esPagoDirecto: false, // Asumiendo que no es un pago directo
                    comentario: comentario,
                    idProyecto: project.id,
                    idAdmin: 1,             // admin actual (puedes parametrizar si deseas)
                  );

                  Navigator.pop(context);
                  _loadProject(); // actualizar UI

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Extra agregado correctamente al presupuesto'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Error al guardar el extra: $e'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    ),
  );
}


}

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:rpg_accounts/Models/ProyectosModel.dart';
// import 'package:rpg_accounts/Provider/MovimientosProvider.dart';
// import 'package:rpg_accounts/Provider/ProyectosProvider.dart';
// import 'package:syncfusion_flutter_gauges/gauges.dart';


// class MultiBarVerticalGauge extends StatefulWidget {
//   final int idProyecto;

//   const MultiBarVerticalGauge({super.key, required this.idProyecto});

//   @override
//   State<MultiBarVerticalGauge> createState() => _MultiBarVerticalGaugeState();
// }

// class _MultiBarVerticalGaugeState extends State<MultiBarVerticalGauge> {
//   late Proyecto project;

//   @override
//   void initState() {
//     super.initState();
//     _loadProject();
//   }

//   void _loadProject() {
//     final projectProvider = Provider.of<ProyectoProvider>(context, listen: false);
//     Proyecto foundProject = projectProvider.getProjectById(widget.idProyecto);
//     setState(() {
//       project = foundProject;
//     });
//   }

//   void _abrirDialogoAdelanto() {
//     double monto = 0;
//     String comentario = '';
//     final TextEditingController montoController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setStateDialog) {
//           return AlertDialog(
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//             title: Row(
//               children: const [
//                 Icon(Icons.attach_money, color: Colors.orange),
//                 SizedBox(width: 10),
//                 Text('Agregar Adelanto'),
//               ],
//             ),
//             content: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextFormField(
//                     controller: montoController,
//                     keyboardType: TextInputType.number,
//                     decoration: InputDecoration(
//                       labelText: '💰 Monto',
//                       hintText: 'Ingrese monto del adelanto',
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                       prefixIcon: const Icon(Icons.monetization_on),
//                     ),
//                     onChanged: (value) {
//                       monto = double.tryParse(value) ?? 0;
//                     },
//                   ),
//                   const SizedBox(height: 12),
//                   TextFormField(
//                     maxLines: 2,
//                     decoration: InputDecoration(
//                       labelText: '📝 Comentario',
//                       hintText: 'Motivo del adelanto',
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                       prefixIcon: const Icon(Icons.comment),
//                     ),
//                     onChanged: (val) => comentario = val,
//                   ),
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Cancelar'),
//               ),
//               ElevatedButton(
//                 onPressed: () async {
//                   if (monto <= 0) return;

//                   final provider= Provider.of<ProveedorMovimientoProvider>(context, listen: false);

//                   await provider.agregarMovimientoContable(
//                     idCliente: project.clienteId,
//                     idServicio:1, // Asumiendo que el proyecto tiene un servicio asociado
//                     idTipoMovimiento: 3, // Suponiendo que 1 es tipo "Adelanto"
//                     monto: monto,
//                     comentario: comentario,
//                     idProyecto: project.id,
//                     idAdmin:1,
//                   );

//                   Navigator.pop(context);
//                   _loadProject(); // recarga después de agregar
//                 },
//                 child: const Text('Guardar'),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// @override
// Widget build(BuildContext context) {
//   const double maxValor = 100000;

//   final Map<String, double> datos = {
//     "Presupuesto": project.presupuesto.toDouble(),
//     "Gastos": project.adelantos.toDouble(),
//     "Adelantos": project.adelantos.toDouble(),
//     "Ganancias": project.adelantos.toDouble(),
//   };

//   const Map<String, Color> colores = {
//     "Presupuesto": Colors.blue,
//     "Gastos": Colors.red,
//     "Adelantos": Colors.orange,
//     "Ganancias": Colors.green,
//   };

//   return Column(
//     children: [
//       // 🔹 Botón para agregar adelanto
//       Align(
//         alignment: Alignment.centerRight,
//         child: IconButton(
//           icon: const Icon(Icons.add_circle, color: Colors.orange, size: 32),
//           tooltip: 'Agregar Adelanto',
//           onPressed: _abrirDialogoAdelanto,
//         ),
//       ),
//       Expanded(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             return SizedBox(
//               height: constraints.maxHeight,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: datos.entries.map((entry) {
//                   return Expanded(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         Text(entry.key,
//                             style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
//                         const SizedBox(height: 8),
//                         Expanded(
//                           child: SfLinearGauge(
//                             orientation: LinearGaugeOrientation.vertical,
//                             minimum: 0,
//                             maximum: maxValor,
//                             axisTrackStyle: const LinearAxisTrackStyle(
//                               thickness: 16,
//                               edgeStyle: LinearEdgeStyle.bothFlat,
//                               color: Color(0xFFE0E0E0),
//                             ),
//                             barPointers: [
//                               LinearBarPointer(
//                                 value: entry.value,
//                                 color: colores[entry.key]!,
//                                 thickness: 16,
//                               ),
//                             ],
//                             markerPointers: [
//                               LinearWidgetPointer(
//                                 value: entry.value,
//                                 enableAnimation: true,
//                                 child: const Icon(Icons.arrow_drop_up, size: 24),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text('${entry.value.toInt()}',
//                             style: const TextStyle(fontSize: 12)),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//               ),
//             );
//           },
//         ),
//       ),
//     ],
//   );
// }
// }

// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_gauges/gauges.dart';

// class MultiBarVerticalGauge extends StatelessWidget {
//   const MultiBarVerticalGauge({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Datos quemados
//     const double maxValor = 100000;
//     const Map<String, double> datos = {
//       "Presupuesto": 100000,
//       "Gastos": 65000,
//       "Adelantos": 30000,
//       "Ganancias": 20000,
//     };

//     const Map<String, Color> colores = {
//       "Presupuesto": Colors.blue,
//       "Gastos": Colors.red,
//       "Adelantos": Colors.orange,
//       "Ganancias": Colors.green,
//     };

//     return LayoutBuilder(
//       builder: (context, constraints) {
//         return SizedBox(
//           height: constraints.maxHeight,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: datos.entries.map((entry) {
//               return Expanded(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     Text(
//                       entry.key,
//                       style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
//                     ),
//                     const SizedBox(height: 8),
//                     Expanded(
//                       child: SfLinearGauge(
//                         orientation: LinearGaugeOrientation.vertical,
//                         minimum: 0,
//                         maximum: maxValor,
//                         axisTrackStyle: const LinearAxisTrackStyle(
//                           thickness: 16,
//                           edgeStyle: LinearEdgeStyle.bothFlat,
//                           color: Color(0xFFE0E0E0),
//                         ),
//                         barPointers: [
//                           LinearBarPointer(
//                             value: entry.value,
//                             color: colores[entry.key]!,
//                             thickness: 16,
//                           ),
//                         ],
//                         markerPointers: [
//                           LinearWidgetPointer(
//                             value: entry.value,
//                             enableAnimation: true,
//                             child: const Icon(Icons.arrow_drop_up, size: 24),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       '${entry.value.toInt()}',
//                       style: const TextStyle(fontSize: 12),
//                     ),
//                   ],
//                 ),
//               );
//             }).toList(),
//           ),
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:rpg_accounts/Models/Proveedores.dart';
import 'package:rpg_accounts/Provider/MovimientosProvider.dart';

class GastosPage extends StatefulWidget {
  @override
  _GastosPageState createState() => _GastosPageState();
}

class _GastosPageState extends State<GastosPage> {

  List<ProveedorModel> proveedoresDropDown = [];  // Lista que almacenará los proveedores dinámicamente
  final ProveedorMovimientoProvider proveedorProvider = ProveedorMovimientoProvider();

  // Inicializa el estado y obtiene los proveedores
  @override
  void initState() {
    super.initState();
    getProveedores();  // Llama a la función que obtiene los proveedores
  }

  // Función que obtiene los proveedores según el tipo de usuario
 Future<void> getProveedores() async {
  await proveedorProvider.fetchProveedores(); // Llama al provider para obtener los proveedores

  // Filtra los proveedores con tipo 3
  proveedoresDropDown = proveedorProvider.proveedores;
     

  setState(() {}); // Actualiza la UI después de obtener los proveedores
}


  final List<Gasto> materiales = [
    Gasto(proveedor: 'Proveedor 1', descripcion: 'Cemento', monto: 150, estado: 'Pagado'),
    Gasto(proveedor: 'Proveedor 1', descripcion: 'Arena', monto: 100, estado: 'Pendiente'),
    Gasto(proveedor: 'Proveedor 2', descripcion: 'Ladrillos', monto: 200, estado: 'Pagado'),
  ];

  final List<Gasto> manoObra = [
    Gasto(proveedor: 'Carlos', descripcion: 'Electricidad', monto: 300, estado: 'Pendiente'),
    Gasto(proveedor: 'Luis', descripcion: 'Pintura', monto: 180, estado: 'Pagado'),
    Gasto(proveedor: 'Luis', descripcion: 'Fontanería', monto: 220, estado: 'Pendiente'),
  ];

  String filtroEstadoMateriales = 'Todos';
  String filtroEstadoManoObra = 'Todos';
  bool isVisibleTotal =false;

 

void _abrirDialogoAgregarGasto(bool esMaterial) async {
  List<Gasto> seleccionados = [];
  List<GastoItem> disponibles = esMaterial
      ? [
          GastoItem(nombre: 'Cemento'),
          GastoItem(nombre: 'Arena'),
          GastoItem(nombre: 'Ladrillos'),
        ]
      : [
          GastoItem(nombre: 'Electricidad'),
          GastoItem(nombre: 'Pintura'),
          GastoItem(nombre: 'Fontanería'),
        ];



  // List<String> proveedores = esMaterial
  //     ? ['Proveedor 1', 'Proveedor 2']
  //     : ['Carlos', 'Luis'];



  double totalAcumulado = 0;

  if (esMaterial) {
    final opcion = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('¿Tipo de factura?'),
        children: [
          SimpleDialogOption(
            child: Text('Factura con detalles'),
            onPressed: () => Navigator.pop(context, 'detallado'),
          ),
          SimpleDialogOption(
            child: Text('Factura sin detalles'),
            onPressed: () => Navigator.pop(context, 'simple'),
          ),
        ],
      ),
    );

    if (opcion == 'simple') {
      String comentario = '';
      double monto = 0;
      String proveedorSeleccionado = '';
      await showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setStateSimple) {
            return AlertDialog(
              title: Text('Agregar Material (sin detalles)'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
 DropdownButtonFormField<String>(
  decoration: InputDecoration(labelText: 'Proveedor'),
  value: proveedorSeleccionado.isNotEmpty ? proveedorSeleccionado : null,
  items: proveedoresDropDown
      .where((proveedor) => esMaterial 
          ? proveedor.tipoUsuario == 3 
          : proveedor.tipoUsuario == 2)  // Filtra según el tipo
      .map((proveedor) {
        return DropdownMenuItem<String>(
          value: proveedor.id.toString(),  // Usa el ID del proveedor como valor
          child: Text(proveedor.nombre),  // Muestra el nombre del proveedor
        );
      }).toList(),
  onChanged: (value) {
    setStateSimple(() => proveedorSeleccionado = value ?? '');
  },
)


,
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Comentario',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      onChanged: (val) => comentario = val,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Monto'),
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        setStateSimple(() => monto = double.tryParse(val) ?? 0);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
                ElevatedButton(
                  onPressed: () {
                    if (proveedorSeleccionado.isEmpty || comentario.isEmpty || monto <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Completa proveedor, comentario y monto válido.')),
                      );
                    } else {
                      setState(() {
                        materiales.add(Gasto(
                          proveedor: proveedorSeleccionado,
                          descripcion: comentario,
                          monto: monto,
                          estado: 'Pendiente',
                        ));
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Guardar'),
                ),
              ],
            );
          },
        ),
      );
      return;
    }
  }

  // Diálogo detallado (material o mano de obra)
  String comentarioGeneral = '';
  String proveedorFactura = '';

  await showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setStateDialog) {
        return AlertDialog(
          title: Text('Agregar ${esMaterial ? 'Material' : 'Trabajo'} (con detalles)'),
          content: SingleChildScrollView(
            child: Column(
              children: [
      DropdownButtonFormField<String>(
  decoration: InputDecoration(labelText: 'Proveedor'),
  value: proveedorFactura.isNotEmpty ? proveedorFactura : null,
  items: proveedoresDropDown
      .where((proveedor) => esMaterial 
          ? proveedor.tipoUsuario == 3 
          : proveedor.tipoUsuario == 2)  // Filtra según el tipo
      .map((proveedor) {
        return DropdownMenuItem<String>(
          value: proveedor.id.toString(),  // Usa el ID del proveedor como valor
          child: Text(proveedor.nombre),  // Muestra el nombre del proveedor
        );
      }).toList(),
  onChanged: (value) {
    setStateDialog(() => proveedorFactura = value ?? '');
  },
),

                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Comentario general',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  onChanged: (val) => comentarioGeneral = val,
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () async {
                    final seleccionadosTemp = await showModalBottomSheet<List<GastoItem>>(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => StatefulBuilder(
                        builder: (context, setStateModal) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Seleccionar', style: TextStyle(fontWeight: FontWeight.bold)),
                                ...disponibles.map((item) => CheckboxListTile(
                                      title: Text(item.nombre),
                                      value: item.seleccionado,
                                      onChanged: (val) {
                                        setStateModal(() => item.seleccionado = val ?? false);
                                      },
                                    )),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(
                                      context,
                                      disponibles.where((i) => i.seleccionado).toList(),
                                    );
                                  },
                                  child: Text('Agregar'),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    );
                    if (seleccionadosTemp != null) {
                      setStateDialog(() {
                        seleccionados = seleccionadosTemp.map((i) => Gasto(
                              proveedor: proveedorFactura,
                              descripcion: i.nombre,
                              monto: 0,
                              estado: '',
                            )).toList();
                      });
                    }
                  },
                  icon: Icon(Icons.add,),
                  label: Text('Seleccionar ítems'),
                ),
                SizedBox(height: 10),
                ...seleccionados.map((gasto) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(gasto.descripcion, style: TextStyle(fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                        
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(labelText: 'Monto'),
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                  setStateDialog(() {
                                    gasto.monto = double.tryParse(val) ?? 0;
                                    totalAcumulado = seleccionados.fold(0, (sum, g) => sum + g.monto);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        Divider(),
                      ],
                    )),
                Divider(),
                Text('Total acumulado: \$${totalAcumulado.toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (proveedorFactura.isEmpty || seleccionados.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Completa el proveedor y al menos un ítem.')));
                } else {
               setState(() {
  for (var item in seleccionados) {
    item.proveedor = proveedorFactura;
    
    List<Gasto> destino = esMaterial ? materiales : manoObra;

    // Verifica si ya existe un ítem con la misma descripción y proveedor
    final existente = destino.firstWhere(
      (g) => g.descripcion == item.descripcion && g.proveedor == item.proveedor,
      orElse: () => Gasto(proveedor: '', descripcion: '', monto: -1, estado: ''),
    );

    if (existente.monto != -1) {
      // Si ya existe, actualiza el monto sumando el nuevo
      existente.monto += item.monto;
    } else {
      // Si no existe, agrégalo sin modificar la descripción
      destino.add(item);
    }
  }
});

                  Navigator.pop(context);
                }
              },
              child: Text('Guardar'),
            )
          ],
        );
      },
    ),
  );
}

@override

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(child: _buildGastosSeccion('Materiales', materiales, filtroEstadoMateriales, true)),
          VerticalDivider(),
          Expanded(child: _buildGastosSeccion('Mano de Obra', manoObra, filtroEstadoManoObra, false)),
        ],
      ),
    );
  }

  Widget _buildGastosSeccion(String titulo, List<Gasto> listaOriginal, String filtro, bool esMaterial) {
    final Map<String, List<Gasto>> agrupado = {};
    for (var g in listaOriginal.where((g) => filtro == 'Todos' || g.estado == filtro)) {
      agrupado.putIfAbsent(g.proveedor, () => []).add(g);
    }

    double totalSeccion = listaOriginal
        .where((g) => filtro == 'Todos' || g.estado == filtro)
        .fold(0.0, (sum, g) => sum + g.monto);

    return Column(
      children: [
        ListTile(
          title: Text(titulo, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          trailing: ElevatedButton.icon(
            onPressed: () => _abrirDialogoAgregarGasto(esMaterial),
            icon: Icon(Icons.add),
            label: Text('Agregar'),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: ['Todos', 'Pagado', 'Pendiente'].map((estado) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(estado),
                selected: (esMaterial ? filtroEstadoMateriales : filtroEstadoManoObra) == estado,
                onSelected: (_) {
                  setState(() {
                    if (esMaterial) {
                      filtroEstadoMateriales = estado;
                    } else {
                      filtroEstadoManoObra = estado;
                    }
                  });
                },
              ),
            );
          }).toList(),
        ),
        Expanded(
          child: agrupado.isEmpty
              ? Center(child: Text('Sin datos'))
              : ListView(
                  children: agrupado.entries.map((e) {
                    return 
                    
                    // ExpansionTile(
                    //   title: Text(e.key, style: TextStyle(fontWeight: FontWeight.bold)),
                    //   subtitle: Text('Total: \$${e.value.fold(0.0, (s, g) => s + g.monto).toStringAsFixed(2)}'),
                    //   children: e.value
                    //       .map((g) => ListTile(
                    //             title: Text(g.descripcion),
                    //             subtitle: Text('Estado: ${g.estado}'),
                    //             trailing: Text('\$${g.monto.toStringAsFixed(2)}'),
                    //           ))
                    //       .toList(),
                    // );
ExpansionTile(
  title: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(e.key, style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Total: \$${e.value.fold(0.0, (s, g) => s + g.monto).toStringAsFixed(2)}'),
          ],
        ),
      ),
 
        IconButton(
          icon: Icon(Icons.info_outline, color: Colors.blue,),
          onPressed: () => _abrirModalDetalle(
            context,
            e.key,
            e.value.map((g) => Grupo(
              descripcion: g.descripcion,
              estado: g.estado,
              monto: g.monto,
            )).toList(),
            isRestando: false, // o puedes eliminar este flag si ya no lo usas
          ),
        ),
    ],
  ),
  children: e.value
      .map((g) => ListTile(
            title: Text(g.descripcion),
            subtitle: Text('Estado: ${g.estado}'),
            trailing: Text('\$${g.monto.toStringAsFixed(2)}'),
          ))
      .toList(),
)


;

                  }).toList(),
                ),
        ),
        Divider(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Total $titulo: \$${totalSeccion.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }
  
  void _abrirModalDetalle(BuildContext context, String nombre, List<Grupo> movimientos, {required bool isRestando}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    builder: (context) {
      double total = movimientos.fold(0.0, (s, g) => s + g.monto);

      return StatefulBuilder(
        builder: (context, setStateModal) => Padding(
          padding: EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Detalles de $nombre', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Divider(),
              SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                itemCount: movimientos.length,
                itemBuilder: (context, index) {
                  final mov = movimientos[index];
                  return ListTile(
                    title: Text(mov.descripcion),
                    subtitle: Text('Estado: ${mov.estado}'),
                    trailing: Text('\$${mov.monto.toStringAsFixed(2)}'),
                  );
                },
              ),
              Divider(),
              Text('Total Actual: \$${total.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.add,color: Colors.white),
                    label: Text('Agregar Pendiente' ,style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red , textStyle: TextStyle(color: Colors.black)),
                    onPressed: () {
                      _mostrarModalIngreso(context, isDescuento: false, onSubmit: (monto, descripcion) {
                        setStateModal(() {
                          movimientos.add(Grupo(
                            descripcion: descripcion,
                            estado: 'Pendiente',
                            monto: monto,
                          ));
                          total = movimientos.fold(0.0, (s, g) => s + g.monto); // Recalcular total
                        });
                      });
                    },
                  ),
                  SizedBox(width: 10),
                
                    ElevatedButton.icon(
                    icon: Icon(Icons.remove ,color: Colors.white),
                    label: Text('Saldo Pagado',style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green , textStyle: TextStyle(color: Colors.black)),
                    onPressed: () {
                      _mostrarModalIngreso(context, isDescuento: true, onSubmit: (monto, descripcion) {
                        setStateModal(() {
                          movimientos.add(Grupo(
                            descripcion: descripcion,
                            estado: 'Pagado',
                            monto: -monto,
                          ));
                          total = movimientos.fold(0.0, (s, g) => s + g.monto); // Recalcular total
                        });
                      });
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      );
    },
  );
}

void _mostrarModalIngreso(BuildContext context, {required bool isDescuento, required Function(double, String) onSubmit}) {
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(isDescuento ? 'Registrar Descuento' : 'Agregar Pago'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _descripcionController,
              decoration: InputDecoration(labelText: 'Descripción'),
            ),
            TextField(
              controller: _montoController,
              decoration: InputDecoration(labelText: 'Monto'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text('Guardar'),
            onPressed: () {
              final descripcion = _descripcionController.text.trim();
              final monto = double.tryParse(_montoController.text) ?? 0.0;
              if (monto > 0 && descripcion.isNotEmpty) {
                onSubmit(monto, descripcion);
                Navigator.pop(context);
              }
            },
          ),
        ],
      );
    },
  );
}




}

class Grupo {
  final String descripcion;
  final String estado;
  final double monto;

  Grupo({required this.descripcion, required this.estado, required this.monto});
}


class Gasto {
  String proveedor;
  String descripcion;
  double monto;
  String estado;

  Gasto({
    required this.proveedor,
    required this.descripcion,
    required this.monto,
    required this.estado,
  });
}

class GastoItem {
  String nombre;
  bool seleccionado;

  GastoItem({required this.nombre, this.seleccionado = false});
}

// import 'package:flutter/material.dart';

// class GastosPage extends StatefulWidget {
//   @override
//   _GastosPageState createState() => _GastosPageState();
// }

// class _GastosPageState extends State<GastosPage> {
//   final List<Gasto> materiales = [
//     Gasto(proveedor: 'Proveedor 1', descripcion: 'Cemento', monto: 150, estado: 'Pagado'),
//     Gasto(proveedor: 'Proveedor 1', descripcion: 'Arena', monto: 100, estado: 'Pendiente'),
//     Gasto(proveedor: 'Proveedor 2', descripcion: 'Ladrillos', monto: 200, estado: 'Pagado'),
//   ];

//   final List<Gasto> manoObra = [
//     Gasto(proveedor: 'Carlos', descripcion: 'Electricidad', monto: 300, estado: 'Pendiente'),
//     Gasto(proveedor: 'Luis', descripcion: 'Pintura', monto: 180, estado: 'Pagado'),
//     Gasto(proveedor: 'Luis', descripcion: 'Fontanería', monto: 220, estado: 'Pendiente'),
//   ];

//   String filtroEstadoMateriales = 'Todos';
//   String filtroEstadoManoObra = 'Todos';

//   void _abrirDialogoAgregarGasto(bool esMaterial) async {
//     List<Gasto> seleccionados = [];
//     List<GastoItem> disponibles = esMaterial
//         ? [
//             GastoItem(nombre: 'Cemento'),
//             GastoItem(nombre: 'Arena'),
//             GastoItem(nombre: 'Ladrillos'),
//           ]
//         : [
//             GastoItem(nombre: 'Electricidad'),
//             GastoItem(nombre: 'Pintura'),
//             GastoItem(nombre: 'Fontanería'),
//           ];

//     List<String> proveedores = esMaterial
//         ? ['Proveedor 1', 'Proveedor 2']
//         : ['Carlos', 'Luis'];

//     await showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setStateDialog) {
//           return AlertDialog(
//             title: Text('Agregar ${esMaterial ? 'Material' : 'Trabajo'}'),
//             content: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   ElevatedButton.icon(
//                     onPressed: () async {
//                       final seleccionadosTemp = await showModalBottomSheet<List<GastoItem>>(
//                         context: context,
//                         isScrollControlled: true,
//                         builder: (context) => StatefulBuilder(
//                           builder: (context, setStateModal) {
//                             return Padding(
//                               padding: const EdgeInsets.all(16),
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Text('Seleccionar', style: TextStyle(fontWeight: FontWeight.bold)),
//                                   ...disponibles.map((item) => CheckboxListTile(
//                                         title: Text(item.nombre),
//                                         value: item.seleccionado,
//                                         onChanged: (val) {
//                                           setStateModal(() => item.seleccionado = val ?? false);
//                                         },
//                                       )),
//                                   ElevatedButton(
//                                     onPressed: () {
//                                       Navigator.pop(
//                                         context,
//                                         disponibles.where((i) => i.seleccionado).toList(),
//                                       );
//                                     },
//                                     child: Text('Agregar'),
//                                   )
//                                 ],
//                               ),
//                             );
//                           },
//                         ),
//                       );
//                       if (seleccionadosTemp != null) {
//                         setStateDialog(() {
//                           seleccionados = seleccionadosTemp.map((i) => Gasto(
//                                 proveedor: '',
//                                 descripcion: i.nombre,
//                                 monto: 0,
//                                 estado: 'Pendiente',
//                               )).toList();
//                         });
//                       }
//                     },
//                     icon: Icon(Icons.add),
//                     label: Text('Seleccionar'),
//                   ),
//                   SizedBox(height: 10),
//                   ...seleccionados.map((gasto) => Column(
//                         children: [
//                           Text(gasto.descripcion, style: TextStyle(fontWeight: FontWeight.bold)),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: TextFormField(
//                                   keyboardType: TextInputType.number,
//                                   decoration: InputDecoration(labelText: 'Monto'),
//                                   onChanged: (val) {
//                                     setStateDialog(() {
//                                       gasto.monto = double.tryParse(val) ?? 0;
//                                     });
//                                   },
//                                 ),
//                               ),
//                               SizedBox(width: 10),
//                               Expanded(
//                                 child: DropdownButtonFormField<String>(
//                                   value: gasto.proveedor.isNotEmpty ? gasto.proveedor : null,
//                                   hint: Text("Proveedor"),
//                                   items: proveedores.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
//                                   onChanged: (value) => setStateDialog(() => gasto.proveedor = value ?? ''),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Divider()
//                         ],
//                       )),
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
//               ElevatedButton(
//                 onPressed: () {
//                   setState(() {
//                     if (esMaterial) {
//                       materiales.addAll(seleccionados);
//                     } else {
//                       manoObra.addAll(seleccionados);
//                     }
//                   });
//                   Navigator.pop(context);
//                 },
//                 child: Text('Guardar'),
//               )
//             ],
//           );
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(

//       body: Row(
//         children: [
//           Expanded(child: _buildGastosSeccion('Materiales', materiales, filtroEstadoMateriales, true)),
//           VerticalDivider(),
//           Expanded(child: _buildGastosSeccion('Mano de Obra', manoObra, filtroEstadoManoObra, false)),
//         ],
//       ),
//     );
//   }

//   Widget _buildGastosSeccion(String titulo, List<Gasto> listaOriginal, String filtro, bool esMaterial) {
//     final Map<String, List<Gasto>> agrupado = {};
//     for (var g in listaOriginal.where((g) => filtro == 'Todos' || g.estado == filtro)) {
//       agrupado.putIfAbsent(g.proveedor, () => []).add(g);
//     }

//     double totalSeccion = listaOriginal
//         .where((g) => filtro == 'Todos' || g.estado == filtro)
//         .fold(0.0, (sum, g) => sum + g.monto);

//     return Column(
//       children: [
//         ListTile(
//           title: Text(titulo, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//           trailing: ElevatedButton.icon(
//             onPressed: () => _abrirDialogoAgregarGasto(esMaterial),
//             icon: Icon(Icons.add),
//             label: Text('Agregar'),
//           ),
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: ['Todos', 'Pagado', 'Pendiente'].map((estado) {
//             return Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 4),
//               child: ChoiceChip(
//                 label: Text(estado),
//                 selected: (esMaterial ? filtroEstadoMateriales : filtroEstadoManoObra) == estado,
//                 onSelected: (_) {
//                   setState(() {
//                     if (esMaterial) {
//                       filtroEstadoMateriales = estado;
//                     } else {
//                       filtroEstadoManoObra = estado;
//                     }
//                   });
//                 },
//               ),
//             );
//           }).toList(),
//         ),
//         Expanded(
//           child: agrupado.isEmpty
//               ? Center(child: Text('Sin datos'))
//               : ListView(
//                   children: agrupado.entries.map((e) {
//                     return ExpansionTile(
//                       title: Text(e.key, style: TextStyle(fontWeight: FontWeight.bold)),
//                       subtitle: Text('Total: \$${e.value.fold(0.0, (s, g) => s + g.monto).toStringAsFixed(2)}'),
//                       children: e.value
//                           .map((g) => ListTile(
//                                 title: Text(g.descripcion),
//                                 subtitle: Text('Estado: ${g.estado}'),
//                                 trailing: Text('\$${g.monto.toStringAsFixed(2)}'),
//                               ))
//                           .toList(),
//                     );
//                   }).toList(),
//                 ),
//         ),
//         Divider(),
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Text('Total $titulo: \$${totalSeccion.toStringAsFixed(2)}',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//         )
//       ],
//     );
//   }
// }

// class Gasto {
//   String proveedor;
//   String descripcion;
//   double monto;
//   String estado;

//   Gasto({
//     required this.proveedor,
//     required this.descripcion,
//     required this.monto,
//     required this.estado,
//   });
// }

// class GastoItem {
//   String nombre;
//   bool seleccionado;

//   GastoItem({required this.nombre, this.seleccionado = false});
// }


// import 'package:flutter/material.dart';

// class ExpenseAccordionView extends StatefulWidget {
//   @override
//   _ExpenseAccordionViewState createState() => _ExpenseAccordionViewState();
// }

// class _ExpenseAccordionViewState extends State<ExpenseAccordionView> {
//   String materialFilter = 'Todos';
//   String laborFilter = 'Todos';

//   List<Map<String, dynamic>> materialExpenses = [
//     {
//       'proveedor': 'Ferretería Central',
//       'facturas': [
//         {'descripcion': 'Cemento', 'monto': 500, 'estado': 'Pagado'},
//         {'descripcion': 'Arena', 'monto': 200, 'estado': 'Pendiente'},
//       ]
//     },
//     {
//       'proveedor': 'Materiales Norte',
//       'facturas': [
//         {'descripcion': 'Ladrillos', 'monto': 350, 'estado': 'Pagado'}
//       ]
//     }
//   ];

//   List<Map<String, dynamic>> laborExpenses = [
//     {
//       'proveedor': 'Albañil Carlos',
//       'trabajos': [
//         {'descripcion': 'Colocación de bloques', 'monto': 600, 'estado': 'Pendiente'},
//       ]
//     },
//     {
//       'proveedor': 'Pintor Luis',
//       'trabajos': [
//         {'descripcion': 'Pintura interior', 'monto': 450, 'estado': 'Pagado'}
//       ]
//     }
//   ];

//   List<Widget> _buildAccordionList(List<Map<String, dynamic>> data, String tipo, String filtro) {
//     return data.map((item) {
//       List<dynamic> detalles = item[tipo];
//       List<Widget> filtered = detalles.where((d) =>
//         filtro == 'Todos' || d['estado'] == filtro).map<Widget>((detalle) {
//         return ListTile(
//           title: Text(detalle['descripcion']),
//           subtitle: Text('Estado: ${detalle['estado']}'),
//           trailing: Text('\$${detalle['monto']}'),
//         );
//       }).toList();

//       if (filtered.isEmpty) return SizedBox();

//       return ExpansionTile(
//         title: Text(item['proveedor']),
//         children: filtered,
//       );
//     }).toList();
//   }

//   Widget _buildFilter(String label, String currentFilter, void Function(String) onChanged) {
//     return Row(
//       children: [
//         Text("$label: ", style: TextStyle(fontWeight: FontWeight.bold)),
//         DropdownButton<String>(
//           value: currentFilter,
//           items: ['Todos', 'Pagado', 'Pendiente'].map((e) => DropdownMenuItem(
//             child: Text(e),
//             value: e,
//           )).toList(),
//           onChanged: (val) => onChanged(val!),
//         )
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//           child: Column(
//             children: [
//               Text("Gastos de Materiales", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               _buildFilter("Filtrar", materialFilter, (val) => setState(() => materialFilter = val)),
//               Expanded(
//                 child: ListView(
//                   children: _buildAccordionList(materialExpenses, 'facturas', materialFilter),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         VerticalDivider(),
//         Expanded(
//           child: Column(
//             children: [
//               Text("Gastos de Mano de Obra", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               _buildFilter("Filtrar", laborFilter, (val) => setState(() => laborFilter = val)),
//               Expanded(
//                 child: ListView(
//                   children: _buildAccordionList(laborExpenses, 'trabajos', laborFilter),
//                 ),
//               ),
//             ],
//           ),
//         )
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rpg_accounts/Drawer/AppDrawer.dart';
import 'package:rpg_accounts/Models/MovimientosContablesProyecto.dart';
import 'package:rpg_accounts/Models/Proveedores.dart';
import 'package:rpg_accounts/Models/ProyectosModel.dart';
import 'package:rpg_accounts/Provider/MovimientosProvider.dart';
import 'package:rpg_accounts/Provider/ProyectosProvider.dart';
import 'package:rpg_accounts/Views/Proyectos/DetallesDeEmpresa.dart';
import 'package:flutter/services.dart';
import 'package:rpg_accounts/Widgets/Utils.dart';
class MovimientosPorProyectoScreen extends StatefulWidget {
  final int idProyecto;

  const MovimientosPorProyectoScreen({Key? key, required this.idProyecto}) : super(key: key);

  @override
  State<MovimientosPorProyectoScreen> createState() => _MovimientosPorProyectoScreenState();
}

class _MovimientosPorProyectoScreenState extends State<MovimientosPorProyectoScreen> {
  bool _isLoading = true;
  List<ProveedorModel> proveedoresDropDown = [];  // Lista que almacenará los proveedores dinámicamente

  
  @override
  void initState() {
    super.initState();
    _fetchData();
     _loadProject();
     getProveedores();
  }
   late Proyecto project;


  // Función que obtiene los proveedores según el tipo de usuario
 Future<void> getProveedores() async {
   final ProveedorMovimientoProvider proveedorProvider = ProveedorMovimientoProvider();

  await proveedorProvider.fetchProveedores(); // Llama al provider para obtener los proveedores

  // Filtra los proveedores con tipo 3
  proveedoresDropDown = proveedorProvider.proveedores;
     

  setState(() {}); // Actualiza la UI después de obtener los proveedores
}


  // Future<void> _fetchData() async {
  //   await Provider.of<ProveedorMovimientoProvider>(context, listen: false)
  //       .fetchMovimientos(widget.idProyecto);
  //   setState(() => _isLoading = false);
  // }

// Future<void> _fetchData() async {
//   setState(() {
//     _isLoading = true;  // empieza carga
//     _isLoadingProject = true;
//   });

//   // Carga movimientos
//   await Provider.of<ProveedorMovimientoProvider>(context, listen: false)
//       .fetchMovimientos(widget.idProyecto);

//   // Carga proyectos
//   final projectProvider = Provider.of<ProyectoProvider>(context, listen: false);
//   await projectProvider.fetchProyectos(); // asegúrate que es async

//   // Obtiene proyecto actualizado
//   Proyecto foundProject = projectProvider.getProjectById(widget.idProyecto);

//   setState(() {
//     _isLoadingProject=false;
//     project = foundProject;  // actualiza proyecto local
//     _isLoading = false;      // termina carga
//   });
// }
Future<void> _fetchData() async {
  setState(() {
    _isLoading = true;
    _isLoadingProject = true;
  });

  final provider = Provider.of<ProveedorMovimientoProvider>(context, listen: false);

  // Cargar movimientos
  await provider.fetchMovimientos(widget.idProyecto);

  // Cargar proyectos
  final projectProvider = Provider.of<ProyectoProvider>(context, listen: false);
  await projectProvider.fetchProyectos();

  // Obtener proyecto actualizado
  Proyecto foundProject = projectProvider.getProjectById(widget.idProyecto);

  // Variables temporales para acumular
  double totalMateriales = 0.0;
  double totalManoObra = 0.0;
  double totalPagado = 0.0;

  for (var usuario in provider.movimientosPorUsuario) {
    final materiales = usuario.movimientos.where((m) => m.idProveedor != null).toList();
    final manoObra = usuario.movimientos.where((m) => m.idTrabajador != null).toList();

    totalMateriales += materiales
        .where((m) => m.tipoMovimiento == 1 || (m.tipoMovimiento == 2 && m.pagoDirecto) )
        .fold(0.0, (sum, m) => sum + m.monto);

 totalManoObra += manoObra
    .where((m) => m.tipoMovimiento == 1 || (m.tipoMovimiento == 2 && m.pagoDirecto))
    .fold(0.0, (sum, m) => sum + m.monto);

    totalPagado += manoObra
        .where((m) => m.tipoMovimiento == 2)
        .fold(0.0, (sum, m) => sum + m.monto);
  }

  final totalAdeudado = totalManoObra - totalPagado;

  setState(() {
    _isLoading = false;
    _isLoadingProject = false;
    project = foundProject;

    TotalMaterialGlobal = totalMateriales;
    TotalManoObraGlobal = totalManoObra;
    this.totalPagado = totalPagado;
    this.totalAdeudado = totalAdeudado;
  });
}


  // Función para cargar el proyecto desde el provider
  void _loadProject() {
    final projectProvider = Provider.of<ProyectoProvider>(context, listen: false);
    
    // Obtener el proyecto por id
    Proyecto foundProject = projectProvider.getProjectById(widget.idProyecto);

    // Establecer el proyecto en el estado local
    setState(() {
      project = foundProject;
    });
  }

ProveedorModel? proveedorSeleccionado;
void _abrirModalProveedores(BuildContext context, List<ProveedorModel> proveedores, Function(ProveedorModel) onSeleccionar) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    builder: (context) {
      String filtro = '';
      List<ProveedorModel> proveedoresFiltrados = proveedores;

      return StatefulBuilder(
        builder: (context, setStateModal) {
          proveedoresFiltrados = proveedores
              .where((p) => p.nombre.toLowerCase().contains(filtro.toLowerCase()))
              .toList();

          return Padding(
            padding: EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Selecciona un proveedor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Divider(),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Buscar proveedor',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (val) {
                    setStateModal(() {
                      filtro = val;
                    });
                  },
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: 300, // para que la lista tenga altura limitada y scroll
                  child: proveedoresFiltrados.isEmpty
                      ? Center(child: Text('No hay proveedores'))
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: proveedoresFiltrados.length,
                          separatorBuilder: (_, __) => Divider(),
                          itemBuilder: (context, index) {
                            final p = proveedoresFiltrados[index];
                            return ListTile(
                              title: Text(p.nombre),
                              onTap: () {
                                onSeleccionar(p);
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cerrar'),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

    final TextEditingController montoController = TextEditingController();
void _abrirDialogoAgregarGasto(bool esMaterial) async {
  String comentario = '';
montoController.clear(); // Limpia el campo de monto
  ProveedorModel? proveedorSeleccionado;
int idTipoMovimiento =  1; // 3 para material, 2 para mano de obra
  List<ProveedorModel> proveedoresFiltrados = proveedoresDropDown
      .where((p) => p.tipoUsuario == (esMaterial ? 3 : 2))
      .toList();
  // Controlador para mostrar el id en el TextFormField
  final TextEditingController proveedorController = TextEditingController();
bool esPagoDirecto = false; 
  await showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setStateDialog) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: [
              Icon(
                esMaterial ? Icons.construction : Icons.handyman,
                color: esMaterial ? Colors.orange : Colors.blue,
              ),
              SizedBox(width: 10),
              Text(esMaterial ? 'Agregar Material' : 'Agregar Mano de Obra'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // DropdownButtonFormField<ProveedorModel>(
                //   decoration: InputDecoration(
                //     labelText: '🏢 Proveedor',
                //     hintText: 'Selecciona un proveedor',
                //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                //     prefixIcon: Icon(Icons.store),
                //   ),
                //   value: proveedorSeleccionado,
                //   items: proveedoresFiltrados.map((p) {
                //     return DropdownMenuItem<ProveedorModel>(
                //       value: p,
                //       child: Text(p.nombre),
                //     );
                //   }).toList(),
                //   onChanged: (value) {
                //     setStateDialog(() => proveedorSeleccionado = value);
                //   },
                // ),
                 TextFormField(
                  controller: proveedorController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: '🏢 Proveedor',
                    hintText: 'Selecciona un proveedor',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.store),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.arrow_drop_down),
                      onPressed: () {
                        _abrirModalProveedores(context, proveedoresFiltrados, (ProveedorModel p) {
                          setStateDialog(() {
                            proveedorSeleccionado = p;
                            proveedorController.text = p.nombre; // Actualiza el texto aquí
                          });
                        });
                      },
                    ),
                  ),
                  onTap: () {
                    _abrirModalProveedores(context, proveedoresFiltrados, (ProveedorModel p) {
                      setStateDialog(() {
                        proveedorSeleccionado = p;
                        proveedorController.text = p.nombre; // Actualiza el texto aquí
                      });
                    });
                  },
                ),
SizedBox(height: 16),

// 👇 Aquí agregamos el Switch de pago directo
SwitchListTile(
  title: Text('💳 Pago directo'),
  value: esPagoDirecto,
  onChanged: (bool value) {
    setStateDialog(() {
      esPagoDirecto = value;
    });
  },
  activeColor: Colors.green,
),

                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: '📝 Comentario',
                    hintText: 'Escribe un comentario',
                    prefixIcon: Icon(Icons.comment),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  maxLines: 3,
                  onChanged: (val) => comentario = val,
                ),
                SizedBox(height: 16),
  _buildBudgetField(montoController),
                // TextFormField(
                //   decoration: InputDecoration(
                //     labelText: '💰 Monto'
                //     hintText: 'Ingresa un monto',
                //     prefixIcon: Icon(Icons.attach_money),
                //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                //   ),
                //   keyboardType: TextInputType.numberWithOptions(decimal: true),
                //   inputFormatters: [
                //     FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                //   ],
                //   onChanged: (val) {
                //     setStateDialog(() => monto = double.tryParse(val) ?? 0);
                //   },
                // ),


              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.cancel, color: Colors.red),
                    label: Text('Cancelar', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (proveedorSeleccionado == null || comentario.isEmpty ) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Completa todos los campos correctamente.')),
                      );
                      return;
                    }

                    final movimientoProvider = Provider.of<ProveedorMovimientoProvider>(context, listen: false);
if(esPagoDirecto){
idTipoMovimiento=2;

}
                    await movimientoProvider.agregarMovimientoContable(
                      idCliente: project.clienteId ?? 0,
                      idServicio: 1 ??  0,
                      idTipoMovimiento:idTipoMovimiento , // Asumo que es egreso (tipo 1)
                      monto: double.tryParse(
  montoController.text
    .replaceAll('\$', '')  // Elimina símbolo de moneda
    .replaceAll(',', '')   // Elimina comas (separadores de miles)
    .trim()
) ?? 0.0,
          
                      comentario: comentario,
                      idProyecto: widget.idProyecto ?? 0,
                      idAdmin: 1,
                      esPagoDirecto: esPagoDirecto,
                      idTrabajador: esMaterial ? null : proveedorSeleccionado!.id,
                      idProveedor: esMaterial ? proveedorSeleccionado!.id : null,
                    );
montoController.clear(); // Limpia el campo de monto  
                    _fetchData(); // Actualiza los datos después de guardar
                    Navigator.pop(context); // Cierra el diálogo
                  },
                  icon: Icon(Icons.save_alt),
                  label: Text('Guardar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );
}


bool esMaterial = true;
void _mostrarModalIngreso(BuildContext context, MovimientosPorUsuario usuario, String isPendiente) {
  final TextEditingController comentarioController = TextEditingController();
  final TextEditingController montoController = TextEditingController();

  final int idTipoMovimiento = isPendiente == 'Pendiente' ? 1 : 2; // 1 = Egreso, 2 = Ingreso

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        
        title: Text('Nuevo Movimiento Contable'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
      

    const SizedBox(height: 10),

// Campo para monto

// TextField(
//   controller: ,
//   decoration: InputDecoration(
//     labelText: '💰 Monto',
//     hintText: 'Ingresa un monto',
//     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//     prefixIcon: Icon(Icons.attach_money),
//   ),
//   keyboardType: TextInputType.numberWithOptions(decimal: true),
//   inputFormatters: [
//     FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
//   ],
// ),
  _buildBudgetField(montoController),

const SizedBox(height: 16),

// Campo para comentario
TextField(
  controller: comentarioController,
  decoration: InputDecoration(
    labelText: '📝 Comentario',
    hintText: 'Escribe un comentario',
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    prefixIcon: Icon(Icons.comment),
  ),
  maxLines: 4,
  minLines: 3,
  keyboardType: TextInputType.multiline,
),

            ],
          ),
        ),
        actions: [
         Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    // Botón Cancelar
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: OutlinedButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.cancel, color: Colors.red),
        label: Text('Cancelar', style: TextStyle(color: Colors.red)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    ),
    // Botón Confirmar y Guardar
    ElevatedButton.icon(
      onPressed: () async {
        final movimientoProvider = Provider.of<ProveedorMovimientoProvider>(context, listen: false);

        await movimientoProvider.agregarMovimientoContable(
          idCliente: project.clienteId ?? 0,
          idServicio: usuario.movimientos[0].idServicio ?? 0,
          idTipoMovimiento:idTipoMovimiento,
          // monto: double.tryParse(montoController.text) ?? 0.0,
          monto: double.tryParse(
  montoController.text
    .replaceAll('\$', '')  // Elimina símbolo de moneda
    .replaceAll(',', '')   // Elimina comas (separadores de miles)
    .trim()
) ?? 0.0,
          comentario: comentarioController.text,
          idProyecto: widget.idProyecto ?? 0,
          esPagoDirecto: false,
          idAdmin: 1,
          idTrabajador: usuario.movimientos[0].idTrabajador,
          idProveedor: usuario.movimientos[0].idProveedor,
        );
   _fetchData();
        Navigator.pop(context);
           Navigator.pop(context);
      },
      icon: Icon(Icons.save_alt),
      label: Text('Guardar'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
  ],
),

        ],
      );
    },
  );
}

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
        labelText: '💰 Monto',
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


void _abrirModalDetalle(BuildContext context, MovimientosPorUsuario usuario, List<Grupo> movimientos, {required bool isRestando}) {
  var nombre = usuario.usuario.nombre;
  final List<TextEditingController> _descControllers = [];
  final List<TextEditingController> _montoControllers = [];
  final List<bool> _isEditingList = List.generate(movimientos.length, (_) => false);


 // ORDENAR MOVIMIENTOS: MÁS NUEVOS ARRIBA (antes de mostrar el modal)
  movimientos.sort((a, b) => b.fecha.compareTo(a.fecha));

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxWidth: MediaQuery.of(context).size.width * 0.95,
      minWidth: MediaQuery.of(context).size.width * 0.95,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    builder: (context) {
      
  final total = movimientos.fold(0.0, (sum, m) {
        if (m.tipoMovimiento == 1) return sum + m.monto;
        else if (m.tipoMovimiento == 2 && !m.pagoDirecto) return sum - m.monto;
        return sum;
      });
      return StatefulBuilder(
        builder: (context, setStateModal) {
          // Inicializar controladores si están vacíos
          if (_descControllers.isEmpty) {
            _descControllers.addAll(movimientos.map((mov) => TextEditingController(text: mov.descripcion)));
            _montoControllers.addAll(movimientos.map((mov) => TextEditingController(text: mov.monto.toString())));
          }

          return Padding(
            padding: EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: SingleChildScrollView(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('Detalles de $nombre', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      Divider(),
      SizedBox(height: 8),
      
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: 
        
        DataTable(
  columnSpacing: 20,
  dataRowHeight: 60,
  columns: const [
    DataColumn(label: SizedBox(width: 40, child: Text('Tipo'))),
    DataColumn(label: SizedBox(width: 200, child: Text('Comentario'))),
    DataColumn(label: SizedBox(width: 100, child: Text('Monto'))),
    DataColumn(label: SizedBox(width: 150, child: Text('Fecha'))),
    DataColumn(label: SizedBox(width: 150, child: Text('Pago Directo'))),
    DataColumn(label: SizedBox(width: 120, child: Text('Acciones'))),
  ],
  rows: List<DataRow>.generate(movimientos.length, (index) {
    final mov = movimientos[index];
    final isEditing = _isEditingList[index];
    
    final (icon, color) = switch (mov.tipoMovimiento) {
      1 => (Icons.pending, Colors.orange),
      2 => (Icons.check_circle, Colors.green),
      3 => (Icons.arrow_circle_down, Colors.red),
      _ => (Icons.help_outline, Colors.grey),
    };

    return DataRow(
      cells: [
        DataCell(
          Tooltip(
            message: switch (mov.tipoMovimiento) {
              1 => 'Pendiente',
              2 => 'Pagado',
              3 => 'Reversado',
              _ => 'Otro',
            },
            child: Icon(icon, color: color, size: 20),
          ),
        ),
        DataCell(
          isEditing
            ? TextField(
                controller: _descControllers[index],
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(8),
                ),
              )
            : Text(mov.descripcion),
        ),
        DataCell(
          isEditing
            ? _buildBudgetField(_montoControllers[index])
            : Text('\$${NumberFormatter.formatCurrency(mov.monto)}')
        ),
        DataCell(Text(DateFormat("d 'de' MMMM 'de' yyyy").format(mov.fecha))),
        DataCell(
          Center(
            child: isEditing
              ? Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: mov.tipoMovimiento == 2,
                    onChanged: (value) {
                      setStateModal(() {
                        movimientos[index] = Grupo(
                          idMovimiento: mov.idMovimiento,
                          pagoDirecto: value,
                          descripcion: mov.descripcion,
                          monto: mov.monto,
                          fecha: mov.fecha,
                          estado: mov.estado,
                          tipoMovimiento: value ? 2 : 1,
                        );
                      });
                    },
                    activeColor: Colors.green,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                )
              : Icon(
                  mov.tipoMovimiento == 2 ? Icons.check : Icons.close,
                  color: mov.tipoMovimiento == 2 ? Colors.green : Colors.red,
                  size: 24,
                ),
          ),
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
                      final movimientoProvider = Provider.of<ProveedorMovimientoProvider>(context, listen: false);
                      
                      // Validaciones
                      if (_descControllers[index].text.isEmpty) {
                        throw Exception('El comentario no puede estar vacío');
                      }
                      
                      final monto = double.tryParse(
                        _montoControllers[index].text
                          .replaceAll('\$', '')
                          .replaceAll(',', '')
                          .trim()
                      ) ?? mov.monto;
                      
                      if (monto <= 0) {
                        throw Exception('El monto debe ser mayor a cero');
                      }
// Envío al backend
print('Enviando al backend:');
print('idMovimiento: ${mov.idMovimiento??0}');
print('monto: $monto');
print('comentario: ${_descControllers[index].text}');
print('tipoMovimiento: ${mov.tipoMovimiento}');
print('pagoDirecto: ${mov.tipoMovimiento == 2}');

                      // Envío al backend
                      await movimientoProvider.editarMovimientoContable(
                        idMovimiento: mov.idMovimiento??0,
                        monto: monto,
                        comentario: _descControllers[index].text,
                        tipoMovimiento: mov.tipoMovimiento,
                        pagoDirecto: mov.tipoMovimiento == 2,
                      );

                      // Cierre de edición
                      setStateModal(() {
                        _isEditingList[index] = false;
                      });

//         DataTable(
//           columnSpacing: 20,
//           dataRowHeight: 60,
//           columns: const [
//             DataColumn(label: SizedBox(width: 40, child: Text('Tipo'))),  // Nueva columna compacta
//             DataColumn(label: SizedBox(width: 200, child: Text('Comentario'))),
//             DataColumn(label: SizedBox(width: 100, child: Text('Monto'))),
//             DataColumn(label: SizedBox(width: 150, child: Text('Fecha'))),
//             DataColumn(label: SizedBox(width: 120, child: Text('Acciones'))),
//           ],
//           rows: List<DataRow>.generate(movimientos.length, (index) {
//             final mov = movimientos[index];
//             final isEditing = _isEditingList[index];
            
//             // Configuración visual según tipoMovimiento
//             final (icon, color) = switch (mov.tipoMovimiento) {
//               1 => (Icons.pending, Colors.orange),      // Pendiente
//               2 => (Icons.check_circle, Colors.green),   // Pagado
//               3 => (Icons.arrow_circle_down, Colors.red), // Negativo
//               _ => (Icons.help_outline, Colors.grey),    // Default
//             };

//             return DataRow(
//               cells: [
//                 DataCell(  // Nueva celda de tipo
//                   Tooltip(
//                     message: switch (mov.tipoMovimiento) {
//                       1 => 'Pendiente',
//                       2 => 'Pagado',
//                       3 => 'Reversado',
//                       _ => 'Otro',
//                     },
//                     child: Icon(icon, color: color, size: 20),
//                   ),
//                 ),
//                             DataCell(
//                               isEditing
//                                 ? TextField(
//                                     controller: _descControllers[index],
//                                     decoration: InputDecoration(
//                                       border: OutlineInputBorder(),
//                                       contentPadding: EdgeInsets.all(8),
//                                     ),
//                                   )
//                                 : Text(mov.descripcion),
//                             ),
//                             DataCell(
//                               isEditing
//                                 ? 
//                                                _buildBudgetField(_montoControllers[index])
//                                 // TextField(
//                                 //     controller: _montoControllers[index],
//                                 //     keyboardType: TextInputType.numberWithOptions(decimal: true),
//                                 //     decoration: InputDecoration(
//                                 //       border: OutlineInputBorder(),
//                                 //       contentPadding: EdgeInsets.all(8),
//                                 //     ),
//                                 //   )
                                  
//                                 : Text('\$${ NumberFormatter.formatCurrency(mov.monto)}')
//                             ),
//                             DataCell(Text(DateFormat("d 'de' MMMM 'de' yyyy").format(mov.fecha))),
//                          DataCell(
//   Row(
//     mainAxisSize: MainAxisSize.min,
//     children: [
//       IconButton(
//         icon: Icon(
//           isEditing ? Icons.save : Icons.edit,
//           color: isEditing ? Colors.green : Colors.blue,
//           size: 20,
//         ),
//         onPressed: () async {
//           if (isEditing) {
//             try {
//               // Lógica para guardar
//               final movimientoProvider = Provider.of<ProveedorMovimientoProvider>(context, listen: false);
              
//               await movimientoProvider.editarMovimientoContable(
//                 idMovimiento: mov.idMovimiento??0,
              
//                // monto: double.tryParse(_montoControllers[index].text) ?? mov.monto,

//                 monto : double.tryParse(
//   _montoControllers[index].text
//     .replaceAll('\$', '')  // Elimina símbolo de moneda
//     .replaceAll(',', '')   // Elimina comas (separadores de miles)
//     .trim()
// ) ?? mov.monto,
//                 comentario: _descControllers[index].text
//               );
// _fetchData();
//               final updatedMov = Grupo(
//                 idMovimiento: mov.idMovimiento,
//                 pagoDirecto: mov.pagoDirecto,
//                 descripcion: _descControllers[index].text,
//                 monto: double.tryParse(_montoControllers[index].text) ?? mov.monto,
//                 fecha: mov.fecha,
//                 estado: mov.estado,
//                 tipoMovimiento: mov.tipoMovimiento,
//               );

//               setStateModal(() {
//                 movimientos[index] = updatedMov;
//                 _isEditingList[index] = false;
//               });

   _fetchData();

           Navigator.pop(context);


              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
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
            setStateModal(() {
              _isEditingList[index] = true;
            });
          }
        },
      ),
      IconButton(
        icon: Icon(Icons.delete, size: 20, color: Colors.red),
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Confirmar eliminación'),
              content: Text('¿Estás seguro de eliminar este movimiento?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Eliminar', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );

          if (confirmed ?? false) {
            try {
              await Provider.of<ProveedorMovimientoProvider>(context, listen: false)
                .eliminarMovimientoContable(idMovimiento: mov.idMovimiento?? 0  );

              setStateModal(() {
                movimientos.removeAt(index);
                _descControllers.removeAt(index);
                _montoControllers.removeAt(index);
                _isEditingList.removeAt(index);
              });

                 _fetchData();
        Navigator.pop(context);
        
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
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

                  Divider(),
                  Text('Total Adeudado Actual: \$${NumberFormatter.formatCurrency(total)}',
                   style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(Icons.add, color: Colors.white),
                        label: Text('Agregar Pendiente', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () => _mostrarModalIngreso(context, usuario, 'Pendiente'),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton.icon(
                        icon: Icon(Icons.remove, color: Colors.white),
                        label: Text('Saldo Pagado', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () => _mostrarModalIngreso(context, usuario, 'Pagado'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      );
    },
  );
}


double  TotalMaterialGlobal =0.00;
double TotalManoObraGlobal = 0.00;

  double totalPagado = 0.00;
  double totalAdeudado = 0.00;  
bool _isLoadingProject = false; // declara esta variable en tu State

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProveedorMovimientoProvider>(context);

    return Scaffold(

     appBar:AppBar(
              backgroundColor: Colors.black,
              iconTheme: IconThemeData(color: Colors.white),
              title: Text("Proyectos", style: TextStyle(color: Colors.white)),
            ),
      drawer: AppDrawer(),
        


//       appBar: AppBar(
//   title: const Text('Movimientos por Usuario'),
//   leading: IconButton(
//     icon: Icon(Icons.arrow_back),
//     onPressed: () {
//       Navigator.pop(context, true); // <- devuelve `true` para que la anterior sepa que debe refrescar
//     },
//   ),
// ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage != null
              ? Center(child: Text(provider.errorMessage!))
              : Column(
                children: [
                  Flexible(
  flex: 2,
 child: Container(
  height: double.infinity,
  color: Colors.black12,
  padding: EdgeInsets.all(20),
  child: _isLoadingProject || project == null
      ? const Center(child: CircularProgressIndicator())
      : ProjectProfileCompactSection(
          projectName: project!.nombre,
          client: project!.clienteNombre,
          budget: project!.presupuesto.toString(),
          location: project!.ubicacion,
          advances: project!.adelantos.toString(),
          startDate: project!.fechaInicio.toString(),
          endDate: project!.fechaFin.toString(),
          comentario: project!.comentario ?? 'Sin comentario'  ,
          cedula: project!.cedula ?? 'Sin cédula'  ,
          licencia: project!.licencia ?? 'Sin licencia'  ,
          //ruc: project!.clienteRuc ?? 'Sin RUC' ,
          phone: project!.telefono ?? 'Sin teléfono',
          type: 'Tipo', // Ajusta según modelo
          estado: 'En Progreso',
          isActive: project!.estado == 'En Progreso',
          imageUrl: "https://cdn.pixabay.com/photo/2016/11/29/09/15/architecture-1868667_960_720.jpg",
          idProyecto: widget.idProyecto,
        ),
),
),
Flexible(
  flex: 4,
  child: Row(
    children: [
      // Materiales
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

             ListTile(
          title: Text('Materiales', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          trailing: ElevatedButton.icon(
            onPressed: () => {           _abrirDialogoAgregarGasto(esMaterial),},
            
 
            icon: Icon(Icons.add),
            label: Text('Agregar'),
          ),
        ),
       
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.movimientosPorUsuario.length,
                itemBuilder: (context, index) {
                  final usuario = provider.movimientosPorUsuario[index];
                  // Filtrar movimientos que tienen idProveedor (materiales)
                  final movimientosMateriales =
                      usuario.movimientos.where((m) => m.idProveedor != null).toList();
                      movimientosMateriales.sort((a, b) => b.fecha.compareTo(a.fecha));
                  if (movimientosMateriales.isEmpty) return const SizedBox.shrink();

double totalDeuda = 0;
double totalPagosAplicables = 0;

for (final m in movimientosMateriales) {
  if (m.tipoMovimiento == 1) {
    totalDeuda += m.monto;
  } else if (m.tipoMovimiento == 2 && !m.pagoDirecto) {
    totalPagosAplicables += m.monto;
  }
}

final totalMateriales = totalDeuda - totalPagosAplicables;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    child: ExpansionTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(usuario.usuario.nombre,
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('Total Adeudado: \$${ NumberFormatter.formatCurrency(totalMateriales)}'),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.info_outline, color: Colors.blue),
                            onPressed: () {
                              _abrirModalDetalle(
                                context,
                                usuario,
                                movimientosMateriales
                                    .map((m) => Grupo(
                                      idMovimiento: m.id,
                                      pagoDirecto: m.pagoDirecto  ,
                                          descripcion: m.comentario,
                                          estado: m.tipoMovimiento.toString(),
                                          fecha: DateTime.parse(m.fecha),
                                          monto: m.monto,
                                          tipoMovimiento: m.tipoMovimiento,
                                        ))
                                    .toList(),
                                isRestando: false,
                              );
                            },
                          ),
                        ],
                      ),
                     children: [
  SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: DataTable(
  columns: const [
    DataColumn(label: Text('Tipo')),
    DataColumn(label: Text('Comentario')),
    DataColumn(label: Text('Monto')),
    DataColumn(label: Text('Fecha')),
  ],
  rows: movimientosMateriales.map((mov) {
    // Determinar icono, color y texto según tipoMovimiento
    final (icon, color, tooltipText) = switch (mov.tipoMovimiento) {
      1 => (Icons.pending, Colors.orange, 'Pendiente'),
      2 => (Icons.payments, Colors.green, 'Pagado'), 
      3 => (Icons.arrow_circle_down, Colors.red, 'Pago negativo'),
      _ => (Icons.help_outline, Colors.grey, 'Otro'),
    };

    // Formatear monto
    final montoFormateado = NumberFormatter.formatCurrency(mov.monto.abs());
    final simbolo = mov.monto < 0 ? '-\$' : '\$';

    return DataRow(
      cells: [
        DataCell(
          Tooltip(
            message: tooltipText,
            child: Icon(icon, color: color),
          ),
        ),
        DataCell(Text(mov.comentario)),
        DataCell(
          Text(
            '$simbolo$montoFormateado',
            style: TextStyle(
              color: mov.monto < 0 ? Colors.red : null,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DataCell(
          Text(
            DateFormat("d 'de' MMMM 'de' yyyy")
                .format(DateTime.parse(mov.fecha)),
          ),
        ),
      ],
    );
  }).toList(),
)
  ),
],

                    ),
                  );
                },
              ),
            ),
// Row para el total de Materiales
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    Column(
      children: [
        Text('Total de Materiales', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Text( NumberFormatter.formatCurrency(TotalMaterialGlobal), style: TextStyle(color: Colors.blue)),
      ],
    ),
  ]
)



          ],
        ),
      ),

      Container(width: 1, color: Colors.grey[300]),

      // Mano de obra
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                   ListTile(
          title: Text('Mano de Obra', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          trailing: ElevatedButton.icon(
            onPressed: () => {
             
              _abrirDialogoAgregarGasto(false),},
            
            //
            icon: Icon(Icons.add),
            label: Text('Agregar'),
          ),
        ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.movimientosPorUsuario.length,
                itemBuilder: (context, index) {
                  final usuario = provider.movimientosPorUsuario[index];
                  // Filtrar movimientos que tienen idTrabajador (mano de obra)
                  final movimientosManoObra =
                      usuario.movimientos.where((m) => m.idTrabajador != null).toList();

                      movimientosManoObra.sort((a, b) => b.fecha.compareTo(a.fecha));
                  if (movimientosManoObra.isEmpty) return const SizedBox.shrink();

//        final totalManoObra = movimientosManoObra.fold(0.0, (sum, m) {
//   if (m.tipoMovimiento == 1) {
//     return sum + m.monto; // SUMAR deudas (tipo 1)
//   } else if (m.tipoMovimiento == 2) {
//     return sum - m.monto; // RESTAR pagos (tipo 2) - TODOS restan
//   } else {
//     return sum; // ignorar otros tipos
//   }
// });
final totalManoObra = movimientosManoObra.fold(0.0, (sum, m) {
  if (m.tipoMovimiento == 1) {
    return sum + m.monto; // SUMAR deudas (tipo 1)
  } else if (m.tipoMovimiento == 2 && !m.pagoDirecto) {
    return sum - m.monto; // RESTAR pagos (tipo 2) solo si NO son pago directo
  } else {
    return sum; // ignorar pagos directos y otros tipos
  }
});
final totalPagado = movimientosManoObra.fold(0.0, (sum, m) {
  return m.tipoMovimiento == 2 ? sum + m.monto : sum;
});
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    child: ExpansionTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Expanded(
                          //   child: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       Text(usuario.usuario.nombre,
                          //           style: const TextStyle(fontWeight: FontWeight.bold)),
                          //       Text('Total Adeudado: \$${ NumberFormatter.formatCurrency(totalManoObra)}'),
                          //     ],
                          //   ),
                          // ),
                 Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(usuario.usuario.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      Row(
        children: [
          // Total Pagado (verde)
          Text('Pagado: ',
              style: TextStyle(color: Colors.grey[600])),
          Text('\$${NumberFormatter.formatCurrency(totalPagado)}',
              style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold)),
          
          SizedBox(width: 16), // Espacio entre los valores
          
          // Total Adeudado (rojo/naranja si hay deuda)
          Text('Adeudado linea: ',
              style: TextStyle(color: Colors.grey[600])),
          Text('\$${NumberFormatter.formatCurrency(totalManoObra)}',
              style: TextStyle(
                  color: totalManoObra > 0 ? Colors.orange[700] : Colors.green[700],
                  fontWeight: FontWeight.bold)),
        ],
      ),
    ],
  ),
),
                          IconButton(
                            icon: const Icon(Icons.info_outline, color: Colors.blue),
                            onPressed: () {

                  
                              _abrirModalDetalle(
                                context,
                                usuario,
                                movimientosManoObra
                                    .map((m) => Grupo(
                                      idMovimiento: m.id   ,
                                      pagoDirecto: m.pagoDirecto,
                                          descripcion: m.comentario,
                                          estado: m.tipoMovimiento.toString(),
                                        fecha: DateTime.parse(m.fecha),
                                          monto: m.monto,
                                          tipoMovimiento: m.tipoMovimiento, 
                                        ))
                                    .toList(),
                                isRestando: false,
                              );
                            },
                          ),
                        ],
                      ),
                                 children: [
  SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: DataTable(
  columns: const [
    DataColumn(label: Text('Tipo')),
    DataColumn(label: Text('Comentario')),
    DataColumn(label: Text('Monto')),
    DataColumn(label: Text('Fecha')),
  ],
  rows: movimientosManoObra.map((mov) {
    // Determinar icono, color y texto según tipoMovimiento
    final (icon, color, tooltipText) = switch (mov.tipoMovimiento) {
      1 => (Icons.pending, Colors.orange, 'Pendiente'),
      2 => (Icons.payments, Colors.green, 'Pagado'), 
      3 => (Icons.arrow_circle_down, Colors.red, 'Pago negativo'),
      _ => (Icons.help_outline, Colors.grey, 'Otro'),
    };

    // Formatear monto
    final montoFormateado = NumberFormatter.formatCurrency(mov.monto.abs());
    final simbolo = mov.monto < 0 ? '-\$' : '\$';

    return DataRow(
      cells: [
        DataCell(
          Tooltip(
            message: tooltipText,
            child: Icon(icon, color: color),
          ),
        ),
        DataCell(Text(mov.comentario)),
        DataCell(
          Text(
            '$simbolo$montoFormateado',
            style: TextStyle(
              color: mov.monto < 0 ? Colors.red : null,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DataCell(
          Text(
            DateFormat("d 'de' MMMM 'de' yyyy")
                .format(DateTime.parse(mov.fecha)),
          ),
        ),
      ],
    );
  }).toList(),
)
  ),
],

                    ),
                  );
                },
              ),
            ),

// Row para Mano de Obra: Total, Pagado, Adeudado
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    Column(
      children: [
        Text('Total de Mano de Obra', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Text( NumberFormatter.formatCurrency(TotalManoObraGlobal), style: TextStyle(color: Colors.blue)),
      ],
    ),
Column(
  children: [
    Text('Pagado', style: TextStyle(fontWeight: FontWeight.bold)),
    SizedBox(height: 4),
    Text(
       NumberFormatter.formatCurrency(totalPagado), // Muestra 2 decimales
      style: TextStyle(color: Colors.green),
    ),
  ],
),
Column(
  children: [
    Text('Adeudado', style: TextStyle(fontWeight: FontWeight.bold)),
    SizedBox(height: 4),
    Text(
       NumberFormatter.formatCurrency(totalAdeudado), // Muestra 2 decimales
      style: TextStyle(color: Colors.red),
    ),
  ],
),
  ],
)

            
          ],
        ),
      ),
    ],
  ),
),

                ],
              ),
    );


    
  }


}
class Grupo {
  final String descripcion;
  final int? idMovimiento;
  final String estado;
  final DateTime fecha;
  final double monto;
  bool pagoDirecto; // Agregado para indicar si es un pago directo
  final int tipoMovimiento;
  // Constructor para el grupo de movimientos

  Grupo({required this.descripcion,required this.pagoDirecto,required this.idMovimiento,required this.tipoMovimiento,required this.fecha, required this.estado, required this.monto});
}







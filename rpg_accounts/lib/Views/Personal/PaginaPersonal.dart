import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rpg_accounts/Drawer/AppDrawer.dart';

import 'package:http/http.dart' as http;
class AgregarPersonalManoDeObra extends StatefulWidget {
  @override
  _AgregarPersonalManoDeObraState createState() => _AgregarPersonalManoDeObraState();
}

class _AgregarPersonalManoDeObraState extends State<AgregarPersonalManoDeObra> {
  List<Proveedor> proveedores = [];
  List<String> tipos = ['Todos', 'Personal', 'Proveedor'];
  String selectedTipo = 'Todos';
  TextEditingController nombreController = TextEditingController();
  TextEditingController contactoController = TextEditingController();
  TextEditingController comentarioController = TextEditingController();
  TextEditingController searchController = TextEditingController();

final cedulaController = TextEditingController();
final licenciaController = TextEditingController();
final direccionController = TextEditingController();

int tipoUsuarioSeleccionado = 2; // 2 = Personal, 3 = Proveedor

  @override
  void initState() {
    super.initState();
    proveedores.addAll([
      Proveedor(nombre: 'Juan Pérez', contacto: '123456789', tipo: 'Personal', comentario: 'Electricista experto', deudas: [DeudaPago(montoPago: 500)]),
      Proveedor(nombre: 'Ana Gómez', contacto: '987654321', tipo: 'Proveedor', comentario: 'Proveedor de pintura', deudas: [DeudaPago(montoPago: 300)]),
      Proveedor(nombre: 'Carlos López', contacto: '111222333', tipo: 'Personal', comentario: 'Fontanero certificado', deudas: [DeudaPago(montoPago: 100)]),
      Proveedor(nombre: 'María Ruiz', contacto: '444555666', tipo: 'Proveedor', comentario: 'Suministro de materiales', deudas: [DeudaPago(montoPago: 200)]),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    List<Proveedor> proveedoresFiltrados = proveedores.where((proveedor) {
      final matchTexto = proveedor.nombre.toLowerCase().contains(searchController.text.toLowerCase()) || proveedor.comentario.toLowerCase().contains(searchController.text.toLowerCase());
      final matchTipo = selectedTipo == 'Todos' || proveedor.tipo == selectedTipo;
      return matchTexto && matchTipo;
    }).toList();return
Scaffold(
  appBar: AppBar(
    backgroundColor: Colors.black,
    iconTheme: IconThemeData(color: Colors.white),
  ),
  drawer: AppDrawer(),
  body: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      children: [
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            labelText: 'Buscar Proveedor/Personal',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 10),
        DropdownButton<String>(
          value: selectedTipo,
          onChanged: (value) => setState(() => selectedTipo = value!),
          items: tipos.map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo))).toList(),
        ),
        SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: FloatingActionButton(
            onPressed: () => _mostrarFormularioAgregarProveedor(context),
            backgroundColor: Colors.green,
            child: Icon(Icons.add),
          ),
        ),
        SizedBox(height: 10),
        Expanded(
          child: GridView.count(
            crossAxisCount: 8, // Cambié a 5 para que haya 5 elementos por fila
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            children: proveedoresFiltrados.map((proveedor) {
              final totalPagado = proveedor.deudas.fold(0.0, (sum, d) => sum + d.montoPago);
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 5,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _mostrarDetallesProveedor(context, proveedor),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(proveedor.nombre, style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(proveedor.tipo, style: TextStyle(color: Colors.grey[700])),
                        Text('Comentario: ${proveedor.comentario}', overflow: TextOverflow.ellipsis),
                        SizedBox(height: 4),
                        Text('Pagado: \$${totalPagado.toStringAsFixed(2)}'),
                        Text('Pendiente: \$${(4000 - totalPagado).toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    ),
  ),
);

  }
void _mostrarFormularioAgregarProveedor(BuildContext context) {
  nombreController.clear();
  contactoController.clear();
  comentarioController.clear();
  cedulaController.clear();
  licenciaController.clear();
  direccionController.clear();
  tipoUsuarioSeleccionado = 2; // Por defecto, Personal

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Agregar Proveedor o Personal'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(controller: nombreController, decoration: InputDecoration(labelText: 'Nombre')),
            TextField(controller: contactoController, decoration: InputDecoration(labelText: 'Teléfono')),
            TextField(controller: cedulaController, decoration: InputDecoration(labelText: 'Cédula')),
            TextField(controller: licenciaController, decoration: InputDecoration(labelText: 'Licencia')),
            TextField(controller: direccionController, decoration: InputDecoration(labelText: 'Dirección')),
            DropdownButton<int>(
              value: tipoUsuarioSeleccionado,
              items: const [
                DropdownMenuItem(value: 2, child: Text('Personal')),
                DropdownMenuItem(value: 3, child: Text('Proveedor')),
              ],
              onChanged: (value) {
                setState(() {
                  tipoUsuarioSeleccionado = value!;
                });
              },
            ),
            TextField(controller: comentarioController, decoration: InputDecoration(labelText: 'Comentario')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
        ElevatedButton(
          onPressed: () async {
            if (nombreController.text.isEmpty || contactoController.text.isEmpty || comentarioController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Complete todos los campos')));
              return;
            }

            await crearUsuario(
              nombreController.text,
              tipoUsuarioSeleccionado,
              contactoController.text,
              cedulaController.text,
              licenciaController.text,
              direccionController.text,
            );

            Navigator.pop(context);
          },
          child: Text('Agregar'),
        ),
      ],
    ),
  );
}
Future<void> crearUsuario(String nombre, int tipo, String telefono, String cedula, String licencia, String direccion) async {
  final response = await http.post(
    Uri.parse('http://localhost:3000/crear_usuario'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'Nombre_Usuario': nombre,
      'Id_Tipo_Usuario': tipo,
      'Telefono': telefono,
      'Cedula': cedula,
      'Licencia': licencia,
      'Direccion': direccion,
    }),
  );

  if (response.statusCode == 200) {
    print('Usuario creado correctamente');
  } else {
    print('Error al crear usuario: ${response.statusCode}');
  }
}

  void _mostrarDetallesProveedor(BuildContext context, Proveedor proveedor) {
    TextEditingController montoController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          double totalPagado = proveedor.deudas.fold(0, (sum, item) => sum + item.montoPago);
          return AlertDialog(
            title: Text('Detalles de ${proveedor.nombre}'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Contacto: ${proveedor.contacto}'),
                  Text('Tipo: ${proveedor.tipo}'),
                  Text('Comentario: ${proveedor.comentario}'),
                  SizedBox(height: 10),
                  Text('Pagos:'),
                  Column(
                    children: proveedor.deudas.map((d) => Text('- \$${d.montoPago.toStringAsFixed(2)}')).toList(),
                  ),
                  Divider(),
                  Text('Total Pagado: \$${totalPagado.toStringAsFixed(2)}'),
                  Text('Saldo Pendiente: \$${(4000 - totalPagado).toStringAsFixed(2)}'),
                  TextField(
                    controller: montoController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Nuevo pago'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      final monto = double.tryParse(montoController.text);
                      if (monto != null && monto > 0) {
                        setState(() => proveedor.deudas.add(DeudaPago(montoPago: monto)));
                        setModalState(() {});
                        montoController.clear();
                      }
                    },
                    child: Text('Agregar Pago'),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class Proveedor {
  String nombre;
  String contacto;
  String tipo; // 'Proveedor' o 'Personal'
  String comentario;
  List<DeudaPago> deudas;
  Proveedor({required this.nombre, required this.contacto, required this.tipo, required this.comentario, required this.deudas});
}

class DeudaPago {
  double montoPago;
  DeudaPago({required this.montoPago});
}

// import 'package:flutter/material.dart';
// import 'package:rpg_accounts/Drawer/AppDrawer.dart';

// class AgregarPersonalManoDeObra extends StatefulWidget {
//   @override
//   _AgregarPersonalManoDeObraState createState() =>
//       _AgregarPersonalManoDeObraState();
// }

// class _AgregarPersonalManoDeObraState extends State<AgregarPersonalManoDeObra> {
//   List<Trabajador> trabajadores = [];
//   List<String> servicios = ['Electricidad', 'Pintura', 'Fontanería'];
//   TextEditingController nombreController = TextEditingController();
//   TextEditingController contactoController = TextEditingController();
//   TextEditingController comentarioController = TextEditingController();
//   String selectedServicio = 'Electricidad';
//   TextEditingController searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     // Crear trabajadores por defecto
//     trabajadores.addAll([
//       Trabajador(
//         nombre: 'Juan Pérez',
//         contacto: '123456789',
//         servicio: 'Electricidad',
//         comentario: 'Trabajo de electricidad',
//         deudas: [DeudaPago(montoPago: 500)],
//       ),
//       Trabajador(
//         nombre: 'Ana Gómez',
//         contacto: '987654321',
//         servicio: 'Pintura',
//         comentario: 'Trabajo de pintura',
//         deudas: [DeudaPago(montoPago: 300)],
//       ),
//       Trabajador(
//         nombre: 'Carlos López',
//         contacto: '111222333',
//         servicio: 'Fontanería',
//         comentario: 'Trabajo de fontanería',
//         deudas: [DeudaPago(montoPago: 100)],
//       ),
//       Trabajador(
//         nombre: 'María Ruiz',
//         contacto: '444555666',
//         servicio: 'Electricidad',
//         comentario: 'Instalación eléctrica',
//         deudas: [DeudaPago(montoPago: 200)],
//       ),
//       Trabajador(
//         nombre: 'Luis Fernández',
//         contacto: '777888999',
//         servicio: 'Pintura',
//         comentario: 'Pintura de interiores',
//         deudas: [DeudaPago(montoPago: 400)],
//       ),
//     ]);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         iconTheme: IconThemeData(color: Colors.white),
//       ),
//       drawer: AppDrawer(),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Barra de búsqueda
//             TextField(
//               controller: searchController,
//               decoration: InputDecoration(
//                 labelText: 'Buscar Personal',
//                 prefixIcon: Icon(Icons.search),
//                 border: OutlineInputBorder(),
//               ),
//               onChanged: (query) {
//                 setState(() {});
//               },
//             ),
//             SizedBox(height: 20),
//             // Botón circular para agregar trabajador
//             FloatingActionButton(
//               onPressed: () => _mostrarFormularioAgregarTrabajador(context),
//               child: Icon(Icons.add),
//               backgroundColor: Colors.green,
//             ),
//             SizedBox(height: 20),
//             // Mostrar la lista de trabajadores en un grid
//             Expanded(
//               child: GridView.builder(
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 5,
//                   crossAxisSpacing: 10,
//                   mainAxisSpacing: 10,
//                 ),
//                 itemCount: trabajadores
//                     .where((trabajador) => trabajador.nombre
//                         .toLowerCase()
//                         .contains(searchController.text.toLowerCase()) ||
//                         trabajador.servicio
//                             .toLowerCase()
//                             .contains(searchController.text.toLowerCase()))
//                     .toList()
//                     .length,
//                 itemBuilder: (context, index) {
//                   final trabajador = trabajadores
//                       .where((trabajador) => trabajador.nombre
//                           .toLowerCase()
//                           .contains(searchController.text.toLowerCase()) ||
//                           trabajador.servicio
//                               .toLowerCase()
//                               .contains(searchController.text.toLowerCase()))
//                       .toList()[index];

//                   return Card(
//                     elevation: 5,
//                     child: InkWell(
//                       onTap: () {
//                         _mostrarDetallesTrabajador(context, trabajador);
//                       },
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Text(
//                             trabajador.nombre,
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text(trabajador.servicio),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Método para mostrar el formulario de agregar trabajador en un modal
//   void _mostrarFormularioAgregarTrabajador(BuildContext context) {
//     nombreController.clear();
//     contactoController.clear();
//     comentarioController.clear();
//     selectedServicio = 'Electricidad';

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Agregar Personal'),
//           content: SingleChildScrollView(
//             child: Column(
//               children: [
//                 TextField(
//                   controller: nombreController,
//                   decoration: InputDecoration(labelText: 'Nombre'),
//                 ),
//                 TextField(
//                   controller: contactoController,
//                   decoration: InputDecoration(labelText: 'Teléfono'),
//                 ),
//                 TextField(
//                   controller: comentarioController,
//                   decoration: InputDecoration(labelText: 'Comentario'),
//                 ),
//                 DropdownButtonFormField<String>(
//                   value: selectedServicio,
//                   items: servicios
//                       .map((servicio) => DropdownMenuItem<String>(
//                             value: servicio,
//                             child: Text(servicio),
//                           ))
//                       .toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       selectedServicio = value!;
//                     });
//                   },
//                   decoration: InputDecoration(labelText: 'Servicio'),
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: Text('Cancelar'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 // Validación de los campos
//                 if (nombreController.text.isEmpty ||
//                     contactoController.text.isEmpty ||
//                     comentarioController.text.isEmpty) {
//                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                       content: Text('Por favor, complete todos los campos')));
//                   return;
//                 }

//                 // Agregar el trabajador
//                 setState(() {
//                   trabajadores.add(Trabajador(
//                     nombre: nombreController.text,
//                     contacto: contactoController.text,
//                     servicio: selectedServicio,
//                     comentario: comentarioController.text,
//                     deudas: [],
//                   ));
//                 });

//                 Navigator.pop(context);
//               },
//               child: Text('Agregar'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Método para mostrar los detalles del trabajador
//   void _mostrarDetallesTrabajador(
//       BuildContext context, Trabajador trabajador) {
//     TextEditingController montoController = TextEditingController();
//     double totalPagado = trabajador.deudas.fold(0, (sum, item) => sum + item.montoPago);

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Detalles de ${trabajador.nombre}'),
//           content: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Información básica del trabajador
//                 Text('Nombre: ${trabajador.nombre}'),
//                 Text('Contacto: ${trabajador.contacto}'),
//                 Text('Servicio: ${trabajador.servicio}'),
//                 Text('Comentario: ${trabajador.comentario}'),
//                 SizedBox(height: 10),

//                 // Tabla de deudas y pagos
//                 Text('Deudas y Pagos:', style: TextStyle(fontWeight: FontWeight.bold)),
//                 DataTable(
//                   columns: [
//                     DataColumn(label: Text('Factura Total')),
//                     DataColumn(label: Text('Pagos Realizados')),
//                     DataColumn(label: Text('Saldo Pendiente')),
//                   ],
//                   rows: [
//                     DataRow(cells: [
//                       DataCell(Text('4000')),
//                       DataCell(Text('${totalPagado}')),
//                       DataCell(Text('${4000 - totalPagado}')),
//                     ]),
//                   ],
//                 ),
//                 SizedBox(height: 10),

//                 // Formulario para agregar un pago
//                 TextField(
//                   controller: montoController,
//                   decoration: InputDecoration(labelText: 'Monto de Pago'),
//                   keyboardType: TextInputType.number,
//                 ),
//                 SizedBox(height: 10),
//                 ElevatedButton(
//                   onPressed: () {
//                     // Agregar el pago
//                     setState(() {
//                       trabajador.deudas.add(DeudaPago(montoPago: double.tryParse(montoController.text) ?? 0));
//                       montoController.clear();
//                     });

//                     Navigator.pop(context);
//                   },
//                   child: Text('Agregar Pago'),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// // Clase para los trabajadores
// class Trabajador {
//   String nombre;
//   String contacto;
//   String servicio;
//   String comentario;
//   List<DeudaPago> deudas;

//   Trabajador({
//     required this.nombre,
//     required this.contacto,
//     required this.servicio,
//     required this.comentario,
//     required this.deudas,
//   });
// }

// // Clase para los pagos de deuda
// class DeudaPago {
//   double montoPago;

//   DeudaPago({required this.montoPago});
// }



// import 'package:flutter/material.dart';
// import 'package:rpg_accounts/Drawer/AppDrawer.dart';

// class AgregarPersonalManoDeObra extends StatefulWidget {
//   @override
//   _AgregarPersonalManoDeObraState createState() =>
//       _AgregarPersonalManoDeObraState();
// }

// class _AgregarPersonalManoDeObraState extends State<AgregarPersonalManoDeObra> {
//   List<Trabajador> trabajadores = [];
//   List<DeudaPago> pagos = [];

//   TextEditingController nombreController = TextEditingController();
//   TextEditingController contactoController = TextEditingController();
//   TextEditingController servicioController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar:
        
//          AppBar(
//           backgroundColor: Colors.black,
//           iconTheme: IconThemeData(color: Colors.white),
//         ),
//         drawer:AppDrawer(),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Formulario de entrada para agregar datos del trabajador
//             TextFormField(
//               controller: nombreController,
//               decoration: InputDecoration(labelText: 'Nombre'),
//             ),
//             TextFormField(
//               controller: contactoController,
//               decoration: InputDecoration(labelText: 'Contacto'),
//             ),
//             TextFormField(
//               controller: servicioController,
//               decoration: InputDecoration(labelText: 'Servicio Prestado'),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 // Agregar el trabajador a la lista
//                 setState(() {
//                   trabajadores.add(Trabajador(
//                     nombre: nombreController.text,
//                     contacto: contactoController.text,
//                     servicio: servicioController.text,
//                     deudas: [],
//                   ));
//                   nombreController.clear();
//                   contactoController.clear();
//                   servicioController.clear();
//                 });
//               },
//               child: Text('Agregar Trabajador'),
//             ),
//             SizedBox(height: 20),
//             // Mostrar la lista de trabajadores
//             Expanded(
//               child: ListView.builder(
//                 itemCount: trabajadores.length,
//                 itemBuilder: (context, index) {
//                   final trabajador = trabajadores[index];
//                   return Card(
//                     child: ListTile(
//                       title: Text(trabajador.nombre),
//                       subtitle: Text(trabajador.servicio),
//                       trailing: IconButton(
//                         icon: Icon(Icons.details),
//                         onPressed: () {
//                           _mostrarDetallesTrabajador(context, trabajador);
//                         },
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Método para mostrar los detalles del trabajador
//   void _mostrarDetallesTrabajador(
//       BuildContext context, Trabajador trabajador) {
//     TextEditingController montoController = TextEditingController();
//     double totalPagado = trabajador.deudas.fold(0, (sum, item) => sum + item.montoPago);

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Detalles de ${trabajador.nombre}'),
//           content: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Información básica del trabajador
//                 Text('Nombre: ${trabajador.nombre}'),
//                 Text('Contacto: ${trabajador.contacto}'),
//                 Text('Servicio: ${trabajador.servicio}'),
//                 SizedBox(height: 10),

//                 // Tabla de deudas y pagos
//                 Text('Deudas y Pagos:', style: TextStyle(fontWeight: FontWeight.bold)),
//                 DataTable(
//                   columns: [
//                     DataColumn(label: Text('Factura Total')),
//                     DataColumn(label: Text('Pagos Realizados')),
//                     DataColumn(label: Text('Saldo Pendiente')),
//                   ],
//                   rows: [
//                     DataRow(cells: [
//                       DataCell(Text('4000')),
//                       DataCell(Text('${totalPagado}')),
//                       DataCell(Text('${4000 - totalPagado}')),
//                     ]),
//                   ],
//                 ),
//                 SizedBox(height: 10),

//                 // Formulario para agregar un pago
//                 TextField(
//                   controller: montoController,
//                   decoration: InputDecoration(labelText: 'Monto de Pago'),
//                   keyboardType: TextInputType.number,
//                 ),
//                 SizedBox(height: 10),
//                 ElevatedButton(
//                   onPressed: () {
//                     // Agregar el pago
//                     setState(() {
//                       trabajador.deudas.add(DeudaPago(montoPago: double.tryParse(montoController.text) ?? 0));
//                       montoController.clear();
//                     });
//                     Navigator.pop(context);
//                   },
//                   child: Text('Agregar Pago'),
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('Cerrar'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// class Trabajador {
//   final String nombre;
//   final String contacto;
//   final String servicio;
//   List<DeudaPago> deudas;

//   Trabajador({
//     required this.nombre,
//     required this.contacto,
//     required this.servicio,
//     required this.deudas,
//   });
// }

// class DeudaPago {
//   final double montoPago;

//   DeudaPago({required this.montoPago});
// }
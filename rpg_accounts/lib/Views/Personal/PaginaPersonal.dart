import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rpg_accounts/Drawer/AppDrawer.dart';

import 'package:http/http.dart' as http;
import 'package:rpg_accounts/Models/Usuarios/UsuariosSistema.dart';
class AgregarPersonalManoDeObra extends StatefulWidget {
  @override
  _AgregarPersonalManoDeObraState createState() => _AgregarPersonalManoDeObraState();
}

class _AgregarPersonalManoDeObraState extends State<AgregarPersonalManoDeObra> {

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
@override
void initState() {
  super.initState();
  cargarUsuarios();
}
void cargarUsuarios() async {
  try {
    final data = await obtenerUsuarios();
    setState(() {
      usuarios = data;
      usuariosFiltrados = data;
    });
  } catch (e) {
    print('Error: $e');
  }
}
List<UsuarioSistema> usuarios = [];
List<UsuarioSistema> usuariosFiltrados = [];


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

Future<List<UsuarioSistema>> obtenerUsuarios() async {
  final response = await http.get(Uri.parse('http://localhost:3000/usuarios'));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => UsuarioSistema.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar los usuarios');
  }
}
List<PagoUsuario> pagosUsuario = [];

void filtrarUsuarios() {
  final texto = searchController.text.toLowerCase();

  setState(() {
    usuariosFiltrados = usuarios.where((u) {
      final coincideNombre = u.nombre.toLowerCase().contains(texto);
      final coincideTipo = selectedTipo == 'Todos' || selectedTipo == tipoUsuario(u.tipo);
      return coincideNombre && coincideTipo;
    }).toList();
  });
}

String tipoUsuario(int tipo) {
  switch (tipo) {
    case 1: return 'Administrador';
    case 2: return 'Conductor';
    case 3: return 'Proveedor';
    case 4: return 'Cliente';
    default: return 'Desconocido';
  }
}

  @override
  Widget build(BuildContext context) {
 return
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
         children: usuariosFiltrados.map((usuario) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 5,
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
_mostrarDetallesUsuario(context, usuario, pagosUsuario);

      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(usuario.nombre, style: TextStyle(fontWeight: FontWeight.bold)),
            Text(tipoUsuario(usuario.tipo), style: TextStyle(color: Colors.grey[700])),
            Text('Tel: ${usuario.telefono ?? 'N/D'}'),
            Text('Dirección: ${usuario.direccion ?? 'N/D'}', overflow: TextOverflow.ellipsis),
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

Widget buildUsuarioCard(BuildContext context, UsuarioSistema usuario) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 5,
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        // Aquí podrías mostrar detalles del usuario si deseas
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(usuario.nombre),
            content: Text('Dirección: ${usuario.direccion ?? "No registrada"}'),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(usuario.nombre, style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Tipo de usuario: ${usuario.tipo}', style: TextStyle(color: Colors.grey[700])),
            if (usuario.direccion != null)
              Text('Dirección: ${usuario.direccion}'),
          ],
        ),
      ),
    ),
  );
}
void _mostrarDetallesUsuario(BuildContext context, UsuarioSistema usuario, List<PagoUsuario> pagos) {
  TextEditingController montoController = TextEditingController();

  showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setModalState) {
        double totalPagado = pagos.fold(0, (sum, pago) => sum + pago.monto);

        return AlertDialog(
          title: Text('Detalles de ${usuario.nombre}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tipo Usuario: ${usuario.tipo}'),
                if (usuario.telefono != null) Text('Teléfono: ${usuario.telefono}'),
                if (usuario.cedula != null) Text('Cédula: ${usuario.cedula}'),
                if (usuario.licencia != null) Text('Licencia: ${usuario.licencia}'),
                if (usuario.direccion != null) Text('Dirección: ${usuario.direccion}'),
                SizedBox(height: 20),

                Text('Pagos Realizados:', style: TextStyle(fontWeight: FontWeight.bold)),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('N°')),
                      DataColumn(label: Text('Monto')),
                      DataColumn(label: Text('Fecha')),
                    ],
                    rows: List.generate(pagos.length, (index) {
                      final pago = pagos[index];
                      return DataRow(cells: [
                        DataCell(Text('${index + 1}')),
                        DataCell(Text('\$${pago.monto.toStringAsFixed(2)}')),
                        DataCell(Text('${pago.fecha.day}/${pago.fecha.month}/${pago.fecha.year}')),
                      ]);
                    }),
                  ),
                ),

                Divider(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Pagado: \$${totalPagado.toStringAsFixed(2)}'),
                    Text('Total Final: \$----'), // Reservado para lógica futura
                  ],
                ),

                SizedBox(height: 10),

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
                      setModalState(() {
                        pagos.add(PagoUsuario(monto: monto, fecha: DateTime.now()));
                        montoController.clear();
                      });
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

class PagoUsuario {
  final double monto;
  final DateTime fecha;

  PagoUsuario({required this.monto, required this.fecha});
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
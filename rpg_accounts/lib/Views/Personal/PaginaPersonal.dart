import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rpg_accounts/Drawer/AppDrawer.dart';
import 'package:rpg_accounts/Models/Usuarios/UsuariosSistema.dart';

class AgregarPersonalManoDeObra extends StatefulWidget {
  @override
  _AgregarPersonalManoDeObraState createState() => _AgregarPersonalManoDeObraState();
}

class _AgregarPersonalManoDeObraState extends State<AgregarPersonalManoDeObra> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController contactoController = TextEditingController();
  final TextEditingController cedulaController = TextEditingController();
  final TextEditingController licenciaController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();

  List<UsuarioSistema> usuarios = [];
  List<UsuarioSistema> usuariosFiltrados = [];
  List<String> tipos = ['Todos', 'Personal', 'Proveedor', 'Cliente'];
  String selectedTipo = 'Todos';
  int tipoUsuarioSeleccionado = 2;

  @override
  void initState() {
    super.initState();
    cargarUsuarios();
  }

  Future<void> cargarUsuarios() async {
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

  Future<List<UsuarioSistema>> obtenerUsuarios() async {
    final response = await http.get(Uri.parse('http://localhost:3002/usuarios'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => UsuarioSistema.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los usuarios');
    }
  }

  Future<void> actualizarUsuario(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('http://localhost:3002/actualizar_usuario/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      await cargarUsuarios();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Usuario actualizado correctamente')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al actualizar usuario')));
    }
  }

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

  // Future<void> crearUsuario(String nombre, int tipo, String telefono, String cedula, String licencia, String direccion) async {
  //   final response = await http.post(
  //     Uri.parse('http://localhost:3002crear_usuario'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: json.encode({
  //       'Nombre_Usuario': nombre,
  //       'Id_Tipo_Usuario': tipo,
  //       'Telefono': telefono,
  //       'Cedula': cedula,
  //       'Licencia': licencia,
  //       'Direccion': direccion,
  //     }),
  //   );
Future<void> crearUsuario(
  String nombre, 
  int tipo, 
  String telefono, 
  String cedula, 
  String licencia, 
  String direccion,
  String placa,
  String cuentaBancaria,
  String comentario,
) async {
    final response = await http.post(
      Uri.parse('http://localhost:3002/crear_usuario'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'Nombre_Usuario': nombre,
        'Id_Tipo_Usuario': tipo,
        'Telefono': telefono,
        'Cedula': cedula,
        'Licencia': licencia,
        'Direccion': direccion,
        'Placa_Auto': placa,
        'Cuenta_Banco': cuentaBancaria,
        'Comentario': comentario,
      }),
    );
    if (response.statusCode == 200) {
      await cargarUsuarios();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Usuario creado correctamente')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al crear usuario')));
    }
  }

  String tipoUsuario(int tipo) {
    switch (tipo) {
      case 1:
        return 'Administrador';
      case 2:
        return 'Personal';
      case 3:
        return 'Proveedor';
      case 4:
        return 'Cliente';
      default:
        return 'Desconocido';
    }
  }

void mostrarFormularioCrearUsuario() {
  // Limpiar controladores
  nombreController.clear();
  contactoController.clear();
  cedulaController.clear();
  licenciaController.clear();
  direccionController.clear();
  comentarioController.clear();
  placaController.clear();
  cuentaBancariaController.clear();
  tipoUsuarioSeleccionado = 2;

  showDialog(
    context: context,
    builder: (_) => Dialog(
      insetPadding: EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 500,
        padding: EdgeInsets.all(25),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_add, size: 24, color: Colors.blue),
                    SizedBox(width: 10),
                    Text('Nuevo Usuario', 
                      style: TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Campos principales en dos columnas
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Columna izquierda
                    Expanded(
                      child: Column(
                        children: [
                          buildInput(nombreController, 'Nombre', Icons.person, required: true),
                          SizedBox(height: 15),
                          buildInput(contactoController, 'Teléfono', Icons.phone, required: true),
                          SizedBox(height: 15),
                          buildInput(cedulaController, 'Cédula', Icons.badge),
                        ],
                      ),
                    ),
                    
                    SizedBox(width: 15),
                    
                    // Columna derecha
                    Expanded(
                      child: Column(
                        children: [
                          buildInput(licenciaController, 'Licencia', Icons.card_membership),
                          SizedBox(height: 15),
                          buildInput(direccionController, 'Dirección', Icons.location_on),
                          SizedBox(height: 15),
                          DropdownButtonFormField<int>(
                            value: tipoUsuarioSeleccionado,
                            decoration: InputDecoration(
                              labelText: 'Tipo de Usuario',
                              prefixIcon: Icon(Icons.group),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                            ),
                            items: [
                              DropdownMenuItem(value: 2, child: Text('Personal')),
                              DropdownMenuItem(value: 3, child: Text('Proveedor')),
                              DropdownMenuItem(value: 4, child: Text('Cliente')),
                            ],
                            onChanged: (value) => setState(() => tipoUsuarioSeleccionado = value!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Campos adicionales
                SizedBox(height: 15),
                buildInput(placaController, 'Placa de vehículo', Icons.directions_car),
                SizedBox(height: 15),
                buildInput(cuentaBancariaController, 'Cuenta bancaria', Icons.account_balance),
                SizedBox(height: 15),
                
                // Campo de comentario grande
                TextFormField(
                  controller: comentarioController,
                  decoration: InputDecoration(
                    labelText: 'Comentarios',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.comment),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  maxLength: 300,
                ),

                // Botones
                SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancelar', style: TextStyle(color: Colors.grey[600])),
                 ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await crearUsuario(
                            nombreController.text,
                            tipoUsuarioSeleccionado,
                            contactoController.text,
                            cedulaController.text,
                            licenciaController.text,
                            direccionController.text,
                            placaController.text,
                            cuentaBancariaController.text,
                            comentarioController.text,
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: Text('Guardar'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

TextEditingController comentarioController = TextEditingController();
TextEditingController placaController = TextEditingController();
TextEditingController cuentaBancariaController = TextEditingController();
void mostrarDetallesUsuario(UsuarioSistema usuario) {
  final nombre = TextEditingController(text: usuario.nombre);
  final telefono = TextEditingController(text: usuario.telefono);
  final cedula = TextEditingController(text: usuario.cedula);
  final licencia = TextEditingController(text: usuario.licencia?.toString() ?? '');
  final direccion = TextEditingController(text: usuario.direccion);
  final placa = TextEditingController(text: usuario.placaAuto ?? '');
  final cuentaBancaria = TextEditingController(text: usuario.cuentaBanco ?? '');
  final comentario = TextEditingController(text: usuario.comentario ?? '');
  int tipoUsuarioSeleccionado = usuario.id_tipo_usuario; // Usar el tipo actual del usuario

  showDialog(
    context: context,
    builder: (_) => Dialog(
      insetPadding: EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 500,
        padding: EdgeInsets.all(25),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline, size: 24, color: Colors.blue),
                  SizedBox(width: 10),
                  Text('Detalle de ${usuario.nombre}', 
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Campos en dos columnas
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Columna izquierda
                  Expanded(
                    child: Column(
                      children: [
                        buildInput(nombre, 'Nombre', Icons.person_outline),
                        SizedBox(height: 15),
                        buildInput(telefono, 'Teléfono', Icons.phone_outlined),
                        SizedBox(height: 15),
                        buildInput(cedula, 'Cédula', Icons.badge_outlined),
                      ],
                    ),
                  ),
                  
                  SizedBox(width: 15),
                  
                  // Columna derecha
                  Expanded(
                    child: Column(
                      children: [
                        buildInput(licencia, 'Licencia', Icons.credit_card_outlined),
                        SizedBox(height: 15),
                        buildInput(direccion, 'Dirección', Icons.home_outlined),
                        SizedBox(height: 15),
                        // Dropdown para tipo de usuario
                        DropdownButtonFormField<int>(
                          value: tipoUsuarioSeleccionado,
                          decoration: InputDecoration(
                            labelText: 'Tipo de Usuario',
                            prefixIcon: Icon(Icons.group_outlined),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                          ),
                          items: [
                            DropdownMenuItem(value: 1, child: Text('Administrador')),
                            DropdownMenuItem(value: 2, child: Text('Personal')),
                            DropdownMenuItem(value: 3, child: Text('Proveedor')),
                            DropdownMenuItem(value: 4, child: Text('Cliente')),
                          ],
                          onChanged: (value) => tipoUsuarioSeleccionado = value!,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Campos adicionales
              SizedBox(height: 15),
              buildInput(placa, 'Placa vehículo', Icons.directions_car_outlined),
              SizedBox(height: 15),
              buildInput(cuentaBancaria, 'Cuenta bancaria', Icons.account_balance_outlined),
              SizedBox(height: 15),
              
              // Campo de comentario grande
              TextFormField(
                controller: comentario,
                decoration: InputDecoration(
                  labelText: 'Comentarios',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.comment_outlined),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                maxLength: 300,
              ),

              // Botones
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancelar', style: TextStyle(color: Colors.grey[600])),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                    ),
                    onPressed: () async {
                      await actualizarUsuario(usuario.id, {
                        'Nombre_Usuario': nombre.text,
                        'Telefono': telefono.text,
                        'Cedula': cedula.text,
                        'Licencia': licencia.text,
                        'Direccion': direccion.text,
                        'Placa_Auto': placa.text,
                        'Cuenta_Banco': cuentaBancaria.text,
                        'Comentario': comentario.text,
                        'Id_Tipo_Usuario': tipoUsuarioSeleccionado, // Agregar este campo
                      });
                      Navigator.pop(context);
                    },
                    child: Text('Guardar cambios'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget buildInput(TextEditingController controller, String label, IconData icon, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        validator: required ? (value) => value!.isEmpty ? 'Campo requerido' : null : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Usuarios',style: TextStyle(color: Colors.white),),
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
                labelText: 'Buscar usuario',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => filtrarUsuarios(),
            ),
            SizedBox(height: 10),
            DropdownButton<String>(
              value: selectedTipo,
              onChanged: (value) {
                setState(() {
                  selectedTipo = value!;
                  filtrarUsuarios();
                });
              },
              items: tipos.map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo))).toList(),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: FloatingActionButton(
                onPressed: mostrarFormularioCrearUsuario,
                backgroundColor: Colors.green,
                child: Icon(Icons.add),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: usuariosFiltrados.length,
                itemBuilder: (context, index) {
                  final u = usuariosFiltrados[index];
                  return GestureDetector(
                    onTap: () => mostrarDetallesUsuario(u),
                    child: 
                    
                    
Card(
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  elevation: 6,
  child: Container(
    padding: EdgeInsets.all(8),
    child: Stack(
      children: [
        // Contenido principal centrado
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_circle, size: 36, color: Colors.blueGrey),
              SizedBox(height: 6),
              Text(
                u.nombre,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                tipoUsuario(u.tipo),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        // Botón de eliminar posicionado en la esquina superior derecha
    Positioned(
  top: 4,
  right: 4,
  child: IconButton(
    icon: Icon(Icons.delete, size: 20, color: Colors.red.withOpacity(0.7)),
    padding: EdgeInsets.zero,
    constraints: BoxConstraints(),
    onPressed: () => _mostrarDialogoEliminarUsuario(context, u),
  ),
),
      ],
    ),
  ),
),

                    // Card(
                    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    //   elevation: 6,
                    //   child: Container(
                    //     padding: EdgeInsets.all(12),
                    //     child: Column(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         Icon(Icons.account_circle, size: 36, color: Colors.blueGrey),
                    //         SizedBox(height: 10),
                    //         Text(
                    //           u.nombre,
                    //           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    //           textAlign: TextAlign.center,
                    //           maxLines: 2,
                    //           overflow: TextOverflow.ellipsis,
                    //         ),
                    //         SizedBox(height: 5),
                    //         Text(
                    //           tipoUsuario(u.tipo),
                    //           style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),



                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

void _mostrarDialogoEliminarUsuario(BuildContext context, UsuarioSistema usuario) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 12),
            Text(
              'Confirmar eliminación',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Estás seguro de eliminar al usuario:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '"${usuario.nombre}"',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Se borrará toda la información asociada a este usuario.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await eliminarUsuario(usuario.id);
            },
            child: Text('Eliminar', style: TextStyle(fontSize: 16)),
          ),
        ],
        actionsPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
      );
    },
  );
}

Future<void> eliminarUsuario(int id) async {
  final response = await http.delete(
    Uri.parse('http://localhost:3002/eliminar_usuario/$id'),
    headers: {'Content-Type': 'application/json'},
  );
  
  if (response.statusCode == 200) {
    await cargarUsuarios();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Usuario eliminado correctamente'))
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al eliminar usuario'))
    );
  }
}
}



// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:rpg_accounts/Drawer/AppDrawer.dart';
// import 'package:rpg_accounts/Models/Usuarios/UsuariosSistema.dart';

// class AgregarPersonalManoDeObra extends StatefulWidget {
//   @override
//   _AgregarPersonalManoDeObraState createState() => _AgregarPersonalManoDeObraState();
// }

// class _AgregarPersonalManoDeObraState extends State<AgregarPersonalManoDeObra> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController searchController = TextEditingController();
//   final TextEditingController nombreController = TextEditingController();
//   final TextEditingController contactoController = TextEditingController();
//   final TextEditingController cedulaController = TextEditingController();
//   final TextEditingController licenciaController = TextEditingController();
//   final TextEditingController direccionController = TextEditingController();

//   List<UsuarioSistema> usuarios = [];
//   List<UsuarioSistema> usuariosFiltrados = [];
//   List<String> tipos = ['Todos', 'Personal', 'Proveedor', 'Cliente'];
//   String selectedTipo = 'Todos';
//   int tipoUsuarioSeleccionado = 2;

//   @override
//   void initState() {
//     super.initState();
//     cargarUsuarios();
//   }

//   Future<void> cargarUsuarios() async {
//     try {
//       final data = await obtenerUsuarios();
//       setState(() {
//         usuarios = data;
//         usuariosFiltrados = data;
//       });
//     } catch (e) {
//       print('Error: $e');
//     }
//   }

//   Future<List<UsuarioSistema>> obtenerUsuarios() async {
//     final response = await http.get(Uri.parse('http://localhost:3002usuarios'));
//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);
//       return data.map((json) => UsuarioSistema.fromJson(json)).toList();
//     } else {
//       throw Exception('Error al cargar los usuarios');
//     }
//   }

//   void filtrarUsuarios() {
//     final texto = searchController.text.toLowerCase();
//     setState(() {
//       usuariosFiltrados = usuarios.where((u) {
//         final coincideNombre = u.nombre.toLowerCase().contains(texto);
//         final coincideTipo = selectedTipo == 'Todos' || selectedTipo == tipoUsuario(u.tipo);
//         return coincideNombre && coincideTipo;
//       }).toList();
//     });
//   }

//   Future<void> crearUsuario(String nombre, int tipo, String telefono, String cedula, String licencia, String direccion) async {
//     final response = await http.post(
//       Uri.parse('http://localhost:3002crear_usuario'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({
//         'Nombre_Usuario': nombre,
//         'Id_Tipo_Usuario': tipo,
//         'Telefono': telefono,
//         'Cedula': cedula,
//         'Licencia': licencia,
//         'Direccion': direccion,
//       }),
//     );

//     if (response.statusCode == 200) {
//       await cargarUsuarios();
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Usuario creado correctamente')));
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al crear usuario')));
//     }
//   }

//   String tipoUsuario(int tipo) {
//     switch (tipo) {
//       case 1:
//         return 'Administrador';
//       case 2:
//         return 'Personal';
//       case 3:
//         return 'Proveedor';
//       case 4:
//         return 'Cliente';
//       default:
//         return 'Desconocido';
//     }
//   }

//   void mostrarFormularioCrearUsuario() {
//     nombreController.clear();
//     contactoController.clear();
//     cedulaController.clear();
//     licenciaController.clear();
//     direccionController.clear();
//     tipoUsuarioSeleccionado = 2;

//     showDialog(
//       context: context,
//       builder: (_) => Dialog(
//         insetPadding: EdgeInsets.all(20),
//         child: Container(
//           width: 500,
//           padding: EdgeInsets.all(20),
//           child: SingleChildScrollView(
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   Text('Nuevo Usuario', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                   SizedBox(height: 20),
//                   buildInput(nombreController, 'Nombre', Icons.person, required: true),
//                   buildInput(contactoController, 'Teléfono', Icons.phone, required: true),
//                   buildInput(cedulaController, 'Cédula', Icons.badge),
//                   buildInput(licenciaController, 'Licencia', Icons.card_membership),
//                   buildInput(direccionController, 'Dirección', Icons.location_on),
//                   DropdownButtonFormField<int>(
//                     value: tipoUsuarioSeleccionado,
//                     decoration: InputDecoration(labelText: 'Tipo de Usuario', prefixIcon: Icon(Icons.group)),
//                     items: [
//                       DropdownMenuItem(value: 2, child: Text('Personal')),
//                       DropdownMenuItem(value: 3, child: Text('Proveedor')),
//                       DropdownMenuItem(value: 4, child: Text('Cliente')),
//                     ],
//                     onChanged: (value) => setState(() => tipoUsuarioSeleccionado = value!),
//                   ),
//                   SizedBox(height: 20),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
//                       ElevatedButton(
//                         onPressed: () async {
//                           if (_formKey.currentState!.validate()) {
//                             await crearUsuario(
//                               nombreController.text,
//                               tipoUsuarioSeleccionado,
//                               contactoController.text,
//                               cedulaController.text,
//                               licenciaController.text,
//                               direccionController.text,
//                             );
//                             Navigator.pop(context);
//                           }
//                         },
//                         child: Text('Guardar'),
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void mostrarDetallesUsuario(UsuarioSistema usuario) {
//     final nombre = TextEditingController(text: usuario.nombre);
//     final telefono = TextEditingController(text: usuario.telefono);
//     final cedula = TextEditingController(text: usuario.cedula);
//     final licencia = TextEditingController(text: usuario.licencia?.toString() ?? '');
//     final direccion = TextEditingController(text: usuario.direccion);

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text('Detalle de ${usuario.nombre}'),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               buildInput(nombre, 'Nombre', Icons.person),
//               buildInput(telefono, 'Teléfono', Icons.phone),
//               buildInput(cedula, 'Cédula', Icons.badge),
//               buildInput(licencia, 'Licencia', Icons.card_membership),
//               buildInput(direccion, 'Dirección', Icons.location_on),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
//           ElevatedButton(onPressed: () {}, child: Text('Guardar')),
//         ],
//       ),
//     );
//   }

//   Widget buildInput(TextEditingController controller, String label, IconData icon, {bool required = false}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: TextFormField(
//         controller: controller,
//         validator: required ? (value) => value!.isEmpty ? 'Campo requerido' : null : null,
//         decoration: InputDecoration(
//           labelText: label,
//           prefixIcon: Icon(icon),
//           border: OutlineInputBorder(),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Gestión de Usuarios'),
//         backgroundColor: Colors.black,
//         iconTheme: IconThemeData(color: Colors.white),
//       ),
//       drawer: AppDrawer(),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: searchController,
//               decoration: InputDecoration(
//                 labelText: 'Buscar usuario',
//                 prefixIcon: Icon(Icons.search),
//                 border: OutlineInputBorder(),
//               ),
//               onChanged: (_) => filtrarUsuarios(),
//             ),
//             SizedBox(height: 10),
//             DropdownButton<String>(
//               value: selectedTipo,
//               onChanged: (value) {
//                 setState(() {
//                   selectedTipo = value!;
//                   filtrarUsuarios();
//                 });
//               },
//               items: tipos.map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo))).toList(),
//             ),
//             SizedBox(height: 10),
//             Align(
//               alignment: Alignment.centerRight,
//               child: FloatingActionButton(
//                 onPressed: mostrarFormularioCrearUsuario,
//                 backgroundColor: Colors.green,
//                 child: Icon(Icons.add),
//               ),
//             ),
//             SizedBox(height: 10),
//             Expanded(
//               child: GridView.builder(
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 8,
//                   childAspectRatio: 0.85,
//                   crossAxisSpacing: 12,
//                   mainAxisSpacing: 12,
//                 ),
//                 itemCount: usuariosFiltrados.length,
//                 itemBuilder: (context, index) {
//                   final u = usuariosFiltrados[index];
//                   return GestureDetector(
//                     onTap: () => mostrarDetallesUsuario(u),
//                     child: Card(
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                       elevation: 6,
//                       child: Container(
//                         padding: EdgeInsets.all(12),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.account_circle, size: 36, color: Colors.blueGrey),
//                             SizedBox(height: 10),
//                             Text(
//                               u.nombre,
//                               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//                               textAlign: TextAlign.center,
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             SizedBox(height: 5),
//                             Text(
//                               tipoUsuario(u.tipo),
//                               style: TextStyle(color: Colors.grey[600], fontSize: 12),
//                             ),
//                           ],
//                         ),
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
// }


// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:rpg_accounts/Drawer/AppDrawer.dart';

// import 'package:http/http.dart' as http;
// import 'package:rpg_accounts/Models/Usuarios/UsuariosSistema.dart';
// class AgregarPersonalManoDeObra extends StatefulWidget {
//   @override
//   _AgregarPersonalManoDeObraState createState() => _AgregarPersonalManoDeObraState();
// }

// class _AgregarPersonalManoDeObraState extends State<AgregarPersonalManoDeObra> {

//   List<String> tipos = ['Todos', 'Personal', 'Proveedor'];
//   String selectedTipo = 'Todos';
//   TextEditingController nombreController = TextEditingController();
//   TextEditingController contactoController = TextEditingController();
//   TextEditingController comentarioController = TextEditingController();
//   TextEditingController searchController = TextEditingController();

// final cedulaController = TextEditingController();
// final licenciaController = TextEditingController();
// final direccionController = TextEditingController();

// int tipoUsuarioSeleccionado = 2; // 2 = Personal, 3 = Proveedor

//   @override
// @override
// void initState() {
//   super.initState();
//   cargarUsuarios();
// }
// void cargarUsuarios() async {
//   try {
//     final data = await obtenerUsuarios();
//     setState(() {
//       usuarios = data;
//       usuariosFiltrados = data;
//     });
//   } catch (e) {
//     print('Error: $e');
//   }
// }
// List<UsuarioSistema> usuarios = [];
// List<UsuarioSistema> usuariosFiltrados = [];


// Future<void> crearUsuario(String nombre, int tipo, String telefono, String cedula, String licencia, String direccion) async {
//   final response = await http.post(
//     Uri.parse('http://localhost:3002crear_usuario'),
//     headers: {'Content-Type': 'application/json'},
//     body: json.encode({
//       'Nombre_Usuario': nombre,
//       'Id_Tipo_Usuario': tipo,
//       'Telefono': telefono,
//       'Cedula': cedula,
//       'Licencia': licencia,
//       'Direccion': direccion,
//     }),
//   );

//   if (response.statusCode == 200) {
//     print('Usuario creado correctamente');
//   } else {
//     print('Error al crear usuario: ${response.statusCode}');
//   }
// }

// Future<List<UsuarioSistema>> obtenerUsuarios() async {
//   final response = await http.get(Uri.parse('http://localhost:3002usuarios'));

//   if (response.statusCode == 200) {
//     final List<dynamic> data = json.decode(response.body);
//     return data.map((json) => UsuarioSistema.fromJson(json)).toList();
//   } else {
//     throw Exception('Error al cargar los usuarios');
//   }
// }
// List<PagoUsuario> pagosUsuario = [];

// void filtrarUsuarios() {
//   final texto = searchController.text.toLowerCase();

//   setState(() {
//     usuariosFiltrados = usuarios.where((u) {
//       final coincideNombre = u.nombre.toLowerCase().contains(texto);
//       final coincideTipo = selectedTipo == 'Todos' || selectedTipo == tipoUsuario(u.tipo);
//       return coincideNombre && coincideTipo;
//     }).toList();
//   });
// }

// String tipoUsuario(int tipo) {
//   switch (tipo) {
//     case 1: return 'Administrador';
//     case 2: return 'Conductor';
//     case 3: return 'Proveedor';
//     case 4: return 'Cliente';
//     default: return 'Desconocido';
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//  return
// Scaffold(
//   appBar: AppBar(
//     backgroundColor: Colors.black,
//     iconTheme: IconThemeData(color: Colors.white),
//   ),
//   drawer: AppDrawer(),
//   body: Padding(
//     padding: const EdgeInsets.all(16.0),
//     child: Column(
//       children: [
//         TextField(
//           controller: searchController,
//           decoration: InputDecoration(
//             labelText: 'Buscar Proveedor/Personal',
//             prefixIcon: Icon(Icons.search),
//             border: OutlineInputBorder(),
//           ),
//           onChanged: (_) => setState(() {}),
//         ),
//         SizedBox(height: 10),
//         DropdownButton<String>(
//           value: selectedTipo,
//           onChanged: (value) => setState(() => selectedTipo = value!),
//           items: tipos.map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo))).toList(),
//         ),
//         SizedBox(height: 10),
//         Align(
//           alignment: Alignment.centerRight,
//           child: FloatingActionButton(
//             onPressed: () => _mostrarFormularioAgregarProveedor(context),
//             backgroundColor: Colors.green,
//             child: Icon(Icons.add),
//           ),
//         ),
//         SizedBox(height: 10),
//         Expanded(
//           child: GridView.count(
//             crossAxisCount: 8, // Cambié a 5 para que haya 5 elementos por fila
//             mainAxisSpacing: 20,
//             crossAxisSpacing: 20,
//          children: usuariosFiltrados.map((usuario) {
//   return Card(
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//     elevation: 5,
//     child: InkWell(
//       borderRadius: BorderRadius.circular(12),
//       onTap: () {
// _mostrarDetallesUsuario(context, usuario, pagosUsuario);

//       },
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(usuario.nombre, style: TextStyle(fontWeight: FontWeight.bold)),
//             Text(tipoUsuario(usuario.tipo), style: TextStyle(color: Colors.grey[700])),
//             Text('Tel: ${usuario.telefono ?? 'N/D'}'),
//             Text('Dirección: ${usuario.direccion ?? 'N/D'}', overflow: TextOverflow.ellipsis),
//           ],
//         ),
//       ),
//     ),
//   );
// }).toList(),

//           ),
//         ),
//       ],
//     ),
//   ),
// );

//   }
// void _mostrarFormularioAgregarProveedor(BuildContext context) {
//   nombreController.clear();
//   contactoController.clear();
//   comentarioController.clear();
//   cedulaController.clear();
//   licenciaController.clear();
//   direccionController.clear();
//   tipoUsuarioSeleccionado = 2; // Por defecto, Personal

//   showDialog(
//     context: context,
//     builder: (_) => AlertDialog(
//       title: Text('Agregar Proveedor o Personal'),
//       content: SingleChildScrollView(
//         child: Column(
//           children: [
//             TextField(controller: nombreController, decoration: InputDecoration(labelText: 'Nombre')),
//             TextField(controller: contactoController, decoration: InputDecoration(labelText: 'Teléfono')),
//             TextField(controller: cedulaController, decoration: InputDecoration(labelText: 'Cédula')),
//             TextField(controller: licenciaController, decoration: InputDecoration(labelText: 'Licencia')),
//             TextField(controller: direccionController, decoration: InputDecoration(labelText: 'Dirección')),
//             DropdownButton<int>(
//               value: tipoUsuarioSeleccionado,
//               items: const [
//                 DropdownMenuItem(value: 2, child: Text('Personal')),
//                 DropdownMenuItem(value: 3, child: Text('Proveedor')),
//               ],
//               onChanged: (value) {
//                 setState(() {
//                   tipoUsuarioSeleccionado = value!;
//                 });
//               },
//             ),
//             TextField(controller: comentarioController, decoration: InputDecoration(labelText: 'Comentario')),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
//         ElevatedButton(
//           onPressed: () async {
//             if (nombreController.text.isEmpty || contactoController.text.isEmpty || comentarioController.text.isEmpty) {
//               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Complete todos los campos')));
//               return;
//             }

//             await crearUsuario(
//               nombreController.text,
//               tipoUsuarioSeleccionado,
//               contactoController.text,
//               cedulaController.text,
//               licenciaController.text,
//               direccionController.text,
//             );

//             Navigator.pop(context);
//           },
//           child: Text('Agregar'),
//         ),
//       ],
//     ),
//   );
// }

// Widget buildUsuarioCard(BuildContext context, UsuarioSistema usuario) {
//   return Card(
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//     elevation: 5,
//     child: InkWell(
//       borderRadius: BorderRadius.circular(12),
//       onTap: () {
//         // Aquí podrías mostrar detalles del usuario si deseas
//         showDialog(
//           context: context,
//           builder: (_) => AlertDialog(
//             title: Text(usuario.nombre),
//             content: Text('Dirección: ${usuario.direccion ?? "No registrada"}'),
//           ),
//         );
//       },
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(usuario.nombre, style: TextStyle(fontWeight: FontWeight.bold)),
//             Text('Tipo de usuario: ${usuario.tipo}', style: TextStyle(color: Colors.grey[700])),
//             if (usuario.direccion != null)
//               Text('Dirección: ${usuario.direccion}'),
//           ],
//         ),
//       ),
//     ),
//   );
// }
// void _mostrarDetallesUsuario(BuildContext context, UsuarioSistema usuario, List<PagoUsuario> pagos) {
//   TextEditingController montoController = TextEditingController();

//   showDialog(
//     context: context,
//     builder: (_) => StatefulBuilder(
//       builder: (context, setModalState) {
//         double totalPagado = pagos.fold(0, (sum, pago) => sum + pago.monto);

//         return AlertDialog(
//           title: Text('Detalles de ${usuario.nombre}'),
//           content: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Tipo Usuario: ${usuario.tipo}'),
//                 if (usuario.telefono != null) Text('Teléfono: ${usuario.telefono}'),
//                 if (usuario.cedula != null) Text('Cédula: ${usuario.cedula}'),
//                 if (usuario.licencia != null) Text('Licencia: ${usuario.licencia}'),
//                 if (usuario.direccion != null) Text('Dirección: ${usuario.direccion}'),
//                 SizedBox(height: 20),

//                 Text('Pagos Realizados:', style: TextStyle(fontWeight: FontWeight.bold)),

//                 SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: DataTable(
//                     columns: const [
//                       DataColumn(label: Text('N°')),
//                       DataColumn(label: Text('Monto')),
//                       DataColumn(label: Text('Fecha')),
//                     ],
//                     rows: List.generate(pagos.length, (index) {
//                       final pago = pagos[index];
//                       return DataRow(cells: [
//                         DataCell(Text('${index + 1}')),
//                         DataCell(Text('\$${pago.monto.toStringAsFixed(2)}')),
//                         DataCell(Text('${pago.fecha.day}/${pago.fecha.month}/${pago.fecha.year}')),
//                       ]);
//                     }),
//                   ),
//                 ),

//                 Divider(),

//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text('Total Pagado: \$${totalPagado.toStringAsFixed(2)}'),
//                     Text('Total Final: \$----'), // Reservado para lógica futura
//                   ],
//                 ),

//                 SizedBox(height: 10),

//                 TextField(
//                   controller: montoController,
//                   keyboardType: TextInputType.number,
//                   decoration: InputDecoration(labelText: 'Nuevo pago'),
//                 ),

//                 SizedBox(height: 10),

//                 ElevatedButton(
//                   onPressed: () {
//                     final monto = double.tryParse(montoController.text);
//                     if (monto != null && monto > 0) {
//                       setModalState(() {
//                         pagos.add(PagoUsuario(monto: monto, fecha: DateTime.now()));
//                         montoController.clear();
//                       });
//                     }
//                   },
//                   child: Text('Agregar Pago'),
//                 )
//               ],
//             ),
//           ),
//         );
//       },
//     ),
//   );
// }

// }

// class PagoUsuario {
//   final double monto;
//   final DateTime fecha;

//   PagoUsuario({required this.monto, required this.fecha});
// }

// class Proveedor {
//   String nombre;
//   String contacto;
//   String tipo; // 'Proveedor' o 'Personal'
//   String comentario;
//   List<DeudaPago> deudas;
//   Proveedor({required this.nombre, required this.contacto, required this.tipo, required this.comentario, required this.deudas});
// }

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
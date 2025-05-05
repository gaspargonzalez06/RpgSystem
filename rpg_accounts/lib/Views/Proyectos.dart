import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpg_accounts/Drawer/AppDrawer.dart';
import 'package:rpg_accounts/Models/ProyectosModel.dart';
import 'package:rpg_accounts/Provider/ProyectosProvider.dart';
import 'package:rpg_accounts/Views/Proyectos/DetallesDeEmpresa.dart';
import 'package:rpg_accounts/Views/Proyectos/TablaCobros.dart';
import 'package:rpg_accounts/Views/ProyectosParteSuperior.dart';
import 'package:rpg_accounts/main.dart';

class Project {
  final int id_proyecto;
  final String nombre;
  final double rentabilidad;

  Project({required this.id_proyecto,required this.nombre, required this.rentabilidad});
}

class ProjectScreen extends StatefulWidget {
  final bool isHome; // Parámetro opcional para saber si está en el inicio
  ProjectScreen({this.isHome = false}); // Por defecto, no está en el inicio

  @override
  _ProjectScreenState createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  late List<Project> filteredProjects;

  @override
  void initState() {
    super.initState();
    filteredProjects = []; // Inicializamos la lista vacía
    _loadProjects();
  }

  // Mapea los proyectos del provider a objetos 'Project'
  void _loadProjects() async {
    final provider = Provider.of<ProyectoProvider>(context, listen: false);
    await provider.fetchProyectos();
    setState(() {
      filteredProjects = provider.proyectos.map((p) {
        return Project(
          id_proyecto:p.id ,
          nombre: p.nombre,
          rentabilidad: p.presupuesto - p.adelantos, // Ejemplo de cálculo de rentabilidad
        );
      }).toList();
    });
  }

  String selectedColorFilter = 'Todos'; // Inicial

  void filterProjects(String query) {
    setState(() {
      if (query.startsWith("color:")) {
        String color = query.split(":")[1];
        if (color == "blue") {
          filteredProjects = filteredProjects.where((p) => p.rentabilidad >= 0).toList();
        } else if (color == "red") {
          filteredProjects = filteredProjects.where((p) => p.rentabilidad < 0).toList();
        }
      } else {
        filteredProjects = filteredProjects
            .where((p) => p.nombre.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(


    appBar:widget.isHome 
          ? null 
          : AppBar(
              backgroundColor: Colors.black,
              iconTheme: IconThemeData(color: Colors.white),
              title: Text("Proyectos", style: TextStyle(color: Colors.white)),
            ),
      drawer: AppDrawer(),
        
      body: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12), // Ajusta el padding lateral
    child: Container(
      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(12), // Opcional: bordes redondeados
      ),
        child: Column(
          children: [
            
           Visibility(visible: !widget.isHome,
             child: Flexible(flex:5,child:ProyectosParteSuperior(
  totalProjects: 50,
  completedProjects: 30,
  inProgressProjects: 15,
  pendingProjects: 5,
)

             ),
           ),

            Flexible(flex:8,
              child: Row(
                children: [
              
                  Flexible(
                    flex: 8,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            onChanged: filterProjects, // Filtrar cuando el texto cambie
                            decoration: InputDecoration(
                              hintText: "Buscar proyectos...",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                        ),
Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    Text("Filtrar por rentabilidad:"),
    SizedBox(width: 8),
    IconButton(
      icon: Icon(Icons.filter_alt, color: Colors.blue), // Icon for Positivos (azul)
      onPressed: () {
        setState(() {
          selectedColorFilter = 'Positivos (azul)';
          filterProjects("color:blue");
        });
      },
    ),
    IconButton(
      icon: Icon(Icons.filter_alt_off, color: Colors.red), // Icon for Negativos (rojo)
      onPressed: () {
        setState(() {
          selectedColorFilter = 'Negativos (rojo)';
          filterProjects("color:red");
        });
      },
    ),
    IconButton(
      icon: Icon(Icons.filter_list, color: Colors.grey), // Icon for Todos
      onPressed: () {
        setState(() {
          selectedColorFilter = 'Todos';
          filterProjects(""); // Reset filter for all projects
        });
      },
    ),
  ],
)
,
Expanded(
  child: GridView.builder(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 6,
      childAspectRatio: 0.9,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
    ),
    itemCount: filteredProjects.length,
    itemBuilder: (context, index) {
      return Stack(
        children: [
          ProjectCard(project: filteredProjects[index]),
          if (index == 0) // Solo mostrar la estrella en el primer elemento
            Positioned(
              top: 7, // Ajusta para que quede ligeramente fuera del Card
              right: 0, // Ajusta para que quede fuera del borde derecho
              child: Padding(
                padding: const EdgeInsets.all(8.0),
             child: Container(
  decoration: BoxDecoration(
    color: Colors.black, // Fondo negro
    shape: BoxShape.circle, // Forma circular
    border: Border.all(
      color: Colors.yellowAccent, // Borde dorado
      width: 2, // Ancho del borde
    ),
  ),
  child: Icon(
    Icons.star, // Ícono de la estrella
    color: Colors.yellow, // Color de la estrella
    size: 20, // Tamaño del ícono más pequeño
  ),
),


              ),
            ),
        ],
      );
    },
  ),
),

                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                  Visibility(visible: !widget.isHome,
             child:Flexible(flex:4,child: ProyectoTable()))
                ],
              ),
            ),
          ],
        ),
      ),),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddProjectDialog(),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}

class ProjectCard extends StatelessWidget {
  final Project project;

  ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final Color rentabilidadColor = project.rentabilidad >= 0 ? Colors.blueAccent : Colors.redAccent;

    // Lista de estados posibles
    final List<Map<String, dynamic>> states = [
      {"status": "Pendiente", "icon": Icons.hourglass_empty, "color": Colors.orange},
      {"status": "En Progreso", "icon": Icons.access_time, "color": Colors.blue},
      {"status": "Completado", "icon": Icons.check_circle, "color": Colors.green},
      {"status": "Cancelado", "icon": Icons.cancel, "color": Colors.red},
    ];

    // Selección aleatoria de estado
    final random = Random();
    final currentState = states[random.nextInt(states.length)];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProjectDetailsScreen(idProyecto:project.id_proyecto)),
        );
      },child: Card(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
    side: BorderSide(
      color: Colors.greenAccent, // Set the border color
      width: 1.0, // Set the border width
    ),
  ),
  elevation: 4,
  child: Column(
    children: [
      Container(
        height: 10,
        width: double.infinity,
        decoration: BoxDecoration(
          color: rentabilidadColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Text(
          project.nombre,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
      Spacer(),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(currentState["icon"], color: currentState["color"], size: 14),
            SizedBox(width: 4),
            Text(
              currentState["status"],
              style: TextStyle(fontSize: 10, color: currentState["color"]),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProjectDetailsScreen(idProyecto:project.id_proyecto)),
            );
          },
          style: ElevatedButton.styleFrom(
            minimumSize: Size(60, 25),
            textStyle: TextStyle(fontSize: 10),
            padding: EdgeInsets.symmetric(horizontal: 6),
          ),
          child: Text("Ver más"),
        ),
      ),
    ],
  ),
)

    );
  }
}


class Servicio {
  String nombre;
  bool seleccionado;
  double monto;
  String proveedor;

  Servicio({
    required this.nombre,
    this.seleccionado = false,
    this.monto = 0,
    this.proveedor = '',
  });
}  
class ProjectDetailsScreen extends StatefulWidget {

    final int idProyecto;

  // Constructor para recibir el ID del proyecto
  ProjectDetailsScreen({required this.idProyecto});
  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  late Proyecto project;

  @override
  void initState() {
    super.initState();
    // Llamar al provider para obtener los proyectos
    _loadProject();
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

_abrirDialogoMovimiento(BuildContext context) {
    List<Servicio> serviciosDisponibles = [
      Servicio(nombre: 'Electricidad'),
      Servicio(nombre: 'Fontanería'),
      Servicio(nombre: 'Carpintería'),
      Servicio(nombre: 'Pintura'),
    ];

    List<String> proveedores = ['Ferretería Central', 'Suministros JR', 'Proveedor 3'];

    List<Servicio> serviciosSeleccionados = [];
    String categoria = 'Pago';
    String tipoOrigen = 'Proveedor';
    String nombreOrigen = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            double total = serviciosSeleccionados.fold(
              0,
              (sum, s) => sum + s.monto,
            );

            List<String> opcionesNombre = ['Proveedor', 'Tienda', 'Personal']
                .contains(tipoOrigen)
                ? ['Ferretería Central', 'Suministros JR', 'Proveedor 3']
                : [];

            return AlertDialog(
              title: Text('Agregar Movimiento'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final seleccionados =
                            await showModalBottomSheet<List<Servicio>>(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            List<Servicio> seleccionTemp =
                                List.from(serviciosDisponibles);

                            return StatefulBuilder(
                              builder: (context, setStateModal) {
                                return Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text("Seleccionar Servicios",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(height: 10),
                                      ...seleccionTemp.map((s) {
                                        return CheckboxListTile(
                                          title: Text(s.nombre),
                                          value: s.seleccionado,
                                          onChanged: (bool? value) {
                                            setStateModal(() {
                                              s.seleccionado = value ?? false;
                                            });
                                          },
                                        );
                                      }).toList(),
                                      SizedBox(height: 20),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(
                                            context,
                                            seleccionTemp
                                                .where((s) => s.seleccionado)
                                                .toList(),
                                          );
                                        },
                                        child: Text("Agregar"),
                                      )
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );

                        if (seleccionados != null) {
                          setStateDialog(() {
                            serviciosSeleccionados = seleccionados;
                          });
                        }
                      },
                      icon: Icon(Icons.add),
                      label: Text('Seleccionar Servicios'),
                    ),

                    SizedBox(height: 10),

                    ...serviciosSeleccionados.map((s) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.nombre, style: TextStyle(fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue:
                                        s.monto > 0 ? s.monto.toString() : '',
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Monto',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (val) {
                                      setStateDialog(() {
                                        s.monto = double.tryParse(val) ?? 0;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: s.proveedor.isNotEmpty
                                        ? s.proveedor
                                        : null,
                                    hint: Text("Proveedor"),
                                    items: proveedores
                                        .map((p) => DropdownMenuItem(
                                              value: p,
                                              child: Text(p),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      setStateDialog(() {
                                        s.proveedor = value ?? '';
                                      });
                                    },
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    SizedBox(height: 20),

                    Text("Categoría:", style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      value: categoria,
                      isExpanded: true,
                      items: ['Pago', 'Cobro']
                          .map((c) =>
                              DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setStateDialog(() {
                            categoria = value;
                          });
                        }
                      },
                    ),

                    SizedBox(height: 10),

                    Text("Origen del movimiento:", style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      value: tipoOrigen,
                      isExpanded: true,
                      items: ['Proveedor', 'Tienda', 'Personal']
                          .map((o) =>
                              DropdownMenuItem(value: o, child: Text(o)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setStateDialog(() {
                            tipoOrigen = value;
                            nombreOrigen = '';
                          });
                        }
                      },
                    ),

                    SizedBox(height: 10),

                    DropdownButton<String>(
                      value: nombreOrigen.isEmpty ? null : nombreOrigen,
                      hint: Text('Seleccionar nombre'),
                      isExpanded: true,
                      items: opcionesNombre
                          .map((n) => DropdownMenuItem(
                              value: n, child: Text(n)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setStateDialog(() {
                            nombreOrigen = value;
                          });
                        }
                      },
                    ),

                    SizedBox(height: 20),
                    Divider(),
                    Text("Total: \$${total.toStringAsFixed(2)}",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancelar')),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Movimiento guardado para $nombreOrigen'),
                    ));
                  },
                  child: Text('Guardar'),
                )
              ],
            );
          },
        );
      },
    );
  }
  @override




  
  Widget build(BuildContext context) {
    return Scaffold(
           floatingActionButton: FloatingActionButton(
        onPressed: () {
     _abrirDialogoMovimiento(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
      appBar: AppBar(title: Text("Detalles del Proyecto")),
      body: Container(
        child:Row(children :[

Flexible(flex:4,
child:Column(children: [
Flexible(
  flex: 2,
  child: Container(
    height: double.infinity,
    color: Colors.black12,
    padding: EdgeInsets.all(20),
    child: project == null // Verifica si el proyecto ya está cargado
        ? Center(child: CircularProgressIndicator()) // Muestra un indicador de carga mientras el proyecto se carga
        : ProjectProfileCompactSection(
            projectName: project.nombre,
            client: project.clienteNombre,
            budget: project.presupuesto.toString(),
            location: project.ubicacion,
            startDate: project.fechaInicio.toString(),
            endDate: project.fechaFin.toString(),
            type:'Tipo', // Asumiendo que tienes un campo 'tipo' en tu modelo
            estado: 'En Progreso',
            isActive: project.estado == 'En Progreso', // Aquí puedes determinar si está activo
            imageUrl:    "https://cdn.pixabay.com/photo/2016/11/29/09/15/architecture-1868667_960_720.jpg", // Aquí usas la URL de la imagen
          ),
  ),
),
Flexible(flex:4,
child:

Container(width: double.infinity,  
  height:double.infinity,child: Center(

    child: GastosPage(),
  ),)


),


])
),

        ]





        )


      )
      
  
    );
  }
}


class ResumeCards extends StatelessWidget {
  const ResumeCards({super.key});

  @override
  Widget build(BuildContext context) {
    return     Container(
                height: double.infinity,
                width: double.infinity,
                padding: EdgeInsets.all(8),
                child: GridView.builder(
               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2, // Mantiene dos columnas
  crossAxisSpacing: 8,
  mainAxisSpacing: 8, // Un poco más de espacio
  childAspectRatio: 2.0, // Aumenta para hacer los cards más pequeños
),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    Color cardColor;
                    Color iconColor;
                    Color textColor;

                    switch (index) {
                      case 0:
                        cardColor = Colors.green.shade100;
                        iconColor = Colors.green;
                        textColor = Colors.black;
                        break;
                      case 1:
                        cardColor = Colors.orange.shade100;
                        iconColor = Colors.orange;
                        textColor = Colors.black;
                        break;
                      case 2:
                        cardColor = Colors.blue.shade100;
                        iconColor = Colors.blue;
                        textColor = Colors.black;
                        break;
                      case 3:
                        cardColor = Colors.purple.shade100;
                        iconColor = Colors.purple;
                        textColor = Colors.black;
                        break;
                      default:
                        cardColor = Colors.white;
                        iconColor = Colors.black;
                        textColor = Colors.black;
                    }

                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Card(
                        color: cardColor,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                index == 0
                                    ? Icons.money
                                    : index == 1
                                        ? Icons.attach_money
                                        : index == 2
                                            ? Icons.bar_chart
                                            : Icons.account_balance_wallet,
                                size: 28,
                                color: iconColor,
                              ),
                              SizedBox(height: 6),
                              Text(
                                index == 0
                                    ? '\$5000'
                                    : index == 1
                                        ? '25%'
                                        : index == 2
                                            ? '\$3000'
                                            : '\$2000',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                index == 0
                                    ? 'Total Monto del Mes'
                                    : index == 1
                                        ? 'Porcentaje de Ganancia'
                                        : index == 2
                                            ? 'Total de Costos'
                                            : 'Ganancia en Dinero',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 10, color: textColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              
            );
  }
}




void showAddProjectDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AddProjectDialog(),
  );
}

class AddProjectDialog extends StatefulWidget {
  @override
  _AddProjectDialogState createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<AddProjectDialog> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _clientController = TextEditingController();
  TextEditingController _budgetController = TextEditingController();
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  TextEditingController _locationController = TextEditingController();

  String _selectedStatus = "Pendiente";
  String _selectedType = "Residencial";

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        controller.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8, // Ajuste del ancho
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Imagen ficticia en la parte superior
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(Icons.image, size: 50, color: Colors.white),
                ),
              ),
              SizedBox(height: 10),
              
              Text("Agregar Proyecto", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              
              Form(
                key: _formKey,
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    SizedBox(width: 180, child: _buildTextField(_nameController, "Nombre del Proyecto", Icons.business)),
                    SizedBox(width: 180, child: _buildTextField(_clientController, "Cliente", Icons.person)),
                    SizedBox(width: 180, child: _buildTextField(_budgetController, "Presupuesto", Icons.attach_money, isNumeric: true)),
                    SizedBox(width: 180, child: _buildDatePicker(_startDateController, "Fecha de Inicio")),
                    SizedBox(width: 180, child: _buildDatePicker(_endDateController, "Fecha de Finalización")),
                    SizedBox(width: 180, child: _buildTextField(_locationController, "Ubicación", Icons.location_on)),
                    SizedBox(width: 180, child: _buildDropdownField(
                      "Estado del Proyecto",
                      Icons.flag,
                      ["Pendiente", "En Progreso", "Finalizado"],
                      (newValue) => setState(() => _selectedStatus = newValue!),
                      _selectedStatus,
                    )),
                    SizedBox(width: 180, child: _buildDropdownField(
                      "Tipo de Construcción",
                      Icons.apartment,
                      ["Residencial", "Comercial", "Industrial", "Otro"],
                      (newValue) => setState(() => _selectedType = newValue!),
                      _selectedType,
                    )),
                  ],
                ),
              ),
              SizedBox(height: 20),
              
              // Botones
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Cancelar"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text("Guardar"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumeric = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      validator: (value) => value!.isEmpty ? "Campo requerido" : null,
    );
  }

  Widget _buildDatePicker(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.calendar_today),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      readOnly: true,
      onTap: () => _selectDate(context, controller),
      validator: (value) => value!.isEmpty ? "Campo requerido" : null,
    );
  }

  Widget _buildDropdownField(String label, IconData icon, List<String> options, Function(String?) onChanged, String value) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          onChanged: onChanged,
          items: options.map((option) {
            return DropdownMenuItem(value: option, child: Text(option));
          }).toList(),
        ),
      ),
    );
  }
}


//detalles proyecto dialog



// class AddProjectDialog extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text("Agregar Proyecto"),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           TextField(decoration: InputDecoration(labelText: "Nombre")),
//           TextField(decoration: InputDecoration(labelText: "Cliente")),
//           TextField(decoration: InputDecoration(labelText: "Presupuesto")),
//         ],
//       ),
//       actions: [
//         ElevatedButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           child: Text("Cancelar"),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           child: Text("Guardar"),
//         ),
//       ],
//     );
//   }
// }



//  appBar: AppBar(
//         backgroundColor: Colors.black,
//         iconTheme: IconThemeData(color: Colors.white),
//         title: Padding(
//           padding: EdgeInsets.only(top: 10),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // Botón "Entra"
//               GestureDetector(
//                 onTap: () => _onTabTapped(0),
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
//                   color: _selectedIndex == 0 ? Colors.green : Colors.transparent,
//                   child: Text(
//                     "Cobros",
//                     style: TextStyle(
//                       color: _selectedIndex == 0 ? Colors.white : Colors.grey,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(width: 10),
//               // Botón "Sale"
//               GestureDetector(
//                 onTap: () => _onTabTapped(1),
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
//                   color: _selectedIndex == 1 ? Colors.red : Colors.transparent,
//                   child: Text(
//                     "Costos",
//                     style: TextStyle(
//                       color: _selectedIndex == 1 ? Colors.white : Colors.grey,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(width: 10),
//               // Botón "Balance"
//               GestureDetector(
//                 onTap: () => _onTabTapped(2),
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
//                   color: _selectedIndex == 2 ? Colors.amber : Colors.transparent,
//                   child: Text(
//                     "Balance",
//                     style: TextStyle(
//                       color: _selectedIndex == 2 ? Colors.white : Colors.grey,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),




// import 'package:flutter/material.dart';

// class ProjectScreen extends StatefulWidget {
//   @override
//   _ProjectScreenState createState() => _ProjectScreenState();
// }

// class _ProjectScreenState extends State<ProjectScreen> {
//   bool _isExpanded = false;
//   int? _selectedProject;

//   List<Map<String, dynamic>> projects = List.generate(15, (index) => {
//         "id": index,
//         "name": "Proyecto ${index + 1}",
//         "client": "Cliente ${index + 1}",
//         "total": 100000 + index * 5000,
//         "gastos": 30000 + index * 2000,
//         "ingresos": 50000 + index * 3000,
//       });

//   void _toggleExpand(int index) {
//     setState(() {
//       if (_selectedProject == index) {
//         _isExpanded = !_isExpanded;
//       } else {
//         _selectedProject = index;
//         _isExpanded = true;
//       }
//     });
//   }

//   void _showAddProjectDialog() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text("Agregar Proyecto"),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(decoration: InputDecoration(labelText: "Nombre del Proyecto")),
//               TextField(decoration: InputDecoration(labelText: "Cliente")),
//               TextField(decoration: InputDecoration(labelText: "Presupuesto Total")),
//             ],
//           ),
//           actions: [
//             TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancelar")),
//             ElevatedButton(onPressed: () {}, child: Text("Guardar")),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Proyectos de Construcción')),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showAddProjectDialog,
//         child: Icon(Icons.add),
//       ),
//       body: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 16),
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: TextField(
//                 decoration: InputDecoration(
//                   hintText: "Buscar proyectos...",
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.search),
//                 ),
//               ),
//             ),
//             Expanded(
//               child: GridView.builder(
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 3,
//                   crossAxisSpacing: 10,
//                   mainAxisSpacing: 10,
//                   childAspectRatio: 1.5,
//                 ),
//                 itemCount: projects.length,
//                 itemBuilder: (context, index) {
//                   return GestureDetector(
//                     onTap: () => _toggleExpand(index),
//                     child: AnimatedContainer(
//                       duration: Duration(milliseconds: 300),
//                       padding: EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: Colors.blueAccent,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: _isExpanded && _selectedProject == index
//                           ? ProjectDetails(project: projects[index])
//                           : Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   projects[index]["name"],
//                                   style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                                 ),
//                                 SizedBox(height: 5),
//                                 Container(height: 50, color: Colors.white),
//                               ],
//                             ),
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

// class ProjectDetails extends StatelessWidget {
//   final Map<String, dynamic> project;
//   ProjectDetails({required this.project});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(project["name"], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
//         Text("Cliente: ${project["client"]}", style: TextStyle(color: Colors.white)),
//         Divider(color: Colors.white),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Card(
//               color: Colors.white,
//               child: Padding(
//                 padding: EdgeInsets.all(8.0),
//                 child: Column(
//                   children: [
//                     Text("Total"),
//                     Text("\\${project["total"]}", style: TextStyle(fontWeight: FontWeight.bold)),
//                   ],
//                 ),
//               ),
//             ),
//             Card(
//               color: Colors.white,
//               child: Padding(
//                 padding: EdgeInsets.all(8.0),
//                 child: Column(
//                   children: [
//                     Text("Gastos"),
//                     Text("\\${project["gastos"]}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
//                   ],
//                 ),
//               ),
//             ),
//             Card(
//               color: Colors.white,
//               child: Padding(
//                 padding: EdgeInsets.all(8.0),
//                 child: Column(
//                   children: [
//                     Text("Ingresos"),
//                     Text("\\${project["ingresos"]}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//         Expanded(
//           child: SingleChildScrollView(
//             child: DataTable(
//               columns: [
//                 DataColumn(label: Text('Fecha')),
//                 DataColumn(label: Text('Descripción')),
//                 DataColumn(label: Text('Monto')),
//               ],
//               rows: List.generate(5, (index) => DataRow(cells: [
//                     DataCell(Text("12/02/2025")),
//                     DataCell(Text("Movimiento ${index + 1}")),
//                     DataCell(Text("\\${(index + 1) * 1000}")),
//                   ])),
//             ),
//           ),
//         ),
//         Align(
//           alignment: Alignment.bottomRight,
//           child: Padding(
//             padding: EdgeInsets.all(8.0),
//             child: Text(
//               "Ganancia Total: \$+${project["ingresos"] - project["gastos"]}",
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

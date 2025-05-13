import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpg_accounts/Models/ProyectosModel.dart';
import 'package:rpg_accounts/Provider/MovimientosProvider.dart';
import 'package:rpg_accounts/Provider/ProyectosProvider.dart';
import 'package:rpg_accounts/Views/Proyectos/DetallesDeEmpresa.dart';

class MovimientosPorProyectoScreen extends StatefulWidget {
  final int idProyecto;

  const MovimientosPorProyectoScreen({Key? key, required this.idProyecto}) : super(key: key);

  @override
  State<MovimientosPorProyectoScreen> createState() => _MovimientosPorProyectoScreenState();
}

class _MovimientosPorProyectoScreenState extends State<MovimientosPorProyectoScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
     _loadProject();
  }
   late Proyecto project;


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



  Future<void> _fetchData() async {
    await Provider.of<ProveedorMovimientoProvider>(context, listen: false)
        .fetchMovimientos();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProveedorMovimientoProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Movimientos por Usuario')),
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
                  Flexible(flex: 4,
                    child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.movimientosPorUsuario.length,
                        itemBuilder: (context, index) {
                          final usuario = provider.movimientosPorUsuario[index];
                    
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            child: ExpansionTile(
                              title: Text(usuario.usuario.nombre),
                              subtitle: Text('Tipo Usuario: ${usuario.usuario.id}'),
                              children: usuario.movimientos.map((mov) {
                                return ListTile(
                                  title: Text(mov.comentario),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Monto: \$${mov.monto.toStringAsFixed(2)}'),
                                      Text('Fecha: ${mov.fecha}'),
                                      Text('Tipo Movimiento: ${mov.tipoMovimiento}'),
                                      if (mov.idTrabajador != null) Text('ID Trabajador: ${mov.idTrabajador}'),
                                      if (mov.idProveedor != null) Text('ID Proveedor: ${mov.idProveedor}'),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
                  ),
                ],
              ),
    );
  }
}

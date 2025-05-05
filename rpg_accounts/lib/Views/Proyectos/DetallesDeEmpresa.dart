import 'package:flutter/material.dart';

class ProjectProfileCompactSection extends StatefulWidget {
  final String projectName;
  final String client;
  final String budget;
  final String location;
  final String startDate;
  final String endDate;
  final String type;
  final String estado;
  final bool isActive;
  final String imageUrl;

  const ProjectProfileCompactSection({
    Key? key,
    required this.projectName,
    required this.client,
    required this.budget,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.type,
    required this.estado,
    required this.isActive,
    required this.imageUrl,
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
  late TextEditingController _locationCtrl;
  late TextEditingController _startDateCtrl;
  late TextEditingController _endDateCtrl;
  late TextEditingController _typeCtrl;

  bool activo = false;
  late String selectedEstado;
  final List<String> estadosDisponibles = ['En Progreso', 'Completado', 'Pendiente'];

  @override
  void initState() {
    super.initState();
    _projectNameCtrl = TextEditingController(text: widget.projectName);
    _clientCtrl = TextEditingController(text: widget.client);
    _budgetCtrl = TextEditingController(text: widget.budget);
    _locationCtrl = TextEditingController(text: widget.location);
    _startDateCtrl = TextEditingController(text: widget.startDate);
    _endDateCtrl = TextEditingController(text: widget.endDate);
    _typeCtrl = TextEditingController(text: widget.type);
    activo = widget.isActive;
    selectedEstado = widget.estado;
  }

  @override
  void dispose() {
    _projectNameCtrl.dispose();
    _clientCtrl.dispose();
    _budgetCtrl.dispose();
    _locationCtrl.dispose();
    _startDateCtrl.dispose();
    _endDateCtrl.dispose();
    _typeCtrl.dispose();
    super.dispose();
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Text(
        title,
        style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
      ),
    );
  }

  Widget _labeledField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    double? width,
    bool isDate = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: SizedBox(
        width: width ?? 200,
        child: TextField(
          controller: controller,
          readOnly: isDate,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, size: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            isDense: true,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen circular
          CircleAvatar(
            radius: 40,
            backgroundImage: widget.imageUrl.isNotEmpty
                ? NetworkImage(widget.imageUrl)
                : const AssetImage("assets/images/placeholder_project.jpg")
                    as ImageProvider,
            backgroundColor: Colors.white,
          ),
          const SizedBox(width: 16),

          // Info general
          Expanded(
            child: Wrap(
              spacing: 20,
              runSpacing: 16,
              children: [
                // Sección Información
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("Información General"),
                    _labeledField(
                      label: "Nombre del Proyecto",
                      icon: Icons.title,
                      controller: _projectNameCtrl,
                      width: 220,
                    ),
                    _labeledField(
                      label: "Cliente",
                      icon: Icons.person,
                      controller: _clientCtrl,
                      width: 200,
                    ),
                 
                  ],
                ),

                // Sección Fechas y ubicación
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("Ubicación y Fechas"),
                    _labeledField(
                      label: "Fecha de Inicio",
                      icon: Icons.date_range,
                      controller: _startDateCtrl,
                      isDate: true,
                      width: 180,
                    ),
                    _labeledField(
                      label: "Fecha de Fin",
                      icon: Icons.event,
                      controller: _endDateCtrl,
                      isDate: true,
                      width: 180,
                    ),
                  
                  ],
                ),
                  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     _sectionTitle("."),
                      _labeledField(
                      label: "Ubicación",
                      icon: Icons.location_on,
                      controller: _locationCtrl,
                      width: 240,
                    ),
   _labeledField(
                      label: "Presupuesto",
                      icon: Icons.attach_money,
                      controller: _budgetCtrl,
                      width: 130,
                    ),
                  
                  ],
                ),
               
                // Tipo y activo
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("Clasificación"),
                    _labeledField(
                      label: "Tipo",
                      icon: Icons.apartment,
                      controller: _typeCtrl,
                      width: 200,
                    ),
                    const SizedBox(height: 4),
                    // const Text(
                    //   "Activo",
                    //   style:
                    //       TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    // ),
                    // Switch(
                    //   value: activo,
                    //   onChanged: (value) {
                    //     setState(() {
                    //       activo = value;
                    //     });
                    //   },
                    // ),
                  ],
                ),

                // Estado y botón de guardar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _sectionTitle("Estado y Acción"),
                    SizedBox(
                      width: 180,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Estado',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          prefixIcon: const Icon(Icons.flag, size: 16),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedEstado,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedEstado = value;
                                });
                              }
                            },
                            items: estadosDisponibles.map((estado) {
                              return DropdownMenuItem<String>(
                                value: estado,
                                child: Text(estado,
                                    style: const TextStyle(fontSize: 13)),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    IconButton(
                      icon: Icon(Icons.save,
                          color: Theme.of(context).primaryColor),
                      tooltip: "Guardar Cambios",
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text("Cambios guardados correctamente")),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class ProjectProfileCompactSection extends StatefulWidget {
//   final String imageUrl;
//   final String projectName;
//   final String client;
//   final String budget;
//   final String startDate;
//   final String endDate;
//   final String location;
//   final String status;
//   final String type;

//   const ProjectProfileCompactSection({
//     super.key,
//     required this.imageUrl,
//     required this.projectName,
//     required this.client,
//     required this.budget,
//     required this.startDate,
//     required this.endDate,
//     required this.location,
//     required this.status,
//     required this.type,
//   });

//   @override
//   State<ProjectProfileCompactSection> createState() => _ProjectProfileCompactSectionState();
// }

// class _ProjectProfileCompactSectionState extends State<ProjectProfileCompactSection> {
//   late final TextEditingController _projectNameCtrl;
//   late final TextEditingController _clientCtrl;
//   late final TextEditingController _budgetCtrl;
//   late final TextEditingController _startDateCtrl;
//   late final TextEditingController _endDateCtrl;
//   late final TextEditingController _locationCtrl;
//   late final TextEditingController _statusCtrl;
//   late final TextEditingController _typeCtrl;

//   @override
//   void initState() {
//     super.initState();
//     _projectNameCtrl = TextEditingController(text: widget.projectName);
//     _clientCtrl = TextEditingController(text: widget.client);
//     _budgetCtrl = TextEditingController(text: widget.budget);
//     _startDateCtrl = TextEditingController(text: widget.startDate);
//     _endDateCtrl = TextEditingController(text: widget.endDate);
//     _locationCtrl = TextEditingController(text: widget.location);
//     _statusCtrl = TextEditingController(text: widget.status);
//     _typeCtrl = TextEditingController(text: widget.type);
//   }

//   @override
//   void dispose() {
//     _projectNameCtrl.dispose();
//     _clientCtrl.dispose();
//     _budgetCtrl.dispose();
//     _startDateCtrl.dispose();
//     _endDateCtrl.dispose();
//     _locationCtrl.dispose();
//     _statusCtrl.dispose();
//     _typeCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _selectDate(TextEditingController controller) async {
//     DateTime initial = DateTime.tryParse(controller.text) ?? DateTime.now();
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: initial,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );
//     if (picked != null) {
//       controller.text = DateFormat('yyyy-MM-dd').format(picked);
//     }
//   }

//   Widget _compactField({
//     required IconData icon,
//     required TextEditingController controller,
//     bool isDate = false,
//     double width = 200,
//   }) {
//     return SizedBox(
//       width: width,
//       child: TextField(
//         controller: controller,
//         readOnly: isDate,
//         onTap: isDate ? () => _selectDate(controller) : null,
//         style: TextStyle(fontSize: 13),
//         decoration: InputDecoration(
//           prefixIcon: Icon(icon, size: 16),
//           isDense: true,
//           contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(12.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Avatar circular
//           CircleAvatar(
//             radius: 40,
//             backgroundImage: widget.imageUrl.isNotEmpty
//                 ? NetworkImage(widget.imageUrl)
//                 : AssetImage("assets/images/placeholder_project.jpg") as ImageProvider,
//             backgroundColor: Colors.white,
//           ),
//           SizedBox(width: 16),

//           // Campos compactos con Wrap para adaptarse
//           Expanded(
//             child: Wrap(
//               spacing: 12,
//               runSpacing: 10,
//               children: [
//                 _compactField(icon: Icons.title, controller: _projectNameCtrl, width: 180),
//                 _compactField(icon: Icons.person, controller: _clientCtrl),
//                 _compactField(icon: Icons.attach_money, controller: _budgetCtrl, width: 100),
//                 _compactField(icon: Icons.date_range, controller: _startDateCtrl, isDate: true),
//                 _compactField(icon: Icons.event, controller: _endDateCtrl, isDate: true),
//                 _compactField(icon: Icons.location_on, controller: _locationCtrl),
//                 _compactField(icon: Icons.flag, controller: _statusCtrl),
//                 _compactField(icon: Icons.apartment, controller: _typeCtrl),
//               ],
//             ),
//           ),

//           // Botón guardar
//           IconButton(
//             icon: Icon(Icons.save, color: Theme.of(context).primaryColor),
//             tooltip: "Guardar Cambios",
//             onPressed: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text("Cambios guardados correctamente")),
//               );
//             },
//           )
//         ],
//       ),
//     );
//   }
// }

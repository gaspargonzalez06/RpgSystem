import 'package:flutter/material.dart';
import 'package:rpg_accounts/Drawer/AppDrawer.dart';
import 'package:rpg_accounts/Views/Materariales/AnalisisMateriales.dart';

class MaterialesPage extends StatefulWidget {
  @override
  _MaterialesPageState createState() => _MaterialesPageState();
}

class _MaterialesPageState extends State<MaterialesPage> {
  final TextEditingController _searchController = TextEditingController();
 final List<Map<String, String>> materiales = [
  {'nombre': 'Cemento', 'categoria': 'Bases', 'descripcion': 'Bolsa de cemento Portland 50kg'},
  {'nombre': 'Arena', 'categoria': 'Bases', 'descripcion': 'Saco de arena fina para construcción'},
  {'nombre': 'Ladrillo', 'categoria': 'Estructura', 'descripcion': 'Ladrillo rojo de alta resistencia'},
  {'nombre': 'Madera', 'categoria': 'Acabados', 'descripcion': 'Tablón de madera tratada 2m'},
  {'nombre': 'Pintura', 'categoria': 'Acabados', 'descripcion': 'Galón de pintura blanca mate'},
  {'nombre': 'Yeso', 'categoria': 'Bases', 'descripcion': 'Saco de yeso para construcción'},
  {'nombre': 'Pegamento', 'categoria': 'Acabados', 'descripcion': 'Botella de pegamento para madera'},
  {'nombre': 'Clavos', 'categoria': 'Estructura', 'descripcion': 'Caja de clavos galvanizados'},
  {'nombre': 'Tejas', 'categoria': 'Estructura', 'descripcion': 'Tejas de barro para techado'},
  {'nombre': 'Tornillos', 'categoria': 'Estructura', 'descripcion': 'Set de tornillos para construcción'},
  {'nombre': 'Papel de Lija', 'categoria': 'Acabados', 'descripcion': 'Papel de lija para acabados finos'},
  {'nombre': 'Aislante', 'categoria': 'Estructura', 'descripcion': 'Aislante térmico para paredes'},
  {'nombre': 'Tubos PVC', 'categoria': 'Estructura', 'descripcion': 'Tubos de PVC para plomería'},
  {'nombre': 'Piedra', 'categoria': 'Bases', 'descripcion': 'Piedra triturada para cimentación'},
  {'nombre': 'Alambre', 'categoria': 'Estructura', 'descripcion': 'Bobina de alambre de acero'},
  {'nombre': 'Grava', 'categoria': 'Bases', 'descripcion': 'Saco de grava para mezcla'},
  {'nombre': 'Cartón', 'categoria': 'Acabados', 'descripcion': 'Planchas de cartón para construcción'},
  {'nombre': 'Vidrio', 'categoria': 'Acabados', 'descripcion': 'Vidrio templado para ventanas'},
  {'nombre': 'Papel Contact', 'categoria': 'Acabados', 'descripcion': 'Rollos de papel contact adhesivo'},
  {'nombre': 'Placas de Yeso', 'categoria': 'Estructura', 'descripcion': 'Placas de yeso para interiores'},
  {'nombre': 'Cinta Métrica', 'categoria': 'Acabados', 'descripcion': 'Cinta métrica de 5 metros'},
  {'nombre': 'Escuadra', 'categoria': 'Acabados', 'descripcion': 'Escuadra de metal para carpintería'},
  {'nombre': 'Silicona', 'categoria': 'Acabados', 'descripcion': 'Silicona para juntas y sellado'},
  {'nombre': 'Adhesivo', 'categoria': 'Acabados', 'descripcion': 'Adhesivo industrial para cerámica'},
  {'nombre': 'Cinta Aislante', 'categoria': 'Estructura', 'descripcion': 'Cinta aislante de 5m'},
  {'nombre': 'Aluminio', 'categoria': 'Acabados', 'descripcion': 'Plancha de aluminio para techado'},
  {'nombre': 'Varilla', 'categoria': 'Estructura', 'descripcion': 'Varilla de acero para refuerzo'},
  {'nombre': 'Cuerda', 'categoria': 'Acabados', 'descripcion': 'Cuerda resistente de 30m'},
  {'nombre': 'Cerámica', 'categoria': 'Acabados', 'descripcion': 'Azulejos de cerámica para pisos'},
  {'nombre': 'Grapadora', 'categoria': 'Acabados', 'descripcion': 'Grapadora industrial para tapicería'},
  {'nombre': 'Rollo de Alambre', 'categoria': 'Estructura', 'descripcion': 'Rollo de alambre de 100m'},
  {'nombre': 'Pintura Anticorrosiva', 'categoria': 'Acabados', 'descripcion': 'Pintura para superficies metálicas'},
];

// Expanded(
//   child: GridView.builder(
//     padding: EdgeInsets.all(10),
  
//     itemCount: _filteredMateriales.length,
//     itemBuilder: (context, index) {
//       final material = _filteredMateriales[index];
//       return _buildMaterialCard(material);
//     },
//   ),
// ),


  List<Map<String, String>> _filteredMateriales = [];
  String _selectedCategory = 'Todas';

  @override
  void initState() {
    super.initState();
    _filteredMateriales = List.from(materiales);
  }

  void _filterMaterials() {
    setState(() {
      String query = _searchController.text.toLowerCase();
      _filteredMateriales = materiales.where((material) {
        final matchesQuery = material['nombre']!.toLowerCase().contains(query);
        final matchesCategory = _selectedCategory == 'Todas' || material['categoria'] == _selectedCategory;
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  void _addMaterial(String nombre, String categoria, String descripcion) {
    setState(() {
      materiales.add({'nombre': nombre, 'categoria': categoria, 'descripcion': descripcion});
      _filterMaterials();
    });
  }

  void _showAddMaterialDialog() {
    String nombre = '', categoria = 'Bases', descripcion = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Agregar Material'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField('Nombre', (value) => nombre = value),
              _buildDropdownField(['Bases', 'Estructura', 'Acabados'], categoria, (value) => categoria = value!),
              _buildTextField('Descripción', (value) => descripcion = value),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (nombre.isNotEmpty && descripcion.isNotEmpty) {
                  _addMaterial(nombre, categoria, descripcion);
                  Navigator.pop(context);
                }
              },
              child: Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  void _showEditMaterialDialog(Map<String, String> material) {
    String nombre = material['nombre']!;
    String categoria = material['categoria']!;
    String descripcion = material['descripcion']!;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Material'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField('Nombre', (value) => nombre = value, initialValue: nombre),
              _buildDropdownField(['Bases', 'Estructura', 'Acabados'], categoria, (value) => categoria = value!),
              _buildTextField('Descripción', (value) => descripcion = value, initialValue: descripcion),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  material['nombre'] = nombre;
                  material['categoria'] = categoria;
                  material['descripcion'] = descripcion;
                });
                Navigator.pop(context);
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String label, Function(String) onChanged, {String initialValue = ''}) {
    return TextField(
      controller: TextEditingController(text: initialValue),
      decoration: InputDecoration(labelText: label),
      onChanged: onChanged,
    );
  }

  Widget _buildDropdownField(List<String> items, String value, Function(String?) onChanged) {
    return DropdownButtonFormField(
      value: value,
      items: items.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(labelText: 'Categoría'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar:
        
         AppBar(
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        drawer:AppDrawer(),
      body: Column(
        children: [
             MaterialesAnalysisWidget(materiales: materiales),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar material...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onChanged: (value) => _filterMaterials(),
                  ),
                ),
                SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedCategory,
                  items: ['Todas', 'Bases', 'Estructura', 'Acabados']
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedCategory = value!);
                    _filterMaterials();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 8, // 8 cards por fila
      childAspectRatio: 1, // Ajustar el tamaño de cada card
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
    ),
              itemCount: _filteredMateriales.length,
              itemBuilder: (context, index) {
                final material = _filteredMateriales[index];
                return _buildMaterialCard(material);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMaterialDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildMaterialCard(Map<String, String> material) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              material['nombre']!,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6),
            Text(
              material['descripcion']!,
              style: TextStyle(fontSize: 10, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _showEditMaterialDialog(material),
              child: Text('Ver'),
              style: ElevatedButton.styleFrom(
                textStyle: TextStyle(fontSize: 12),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// // import 'package:flutter/material.dart';

// import 'package:flutter/material.dart';

// class MaterialesPage extends StatefulWidget {
//   @override
//   _MaterialesPageState createState() => _MaterialesPageState();
// }

// class _MaterialesPageState extends State<MaterialesPage> {
//   final List<Map<String, String>> materiales = [
//     {'nombre': 'Cemento', 'categoria': 'Bases', 'descripcion': 'Bolsa de cemento Portland 50kg', 'precio': '50'},
//     {'nombre': 'Arena', 'categoria': 'Bases', 'descripcion': 'Saco de arena fina para construcción', 'precio': '20'},
//     {'nombre': 'Ladrillo', 'categoria': 'Estructura', 'descripcion': 'Ladrillo rojo de alta resistencia', 'precio': '5'},
//     {'nombre': 'Madera', 'categoria': 'Acabados', 'descripcion': 'Tablón de madera tratada 2m', 'precio': '100'},
//     {'nombre': 'Pintura', 'categoria': 'Acabados', 'descripcion': 'Galón de pintura blanca mate', 'precio': '35'},
//   ];
//   List<Map<String, String>> _filteredMateriales = [];
//   String _selectedCategory = 'Todas';


//   final TextEditingController _searchController = TextEditingController();
//   @override
//   void initState() {
//     super.initState();
//     _filteredMateriales = List.from(materiales);
//   }

//   void _filterMaterials(String categoria) {
//     setState(() {
//       if (categoria == 'Todas') {
//         _filteredMateriales = List.from(materiales);
//       } else {
//         _filteredMateriales = materiales.where((material) => material['categoria'] == categoria).toList();
//       }
//       _selectedCategory = categoria;
//     });
//   }
//     void _setCategory(String category) {
//     setState(() {
//       _selectedCategory = category;
//       _filterMaterials(_searchController.text);
//     });
//   }



//   void _addMaterial(String nombre, String categoria, String descripcion, String precio) {
//     setState(() {
//       materiales.add({'nombre': nombre, 'categoria': categoria, 'descripcion': descripcion, 'precio': precio});
//       _filterMaterials(_selectedCategory);
//     });
//   }

//   void _showAddMaterialDialog() {
//     String nombre = '';
//     String categoria = 'Bases';
//     String descripcion = '';
//     String precio = '';
    
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Agregar Material'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 decoration: InputDecoration(labelText: 'Nombre'),
//                 onChanged: (value) => nombre = value,
//               ),
//               DropdownButtonFormField(
//                 value: categoria,
//                 items: ['Bases', 'Estructura', 'Acabados']
//                     .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
//                     .toList(),
//                 onChanged: (value) => categoria = value.toString(),
//                 decoration: InputDecoration(labelText: 'Categoría'),
//               ),
//               TextField(
//                 decoration: InputDecoration(labelText: 'Descripción'),
//                 onChanged: (value) => descripcion = value,
//               ),
//               TextField(
//                 decoration: InputDecoration(labelText: 'Precio por unidad'),
//                 keyboardType: TextInputType.number,
//                 onChanged: (value) => precio = value,
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('Cancelar'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 if (nombre.isNotEmpty && descripcion.isNotEmpty && precio.isNotEmpty) {
//                   _addMaterial(nombre, categoria, descripcion, precio);
//                   Navigator.pop(context);
//                 }
//               },
//               child: Text('Agregar'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showMaterialDetails(Map<String, String> material) {
//     TextEditingController nombreController = TextEditingController(text: material['nombre']);
//     TextEditingController descripcionController = TextEditingController(text: material['descripcion']);
//     TextEditingController precioController = TextEditingController(text: material['precio']);

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Detalles del Material'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: nombreController,
//                 decoration: InputDecoration(labelText: 'Nombre'),
//               ),
//               TextField(
//                 controller: descripcionController,
//                 decoration: InputDecoration(labelText: 'Descripción'),
//               ),
//               TextField(
//                 controller: precioController,
//                 decoration: InputDecoration(labelText: 'Precio por unidad'),
//                 keyboardType: TextInputType.number,
//               ),
//             ],
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

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Inventario de Materiales'),
//       ),
//       body: Column(
//         children: [
//             Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: InputDecoration(
//                       hintText: 'Buscar material...',
//                       prefixIcon: Icon(Icons.search),
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//                     ),
//                     onChanged: _filterMaterials,
//                   ),
//                 ),
//                 SizedBox(width: 8),
//                 DropdownButton<String>(
//                   value: _selectedCategory,
//                   items: ['Todas', 'Bases', 'Estructura', 'Acabados']
//                       .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
//                       .toList(),
//                   onChanged: (value) => _setCategory(value!),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: GridView.builder(
//               padding: EdgeInsets.all(10),
//                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 4,
//                 childAspectRatio: 2.0,
//                 crossAxisSpacing: 10,
//                 mainAxisSpacing: 10,
//               ),
//               itemCount: _filteredMateriales.length,
//               itemBuilder: (context, index) {
//                 final material = _filteredMateriales[index];
//                 return Card(
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(material['nombre']!, style: TextStyle(fontWeight: FontWeight.bold)),
//                       Text('Precio: \$${material['precio']}'),
//                       SizedBox(height: 10),
//                       ElevatedButton(
//                         onPressed: () => _showMaterialDetails(material),
//                         child: Text('Ver'),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showAddMaterialDialog,
//         child: Icon(Icons.add),
//       ),
//     );
//   }
// }




// class MaterialesPage extends StatefulWidget {
//   @override
//   _MaterialesPageState createState() => _MaterialesPageState();
// }

// class _MaterialesPageState extends State<MaterialesPage> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final TextEditingController _searchController = TextEditingController();
//   final List<Map<String, String>> materiales = [
//     {'nombre': 'Cemento', 'categoria': 'Bases', 'descripcion': 'Bolsa de cemento Portland 50kg'},
//     {'nombre': 'Arena', 'categoria': 'Bases', 'descripcion': 'Saco de arena fina para construcción'},
//     {'nombre': 'Ladrillo', 'categoria': 'Estructura', 'descripcion': 'Ladrillo rojo de alta resistencia'},
//     {'nombre': 'Madera', 'categoria': 'Acabados', 'descripcion': 'Tablón de madera tratada 2m'},
//     {'nombre': 'Pintura', 'categoria': 'Acabados', 'descripcion': 'Galón de pintura blanca mate'},
//   ];
//   List<Map<String, String>> _filteredMateriales = [];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _filteredMateriales = List.from(materiales);
//   }

//   void _filterMaterials(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredMateriales = List.from(materiales);
//       } else {
//         _filteredMateriales = materiales
//             .where((material) => material['nombre']!.toLowerCase().contains(query.toLowerCase()))
//             .toList();
//       }
//     });
//   }

//   void _addMaterial(String nombre, String categoria, String descripcion) {
//     setState(() {
//       materiales.add({'nombre': nombre, 'categoria': categoria, 'descripcion': descripcion});
//       _filteredMateriales = List.from(materiales);
//     });
//   }

//   void _showAddMaterialDialog() {
//     String nombre = '';
//     String categoria = 'Bases';
//     String descripcion = '';
    
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Agregar Material'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 decoration: InputDecoration(labelText: 'Nombre'),
//                 onChanged: (value) => nombre = value,
//               ),
//               DropdownButtonFormField(
//                 value: categoria,
//                 items: ['Bases', 'Estructura', 'Acabados']
//                     .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
//                     .toList(),
//                 onChanged: (value) => categoria = value.toString(),
//                 decoration: InputDecoration(labelText: 'Categoría'),
//               ),
//               TextField(
//                 decoration: InputDecoration(labelText: 'Descripción'),
//                 onChanged: (value) => descripcion = value,
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('Cancelar'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 if (nombre.isNotEmpty && descripcion.isNotEmpty) {
//                   _addMaterial(nombre, categoria, descripcion);
//                   Navigator.pop(context);
//                 }
//               },
//               child: Text('Agregar'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Inventario de Materiales'),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: [
//             Tab(text: 'Bases'),
//             Tab(text: 'Estructura'),
//             Tab(text: 'Acabados'),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Buscar material...',
//                 prefixIcon: Icon(Icons.search),
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//               ),
//               onChanged: _filterMaterials,
//             ),
//           ),
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 _buildMaterialList('Bases'),
//                 _buildMaterialList('Estructura'),
//                 _buildMaterialList('Acabados'),
//               ],
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showAddMaterialDialog,
//         child: Icon(Icons.add),
//         backgroundColor: Colors.blue,
//       ),
//     );
//   }

//   Widget _buildMaterialList(String categoria) {
//     List<Map<String, String>> filtered = _filteredMateriales
//         .where((material) => material['categoria'] == categoria)
//         .toList();

//     return filtered.isEmpty
//         ? Center(child: Text('No hay materiales en esta categoría'))
//         : ListView.builder(
//             itemCount: filtered.length,
//             itemBuilder: (context, index) {
//               final material = filtered[index];
//               return Card(
//                 margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                 child: ListTile(
//                   leading: Icon(Icons.build, color: Colors.blue),
//                   title: Text(material['nombre']!, style: TextStyle(fontWeight: FontWeight.bold)),
//                   subtitle: Text(material['descripcion']!),
//                 ),
//               );
//             },
//           );
//   }
// }
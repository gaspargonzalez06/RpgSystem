import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpg_accounts/Drawer/AppDrawer.dart';
import 'package:rpg_accounts/Models/Usuarios/USistema.dart';
import 'package:rpg_accounts/Provider/ComentariosProvider.dart';
import 'package:rpg_accounts/Provider/MovimientosProvider.dart';
import 'package:rpg_accounts/Provider/ProyectosProvider.dart';
import 'package:rpg_accounts/Views/Login/LoginPage.dart';
import 'package:rpg_accounts/Views/Materiales.dart';
import 'package:rpg_accounts/Views/Proyectos.dart';
import 'package:rpg_accounts/Widgets/Utils.dart';

import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProyectoProvider()), // ✅ Aquí se registra
        ChangeNotifierProvider(create: (_) => ProveedorMovimientoProvider()), // ✅ Aquí se registra
        ChangeNotifierProvider(create: (_) => ComentarioProvider()), // ✅ Aquí se registra |
         
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: LoginPage()
        
        //HomePage(),
      ),
    );
  }
}


class ConstructionFinanceApp extends StatefulWidget {
  @override
  _ConstructionFinanceAppState createState() => _ConstructionFinanceAppState();
}

class _ConstructionFinanceAppState extends State<ConstructionFinanceApp> {
  int _selectedIndex = 0; // Índice de la pestaña seleccionada

  // Lista de pantallas
  final List<Widget> _screens = [
    IncomeScreen(), // Pantalla Verde: Dinero que entra
    ExpenseScreen(), // Pantalla Roja: Dinero que sale
    BalanceScreen(), // Pantalla Amarilla: Balance general
  ];

  // Función para actualizar la pestaña seleccionada
  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0, // Sin sombra
        title: Padding(
          padding: EdgeInsets.only(top: 10), // Para que esté más cerca de la parte superior
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Botón para "Entra"
              GestureDetector(
                onTap: () => _onTabTapped(0),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  color: _selectedIndex == 0 ? Colors.green : Colors.transparent,
                  child: Text(
                    "Entra",
                    style: TextStyle(
                      color: _selectedIndex == 0 ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Espaciado entre los botones
              SizedBox(width: 10),
              // Botón para "Sale"
              GestureDetector(
                onTap: () => _onTabTapped(1),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  color: _selectedIndex == 1 ? Colors.red : Colors.transparent,
                  child: Text(
                    "Sale",
                    style: TextStyle(
                      color: _selectedIndex == 1 ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Espaciado entre los botones
              SizedBox(width: 10),
              // Botón para "Balance"
              GestureDetector(
                onTap: () => _onTabTapped(2),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  color: _selectedIndex == 2 ? Colors.amber : Colors.transparent,
                  child: Text(
                    "Balance",
                    style: TextStyle(
                      color: _selectedIndex == 2 ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _screens[_selectedIndex], // Mostrar la pantalla correspondiente
    );
  }
}


class IncomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green[100],
      child: Center(
        child: Text(
          "Dinero que entra",
          style: TextStyle(fontSize: 24, color: Colors.green[900]),
        ),
      ),
    );
  }
}

class ExpenseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red[100],
      child: Center(
        child: Text(
          "Dinero que sale",
          style: TextStyle(fontSize: 24, color: Colors.red[900]),
        ),
      ),
    );
  }
}

class BalanceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.yellow[100],
      child: Center(
        child: Text(
          "Balance general",
          style: TextStyle(fontSize: 24, color: Colors.yellow[900]),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final UsuarioSistemaRPG usuario;

  const HomePage({super.key, required this.usuario});

  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {

      // Obtener el tamaño de la pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Variables de tamaño basadas en el tamaño de la pantalla
    final containerWidth = screenWidth * 1; // 80% del ancho de la pantalla
    final containerHeight = screenHeight * 1; // 30% de la altura de la pantalla


  
    return Scaffold(

       body: Container(
height: containerHeight,
width:containerWidth ,
child:PaginaPrincipal()
       ),


    );
  }
}

class InicioPage2 extends StatefulWidget {
  const InicioPage2({super.key});

  @override
  State<InicioPage2> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage2>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
body: SingleChildScrollView(
  child: Row(
    children: [

Flexible(flex:3,child:
RowWidget()
 ),
Flexible(
  flex: 7,
  child:
Column(children: [
TopRow(),
TopRowBottom()

],)

 )

    ],
  )


),



    );
  }
}

class ColumnWidget extends StatelessWidget {
  const ColumnWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Flexible(child: Container(
height: double.infinity,width: double.infinity,
          color: Colors.yellow,


        )),
        
        Flexible(child: Container(
height: double.infinity,width: double.infinity,
          color: Colors.yellow,

        ))


      ],
    );
  }
}


class TopRowBottom extends StatelessWidget {
  const TopRowBottom({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(


      children: [
     
        Flexible(child: Container(
height: double.infinity,width: double.infinity,
          color: Colors.red,

        )),
     
        Flexible(child: Container(
height: double.infinity,width: double.infinity,
          color: Colors.yellow,

        )),
     
        Flexible(child: Container(
height: double.infinity,width: double.infinity,
          color: Colors.red,

        ))
,     
        Flexible(child: Container(
height: double.infinity,width: double.infinity,
          color: Colors.yellow,

        ))


      ],
    );
  }
}

class TopRow extends StatefulWidget {
  const TopRow({super.key});

  @override
  State<TopRow> createState() => _TopRowState();
}

class _TopRowState extends State<TopRow> {
  @override
  Widget build(BuildContext context) {
    return Row(
children: [
        Flexible(flex: 3,child: Container(height: double.infinity,width: double.infinity,
          color: Colors.red,

        )),
              Flexible(flex: 3,child: Container(height: double.infinity,width: double.infinity,
          color: Colors.redAccent,

        )),
],
      
    );
  }
}

class RowWidget extends StatelessWidget {
  const RowWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        Flexible(flex: 3,child: Container(height: double.infinity,width: double.infinity,
          color: Colors.yellow,

        )),
 
      ],
    );
  }
}





class PaginaPrincipal extends StatefulWidget {
  

  
  @override
  State<PaginaPrincipal> createState() => _PaginaPrincipalState();
}
class _PaginaPrincipalState extends State<PaginaPrincipal> {
  bool isVisible = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    // Accede al provider y llama a fetchProyectos si es necesario
    Future.microtask(() async {
      final provider = Provider.of<ProyectoProvider>(context, listen: false);
      await provider.fetchProyectos(); // Si tienes una función para obtener los proyectos
      print("== Proyectos cargados desde PaginaPrincipal ==");
      print(provider.proyectos.toString()); // Asegúrate de tener .proyectos definido
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Inicio",
            style: TextStyle(color: Colors.white),
          ),    
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        drawer: AppDrawer(),
        body: Container(
          margin: EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    if (isVisible)
                      Flexible(
                        flex: 3,
                        child: Container(
                          color: Colors.redAccent,
                          child: Center(
                            child: Text(
                              "Sección Lateral",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    Flexible(
                      flex: 5,
                      child: Column(
                        children: [
                          Flexible(
                            flex: 3,
                            child: Container(
                              color: Colors.black38,
                              child: Center(child: _ChartApp()),
                            ),
                          ),
                          Flexible(
                            flex: 5,
                            child: Container(
                              color: Colors.lightBlue,
                              child: HomePage2(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// class ProyectoTable extends StatelessWidget {
//   final List<Map<String, dynamic>> proyectos = [
//     {'nombre': 'Proyecto ABC', 'dias': 20},
//     {'nombre': 'Proyecto XYZ', 'dias': 35},
//     {'nombre': 'Proyecto 123', 'dias': 18},
//     {'nombre': 'Proyecto ABC', 'dias': 20},
//     {'nombre': 'Proyecto XYZ', 'dias': 35},
//     {'nombre': 'Proyecto 123', 'dias': 18},
//   ];

//   Color getAlertColor(int dias) {
//     if (dias > 30) {
//       return Colors.yellow.shade700; // Amarillo para más de 30 días
//     } else if (dias > 15) {
//       return Colors.blue.shade700; // Azul para días entre 15 y 30
//     } else {
//       return Colors.green.shade700; // Verde para días menores a 15
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(

//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               Text(
//                 'Alertas Proyectos',
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 10),
//               // Cuadrícula de 4 elementos por fila
//               GridView.builder(
//                 shrinkWrap: true, // Esto permite que el GridView ocupe el espacio disponible sin desbordarse
//                 physics: NeverScrollableScrollPhysics(), // Deshabilitar desplazamiento en el GridView
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 4, // 4 elementos por fila
//                   crossAxisSpacing: 10,
//                   mainAxisSpacing: 10,
//                   childAspectRatio: 1.0, // Ajustar el tamaño de cada card
//                 ),
//                 itemCount: proyectos.length,
//                 itemBuilder: (context, index) {
//                   final proyecto = proyectos[index];
//                   return Card(
//                     elevation: 5,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             proyecto['nombre'],
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 10, // Reducir tamaño de texto
//                             ),
//                           ),
//                           SizedBox(height: 15),
//                           // Mostrar el número de días con el color correspondiente
//                           Container(
//                             padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                             decoration: BoxDecoration(
//                               color: getAlertColor(proyecto['dias']),
//                               borderRadius: BorderRadius.circular(5),
//                             ),
//                             child: Text(
//                               '${proyecto['dias']} días',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 12, // Reducir tamaño de texto
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class BankAccountSummary extends StatefulWidget {
  @override
  _BankAccountSummaryState createState() => _BankAccountSummaryState();
}

class _BankAccountSummaryState extends State<BankAccountSummary> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await Provider.of<ProyectoProvider>(context, listen: false)
          .fetchResumenGeneral();
    } catch (e) {
      // El error ya se maneja en el Consumer
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      body: Consumer<ProyectoProvider>(
        builder: (context, provider, child) {
          if (provider.errorMessage != null) {
            return _buildErrorView(provider.errorMessage!);
          }

          if (provider.resumen == null) {
            return Center(child: CircularProgressIndicator());
          }

          final resumen = provider.resumen!;
          final theme = Theme.of(context);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSummaryCard(
                    context: context,
                    title: 'Resumen General',
                    theme: theme,
                    items: [
                      _buildSummaryItem(
                        'Ingresos Totales',
                        resumen.ingresosGenerales,
                        Colors.green,
                      ),
                      _buildSummaryItem(
                        'Egresos Totales',
                        resumen.egresosGenerales,
                        Colors.red,
                      ),
                      _buildSummaryItem(
                        'Saldo General',
                        resumen.saldoGenerales,
                        resumen.saldoGenerales >= 0 ? Colors.blue : Colors.red,
                        isTotal: true,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _buildSummaryCard(
                    context: context,
                    title: 'Resumen Mensual',
                    theme: theme,
                    items: [
                      _buildSummaryItem(
                        'Ingresos Mensuales',
                        resumen.ingresosMensuales,
                        Colors.green,
                      ),
                      _buildSummaryItem(
                        'Egresos Mensuales',
                        resumen.egresosMensuales,
                        Colors.red,
                      ),
                      _buildSummaryItem(
                        'Saldo Mensual',
                        resumen.saldoMensuales,
                        resumen.saldoMensuales >= 0 ? Colors.blue : Colors.red,
                        isTotal: true,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _buildBankBalanceCard(
                    context: context,
                    theme: theme,
                    balance: resumen.totalBanco,
                    onEdit: () => _showEditDialog(context, resumen.totalBanco),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorView(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 48),
          SizedBox(height: 16),
          Text(
            'Error al cargar los datos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required BuildContext context,
    required String title,
    required ThemeData theme,
    required List<Widget> items,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
  title,
  style: TextStyle(
    fontSize: 18, // Tamaño similar a headline6
    fontWeight: FontWeight.bold,
  ),
),
            SizedBox(height: 12),
            Divider(thickness: 1),
            SizedBox(height: 8),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    double value,
    Color color, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            NumberFormatter.formatCurrency(value),
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
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

  Widget _buildBankBalanceCard({
    required BuildContext context,
    required ThemeData theme,
    required double balance,
    required VoidCallback onEdit,
  }) {
    return Card(
      elevation: 4,
      color: balance >= 0
          ? Colors.blue.shade50
          : Colors.red.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
  children: [
    Text(
      'Saldo Bancario',
      style: TextStyle(
        fontSize: 18, // Tamaño similar a headline6
        fontWeight: FontWeight.bold,
        color: balance >= 0 ? Colors.blue : Colors.red,
      ),
    ),
    Spacer(),
    IconButton(
      icon: Icon(Icons.edit, color: Colors.grey),
      onPressed: onEdit,
      tooltip: 'Editar saldo',
    ),
  ],
),
SizedBox(height: 8),
Text(
  NumberFormatter.formatCurrency(balance),
  style: TextStyle(
    fontSize: 24, // Tamaño similar a headline5
    fontWeight: FontWeight.bold,
    color: balance >= 0 ? Colors.blue : Colors.red,
  ),
),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, double currentBalance) async {
    final controller = TextEditingController(
      text: currentBalance.toStringAsFixed(2),
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Actualizar Saldo Bancario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            _buildBudgetField(controller)
            // TextField(
            //   controller: controller,
            //   keyboardType: TextInputType.numberWithOptions(decimal: true),
            //   decoration: InputDecoration(
            //     labelText: 'Nuevo saldo',
            //     prefixText: '\$',
            //     border: OutlineInputBorder(),
            //   ),
            // ),

            ,
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: _isLoading
                ? null
                : () async {
                    setState(() => _isLoading = true);

                    
                 final newBalance = double.tryParse(
  controller.text
    .replaceAll('\$', '')  // Aplica el mismo formato
    .replaceAll(',', '')
    .trim()
) ?? currentBalance;
                    try {
                      await Provider.of<ProyectoProvider>(context, listen: false)
                          .modificarSaldoBanco(newBalance);
                      Navigator.of(context).pop(true);
                    } finally {
                      setState(() => _isLoading = false);
                    }
                  },
            child: Text('Guardar'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _loadData(); // Recargar datos después de actualizar
    }
  }
}
// class BankAccountSummary extends StatefulWidget {
//   @override
//   _BankAccountSummaryState createState() => _BankAccountSummaryState();
// }

// class _BankAccountSummaryState extends State<BankAccountSummary> {
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() =>
//         Provider.of<ProyectoProvider>(context, listen: false)
//             .fetchResumenGeneral());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Consumer<ProyectoProvider>(
//         builder: (context, provider, child) {
//           final resumen = provider.resumen;

//           if (provider.errorMessage != null) {
//             return Center(child: Text(provider.errorMessage!));
//           }

//           if (resumen == null) {
//             return Center(child: CircularProgressIndicator());
//           }

//           return Center(
//             child: Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Card(
//                 margin: EdgeInsets.all(16),
//                 elevation: 6,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16)),
//                 child: Padding(
//                   padding: const EdgeInsets.all(10.0),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Row(
//                         children: [
//                           Flexible(
//                             flex: 3,
//                             child: Text(
//                               'Resumen Financiero',
//                               style: TextStyle(
//                                   fontSize: 18, fontWeight: FontWeight.bold),
//                             ),
//                           ),
//                           Flexible(
//                             flex: 1,
//                             child: IconButton(
//                               icon: Icon(Icons.edit, color: Colors.grey),
//                               onPressed: () => _showEditDialog(context, resumen.saldo),
//                             ),
//                           ),
//                         ],
//                       ),
//                       Divider(thickness: 1, color: Colors.grey.shade400),
//                       _buildRow("Total Ingresos:", resumen.ingresos, Colors.green),
//                       _buildRow("Total Salidas:", resumen.egresos, Colors.red),
//                       Divider(thickness: 1, color: Colors.grey.shade400),
//                       _buildRow("Saldo Total:", resumen.saldo,
//                           resumen.saldo >= 0 ? Colors.blue : Colors.red,
//                           fontWeight: FontWeight.bold),
                   
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

// void _showEditDialog(BuildContext context, double currentSaldo) {
//   TextEditingController controller =
//       TextEditingController(text: currentSaldo.toStringAsFixed(2));

//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: Text('Editar Saldo Total'),
//       content: TextField(
//         controller: controller,
//         keyboardType: TextInputType.numberWithOptions(decimal: true),
//         decoration: InputDecoration(labelText: 'Nuevo Saldo Total'),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: Text('Cancelar'),
//         ),
//         TextButton(
//           onPressed: () async {
//             double? nuevoSaldo =
//                 double.tryParse(controller.text.replaceAll(',', '.'));
//             if (nuevoSaldo != null) {
//               try {
//                 await Provider.of<ProyectoProvider>(context, listen: false)
//                     .modificarSaldoBanco(nuevoSaldo);

//                 await Provider.of<ProyectoProvider>(context, listen: false)
//                     .fetchResumenGeneral();  // Recarga datos después de actualizar

//                 Navigator.of(context).pop();
//               } catch (e) {
//                 // Opcional: manejar error (mostrar diálogo o snackbar)
//                 Navigator.of(context).pop();
//               }
//             }
//           },
//           child: Text('Guardar'),
//         ),
//       ],
//     ),
//   );
// }

//   Widget _buildRow(String label, double value, Color color,
//       {FontWeight fontWeight = FontWeight.normal}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(fontSize: 16),
//           ),
//           Text(
//             '\$${value.toStringAsFixed(2)}',
//             style:
//                 TextStyle(fontSize: 16, fontWeight: fontWeight, color: color),
//           ),
//         ],
//       ),
//     );
//   }
// }


class HomePage2 extends StatefulWidget {
  @override
  State<HomePage2> createState() => _HomePage2State();
}

class _HomePage2State extends State<HomePage2> {
  int _selectedIndex = 0; // Índice de la pestaña seleccionada

  // Lista de tablas (pantallas) que se mostrarán debajo de la barra de navegación
  final List<Widget> _screens = [
   Container(
      child: Row(
        children: [

//Flexible(flex:3,child: Container(height: double.infinity,width: double.infinity,color: Colors.white12,child: ProyectoTable(),)),
//card rojo mejorar
     Flexible(
   flex:5,
  child: Center(
    child: Container(height: double.infinity,width: double.infinity,child:ProjectScreen(isHome: true,))
  ),
),
// Flexible(
//   flex: 2,
//   child: AspectRatio(
//     aspectRatio: 1, // Container cuadrado
//     child: Stack(
//       children: [
//         // Fondo con scroll tipo Sliver
//         Positioned.fill(
//           child: CustomScrollView(
//             slivers: [
//               // Espacio reservado para el resumen (mismo alto que el widget fijo)
//               SliverToBoxAdapter(
//                 child: SizedBox(height: 150),
//               ),

//               // Contenido desplazable real
//               SliverList(
//                 delegate: SliverChildListDelegate([
//                   Container(
//                     height: 200,
//                     color: Colors.red,
//                     child:BankAccountSummary(),
//                   ),
//                 ]),
//               ),
//             ],
//           ),
//         ),

//         // // Widget fijo encima, transparente
//         Positioned(
//           top: 0,
//           left: 0,
//           right: 0,
//           child: Container(
//             height: 180,
//             color: Colors.transparent,
//             child: ProyectoTable(),
//           ),
//         ),
//       ],
//     ),
//   ),
// )

Flexible(flex: 2,child: BankAccountSummary()),


        ],
      ),
    ), 





       Container(
      child: Row(
        children: [

          Flexible(flex:5,
            child: Center(
              child: DataTable(columns: [
                DataColumn(label: Text('Fecha')),
                DataColumn(label: Text('Monto')),
                DataColumn(label: Text('Descripción')),
              ], rows: [
                DataRow(cells: [
                  DataCell(Text('01/01/2025')),
                  DataCell(Text('\$1000')),
                  DataCell(Text('Pago de proyecto')),
                ]),
                DataRow(cells: [
                  DataCell(Text('02/01/2025')),
                  DataCell(Text('\$500')),
                  DataCell(Text('Pago de material')),
                ]),
              ]),
            ),
          ),
        ],
      ),
    ), 
       Container(
      child: Row(
        children: [


          Flexible(flex:5,
            child: Center(
              child: DataTable(columns: [
                DataColumn(label: Text('Fecha')),
                DataColumn(label: Text('Monto')),
                DataColumn(label: Text('Descripción')),
              ], rows: [
                DataRow(cells: [
                  DataCell(Text('01/01/2025')),
                  DataCell(Text('\$1000')),
                  DataCell(Text('Pago de proyecto')),
                ]),
                DataRow(cells: [
                  DataCell(Text('02/01/2025')),
                  DataCell(Text('\$500')),
                  DataCell(Text('Pago de material')),
                ]),
              ]),
            ),
          ),
        ],
      ),
    ), 
  ];

  // Función para cambiar de tabla
  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // Sección principal con tablas
                Flexible(
                  flex: 5,
                  child: Column(
                    children: [
                      Flexible(
                        flex: 5,
                        child: _screens[_selectedIndex], // Mostrar la tabla correspondiente
                      ),
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




class InicioPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
     
      ),
      body: Center(
        child: Text(
          'Página de Inicio',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
class ProyectosPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(child: ProjectScreen(isHome: false,),) ;
  }
}
// class ProyectosPage extends StatelessWidget {
//   // Lista de proyectos de ejemplo
//   final List<Map<String, dynamic>> proyectos = [
//     {"nombre": "Proyecto 1", "activo": false},
//     {"nombre": "Proyecto 2", "activo": true}, // Solo este tiene botón activo
//     {"nombre": "Proyecto 3", "activo": false},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Seleccionar Proyecto"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Barra de búsqueda
//             Padding(
//               padding: const EdgeInsets.only(bottom: 16.0),
//               child: TextField(
//                 decoration: InputDecoration(
//                   labelText: "Buscar Proyecto",
//                   prefixIcon: Icon(Icons.search),
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//             ),
//             // Tabla de proyectos
//             Expanded(
//               child: ListView.builder(
//                 itemCount: proyectos.length,
//                 itemBuilder: (context, index) {
//                   final proyecto = proyectos[index];
//                   return Card(
//                     margin: EdgeInsets.all(8.0),
//                     child: ListTile(
//                       title: Text(proyecto['nombre']),
//                       trailing: proyecto['activo']
//                           ? ElevatedButton(
//                               onPressed: () {
//                                 // Navegar a la página de DashboardScreen si está activo
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => DashboardScreen(),
//                                   ),
//                                 );
//                               },
//                               child: Text("Abrir"),
//                             )
//                           : null, // Sin botón si no está activo
//                       onTap: () {
//                         // Acción adicional al seleccionar un proyecto (opcional)
//                         showDialog(
//                           context: context,
//                           builder: (context) => AlertDialog(
//                             title: Text("Proyecto Seleccionado"),
//                             content: Text(
//                                 "Seleccionaste: ${proyecto['nombre']}, pero no está activo."),
//                             actions: [
//                               TextButton(
//                                 onPressed: () => Navigator.of(context).pop(),
//                                 child: Text("Cerrar"),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
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



class GestionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  
      ),
      body: Center(
        child: Text(
          'Opciones de Gestión',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

class _ChartApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ConstructionProjectsChart(),
    );
  }
}
 
class ConstructionProjectsChart extends StatefulWidget {
  @override
  _ConstructionProjectsChartState createState() =>
      _ConstructionProjectsChartState();
}

class _ConstructionProjectsChartState extends State<ConstructionProjectsChart> {
  late List<_ProjectData> projectData;
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(enable: true);
 Future.microtask(() {
  final provider = Provider.of<ProyectoProvider>(context, listen: false);
  provider.fetchProjectDataBarChart();
  provider.fetchPieChartData();
});

    // Datos de los proyectos de construcción
    projectData = [
      _ProjectData('Enero', 220, 180, 40),
      _ProjectData('Febrero', 280, 190, 90),
      _ProjectData('Marzo', 250, 210, 40),
      _ProjectData('Abril', 300, 220, 80),
      _ProjectData('Mayo', 260, 190, 70),
      _ProjectData('Junio', 320, 260, 60),
      _ProjectData('Julio', 310, 250, 60),
      _ProjectData('Agosto', 270, 200, 70),
      _ProjectData('Septiembre', 290, 230, 60),
      _ProjectData('Octubre', 310, 240, 70),
      _ProjectData('Noviembre', 330, 250, 80),
      _ProjectData('Diciembre', 350, 270, 80),
    ];
  }

  void _loadProjects() async {
    final provider = Provider.of<ProyectoProvider>(context, listen: false);
    await provider.fetchProjectDataBarChart();
    
  }



  double getTotal(String field) {
    return projectData.fold(
      0.0,
      (sum, item) => sum + (field == 'totalPrice'
          ? item.totalPrice
          : field == 'projectCost'
              ? item.projectCost
              : item.profit),
    );
  }
        
  @override
  Widget build(BuildContext context) {
    // Calcular los totales para la gráfica de pastel
    final total = getTotal('totalPrice');
    final cost = getTotal('projectCost');
    final profit = getTotal('profit');

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
Flexible(
  flex: 5,
  child: Consumer<ProyectoProvider>(
    builder: (context, provider, child) {
      final data = provider.projectData;

      return SfCartesianChart(
        tooltipBehavior: TooltipBehavior(enable: true),
        primaryXAxis: CategoryAxis(title: AxisTitle(text: 'Meses')),
        primaryYAxis: NumericAxis(
          title: AxisTitle(text: 'Montos en USD'),
        ),
        legend: Legend(isVisible: true),
        series: <CartesianSeries>[
          ColumnSeries<ProjectData, String>(
            dataSource: data,
            xValueMapper: (data, _) => data.projectName,
            yValueMapper: (data, _) => data.totalPrice,
            name: 'Totales',
            color: Colors.yellow,
          ),
          ColumnSeries<ProjectData, String>(
            dataSource: data,
            xValueMapper: (data, _) => data.projectName,
            yValueMapper: (data, _) => data.projectCost,
            name: 'Costos',
            color: Colors.red,
          ),
          ColumnSeries<ProjectData, String>(
            dataSource: data,
            xValueMapper: (data, _) => data.projectName,
            yValueMapper: (data, _) => data.profit,
            name: 'Ganancias',
            color: Colors.green,
          ),
        ],
      );
    },
  ),
),

            // Gráfica de pastel
Flexible(
  flex: 3,
  child: Consumer<ProyectoProvider>(
    builder: (context, proyectoProvider, child) {
      final pieData = proyectoProvider.pieChartData;

      if (pieData == null) {
        // Mientras carga o no hay datos
        return Center(child: CircularProgressIndicator());
      }

      return SfCircularChart(
        title: ChartTitle(text: 'Distribución Total'),
        legend: Legend(
          isVisible: true,
          overflowMode: LegendItemOverflowMode.wrap,
        ),
        series: <CircularSeries>[
          PieSeries<_PieData, String>(
            dataSource: [
              _PieData('Adelantos', pieData.total, Colors.yellow),
              _PieData('Costos', pieData.cost, Colors.red),
              _PieData('Ganancias', pieData.profit, Colors.green),
            ],
            xValueMapper: (data, _) => data.label,
            yValueMapper: (data, _) => data.value,
            pointColorMapper: (data, _) => data.color,
            dataLabelSettings: DataLabelSettings(isVisible: true),
          ),
        ],
      );
    },
  ),
),

      Flexible(
  flex: 3,
  child: Consumer<ProyectoProvider>(
    builder: (context, proyectoProvider, child) {
      final pieData = proyectoProvider.pieChartData;

      if (pieData == null) {
        return Center(child: CircularProgressIndicator());
      }

      // Calcular porcentaje de ganancia: (profit / total) * 100
      final porcentajeGanancia = pieData.total != 0
          ? (pieData.profit / pieData.total) * 100
          : 0.0;

      // Datos a mostrar en el Grid
   final List<Map<String, dynamic>> items = [
  {
    'icon': Icons.money,
    'value': '\$${NumberFormatter.format(pieData.total)}',
    'label': 'Total Monto del Mes',
    'cardColor': Colors.green.shade100,
    'iconColor': Colors.green,
    'textColor': Colors.black,
  },
  {
    'icon': Icons.attach_money,
    'value': '${NumberFormatter.format(porcentajeGanancia, decimalPlaces: 2)}%',
    'label': 'Porcentaje de Ganancia',
    'cardColor': Colors.orange.shade100,
    'iconColor': Colors.orange,
    'textColor': Colors.black,
  },
  {
    'icon': Icons.bar_chart,
    'value': '\$${NumberFormatter.format(pieData.cost)}',
    'label': 'Total de Costos',
    'cardColor': Colors.blue.shade100,
    'iconColor': Colors.blue,
    'textColor': Colors.black,
  },
  {
    'icon': Icons.account_balance_wallet,
    'value': '\$${NumberFormatter.format(pieData.profit)}',
    'label': 'Ganancia en Dinero',
    'cardColor': Colors.purple.shade100,
    'iconColor': Colors.purple,
    'textColor': Colors.black,
  },
];

 return Container(
  padding: EdgeInsets.all(2),
  child: GridView.builder(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,        // 2 por fila
      crossAxisSpacing: 4,      // Espaciado horizontal
      mainAxisSpacing: 1,       // Espaciado vertical
      childAspectRatio: 1.9,      // Cuadrado perfecto
    ),
    itemCount: items.length,
    itemBuilder: (context, index) {
      final item = items[index];

      return Card(
        color: item['cardColor'],
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item['icon'],
                size: 24,
                color: item['iconColor'],
              ),
              SizedBox(height: 4),
              Text(
                item['value'],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: item['textColor'],
                ),
              ),
              SizedBox(height: 2),
              Text(
                item['label'],
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 9, color: item['textColor']),
              ),
            ],
          ),
        ),
      );
    },
  ),
);

    },
  ),
),

          ],
        ),
      ),
    );
  }
}

// Clase para los datos de la gráfica de pastel
class _PieData {
  final String label;
  final double value;
  final Color color;

  _PieData(this.label, this.value, this.color);
}

class _ProjectData {
  final String projectName;
  final double totalPrice;
  final double projectCost;
  final double profit;

  _ProjectData(this.projectName, this.totalPrice, this.projectCost, this.profit);
}


// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   int selectedPage = 0;

//   final List<Widget> pages = [
//     ProyectoPage(),
//     Center(child: Text("Categoría 2")),
//     Center(child: Text("Categoría 3")),
//     Center(child: Text("Categoría 4")),
//     Center(child: Text("Categoría 5")),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         NavigationRail(
//           selectedIndex: selectedPage,
//           onDestinationSelected: (index) {
//             setState(() {
//               selectedPage = index;
//             });
//           },
//           labelType: NavigationRailLabelType.all,
//           destinations: [
//             NavigationRailDestination(
//               icon: Icon(Icons.bar_chart),
//               label: Text("Proyecto"),
//             ),
//             NavigationRailDestination(
//               icon: Icon(Icons.settings),
//               label: Text("Categoría 2"),
//             ),
//             NavigationRailDestination(
//               icon: Icon(Icons.list),
//               label: Text("Categoría 3"),
//             ),
//             NavigationRailDestination(
//               icon: Icon(Icons.info),
//               label: Text("Categoría 4"),
//             ),
//             NavigationRailDestination(
//               icon: Icon(Icons.construction),
//               label: Text("Categoría 5"),
//             ),
//           ],
//         ),
//         Expanded(
//           child: Column(
//             children: [
//               Header(),
//               Expanded(child: pages[selectedPage]),
//               Footer(),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

class Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      color: Colors.blue,
      child: Text(
        "Gestión de Proyectos en Construcción",
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }
}

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      color: Colors.blueGrey,
      child: Center(
        child: Text(
          "© 2025 - Gestión de Proyectos",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class ProyectoPage extends StatelessWidget {
  final List<Map<String, dynamic>> movimientos = [
    {"tipo": "Gasto", "detalle": "Compra de materiales", "monto": 2000},
    {"tipo": "Recibo", "detalle": "Pago Cliente A", "monto": 4000},
    {"tipo": "Gasto", "detalle": "Salarios", "monto": 3000},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: CustomPaint(
            painter: BarChartPainter([
              {"label": "Gastos", "value": 5000},
              {"label": "Pagos", "value": 8000},
              {"label": "Rentabilidad", "value": 3000},
            ]),
          ),
        ),
        ButtonBar(
          alignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {},
              child: Text("Gastos"),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text("Recibos"),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text("Totales"),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: movimientos.length,
            itemBuilder: (context, index) {
              final movimiento = movimientos[index];
              return ListTile(
                title: Text(movimiento['detalle']),
                subtitle: Text("Monto: \$${movimiento['monto']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.orange),
                      onPressed: () => _showModal(context, "Editar Movimiento"),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showModal(context, "Eliminar Movimiento"),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FloatingActionButton(
            onPressed: () => _showModal(context, "Agregar Movimiento"),
            child: Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  void _showModal(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text("Formulario simple aquí..."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Aceptar"),
          ),
        ],
      ),
    );
  }
}


class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late List<TransactionData> chartData;
  List<Map<String, dynamic>> tableData = [];

  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(enable: true);

    // Datos iniciales de la gráfica
    chartData = [
      TransactionData('Enero', 1000, 500),
      TransactionData('Febrero', 1500, 800),
      TransactionData('Marzo', 1200, 700),
    ];
  }

  void _addTransaction(String type, String description, DateTime date, double amount) {
    setState(() {
      tableData.add({
        'type': type,
        'description': description,
        'date': date,
        'amount': amount,
      });

      // Actualizar datos de la gráfica
      double totalCobros = tableData
          .where((item) => item['type'] == 'Cobro')
          .fold(0, (sum, item) => sum + item['amount']);
      double totalGastos = tableData
          .where((item) => item['type'] == 'Gasto')
          .fold(0, (sum, item) => sum + item['amount']);

      chartData = [
        TransactionData('Enero', totalCobros, totalGastos),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gráfico y Tabla'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Gráfica de barras
            Expanded(
              flex: 3,
              child: SfCartesianChart(
                tooltipBehavior: _tooltipBehavior,
                primaryXAxis: CategoryAxis(
                  title: AxisTitle(text: 'Meses'),
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: 'Montos en USD'),
                ),
                legend: Legend(isVisible: true),
                series: <CartesianSeries>[
                  ColumnSeries<TransactionData, String>(
                    dataSource: chartData,
                    xValueMapper: (data, _) => data.month,
                    yValueMapper: (data, _) => data.cobros,
                    name: 'Cobros',
                    color: Colors.green,
                  ),
                  ColumnSeries<TransactionData, String>(
                    dataSource: chartData,
                    xValueMapper: (data, _) => data.month,
                    yValueMapper: (data, _) => data.gastos,
                    name: 'Gastos',
                    color: Colors.red,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Tabla
            Expanded(
              flex: 2,
              child: tableData.isEmpty
                  ? Center(child: Text('No hay datos en la tabla.'))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text('Tipo')),
                          DataColumn(label: Text('Descripción')),
                          DataColumn(label: Text('Fecha')),
                          DataColumn(label: Text('Monto')),
                        ],
                        rows: tableData
                            .map(
                              (item) => DataRow(
                                cells: [
                                  DataCell(Text(item['type'])),
                                  DataCell(Text(item['description'])),
                                  DataCell(Text(
                                      "${item['date'].day}/${item['date'].month}/${item['date'].year}")),
                                  DataCell(Text('\$${item['amount']}')),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
      // Botón flotante para agregar cobros/gastos
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => AddTransactionForm(
              onAddTransaction: _addTransaction,
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddTransactionForm extends StatefulWidget {
  final Function(String type, String description, DateTime date, double amount)
      onAddTransaction;

  const AddTransactionForm({required this.onAddTransaction});

  @override
  _AddTransactionFormState createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<AddTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'Cobro';
  String _description = '';
  DateTime _selectedDate = DateTime.now();
  double _amount = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dropdown para seleccionar el tipo
              DropdownButtonFormField<String>(
                value: _type,
                items: ['Cobro', 'Gasto']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _type = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Tipo'),
              ),
              // Campo de descripción
              TextFormField(
                decoration: InputDecoration(labelText: 'Descripción'),
                onChanged: (value) => _description = value,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),
              // Selección de fecha
              TextFormField(
                decoration: InputDecoration(labelText: 'Fecha'),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                  }
                },
                controller: TextEditingController(
                  text:
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
              ),
              // Campo de monto
              TextFormField(
                decoration: InputDecoration(labelText: 'Monto'),
                keyboardType: TextInputType.number,
                onChanged: (value) => _amount = double.tryParse(value) ?? 0,
                validator: (value) => (double.tryParse(value ?? '') ?? 0) <= 0
                    ? 'Ingrese un monto válido'
                    : null,
              ),
              SizedBox(height: 16),
              // Botón para agregar
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onAddTransaction(
                        _type, _description, _selectedDate, _amount);
                    Navigator.pop(context);
                  }
                },
                child: Text('Agregar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TransactionData {
  final String month;
  final double cobros;
  final double gastos;

  TransactionData(this.month, this.cobros, this.gastos);
}



class BarChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;

  BarChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final barWidth = size.width / (data.length * 2);
    final maxBarHeight = size.height - 20; // Espacio para texto

    final maxValue =
        data.map((item) => item['value'] as int).reduce((a, b) => a > b ? a : b);

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final barHeight = (item['value'] / maxValue) * maxBarHeight;
      final xCenter = i * (barWidth * 2) + barWidth;
      final yTop = size.height - barHeight;

      canvas.drawRect(
        Rect.fromLTWH(xCenter - barWidth / 2, yTop, barWidth, barHeight),
        paint,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: item['label'],
          style: TextStyle(fontSize: 12, color: Colors.black),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(xCenter - textPainter.width / 2, size.height - 20),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

import 'package:flutter/material.dart';

class Servicio {
  String nombre;
  bool seleccionado;
  double monto;

  Servicio({required this.nombre, this.seleccionado = false, this.monto = 0});
}


  void _abrirDialogoMovimiento(BuildContext context) {
    List<Servicio> serviciosDisponibles = [
      Servicio(nombre: 'Electricidad'),
      Servicio(nombre: 'Fontanería'),
      Servicio(nombre: 'Carpintería'),
      Servicio(nombre: 'Pintura'),
    ];

    List<Servicio> serviciosSeleccionados = [];
    String categoria = 'Pago';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            double total = serviciosSeleccionados.fold(
              0,
              (sum, s) => sum + s.monto,
            );

            return AlertDialog(
              title: Text('Agregar Movimiento'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
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
                                          style: TextStyle(fontSize: 18)),
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
                      child: Text('Seleccionar Servicios'),
                    ),
                    ...serviciosSeleccionados.map((s) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          children: [
                            Expanded(child: Text(s.nombre)),
                            SizedBox(
                              width: 100,
                              child: TextFormField(
                                initialValue:
                                    s.monto > 0 ? s.monto.toString() : '',
                                keyboardType: TextInputType.number,
                                decoration:
                                    InputDecoration(labelText: 'Monto'),
                                onChanged: (val) {
                                  setStateDialog(() {
                                    s.monto = double.tryParse(val) ?? 0;
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                      );
                    }).toList(),
                    SizedBox(height: 10),
                    DropdownButton<String>(
                      value: categoria,
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
                    Text("Total: \$${total.toStringAsFixed(2)}",
                        style: TextStyle(fontWeight: FontWeight.bold)),
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
                      content:
                          Text('Movimiento guardado como "$categoria"'),
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


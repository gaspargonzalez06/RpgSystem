class ProveedorModel {
  final int id;
  final String nombre;
  final int tipoUsuario;
  final String telefono;
  final String cedula;
  final String direccion;
  final String licencia;

  ProveedorModel({
    required this.id,
    required this.nombre,
    required this.tipoUsuario,
    required this.telefono,
    required this.cedula,
    required this.direccion,
    required this.licencia,
  });

  factory ProveedorModel.fromJson(Map<String, dynamic> json) {
    return ProveedorModel(
      id: json['Id_Usuario_Sistema'],
      nombre: json['Nombre_Usuario'] ?? '',
      tipoUsuario: json['Id_Tipo_Usuario'],
      telefono: json['Telefono'] ?? '',
      cedula: json['Cedula'] ?? '',
      direccion: json['Direccion'] ?? '',
      licencia: (json['Licencia']?.toString() ?? ''),
    );
  }
}

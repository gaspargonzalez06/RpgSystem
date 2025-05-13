class UsuarioSistema {
  final int id;
  final String nombre;
  final int tipo;
  final String? telefono;
  final String? cedula;
  final dynamic licencia; // Puede ser int o null
  final String? direccion;

  UsuarioSistema({
    required this.id,
    required this.nombre,
    required this.tipo,
    this.telefono,
    this.cedula,
    this.licencia,
    this.direccion,
  });

  factory UsuarioSistema.fromJson(Map<String, dynamic> json) {
    return UsuarioSistema(
      id: json['Id_Usuario_Sistema'],
      nombre: json['Nombre_Usuario'],
      tipo: json['Id_Tipo_Usuario'],
      telefono: json['Telefono'],
      cedula: json['Cedula'],
      licencia: json['Licencia'],
      direccion: json['Direccion'],
    );
  }
}

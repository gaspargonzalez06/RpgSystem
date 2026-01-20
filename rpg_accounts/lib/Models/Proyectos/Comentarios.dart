class Comentario {
  final int idComentario;
  final String asunto;
  final String comentario;
  final int idProyecto;
  final DateTime fechaComentario;


  Comentario({
    required this.idComentario,
    required this.asunto,
    required this.comentario,
    required this.idProyecto,
    required this.fechaComentario,

  });

  factory Comentario.fromJson(Map<String, dynamic> json) {
    return Comentario(
      idComentario: json['Id_Comentario'],
      asunto: json['Asunto'],
      comentario: json['Comentario'],
      idProyecto: json['Id_Proyecto'],
      fechaComentario: DateTime.parse(json['Fecha_Comentario']),

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Asunto': asunto,
      'Comentario': comentario,
      'Id_Proyecto': idProyecto,
    };
  }
}
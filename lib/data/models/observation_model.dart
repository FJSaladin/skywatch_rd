class ObservationModel {
  final int? id;
  final String titulo;
  final String fechaHora;       // ISO-8601: "2026-04-07T21:30:00"
  final double? lat;
  final double? lng;
  final String? ubicacionTexto;
  final int? duracionSeg;
  final String categoria;
  final String condicionesCielo;
  final String descripcion;
  final String? fotoPath;
  final String? audioPath;
  final String creadoEn;

  const ObservationModel({
    this.id,
    required this.titulo,
    required this.fechaHora,
    this.lat,
    this.lng,
    this.ubicacionTexto,
    this.duracionSeg,
    required this.categoria,
    required this.condicionesCielo,
    required this.descripcion,
    this.fotoPath,
    this.audioPath,
    required this.creadoEn,
  });

  // Objeto → Map (para INSERT/UPDATE)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'titulo':           titulo,
      'fecha_hora':       fechaHora,
      'lat':              lat,
      'lng':              lng,
      'ubicacion_texto':  ubicacionTexto,
      'duracion_seg':     duracionSeg,
      'categoria':        categoria,
      'condiciones_cielo': condicionesCielo,
      'descripcion':      descripcion,
      'foto_path':        fotoPath,
      'audio_path':       audioPath,
      'creado_en':        creadoEn,
    };
  }

  // Map → Objeto (para SELECT)
  factory ObservationModel.fromMap(Map<String, dynamic> map) {
    return ObservationModel(
      id:               map['id'] as int?,
      titulo:           map['titulo'] as String,
      fechaHora:        map['fecha_hora'] as String,
      lat:              map['lat'] as double?,
      lng:              map['lng'] as double?,
      ubicacionTexto:   map['ubicacion_texto'] as String?,
      duracionSeg:      map['duracion_seg'] as int?,
      categoria:        map['categoria'] as String,
      condicionesCielo: map['condiciones_cielo'] as String,
      descripcion:      map['descripcion'] as String,
      fotoPath:         map['foto_path'] as String?,
      audioPath:        map['audio_path'] as String?,
      creadoEn:         map['creado_en'] as String,
    );
  }

  // Copia con campos modificados
  ObservationModel copyWith({
    int? id,
    String? titulo,
    String? fechaHora,
    double? lat,
    double? lng,
    String? ubicacionTexto,
    int? duracionSeg,
    String? categoria,
    String? condicionesCielo,
    String? descripcion,
    String? fotoPath,
    String? audioPath,
    String? creadoEn,
  }) {
    return ObservationModel(
      id:               id ?? this.id,
      titulo:           titulo ?? this.titulo,
      fechaHora:        fechaHora ?? this.fechaHora,
      lat:              lat ?? this.lat,
      lng:              lng ?? this.lng,
      ubicacionTexto:   ubicacionTexto ?? this.ubicacionTexto,
      duracionSeg:      duracionSeg ?? this.duracionSeg,
      categoria:        categoria ?? this.categoria,
      condicionesCielo: condicionesCielo ?? this.condicionesCielo,
      descripcion:      descripcion ?? this.descripcion,
      fotoPath:         fotoPath ?? this.fotoPath,
      audioPath:        audioPath ?? this.audioPath,
      creadoEn:         creadoEn ?? this.creadoEn,
    );
  }
}
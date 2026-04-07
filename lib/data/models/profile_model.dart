class ProfileModel {
  final int id;
  final String nombre;
  final String apellido;
  final String matricula;
  final String? fotoPath;
  final String frase;

  const ProfileModel({
    this.id = 1, // Siempre es 1, solo hay un perfil
    required this.nombre,
    required this.apellido,
    required this.matricula,
    this.fotoPath,
    required this.frase,
  });

  Map<String, dynamic> toMap() => {
    'id':        id,
    'nombre':    nombre,
    'apellido':  apellido,
    'matricula': matricula,
    'foto_path': fotoPath,
    'frase':     frase,
  };

  factory ProfileModel.fromMap(Map<String, dynamic> map) => ProfileModel(
    id:        map['id'] as int,
    nombre:    map['nombre'] as String,
    apellido:  map['apellido'] as String,
    matricula: map['matricula'] as String,
    fotoPath:  map['foto_path'] as String?,
    frase:     map['frase'] as String,
  );

  ProfileModel copyWith({
    String? nombre,
    String? apellido,
    String? matricula,
    String? fotoPath,
    String? frase,
  }) => ProfileModel(
    nombre:    nombre ?? this.nombre,
    apellido:  apellido ?? this.apellido,
    matricula: matricula ?? this.matricula,
    fotoPath:  fotoPath ?? this.fotoPath,
    frase:     frase ?? this.frase,
  );
}
class AppConstants {
  // Categorías de observación
  static const List<String> categorias = [
    'Fenómeno atmosférico',
    'Astronomía',
    'Aves migratorias',
    'Aeronave / Objeto artificial',
    'Fenómeno luminoso',
    'Otro',
  ];

  // Condiciones del cielo
  static const List<String> condicionesCielo = [
    'Despejado',
    'Parcialmente nublado',
    'Nublado',
    'Bruma / Neblina',
    'Lluvia ligera',
  ];

  // Nombre de la base de datos
  static const String dbName    = 'cielo_obs.db';
  static const int    dbVersion = 1;

  // Nombres de tablas
  static const String tableObservations = 'observacion';
  static const String tableProfile      = 'perfil';
}
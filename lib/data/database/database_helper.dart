import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/observation_model.dart';
import '../models/profile_model.dart';
import '../../core/constants/app_constants.dart';

class DatabaseHelper {
  // ── Singleton ──────────────────────────────────────────────
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  // ── Inicialización ─────────────────────────────────────────
  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path   = join(dbPath, AppConstants.dbName);

    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabla de observaciones
    await db.execute('''
      CREATE TABLE ${AppConstants.tableObservations} (
        id               INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo           TEXT    NOT NULL,
        fecha_hora       TEXT    NOT NULL,
        lat              REAL,
        lng              REAL,
        ubicacion_texto  TEXT,
        duracion_seg     INTEGER,
        categoria        TEXT    NOT NULL,
        condiciones_cielo TEXT   NOT NULL,
        descripcion      TEXT    NOT NULL,
        foto_path        TEXT,
        audio_path       TEXT,
        creado_en        TEXT    NOT NULL
      )
    ''');

    // Tabla de perfil (máximo 1 registro)
    await db.execute('''
      CREATE TABLE ${AppConstants.tableProfile} (
        id        INTEGER PRIMARY KEY,
        nombre    TEXT NOT NULL,
        apellido  TEXT NOT NULL,
        matricula TEXT NOT NULL,
        foto_path TEXT,
        frase     TEXT NOT NULL
      )
    ''');
  }

  // ── CRUD Observaciones ─────────────────────────────────────

  Future<int> insertObservation(ObservationModel obs) async {
    final db = await database;
    return db.insert(
      AppConstants.tableObservations,
      obs.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ObservationModel>> getAllObservations({
    String? categoria,
    String? fechaDesde,
    String? fechaHasta,
  }) async {
    final db = await database;

    // Construcción dinámica del WHERE
    final conditions = <String>[];
    final args       = <dynamic>[];

    if (categoria != null && categoria.isNotEmpty) {
      conditions.add('categoria = ?');
      args.add(categoria);
    }
    if (fechaDesde != null) {
      conditions.add('fecha_hora >= ?');
      args.add(fechaDesde);
    }
    if (fechaHasta != null) {
      conditions.add('fecha_hora <= ?');
      args.add(fechaHasta);
    }

    final where = conditions.isEmpty ? null : conditions.join(' AND ');

    final maps = await db.query(
      AppConstants.tableObservations,
      where:   where,
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'fecha_hora DESC',
    );

    return maps.map(ObservationModel.fromMap).toList();
  }

  Future<ObservationModel?> getObservationById(int id) async {
    final db   = await database;
    final maps = await db.query(
      AppConstants.tableObservations,
      where:     'id = ?',
      whereArgs: [id],
      limit:     1,
    );
    return maps.isEmpty ? null : ObservationModel.fromMap(maps.first);
  }

  Future<int> updateObservation(ObservationModel obs) async {
    final db = await database;
    return db.update(
      AppConstants.tableObservations,
      obs.toMap(),
      where:     'id = ?',
      whereArgs: [obs.id],
    );
  }

  Future<int> deleteObservation(int id) async {
    final db = await database;
    return db.delete(
      AppConstants.tableObservations,
      where:     'id = ?',
      whereArgs: [id],
    );
  }

  // ── CRUD Perfil ────────────────────────────────────────────

  Future<void> upsertProfile(ProfileModel profile) async {
    final db = await database;
    await db.insert(
      AppConstants.tableProfile,
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // INSERT OR REPLACE
    );
  }

  Future<ProfileModel?> getProfile() async {
    final db   = await database;
    final maps = await db.query(AppConstants.tableProfile, limit: 1);
    return maps.isEmpty ? null : ProfileModel.fromMap(maps.first);
  }

  // ── Seguridad: Borrar Todo ─────────────────────────────────

  Future<void> deleteAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(AppConstants.tableObservations);
      await txn.delete(AppConstants.tableProfile);
    });
  }

  Future<void> closeDatabase() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}
import '../database/database_helper.dart';
import '../models/observation_model.dart';
import '../models/profile_model.dart';

class ObservationRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<int>                  save(ObservationModel obs)   => _db.insertObservation(obs);
  Future<int>                  update(ObservationModel obs) => _db.updateObservation(obs);
  Future<int>                  delete(int id)               => _db.deleteObservation(id);
  Future<ObservationModel?>    getById(int id)              => _db.getObservationById(id);
  Future<List<ObservationModel>> getAll({
    String? categoria,
    String? fechaDesde,
    String? fechaHasta,
  }) => _db.getAllObservations(
    categoria:  categoria,
    fechaDesde: fechaDesde,
    fechaHasta: fechaHasta,
  );

  Future<void>          saveProfile(ProfileModel p) => _db.upsertProfile(p);
  Future<ProfileModel?> getProfile()                => _db.getProfile();
  Future<void>          deleteAll()                 => _db.deleteAllData();
}
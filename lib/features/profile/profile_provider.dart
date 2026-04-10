import 'package:flutter/foundation.dart';
import '../../data/models/profile_model.dart';
import '../../data/repositories/observation_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ObservationRepository _repo = ObservationRepository();

  ProfileModel? _profile;
  bool          _loading = false;

  ProfileModel? get profile => _profile;
  bool          get loading => _loading;
  bool          get hasProfile => _profile != null;

  Future<void> loadProfile() async {
    _loading = true;
    notifyListeners();
    _profile = await _repo.getProfile();
    _loading = false;
    notifyListeners();
  }

  Future<bool> saveProfile(ProfileModel p) async {
    try {
      await _repo.saveProfile(p);
      _profile = p;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
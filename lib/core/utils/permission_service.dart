import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestLocation() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  static Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> requestMicrophone() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  // Abre configuración del sistema si el usuario denegó permanentemente
  static Future<void> openSettings() => openAppSettings();
}
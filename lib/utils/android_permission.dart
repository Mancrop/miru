import 'package:permission_handler/permission_handler.dart';


Future<bool> requestStoragePermissions() async {
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    status = await Permission.storage.request();
  }
  var status1 = await Permission.manageExternalStorage.request();
  if (status.isGranted) {
    return true;
  } else if (status.isPermanentlyDenied) {
    openAppSettings();
  }
  return status.isGranted && status1.isGranted;
}
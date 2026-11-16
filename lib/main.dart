import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/app/app.dart';
import 'package:smart_alarm/app/bindings/initial_binding.dart';
import 'package:smart_alarm/core/services/local_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = await LocalStorageService.create();
  Get.put<LocalStorageService>(storageService, permanent: true);

  InitialBinding().dependencies();

  runApp(const SmartAlarmApp());
}

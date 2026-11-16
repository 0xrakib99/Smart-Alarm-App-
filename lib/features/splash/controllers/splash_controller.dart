import 'dart:async';

import 'package:get/get.dart';
import 'package:smart_alarm/app/routes/app_routes.dart';

class SplashController extends GetxController {
  Timer? _navigationTimer;

  @override
  void onInit() {
    super.onInit();
    _navigationTimer = Timer(const Duration(milliseconds: 950), () {
      if (Get.currentRoute == AppRoutes.splash) {
        Get.offAllNamed<void>(AppRoutes.home);
      }
    });
  }

  @override
  void onClose() {
    _navigationTimer?.cancel();
    super.onClose();
  }
}

import 'package:get/get.dart';
import 'package:goodeeps2/constants.dart';

class BaseController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    logger.i("${runtimeType} on Init");
  }

  @override
  void onClose() {
    logger.e("${runtimeType} on Close");
    // TODO: implement onClose
    super.onClose();
  }
}

import 'package:get/get.dart';
import 'package:goodeeps2/controllers/base_controller.dart';

class AgreementFormController extends BaseController {
  var isAgreed = false.obs;

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    isAgreed.refresh();
  }

  void setAgreement(bool value) {
    isAgreed.value = value;
  }
}

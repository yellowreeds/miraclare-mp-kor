import 'package:get/get.dart';
import 'package:goodeeps2/constants.dart';
import 'package:goodeeps2/controllers/base_controller.dart';

class AgreementFormController extends BaseController {
  final String tag;
  var isAgreed = false.obs;

  AgreementFormController({required this.tag});

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    isAgreed.refresh();
  }

  void setAgreement(bool value) {
    logger.i(this);
    isAgreed.value = value;
  }
}

import 'package:get/get.dart';
import 'package:goodeeps2/controllers/base_controller.dart';

class TermsAgreementController extends BaseController {
  var isAgreedForm1 = false.obs;
  var isAgreedForm2 = false.obs;

  var areBothAgreed = false.obs;

  void setAgreement(String tag, bool isAgreed) {
    if (tag == "form1") {
      this.isAgreedForm1.value = isAgreed;
    } else {
      this.isAgreedForm2.value = isAgreed;
    }
  }

  @override
  void onInit() {
    super.onInit();
    everAll([isAgreedForm1, isAgreedForm2], (_) {
      areBothAgreed.value = isAgreedForm1.value && isAgreedForm2.value;
    });
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}

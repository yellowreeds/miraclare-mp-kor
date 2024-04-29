import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/controllers/pages/ble_connection_controller.dart';
import 'package:goodeeps2/controllers/pages/evaluation_controller.dart';
import 'package:goodeeps2/controllers/pages/info_controller.dart';
import 'package:goodeeps2/controllers/pages/main_navigation_controller.dart';
import 'package:goodeeps2/controllers/pages/setting_controller.dart';
import 'package:goodeeps2/controllers/widgets/agreement_form_controller.dart';
import 'package:goodeeps2/controllers/pages/find_password_controller.dart';
import 'package:goodeeps2/controllers/pages/login_controller.dart';
import 'package:goodeeps2/controllers/pages/find_id_controller.dart';
import 'package:goodeeps2/controllers/pages/signup_controller.dart';
import 'package:goodeeps2/controllers/widgets/validity_textfield_controller.dart';
import 'package:goodeeps2/utils/enums.dart';
import 'controllers/pages/home_controller.dart';

class LoginBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}

class FindIdBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FindIdController>(() => FindIdController());
  }
}

class FindPasswordBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FindPasswordController>(() => FindPasswordController());
  }
}

class TermsAgreementBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AgreementFormController>(() => AgreementFormController(),
        tag: 'form1');
    Get.lazyPut<AgreementFormController>(() => AgreementFormController(),
        tag: 'form2');
  }
}

class SignupBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignupController>(() => SignupController());
    Get.lazyPut<ValidityTextFieldController>(
        () => ValidityTextFieldController(TextFieldType.id),
        tag: "id");
    Get.lazyPut<ValidityTextFieldController>(
        () => ValidityTextFieldController(TextFieldType.password),
        tag: "password");
    Get.lazyPut<ValidityTextFieldController>(
        () => ValidityTextFieldController(TextFieldType.passwordConfirm),
        tag: "passwordConfirm");
    Get.lazyPut<ValidityTextFieldController>(
        () => ValidityTextFieldController(TextFieldType.name),
        tag: "name");
    Get.lazyPut<ValidityTextFieldController>(
        () => ValidityTextFieldController(TextFieldType.phone),
        tag: "phone");
    Get.lazyPut<ValidityTextFieldController>(
        () => ValidityTextFieldController(TextFieldType.birthDate),
        tag: "birthDate");
    Get.lazyPut<ValidityTextFieldController>(
        () => ValidityTextFieldController(TextFieldType.email),
        tag: "email");
    // Get.lazyPut<ValidityTextFieldController>(
    //     () => ValidityTextFieldController(TextFieldType.verificationCode),
    //     tag: "verificationCode");
    Get.lazyPut<ValidityTextFieldController>(
        () => ValidityTextFieldController(TextFieldType.address),
        tag: "address");
    Get.lazyPut<ValidityTextFieldController>(
        () => ValidityTextFieldController(TextFieldType.detailAddress),
        tag: "detailAddress");
    Get.lazyPut<TextEditingController>(() => TextEditingController(),
        tag: "authCode");
  }
}

class MainNavigationBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainNavigationController>(() => MainNavigationController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<SettingController>(() => SettingController());
  }
}

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}

class EvaluationBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EvaluationController>(() => EvaluationController());
  }
}

class SettingBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingController>(() => SettingController());
  }
}

class InfoBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InfoController>(() => InfoController());
  }
}

class BluetoothConnectionBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BluetoothConnectionController>(() => BluetoothConnectionController());
  }
}

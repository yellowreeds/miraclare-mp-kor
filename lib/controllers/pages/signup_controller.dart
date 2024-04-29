import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/constants.dart';
import 'package:goodeeps2/controllers/base_controller.dart';
import 'package:goodeeps2/controllers/widgets/validity_textfield_controller.dart';
import 'package:goodeeps2/services/auth_service.dart';
import 'package:goodeeps2/services/user_service.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class SignupController extends BaseController {
  late final idController = Get.find<ValidityTextFieldController>(tag: 'id');
  late final passwordController = Get.find<ValidityTextFieldController>(
      tag: ''
          'password');
  late final passwordConfirmController = Get.find<ValidityTextFieldController>(
      tag: ''
          'passwordConfirm');
  late final nameController = Get.find<ValidityTextFieldController>(
      tag: ''
          'name');
  late final phoneController = Get.find<ValidityTextFieldController>(
      tag: ''
          'phone');
  late final birthDateController = Get.find<ValidityTextFieldController>(
      tag: ''
          'birthDate');
  late final emailController = Get.find<ValidityTextFieldController>(
      tag: ''
          'email');
  late final verificationCodeController = Get.find<ValidityTextFieldController>(
      tag: ''
          'verificationCode');
  late final addressController = Get.find<ValidityTextFieldController>(
      tag: ''
          'address');
  late final detailAddressController = Get.find<ValidityTextFieldController>(
      tag: ''
          'detailAddress');
  late final authCodeController = Get.find<TextEditingController>(
      tag: ''
          'authCode');

  final AuthService authService = AuthService();



  var canSendVerificationCode = false.obs;

  @override
  void onInit() {
    super.onInit();
    emailController.textEditingController.addListener(handleEmailTextField);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    idController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    nameController.dispose();
    phoneController.dispose();
    birthDateController.dispose();
    emailController.textEditingController.removeListener(handleEmailTextField);
    emailController.dispose();
    authCodeController.dispose();
    addressController.dispose();
    detailAddressController.dispose();
    super.onClose();
  }

  void handleEmailTextField() {
    canSendVerificationCode.value =
        (emailController.validationInfo.value.item1 == true);
  }

  void pressedCancelButton(BuildContext context) {
    FocusScope.of(context).unfocus();
    Get.back();
  }

  void pressdVerificationButton() {}

  void pressedSignupButton() {
    logger.i(idController.textEditingController.value);
    logger.i(passwordController.textEditingController.value);
    logger.i(passwordConfirmController.textEditingController.value);
  }

  void pressedBottomSheetCloseButton(BuildContext context) {
    FocusScope.of(context).unfocus();
    Get.back();
  }

  void showBottomSheet(BuildContext context) {
    authCodeController.clear();
    double screenWidth = MediaQuery.of(context).size.width;
    var canVerify = false.obs;
    final inputLength = 6;
    final fieldSize = (screenWidth - 32 - (inputLength - 1) * 10) / 6;
    Get.bottomSheet(
      SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromRGBO(17, 9, 37, 1),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    color: Colors.white,
                    icon: Icon(Icons.close),
                    onPressed: () => pressedBottomSheetCloseButton(context),
                  ),
                ),
                Text(
                  '인증번호 입력',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: "Pretendart",
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 32),
                PinCodeTextField(
                  appContext: context,
                  autoDisposeControllers: false,
                  autoFocus: false,
                  autoDismissKeyboard: true,
                  autoUnfocus: true,
                  enableActiveFill: true,
                  length: 6,
                  obscureText: false,
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    activeColor: Colors.transparent,
                    inactiveColor: Colors.transparent,
                    selectedColor: Colors.blueAccent,
                    inactiveFillColor: Colors.white10,
                    selectedFillColor: Colors.white10,
                    borderWidth: 0,
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(4),
                    fieldHeight: fieldSize,
                    fieldWidth: fieldSize,
                    activeFillColor: Color.fromRGBO(113, 74, 198, 1),
                  ),
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontFamily: "Pretendart", // 입력된 텍스트의 색상
                    fontSize: 20, // 텍스트의 크기
                    fontWeight: FontWeight.bold, // 텍스트의 굵기
                  ),
                  animationDuration: Duration(milliseconds: 300),
                  // backgroundColor: Colors.white10,
                  cursorColor: Colors.white,
                  // enableActiveFill: true,
                  controller: authCodeController,
                  onChanged: (value) {
                    canVerify.value = (value.length == inputLength);
                  },
                  beforeTextPaste: (text) {
                    // 여기서 붙여넣기 행동을 검사하고, 허용 여부를 결정합니다.
                    return true;
                  },
                ),
                SizedBox(height: 16),
                Obx(
                  () => Container(
                    width: screenWidth,
                    height: 56,
                    child: ElevatedButton(
                      onPressed:
                          canVerify.value ? pressdVerificationButton : null,
                      child: Text('인증',
                          style: TextStyle(
                              fontFamily: "Pretendart",
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueAccent,
                        disabledForegroundColor: Colors.white24,
                        disabledBackgroundColor: Colors.white30,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4), //
                          // 테두리 둥근 모서리 설정
                        ), // Text color
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

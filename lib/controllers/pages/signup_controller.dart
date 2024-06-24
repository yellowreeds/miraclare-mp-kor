import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/constants.dart';
import 'package:goodeeps2/controllers/base_controller.dart';
import 'package:goodeeps2/controllers/widgets/validity_textfield_controller.dart';
import 'package:goodeeps2/routes.dart';
import 'package:goodeeps2/services/auth_service.dart';
import 'package:goodeeps2/utils/enums.dart';
import 'package:goodeeps2/widgets/alerts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

enum Gender {
  male,
  female;

  String get value {
    switch (this) {
      case Gender.male:
        return "male";
      case Gender.female:
        return "female";
    }
  }

  String get label {
    switch (this) {
      case Gender.male:
        return "남자";
      case Gender.female:
        return "여자";
    }
  }
}

class SignupController extends BaseController {
  late final idController =
      Get.find<ValidityTextFieldController>(tag: TextFieldType.id.tag);
  late final passwordController =
      Get.find<ValidityTextFieldController>(tag: TextFieldType.password.tag);
  late final passwordConfirmController = Get.find<ValidityTextFieldController>(
      tag: TextFieldType.passwordConfirm.tag);
  late final nameController =
      Get.find<ValidityTextFieldController>(tag: TextFieldType.name.tag);
  late final phoneController =
      Get.find<ValidityTextFieldController>(tag: TextFieldType.phone.tag);
  late final birthDateController =
      Get.find<ValidityTextFieldController>(tag: TextFieldType.birthDate.tag);
  late final emailController =
      Get.find<ValidityTextFieldController>(tag: TextFieldType.email.tag);

  late final addressController =
      Get.find<ValidityTextFieldController>(tag: TextFieldType.address.tag);
  late final detailAddressController = Get.find<ValidityTextFieldController>(
      tag: TextFieldType.detailAddress.tag);
  late final authCodeController = Get.find<TextEditingController>(
      tag: ''
          'authCode');

  final AuthService authService = AuthService();
  var verificationCode = "";
  var canSendVerificationCode = false.obs;
  var canPressVerificationButton = false.obs;
  var isConfirmEmail = false.obs;
  var showErrorMessage = false.obs;

  var gender = Gender.male.obs;

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    ever(isLoading, handleIsLoading);
    emailController.textEditingController.addListener(handleEmailTextField);
    authCodeController..addListener(handleAuthCodeTextField);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void dispose() {
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
    authCodeController.removeListener(handleAuthCodeTextField);
    authCodeController.dispose();
    super.dispose();
  }

  void handleIsLoading(bool isLoading) {
    if (isLoading) {
      GoodeepsDialog.showIndicator();
    } else {
      GoodeepsDialog.hideIndicator(closeOverlays: false);
    }
  }

  void setGender(Gender? value) {
    gender.value = value!;
  }

  void handleEmailTextField() {
    canSendVerificationCode.value =
        (emailController.validationInfo.value.item1 == true);
  }

  void handleAuthCodeTextField() {
    showErrorMessage.value = false;
  }

  void pressedCancelButton(BuildContext context) {
    FocusScope.of(context).unfocus();
    Get.back();
  }

  Future<void> pressedVerificationButton(BuildContext context) async {
    isLoading.value = true;
    logger.i(emailController.textEditingController.value.text);
    final response = await authService
        .verificationCode(emailController.textEditingController.value.text);
    if (response != null) {
      isLoading.value = false;
      showBottomSheet(context);
      this.verificationCode = response.verificationCode;
    } else {
      isLoading.value = false;
    }
  }

  void pressedConfirmVerificationButton() {
    showErrorMessage.value =
        !(this.verificationCode == authCodeController.value.text);

    if (this.verificationCode == authCodeController.value.text) {
      Get.back();
      isConfirmEmail.value = true;
    }
  }

  Future<void> pressedSignupButton() async {
    isLoading.value = true;
    final email = emailController.textEditingController.value.text;
    final password = passwordController.textEditingController.value.text;
    final name = nameController.textEditingController.value.text;
    final phone = phoneController.textEditingController.value.text;
    final birthDate = birthDateController.textEditingController.value.text;
    final gender = this.gender.value.value;
    final address = addressController.textEditingController.value.text;
    final detailAddress =
        detailAddressController.textEditingController.value.text;

    final item = await authService.signup(email, password, name, phone, 
        birthDate, gender,
        address, detailAddress);
    isLoading.value = false;
    if (item != null) {
      Get.offAllNamed(PageRouter.home.rawValue);
    }
  }

  void pressedBottomSheetCloseButton(BuildContext context) {
    FocusScope.of(context).unfocus();
    Get.back();
  }

  void showBottomSheet(BuildContext context) {
    authCodeController.clear();
    double screenWidth = MediaQuery.of(context).size.width;
    final inputLength = 6;
    final fieldSize = (screenWidth - 32 - (inputLength - 1) * 10) / 6;
    Get.bottomSheet(
      isScrollControlled: true,
      Container(
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
              SizedBox(height: 10),
              Obx(() => Opacity(
                    opacity: showErrorMessage.value ? 1.0 : 0.0,
                    child: Text(
                      '인증번호가 일치하지 않습니다',
                      style: TextStyle(
                          color: Colors.red,
                          fontFamily: "Pretendart",
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                  )),
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
                  canPressVerificationButton.value =
                      (value.length == inputLength);
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
                    onPressed: canPressVerificationButton.value
                        ? pressedConfirmVerificationButton
                        : null,
                    child: Text("인증",
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/controllers/pages/signup_controller.dart';
import 'package:goodeeps2/widgets/custom_app_bar.dart';
import 'package:goodeeps2/widgets/gradient_background.dart';
import 'package:goodeeps2/widgets/validity_textfield.dart';
import 'package:goodeeps2/utils/enums.dart';

class SignupPage extends GetView<SignupController> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        appBar: CustomAppBar(title: "회원가입"),
        body: ImageBackground(
          child: Container(
            child: SingleChildScrollView(
              child: Container(
                height: screenHeight + keyboardHeight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ValidityTextField(
                        type: TextFieldType.id,
                        controller: controller.idController),
                    SizedBox(height: 8),
                    ValidityTextField(
                        type: TextFieldType.password,
                        controller: controller.passwordController),
                    SizedBox(height: 8),
                    ValidityTextField(
                        type: TextFieldType.passwordConfirm,
                        controller: controller.passwordConfirmController),
                    SizedBox(height: 8),
                    ValidityTextField(
                        type: TextFieldType.name,
                        controller: controller.nameController),
                    SizedBox(height: 8),
                    ValidityTextField(
                        type: TextFieldType.phone,
                        controller: controller.phoneController),
                    SizedBox(height: 8),
                    ValidityTextField(
                        type: TextFieldType.birthDate,
                        readOnly: true,
                        controller: controller.birthDateController),
                    SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: ValidityTextField(
                              type: TextFieldType.email,
                              controller: controller.emailController),
                        ),
                        SizedBox(width: 16),
                        Container(
                          child: Obx(
                            () => ElevatedButton(
                              onPressed: controller
                                      .canSendVerificationCode.value
                                  ? () => controller.showBottomSheet(context)
                                  : null,
                              child: Text('인증번호 받기'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.blueAccent,
                                disabledForegroundColor: Colors.white24,
                                disabledBackgroundColor: Colors.white30,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ), // Text color
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    ValidityTextField(
                        type: TextFieldType.address,
                        readOnly: true,
                        controller: controller.addressController),
                    SizedBox(height: 8),
                    ValidityTextField(
                        type: TextFieldType.detailAddress,
                        controller: controller.detailAddressController),
                    SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () =>
                                  controller.pressedCancelButton(context),
                              child: Text('취소'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.white54,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4), //
                                  // 테두리 둥근 모서리 설정
                                ), // Text color
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: controller.pressedSignupButton,
                              child: Text('회원가입'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor:
                                    Color.fromRGBO(113, 74, 198, 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4), //
                                  // 테두리 둥근 모서리 설정
                                ), // Text color
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}

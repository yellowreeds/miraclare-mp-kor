import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/controllers/pages/signup_controller.dart';
import 'package:goodeeps2/utils/color_style.dart';
import 'package:goodeeps2/widgets/custom_app_bar.dart';
import 'package:goodeeps2/widgets/backgrounds.dart';
import 'package:goodeeps2/widgets/validity_textfield.dart';
import 'package:goodeeps2/utils/enums.dart';

class SignupPage extends GetView<SignupController> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    double spacing = 16.0;

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
                    SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                            child: Obx(
                          () => ValidityTextField(
                              readOnly: controller.isConfirmEmail.value,
                              type: TextFieldType.email,
                              controller: controller.emailController),
                        )),
                        SizedBox(width: 8),
                        Obx(
                          () => SizedBox(
                            height: 58,
                            child: ElevatedButton(
                              onPressed:
                                  (controller.canSendVerificationCode.value &&
                                          !controller.isConfirmEmail.value)
                                      ? () async => await controller
                                          .pressedVerificationButton(context)
                                      : null,
                              child: Text((controller.isConfirmEmail.value)
                                  ? "인증 완료"
                                  : "인증번호 받기"),
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
                    // ValidityTextField(
                    //     type: TextFieldType.id,
                    //     controller: controller.idController),
                    SizedBox(height: spacing),
                    ValidityTextField(
                        type: TextFieldType.password,
                        controller: controller.passwordController),
                    SizedBox(height: spacing),
                    ValidityTextField(
                        type: TextFieldType.passwordConfirm,
                        controller: controller.passwordConfirmController),
                    SizedBox(height: spacing),
                    ValidityTextField(
                        type: TextFieldType.name,
                        controller: controller.nameController),
                    SizedBox(height: spacing),
                    ValidityTextField(
                        type: TextFieldType.phone,
                        controller: controller.phoneController),
                    SizedBox(height: spacing),
                    ValidityTextField(
                        type: TextFieldType.birthDate,
                        readOnly: true,
                        controller: controller.birthDateController),
                    SizedBox(height: spacing),
                    Container(
                        height: 48,
                        child: Obx(
                          () => Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () =>
                                      controller.setGender(Gender.male),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor:
                                        controller.gender.value == Gender.male
                                            ? Color.fromRGBO(113, 74, 198, 1)
                                            : ColorStyle.Gray400,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4), //
                                      // 테두리 둥근 모서리 설정
                                    ), // Text color
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.male, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text(Gender.male.label),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () =>
                                      controller.setGender(Gender.female),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor:
                                        controller.gender.value == Gender.female
                                            ? Color.fromRGBO(113, 74, 198, 1)
                                            : ColorStyle.Gray400,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4), //
                                      // 테두리 둥근 모서리 설정
                                    ), // Text color
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.female, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text(Gender.female.label),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.start,
                    //   children: [
                    //     Obx(() => Row(children: [
                    //           Radio<Gender>(
                    //             value: Gender.male,
                    //             groupValue: controller.gender.value,
                    //             focusColor: controller.gender == Gender.male
                    //                 ? Colors.white
                    //                 : Colors.grey,
                    //             activeColor: controller.gender == Gender.male
                    //                 ? Colors.white
                    //                 : Colors.grey,
                    //             onChanged: (gender) =>
                    //                 controller.setGender(gender),
                    //           ),
                    //           Text(
                    //             '남자',
                    //             style: TextStyle(
                    //               fontFamily: 'Pretendart',
                    //               fontSize: 14,
                    //               color: controller.gender == Gender.male
                    //                   ? Colors.white
                    //                   : Colors.grey,
                    //             ),
                    //           )
                    //         ])),
                    //     SizedBox(width: 20),
                    //     Obx(() => Row(children: [
                    //           Radio<Gender>(
                    //             value: Gender.female,
                    //             groupValue: controller.gender.value,
                    //             focusColor: controller.gender == Gender.female
                    //                 ? Colors.white
                    //                 : Colors.grey,
                    //             activeColor: controller.gender == Gender.female
                    //                 ? Colors.white
                    //                 : Colors.grey,
                    //             onChanged: (gender) =>
                    //                 controller.setGender(gender),
                    //           ),
                    //           Text(
                    //             '여자',
                    //             style: TextStyle(
                    //               fontFamily: 'Pretendart',
                    //               fontSize: 14,
                    //               color: controller.gender == Gender.female
                    //                   ? Colors.white
                    //                   : Colors.grey,
                    //             ),
                    //           )
                    //         ])),
                    //   ],
                    // ),
                    SizedBox(height: spacing),
                    ValidityTextField(
                        type: TextFieldType.address,
                        readOnly: true,
                        controller: controller.addressController),
                    SizedBox(height: spacing),
                    ValidityTextField(
                        type: TextFieldType.detailAddress,
                        controller: controller.detailAddressController),
                    SizedBox(height: 32),
                    Row(
                      children: [
                        // Expanded(
                        //   child: Container(
                        //     height: 48,
                        //     child: ElevatedButton(
                        //       onPressed: () =>
                        //           controller.pressedCancelButton(context),
                        //       child: Text('취소'),
                        //       style: ElevatedButton.styleFrom(
                        //         foregroundColor: Colors.white,
                        //         backgroundColor: Colors.white54,
                        //         shape: RoundedRectangleBorder(
                        //           borderRadius: BorderRadius.circular(4), //
                        //           // 테두리 둥근 모서리 설정
                        //         ), // Text color
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: controller.pressedSignupButton,
                              child: Text('회원가입',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: "Pretendart",
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700)),
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

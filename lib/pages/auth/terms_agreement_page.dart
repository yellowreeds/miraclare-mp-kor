import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/controllers/pages/terms_agreement_controller.dart';
import 'package:goodeeps2/pages/auth/member_registration_page.dart';
import 'package:goodeeps2/controllers/widgets/agreement_form_controller.dart';
import 'package:goodeeps2/routes.dart';
import 'package:goodeeps2/widgets/agreement_form.dart';
import 'package:goodeeps2/constants.dart';

import '../../widgets/custom_app_bar.dart';

class TermsAgreementPage extends GetView<TermsAgreementController> {
  // late final AgreementFormController form1Controller =
  //     Get.find<AgreementFormController>(tag: 'form1');
  // late final AgreementFormController form2Controller =
  //     Get.find<AgreementFormController>(tag: 'form2');

  TermsAgreementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    // var areBothAgreed = false.obs;
    //
    // // 버튼 상태를 업데이트하는 함수입니다.
    // void updateButtonState() {
    //   areBothAgreed.value =
    //       form1Controller.isAgreed.isTrue && form2Controller.isAgreed.isTrue;
    // }
    //
    // ever(form1Controller.isAgreed, (_) => updateButtonState());
    // ever(form2Controller.isAgreed, (_) => updateButtonState());

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(title: "회원가입 이용약관"),
      body: SingleChildScrollView(
        child: Container(
            height: screenHeight,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg2.png'),
                fit: BoxFit.cover,
              ),
              color: Color.fromRGBO(255, 255, 255, 0.1),
            ),
            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Column(
              children: [
                SizedBox(
                  height: 56 + 48,
                ),
                AgreementForm(
                  tag: "form1",
                  controller: controller,
                  title: '개인정보 이용약관 안내',
                  content: termsAndConditions,
                ),
                SizedBox(
                  height: 48,
                ),
                AgreementForm(
                  tag: "form2",
                  controller: controller,
                  title: '데이터 수집 이용 안내',
                  content: termsAndConditions,
                ),
                SizedBox(
                  height: 60,
                ),
                SizedBox(
                  width: double.infinity, // 원하는 너비
                  height: 54, // 원하는 높이
                  child: Obx(() => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          backgroundColor: Color.fromRGBO(113, 74, 198, 1),
                          disabledBackgroundColor:
                              Colors.grey.withOpacity(0.12),
                        ),
                        onPressed: controller.areBothAgreed.value
                            ? () {
                                Get.toNamed(PageRouter.signup.rawValue);
                              }
                            : null,
                        child: Text(
                          '다음',
                          style: TextStyle(
                            color: controller.areBothAgreed.value
                                ? Colors.white
                                : Colors.grey.withOpacity(0.38),
                            fontFamily: 'Pretendart',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      )),
                )
              ],
            )),
      ), // body: ,
    );
  }
}

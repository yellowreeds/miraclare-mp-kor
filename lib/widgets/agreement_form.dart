import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/controllers/pages/terms_agreement_controller.dart';
import 'package:goodeeps2/controllers/widgets/agreement_form_controller.dart';

class AgreementForm extends StatelessWidget {
  final TermsAgreementController controller;
  final String tag;
  final String title;
  final String content;

  AgreementForm({
    Key? key,
    required this.tag,
    required this.controller,
    required this.title,
    required this.content,
  }) : super(key: key);

  bool isAgreed() {
    if (tag == "form1") {
      return controller.isAgreedForm1.value;
    } else {
      return controller.isAgreedForm2.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          child: Text(
            this.title,
            style: TextStyle(
                fontFamily: 'Pretendart',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
        ),
        SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 160,
          alignment: Alignment.center,
          color: Colors.white,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(8),
            child: Text(
              this.content,
              style: TextStyle(
                  fontFamily: 'Pretendart', fontSize: 12, color: Colors.black),
              textAlign: TextAlign.justify,
            ),
          ),
        ),
        Row(
          children: [
            Obx(() => Radio<bool>(
                  value: true,
                  groupValue: isAgreed(),
                  focusColor: isAgreed() ? Colors.white : Colors.grey,
                  activeColor: isAgreed() ? Colors.white : Colors.grey,
                  onChanged: (value) =>
                      controller.setAgreement(tag, value ?? false),
                )),
            Obx(() => Text(
                  '동의',
                  style: TextStyle(
                    fontFamily: 'Pretendart',
                    fontSize: 14,
                    color: isAgreed() ? Colors.white : Colors.grey,
                  ),
                )),
            SizedBox(width: 20),
            Obx(() => Radio<bool>(
                  value: false,
                  groupValue: isAgreed(),
                  focusColor: isAgreed() ? Colors.grey : Colors.white,
                  activeColor: isAgreed() ? Colors.grey : Colors.white,
                  onChanged: (value) =>
                      controller.setAgreement(tag, value ?? false),
                )),
            Obx(() => Text(
                  '동의하지 않음',
                  style: TextStyle(
                    fontFamily: 'Pretendart',
                    fontSize: 14,
                    color: isAgreed() ? Colors.grey : Colors.white,
                  ),
                )),
          ],
        ),
      ],
    );
  }
}

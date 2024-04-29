import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/controllers/widgets/agreement_form_controller.dart'; // 앞서 만든

class AgreementForm extends StatelessWidget {
  final AgreementFormController controller;
  final String title;
  final String content;

  AgreementForm({
    Key? key,
    required this.controller,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
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
                  groupValue: controller.isAgreed.value,
                  focusColor:
                      controller.isAgreed.value ? Colors.white : Colors.grey,
                  activeColor:
                      controller.isAgreed.value ? Colors.white : Colors.grey,
                  onChanged: (value) => controller.setAgreement(value ?? false),
                )),
            Obx(() => Text(
              '동의',
              style: TextStyle(
                fontFamily: 'Pretendart',
                fontSize: 14,
                color: controller.isAgreed.value ? Colors.white : Colors.grey,
              ),
            )),
            SizedBox(width: 20),
            Obx(() => Radio<bool>(
                  value: false,
                  groupValue: controller.isAgreed.value,
                  focusColor:
                      controller.isAgreed.value ? Colors.grey : Colors.white,
                  activeColor:
                      controller.isAgreed.value ? Colors.grey : Colors.white ,
                  onChanged: (value) => controller.setAgreement(value ?? false)
              ,
                )),
            Obx(() => Text(
              '동의하지 않음',
              style: TextStyle(
                fontFamily: 'Pretendart',
                fontSize: 14,
                color: controller.isAgreed.value ? Colors.grey : Colors.white,
              ),
            )),
          ],
        ),
      ],
    );
  }
}

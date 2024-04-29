import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/controllers/pages/signup_controller.dart';
import 'package:goodeeps2/utils/enums.dart';

import '../controllers/widgets/validity_textfield_controller.dart';

class ValidityTextField extends StatelessWidget {
  final TextFieldType type;
  final bool readOnly;

  late final ValidityTextFieldController controller;

  //
  ValidityTextField(
      {Key? key,
      required this.controller,
      required this.type,
      this.readOnly = false})
      : super(key: key);

  Color borderColor(bool? isValid) {
    return isValid == true ? Colors.green : Colors.white;
  }

  Color iconColor(bool? isValid) {
    if (this.type == TextFieldType.birthDate) {
      return Colors.white;
    } else {
      return isValid == true ? Colors.green : Colors.white54;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: screenWidth,
          child: Obx(
            () => TextField(
              readOnly: readOnly,
              controller: controller.textEditingController,
              obscureText: (type == TextFieldType.password) ||
                  (type == TextFieldType.passwordConfirm),
              keyboardType: type.inputType,
              decoration: InputDecoration(
                suffixIconColor:
                    iconColor(controller.validationInfo.value.item1),
                suffixIcon: (type == TextFieldType.detailAddress) ||
                        (type == TextFieldType.email)
                    ? null
                    : IconButton(
                        icon: type.icon,
                        onPressed: () => controller.pressedIcon(context),
                      ),
                labelText: type.label,
                labelStyle: TextStyle(
                  fontFamily: 'Pretendart',
                  color: Colors.white54,
                  fontSize: 14,
                ),
                hintText: type.placeholder,
                hintStyle: TextStyle(
                  fontFamily: 'Pretendart',
                  color: Color.fromRGBO(133, 135, 140, 0.5),
                  fontSize: 14,
                ),
                helperText: controller.validationInfo.value.item2,
                helperStyle: TextStyle(
                  fontFamily: 'Pretendart',
                  color: Colors.red,
                  fontSize: 12,
                ),
                counterStyle: TextStyle(color: Colors.transparent),
                disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color:
                          borderColor(controller.validationInfo.value.item1)),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color:
                          borderColor(controller.validationInfo.value.item1)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color:
                          borderColor(controller.validationInfo.value.item1)),
                ),
              ),
              style: TextStyle(
                  fontFamily: 'Pretendart', color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}

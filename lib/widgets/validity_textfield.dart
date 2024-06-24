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

  Color labelColor(bool hasFocus) {
    return hasFocus ? Colors.white : Colors.grey;
  }

  int? maxLength() {
    switch (type) {
      case TextFieldType.name:
        return 20;
      case TextFieldType.password:
        return 16;
      case TextFieldType.passwordConfirm:
        return 16;
      default:
        return null;
    }
  }

  int? minLength() {
    switch (type) {
      case TextFieldType.name:
        return 2;
      case TextFieldType.password:
        return 10;
      case TextFieldType.passwordConfirm:
        return 10;
      default:
        return null;
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
              focusNode: controller.focusNode,
              controller: controller.textEditingController,
              obscureText: (type == TextFieldType.password) ||
                  (type == TextFieldType.passwordConfirm),
              keyboardType: type.inputType,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
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
                // labelStyle: TextStyle(
                //   fontFamily: 'Pretendart',
                //   color: Colors.white,
                //   fontSize: 14,
                // ),
                labelStyle: TextStyle(
                  fontFamily: 'Pretendart',
                  fontSize: 14,
                  color: labelColor(controller.hasFocus.value),
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
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color:
                          borderColor(controller.validationInfo.value.item1)),
                ),
                // enabledBorder: OutlineInputBorder(
                //   borderSide: BorderSide(
                //       color:
                //           borderColor(controller.validationInfo.value.item1)),
                // ),
                focusedBorder: OutlineInputBorder(
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

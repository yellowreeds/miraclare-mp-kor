import 'package:get/get.dart';
import 'package:goodeeps2/controllers/base_controller.dart';
import 'package:flutter/material.dart';
import 'package:goodeeps2/utils/enums.dart';
import 'package:kpostal/kpostal.dart';
import 'package:tuple/tuple.dart';

class ValidityTextFieldController extends BaseController {
  late final TextEditingController textEditingController =
      TextEditingController();
  final TextFieldType type;
  var hasFocus = false.obs;
  final focusNode = FocusNode();

  ValidityTextFieldController(this.type);

  // var isValid = Rx<bool?>(null);
  // var message = Rx<String?>(null);
  var validationInfo = Rx<Tuple2<bool?, String?>>(Tuple2(null, null));
  var birthDate = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    focusNode.addListener(() {
      hasFocus.value = focusNode.hasFocus;
    });
    textEditingController.addListener(handleTextChange);
  }

  @override
  void dispose() {
    focusNode.dispose();
    textEditingController.removeListener(handleTextChange);
    textEditingController.dispose();
    super.dispose();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void handleTextChange() {
    setIsValid(textEditingController.text);
  }

  void setIsValid(String text) {
    if (text.isEmpty) {
      validationInfo.value = Tuple2(null, null);
      return;
    }
    switch (type) {
      case TextFieldType.id:
        final isValid = isValidId(text);
        validationInfo.value = Tuple2(
            isValid,
            isValid
                ? null
                : "영어 혹은 영어/숫자 "
                    "조합이어야합니다.");
        break;
      case TextFieldType.password:
        final isValid = isValidPassword(text);
        ;
        validationInfo.value = Tuple2(
            isValid,
            isValid
                ? null
                : "비밀번호 생성 규칙에 "
                    "맞게 다시 입력해주세요.");
        break;
      case TextFieldType.passwordConfirm:
        final isValid = isValidPassword(text);
        ;
        validationInfo.value = Tuple2(
            isValid,
            isValid
                ? null
                : "비밀번호 생성 규칙에 "
                    "맞게 다시 입력해주세요.");
        break;
      case TextFieldType.name:
        final isValid = isValidName(text);
        ;
        validationInfo.value = Tuple2(
            isValid,
            isValid
                ? null
                : "이름 생성 규칙에 "
                    "맞게 다시 입력해주세요.");
        break;
      case TextFieldType.phone:
        final isValid = isValidPhone(text);
        validationInfo.value = Tuple2(
            isValid,
            isValid
                ? null
                : "휴대폰 번호 생성 "
                    "규칙에 맞게 다시 입력해주세요.");
        break;
      case TextFieldType.email:
        final isValid = isValidEmail(text);
        validationInfo.value = Tuple2(isValid, null);
        break;

      default:
        break;
    }
  }

  bool isValidId(String id) {
    RegExp regex = RegExp(r'^(?=.*[A-Za-z])[A-Za-z0-9]*[A-Za-z][A-Za-z0-9]*$');
    return regex.hasMatch(id);
  }

  bool isValidPassword(String password) {
    RegExp regex = RegExp(
        r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#$%^&*()_+{}:<>?])[A-Za-z\d!@#$%^&*()_+{}:<>?]{10,16}$');
    return regex.hasMatch(password);
  }

  bool isValidEmail(String email) {
    RegExp regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  bool isValidName(String name) {
    return (name.length > 2);
  }

  bool isValidPhone(String phoneNumber) {
    RegExp regex = RegExp(r'^\d{10,11}$');
    return regex.hasMatch(phoneNumber);
  }

  void pressedIcon(BuildContext? context) {
    switch (type) {
      case TextFieldType.birthDate:
        showCalender(context!);
        break;
      case TextFieldType.address:
        goToKpostalView();
        break;
      default:
        break;
    }
  }

  void goToKpostalView() async {
    await Get.to(
      () => KpostalView(
        callback: (Kpostal result) {
          textEditingController.text = result.address;
        },
      ),
    );
  }

  void showCalender(BuildContext context) {
    final initialDate = DateTime.now();
    final firstDate = DateTime(initialDate.year - 100);
    final lastDate = DateTime(initialDate.year + 1);

    showDatePicker(
        context: context,
        initialDate: birthDate.value ?? initialDate,
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        firstDate: firstDate,
        lastDate: lastDate,
        locale: Locale("ko", "KR"),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.dark(),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            child: child!,
          );
        }).then((selectedDate) {
      if (selectedDate != null) {
        final dateString =
            "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
        textEditingController.text = dateString;
      }
    });
  }
}

import 'package:flutter/material.dart';

enum TextFieldType {
  id,
  password,
  passwordConfirm,
  name,
  phone,
  birthDate,
  email,
  address,
  detailAddress;

  String get tag {
    switch (this) {
      case TextFieldType.id:
        return "id";
      case TextFieldType.password:
        return "password";
      case TextFieldType.passwordConfirm:
        return 'passwordConfirm';
      case TextFieldType.name:
        return 'name';
      case TextFieldType.phone:
        return 'phone';
      case TextFieldType.birthDate:
        return "birthDate";
      case TextFieldType.email:
        return 'email';
      case TextFieldType.address:
        return "address";
      case TextFieldType.detailAddress:
        return "detailAddress";
    }
  }

  String get label {
    switch (this) {
      case TextFieldType.id:
        return '아이디';
      case TextFieldType.password:
        return '비밀번호';
      case TextFieldType.passwordConfirm:
        return '비밀번호 확인';
      case TextFieldType.name:
        return '이름';
      case TextFieldType.phone:
        return '휴대폰 번호';
      case TextFieldType.birthDate:
        return "생년월일";
      case TextFieldType.email:
        return '이메일';
      case TextFieldType.address:
        return '주소';
      case TextFieldType.detailAddress:
        return '상세 주소';
    }
  }

  String get placeholder {
    switch (this) {
      case TextFieldType.id:
        return '아직 정해지지 않음';
      case TextFieldType.password:
        return '10~16자, 영문 + 숫자/특수문자';
      case TextFieldType.passwordConfirm:
        return '10~16자, 영문 + 숫자/특수문자';
      case TextFieldType.name:
        return '홍길동';
      case TextFieldType.phone:
        return '01012345678';
      case TextFieldType.birthDate:
        return "생년월일";
      case TextFieldType.email:
        return 'contact@miraclare.com';
      case TextFieldType.address:
        return '주소';
      case TextFieldType.detailAddress:
        return '상세주소';
    }
  }

  Icon get icon {
    switch (this) {
      case TextFieldType.id:
        return Icon(Icons.check);
      case TextFieldType.password:
        return Icon(Icons.check);
      case TextFieldType.passwordConfirm:
        return Icon(Icons.check);
      case TextFieldType.name:
        return Icon(Icons.check);
      case TextFieldType.phone:
        return Icon(Icons.check);
      case TextFieldType.birthDate:
        return Icon(Icons.calendar_today);
      case TextFieldType.email:
        return Icon(Icons.check);
      case TextFieldType.address:
        return Icon(Icons.search);
      default:
        return Icon(Icons.check);
    }
  }

  TextInputType get inputType {
    switch (this) {
      case TextFieldType.id:
        return TextInputType.text;
      case TextFieldType.password:
        return TextInputType.text;
      case TextFieldType.passwordConfirm:
        return TextInputType.text;
      case TextFieldType.name:
        return TextInputType.name;
      case TextFieldType.phone:
        return TextInputType.phone;
      case TextFieldType.email:
        return TextInputType.emailAddress;
      case TextFieldType.address:
        return TextInputType.text;
      case TextFieldType.detailAddress:
        return TextInputType.text;
      default:
        return TextInputType.text;
    }
  }
}

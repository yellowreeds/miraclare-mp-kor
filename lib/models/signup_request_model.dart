import 'package:json_annotation/json_annotation.dart';

class SignupRequestModel {
  final String email;
  final String password;
  final String name;
  final String phone;
  final String birthDate;
  final String gender;
  final String address;
  final String detailAddress;

  SignupRequestModel({
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
    required this.birthDate,
    required this.gender,
    required this.address,
    required this.detailAddress,
  });
}

import 'package:json_annotation/json_annotation.dart';

part 'signup_model.g.dart';

@JsonSerializable()
class SignupModel {
  final String email;
  final String password;
  final String name;
  final String phone;
  @JsonKey(name: 'birth_date')
  final DateTime birthDate;
  final String gender;
  final String address;
  @JsonKey(name: 'detail_address')
  final String detailAddress;

  SignupModel({
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
    required this.birthDate,
    required this.gender,
    required this.address,
    required this.detailAddress,
  });

  factory SignupModel.fromJson(Map<String, dynamic> json) => _$SignupModelFromJson(json);
  Map<String, dynamic> toJson() => _$SignupModelToJson(this);
}

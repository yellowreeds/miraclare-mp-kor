import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  final String name;
  final String phone;
  @JsonKey(name: 'birth_date')
  final String birthDate;
  final String gender;
  final String address;
  @JsonKey(name: 'detail_address')
  final String detailAddress;

  // 생성자
  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.birthDate,
    required this.gender,
    required this.address,
    required this.detailAddress,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

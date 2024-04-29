import 'package:json_annotation/json_annotation.dart';

part 'verification_code_model.g.dart';

@JsonSerializable()
class VerificationCodeModel {
  @JsonKey(name: 'verification_code')
  final String verificationCode;

  // 생성자
  VerificationCodeModel({
    required this.verificationCode,
  });

  factory VerificationCodeModel.fromJson(Map<String, dynamic> json) =>
      _$VerificationCodeModelFromJson(json);

  Map<String, dynamic> toJson() => _$VerificationCodeModelToJson(this);
}

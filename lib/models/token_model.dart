import 'package:json_annotation/json_annotation.dart';

part 'token_model.g.dart';

@JsonSerializable()
class TokenModel {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'refresh_token')
  final String refreshToken;
  // 생성자
  TokenModel({
    required this.accessToken,
    required this.refreshToken,
  });

  // JSON으로부터 User 객체를 생성하는 팩토리 생성자
  factory TokenModel.fromJson(Map<String, dynamic> json) => _$TokenModelFromJson(json);

  // User 객체를 JSON으로 변환하는 메서드
  Map<String, dynamic> toJson() => _$TokenModelToJson(this);
}

import 'dart:convert';
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

  String extractSubFromJWT() {
    try {
      // JWT는 점(.)으로 구분된 세 부분으로 구성되어 있습니다.
      final parts = accessToken.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid JWT');
      }

      // 두 번째 부분(payload)을 디코딩합니다.
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));

      // JSON 객체로 변환합니다.
      final payloadMap = json.decode(decoded);
      if (payloadMap is! Map<String, dynamic>) {
        throw Exception('Invalid payload');
      }

      // 'sub' 값을 추출합니다.
      final sub = payloadMap['sub'];
      if (sub == null) {
        throw Exception('sub not found in payload');
      }

      return sub;
    } catch (e) {
      throw Exception('Error decoding JWT: $e');
    }
  }

  // JSON으로부터 User 객체를 생성하는 팩토리 생성자
  factory TokenModel.fromJson(Map<String, dynamic> json) => _$TokenModelFromJson(json);

  // User 객체를 JSON으로 변환하는 메서드
  Map<String, dynamic> toJson() => _$TokenModelToJson(this);
}

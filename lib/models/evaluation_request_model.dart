import 'package:json_annotation/json_annotation.dart';

part 'evaluation_request_model.g.dart';

@JsonSerializable()
class EvaluationRequestModel {
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'pain_intensity')
  final int painIntensity;
  @JsonKey(name: 'vibration_intensity')
  final int vibrationIntensity;
  @JsonKey(name: 'vibration_frequency')
  final int vibrationFrequency;

  // 생성자
  EvaluationRequestModel({
    required this.userId,
    required this.painIntensity,
    required this.vibrationIntensity,
    required this.vibrationFrequency,
  });

  factory EvaluationRequestModel.fromJson(Map<String, dynamic> json) =>
      _$EvaluationRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$EvaluationRequestModelToJson(this);
}




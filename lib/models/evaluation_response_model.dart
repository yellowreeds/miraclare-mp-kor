import 'package:json_annotation/json_annotation.dart';

part 'evaluation_response_model.g.dart';

@JsonSerializable()
class EvaluationResponseModel {
  final String id;
  final String user_id;
  final int pain_intensity;
  final int vibration_intensity;
  final int vibration_frequency;
  final DateTime created_at;
  final DateTime updated_at;

  // 생성자
  EvaluationResponseModel({
    required this.id,
    required this.user_id,
    required this.pain_intensity,
    required this.vibration_intensity,
    required this.vibration_frequency,
    required this.created_at,
    required this.updated_at,
  });

  factory EvaluationResponseModel.fromJson(Map<String, dynamic> json) =>
      _$EvaluationResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$EvaluationResponseModelToJson(this);
}

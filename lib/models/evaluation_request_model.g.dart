// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evaluation_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EvaluationRequestModel _$EvaluationRequestModelFromJson(
        Map<String, dynamic> json) =>
    EvaluationRequestModel(
      userId: json['user_id'] as String,
      painIntensity: (json['pain_intensity'] as num).toInt(),
      vibrationIntensity: (json['vibration_intensity'] as num).toInt(),
      vibrationFrequency: (json['vibration_frequency'] as num).toInt(),
    );

Map<String, dynamic> _$EvaluationRequestModelToJson(
        EvaluationRequestModel instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'pain_intensity': instance.painIntensity,
      'vibration_intensity': instance.vibrationIntensity,
      'vibration_frequency': instance.vibrationFrequency,
    };

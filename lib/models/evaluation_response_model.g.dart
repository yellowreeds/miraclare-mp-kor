// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evaluation_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EvaluationResponseModel _$EvaluationResponseModelFromJson(
        Map<String, dynamic> json) =>
    EvaluationResponseModel(
      id: json['id'] as String,
      user_id: json['user_id'] as String,
      pain_intensity: (json['pain_intensity'] as num).toInt(),
      vibration_intensity: (json['vibration_intensity'] as num).toInt(),
      vibration_frequency: (json['vibration_frequency'] as num).toInt(),
      created_at: DateTime.parse(json['created_at'] as String),
      updated_at: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$EvaluationResponseModelToJson(
        EvaluationResponseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.user_id,
      'pain_intensity': instance.pain_intensity,
      'vibration_intensity': instance.vibration_intensity,
      'vibration_frequency': instance.vibration_frequency,
      'created_at': instance.created_at.toIso8601String(),
      'updated_at': instance.updated_at.toIso8601String(),
    };

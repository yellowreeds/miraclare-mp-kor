// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_analysis_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SleepAnalysisModel _$SleepAnalysisModelFromJson(Map<String, dynamic> json) =>
    SleepAnalysisModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      bruxismCount: (json['bruxism_count'] as num).toInt(),
      vth: (json['vth'] as num).toInt(),
      emgMax: (json['emg_max'] as num).toInt(),
      emgMean: (json['emg_mean'] as num).toInt(),
      emgMin: (json['emg_min'] as num).toInt(),
      windowSize: (json['window_size'] as num).toInt(),
      vibrationIntensity: (json['vibration_intensity'] as num).toInt(),
      path: json['path'] as String,
    );

Map<String, dynamic> _$SleepAnalysisModelToJson(SleepAnalysisModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'start_time': instance.startTime.toIso8601String(),
      'end_time': instance.endTime.toIso8601String(),
      'bruxism_count': instance.bruxismCount,
      'vth': instance.vth,
      'emg_max': instance.emgMax,
      'emg_mean': instance.emgMean,
      'emg_min': instance.emgMin,
      'window_size': instance.windowSize,
      'vibration_intensity': instance.vibrationIntensity,
      'path': instance.path,
    };

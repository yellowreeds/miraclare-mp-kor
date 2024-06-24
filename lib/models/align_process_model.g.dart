// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'align_process_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlignProcessModel _$AlignProcessModelFromJson(Map<String, dynamic> json) =>
    AlignProcessModel(
      meanRaw: (json['mean_raw'] as num).toDouble(),
      stdRaw: (json['std_raw'] as num).toDouble(),
      meanEmg: (json['mean_emg'] as num).toDouble(),
      max: (json['max'] as num).toDouble(),
      min: (json['min'] as num).toDouble(),
      stdEmg: (json['std_emg'] as num).toDouble(),
      maa: (json['maa'] as num).toDouble(),
    );

Map<String, dynamic> _$AlignProcessModelToJson(AlignProcessModel instance) =>
    <String, dynamic>{
      'mean_raw': instance.meanRaw,
      'std_raw': instance.stdRaw,
      'mean_emg': instance.meanEmg,
      'max': instance.max,
      'min': instance.min,
      'std_emg': instance.stdEmg,
      'maa': instance.maa,
    };

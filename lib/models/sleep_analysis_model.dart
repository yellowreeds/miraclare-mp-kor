import 'package:json_annotation/json_annotation.dart';

part 'sleep_analysis_model.g.dart';

@JsonSerializable()
class SleepAnalysisModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'start_time')
  final DateTime startTime;
  @JsonKey(name: 'end_time')
  final DateTime endTime;
  @JsonKey(name: 'bruxism_count')
  final int bruxismCount;
  final int vth;
  @JsonKey(name: 'emg_max')
  final int emgMax;
  @JsonKey(name: 'emg_mean')
  final int emgMean;
  @JsonKey(name: 'emg_min')
  final int emgMin;
  @JsonKey(name: 'window_size')
  final int windowSize;
  @JsonKey(name: 'vibration_intensity')
  final int vibrationIntensity;
  final String path;

  SleepAnalysisModel({
    required this.id,
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.bruxismCount,
    required this.vth,
    required this.emgMax,
    required this.emgMean,
    required this.emgMin,
    required this.windowSize,
    required this.vibrationIntensity,
    required this.path,
  });

  factory SleepAnalysisModel.fromJson(Map<String, dynamic> json) =>
      _$SleepAnalysisModelFromJson(json);

  Map<String, dynamic> toJson() => _$SleepAnalysisModelToJson(this);
}

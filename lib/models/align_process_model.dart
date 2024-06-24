import 'package:json_annotation/json_annotation.dart';

part 'align_process_model.g.dart';

@JsonSerializable()
class AlignProcessModel {
  @JsonKey(name: 'mean_raw')
  final double meanRaw;
  @JsonKey(name: 'std_raw')
  final double stdRaw;
  @JsonKey(name: 'mean_emg')
  final double meanEmg;
  final double max;
  final double min;
  @JsonKey(name: 'std_emg')
  final double stdEmg;
  final double maa;

  // 생성자
  AlignProcessModel({
    required this.meanRaw,
    required this.stdRaw,
    required this.meanEmg,
    required this.max,
    required this.min,
    required this.stdEmg,
    required this.maa,
  });

  factory AlignProcessModel.fromJson(Map<String, dynamic> json) =>
      _$AlignProcessModelFromJson(json);

  Map<String, dynamic> toJson() => _$AlignProcessModelToJson(this);

  @override
  String toString() {
    return 'AlignProcessModel(mean_raw: $meanRaw, std_raw: $stdRaw, mean_emg:'
        ' $meanEmg, max: $max, min: $min, std_emg: $stdEmg, maa: $maa)';
  }
}

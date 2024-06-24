import 'dart:ffi';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';
import 'package:goodeeps2/utils/color_style.dart';

part 'align_process_state.freezed.dart';

@freezed
class AlignProcessState with _$AlignProcessState {
  const factory AlignProcessState.ready() = _Ready;

  const factory AlignProcessState.measuring(MeasurementType detail) =
      _Measuring;

  const factory AlignProcessState.finish() = _Finish;

  const AlignProcessState._();

  String get buttonTitle {
    return when(
      ready: () => "측정시작",
      measuring: (detail) {
        return "측정중";
      },
      finish: () => "측정완료",
    );
  }

  int get duration {
    return when(
      ready: () => 0,
      measuring: (detail) {
        switch (detail) {
          case MeasurementType.clench:
            return 2;
          case MeasurementType.relax:
            return 3;
        }
      },
      finish: () => 0,
    );
  }

  String get description {
    return when(
      ready: () => "측정을 시작해주세요.",
      measuring: (detail) {
        switch (detail) {
          case MeasurementType.clench:
            return "2초간 이를 악물어주세요.";
          case MeasurementType.relax:
            return "3초간 쉬어주세요.";
        }
      },
      finish: () => "측정이 완료되었습니다.",
    );
  }

  Color get buttonColor {
    return when(
      ready: () => ColorStyle.C_128_59_160,
      measuring: (detail) => ColorStyle.C_242_156_27,
      finish: () => ColorStyle.C_128_59_160,
    );
  }

  Color get progressColor {
    return maybeWhen(
      measuring: (detail) {
        switch (detail) {
          case MeasurementType.clench:
            return ColorStyle.C_93_217_34;
          case MeasurementType.relax:
            return ColorStyle.C_210_18_30;
        }
      },
      orElse: () => Colors.white,
    );
  }
}

enum MeasurementType { clench, relax }

enum AlignProcessResult {
  success,
  fail;

  String get title {
    switch (this) {
      case AlignProcessResult.success:
        return '측정이 완료되었습니다.';
      case AlignProcessResult.fail:
        return '다시 측정해주세요.';
    }
  }

  String get buttonTitle {
    switch (this) {
      case AlignProcessResult.success:
        return '저장';
      case AlignProcessResult.fail:
        return '측정실패';
    }
  }

  Color get buttonColor {
    switch (this) {
      case AlignProcessResult.success:
        return ColorStyle.C_22_191_130;
      case AlignProcessResult.fail:
        return ColorStyle.C_237_70_69;
    }
  }
}

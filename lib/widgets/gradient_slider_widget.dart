import 'package:flutter/material.dart';
import 'package:goodeeps2/constants.dart';
import 'package:goodeeps2/controllers/pages/evaluation_controller.dart';
import 'package:goodeeps2/controllers/widgets/gradient_slider_controller.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:get/get.dart';

class GradientSliderWidget extends StatelessWidget {
  // final EvaluationController controller;
  final GradientSliderController controller;

  const GradientSliderWidget({super.key, required this.controller});

  final trackHeight = 14.0;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        child: SfSliderTheme(
          data: SfSliderThemeData(
              activeLabelStyle: TextStyle(color: Colors.white, fontSize: 14),
              inactiveLabelStyle: TextStyle(color: Colors.white, fontSize: 14),
              activeTrackHeight: trackHeight,
              inactiveTrackHeight: trackHeight,
              labelOffset: Offset(0, 8)),
          child: SfSlider(
            min: 0.0,
            max: 10.0,
            value: controller.sliderValue.value,
            interval: 1,
            showTicks: false,
            showDividers: true,
            showLabels: true,
            enableTooltip: false,
            labelFormatterCallback:
                (dynamic actualValue, String formattedText) {
              return actualValue % 2 == 0 ? actualValue.toInt().toString() : '';
            },
            stepSize: 1,
            onChanged: (dynamic value) {
              if (value is double) {
                controller.updateValue(value);
              }
            },
            thumbIcon: Icon(
              Icons.arrow_drop_down,
              color: Colors.orange,
            ),
            trackShape: TrackShape(),
            dividerShape: DividerShape(),
            thumbShape: ThumbShape(),
          ),
        ),
      );
    });
  }
}

class TrackShape extends SfTrackShape {
  @override
  void paint(PaintingContext context, Offset offset, Offset? startThumbCenter,
      Offset? endThumbCenter, Offset? thumbCenter,
      {required RenderBox parentBox,
      required SfSliderThemeData themeData,
      required Animation<double> enableAnimation,
      required TextDirection textDirection,
      required Paint? inactivePaint,
      required Paint? activePaint,
      dynamic currentValue,
      SfRangeValues? currentValues}) {
    final Rect trackRect = getPreferredRect(
      parentBox,
      themeData,
      offset,
      // startThumbCenter: startThumbCenter,
      // endThumbCenter: endThumbCenter,
    );

    final Paint paint = Paint()
      ..shader = LinearGradient(
        colors: <Color>[
          Colors.green,
          Colors.yellow,
          Colors.orange,
          Colors.red,
        ],
      ).createShader(trackRect);

    context.canvas.drawRRect(
      RRect.fromRectAndRadius(trackRect, Radius.circular(20)),
      paint,
    );
  }
}

class ThumbShape extends SfThumbShape {
  @override
  void paint(PaintingContext context, Offset center,
      {required RenderBox parentBox,
      required RenderBox? child,
      required SfSliderThemeData themeData,
      SfRangeValues? currentValues,
      dynamic currentValue,
      required Paint? paint,
      required Animation<double> enableAnimation,
      required TextDirection textDirection,
      required SfThumb? thumb}) {
    final Path path = Path();

    path.moveTo(center.dx, center.dy - 10);
    path.lineTo(center.dx + 10, center.dy - 25);
    path.lineTo(center.dx - 10, center.dy - 25);
    path.close();
    context.canvas.drawPath(path, Paint()..color = Color(0xFFFFC71B));
  }
}

class DividerShape extends SfDividerShape {
  var dividers = [];

  @override
  void paint(PaintingContext context, Offset center, Offset? thumbCenter,
      Offset? startThumbCenter, Offset? endThumbCenter,
      {required RenderBox parentBox,
      required SfSliderThemeData themeData,
      SfRangeValues? currentValues,
      dynamic currentValue,
      required Paint? paint,
      required Animation<double> enableAnimation,
      required TextDirection textDirection}) {
    final double sliderMin = 0.0;
    final double sliderMax = 10.0;
    final double sliderInterval = 1.0;
    final double totalDividers = (sliderMax - sliderMin) / sliderInterval;

    // 현재 디바이더의 위치를 계산합니다.
    double position = center.dx;
    double startPosition = parentBox.localToGlobal(Offset.zero).dx;
    double endPosition =
        parentBox.localToGlobal(Offset(parentBox.size.width, 0)).dx;

    dividers.add(position);
    // 첫 디바이더 제외
    if (dividers.length == 1) {
      return;
    }
    // 마지막 디바이더 제외
    if (dividers.length == 11) {
      dividers.clear();
      return;
    }
    context.canvas.drawRect(
      Rect.fromCenter(center: center, width: 2, height: 14.0),
      Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.fill
        ..color = Colors.black,
    );
  }
}

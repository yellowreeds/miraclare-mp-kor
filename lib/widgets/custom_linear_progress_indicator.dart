import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomLinearProgressIndicator extends StatelessWidget {
  final RxDouble progress;
  final Color backgroundColor;
  final Color fillColor;
  final double height;
  final BorderRadius borderRadius;

  const CustomLinearProgressIndicator({
    Key? key,
    required this.progress,
    required this.backgroundColor,
    required this.fillColor,
    this.height = 4.0,
    this.borderRadius = BorderRadius.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: LinearProgressIndicator(
            value: progress.value,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(fillColor),
          ),
        ),
      );
    });
  }
}

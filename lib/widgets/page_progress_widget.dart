import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/controllers/pages/evaluation_controller.dart';
import 'package:goodeeps2/utils/color_style.dart';

class PageProgressWidget extends StatelessWidget {
  final EvaluationController controller;

  const PageProgressWidget({super.key, required this.controller});

  final space = 10.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      child: Obx(() {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: controller.currentPageIndex.value >= 0
                      ? ColorStyle.C_255_199_27
                      : ColorStyle.C_89_93_104,
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            SizedBox(width: space),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: controller.currentPageIndex.value >= 1
                      ? ColorStyle.C_255_199_27
                      : ColorStyle.C_89_93_104,
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            SizedBox(width: space),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: controller.currentPageIndex.value >= 2
                      ? ColorStyle.C_255_199_27
                      : ColorStyle.C_89_93_104,
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
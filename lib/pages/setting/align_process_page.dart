import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/controllers/pages/align_process_controller.dart';
import 'package:goodeeps2/utils/color_style.dart';
import 'package:goodeeps2/widgets/align_process_state_widget.dart';
import 'package:goodeeps2/widgets/backgrounds.dart';
import 'package:goodeeps2/widgets/custom_app_bar.dart';

class AlignProcessPage extends GetView<AlignProcessController> {
  const AlignProcessPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(title: "Align Process"),
      body: GradientBackground(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AlignProcessStateWidget(controller: controller),
              SizedBox(height: 60),
              Text(
                "TIP",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Pretendart',
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
                height: 208,
                decoration: BoxDecoration(
                  color: ColorStyle.C_252_232_219,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.circle, color: Colors.green, size: 32),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "초록색 신호가 나타나면 2초간 이를 꽉 물어주세요.",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Pretendart',
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32),
                    Row(
                      children: [
                        Icon(Icons.circle, color: Colors.red, size: 32),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "빨간색 신호가 나타나면 3초간 쉬어주세요.",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Pretendart',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



}

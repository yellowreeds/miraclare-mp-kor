import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/controllers/camera_controller.dart';

class CameraScreen extends StatelessWidget {
  final MyCameraController cameraController = Get.put(MyCameraController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Front Camera with GetX'),
      ),
      body: Obx(() {
        if (cameraController.isCameraInitialized.value) {
          return Stack(
            children: [
              CameraPreview(cameraController.cameraController!),
              // 이미지 오버레이 추가
              Center(
                child: Image.asset(
                  "assets/images/face.png",
                  width: 500,  // 원하는 이미지 크기로 설정
                  height: 500,  // 원하는 이미지 크기로 설정
                ),
              ),
            ],
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      }),
    );
  }
}

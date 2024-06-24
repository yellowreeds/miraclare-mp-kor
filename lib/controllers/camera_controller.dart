import 'package:camera/camera.dart';
import 'package:get/get.dart';

class MyCameraController extends GetxController {
  CameraController? cameraController;
  late List<CameraDescription> cameras;
  var isCameraInitialized = false.obs;
  var isFrontCameraSelected = true.obs;

  @override
  void onInit() {
    super.onInit();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    selectFrontCamera();
  }

  void selectFrontCamera() async {
    final frontCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front);
    cameraController = CameraController(frontCamera, ResolutionPreset.high);

    await cameraController!.initialize();
    isCameraInitialized.value = true;
  }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }
}
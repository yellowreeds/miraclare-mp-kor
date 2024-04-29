import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/constants.dart';
import 'package:goodeeps2/controllers/base_controller.dart';
import 'package:goodeeps2/services/auth_service.dart';
import 'package:video_player/video_player.dart';

class LoginController extends BaseController {
  late final VideoPlayerController videoPlayerController;
  late final TextEditingController idController;
  late final TextEditingController passwordController;
  var id = "".obs;
  var password = "".obs;
  var count = 0.obs; // 관찰 가능한 상태
  var rememberLogin = false.obs;
  var isLoading = false.obs;
  var ipAddress = "";
  var errorMessage = "".obs;
  var isAutoLogin = false.obs;

  final AuthService authService = AuthService();

  @override
  void onInit() {
    super.onInit();
    idController = TextEditingController();
    passwordController = TextEditingController();
    videoPlayerController =
        VideoPlayerController.asset('assets/images/bglogin.mp4')
          ..initialize().then((_) {
            videoPlayerController.setLooping(true);
            if (!videoPlayerController.value.isPlaying) {
              videoPlayerController.play();
            }
          });
  }

  @override
  void onClose() {
    idController.dispose();
    passwordController.dispose();
    videoPlayerController.dispose();
    super.onClose();
  }

  // void login(String email, String password) async {
  //   isLoading.value = true;
  //   final result = await authService.login(email, password);
  //   isLoading.value = false;
  //
  //   if (result.status == 200) {
  //     // Get.to(HomeScreen());
  //   } else {
  //     Get.snackbar("Error", "Login failed");
  //   }
  // }

  void login() async {
    isLoading.value = true;
    logger.i(id.value);
    logger.i(password.value);
    final result = await authService.login(id.value, password.value);
    isLoading.value = false;
  }

  void pressedFindIdButton() {
    Get.toNamed("/find-id");
  }

  void pressedFindPasswordButton() {
    Get.toNamed("/find-password");

  }



  void tappedFindPasswordButton() {}

  void tappedSignupButton() {}
}

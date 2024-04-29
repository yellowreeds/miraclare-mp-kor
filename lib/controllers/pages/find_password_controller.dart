import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/constants.dart';
import 'package:goodeeps2/controllers/base_controller.dart';
import 'package:goodeeps2/services/auth_service.dart';
import 'package:video_player/video_player.dart';

class FindPasswordController extends BaseController {
  late final TextEditingController countryCodeController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;

  late final FocusNode phoneFocusNode;

  var isLoading = false.obs;
  var ipAddress = "".obs;

  final AuthService authService = AuthService();

  @override
  void onInit() {
    super.onInit();
    phoneFocusNode = FocusNode();
    countryCodeController = TextEditingController(text:countryCode);
    phoneController = TextEditingController();
    emailController = TextEditingController();
  }

  @override
  void onClose() {
    countryCodeController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.onClose();
  }

  void onFocus() {
    phoneFocusNode.requestFocus();
  }
}

import 'package:get/get.dart';
import 'package:goodeeps2/controllers/base_controller.dart';

class GradientSliderController extends BaseController {
  var sliderValue = 0.0.obs;

  void updateValue(double newValue) {
    sliderValue.value = newValue;
  }
}


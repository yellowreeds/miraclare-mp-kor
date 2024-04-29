import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/constants.dart';

class GoodeepsSnackBar {
  static show(String title, String content) {
    Get.snackbar(title, content,
        colorText: Colors.white,
        backgroundColor: Colors.black,
        snackPosition: SnackPosition.BOTTOM);
  }
}

class GoodeepsDialog {
  static void showIndicator() {
    if (Get.isDialogOpen ?? false) {
      return;
    }
    Get.dialog(
        barrierDismissible: false,
        Dialog.fullscreen(
          backgroundColor: Colors.black26,
          child: Center(
            child: SizedBox(
                width: 64, height: 64, child: CircularProgressIndicator()),
          ),
        ));
  }

  static void hideIndicator() {
    if (Get.isDialogOpen ?? false) {
      Get.back(closeOverlays: true);
    }
  }

  static showError(String content) {
    Get.dialog(
      Dialog(
        backgroundColor: Color.fromRGBO(8, 8, 20, 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 40, 0, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 다이얼로그 크기를 내용에 맞게 조절합니다.
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(content,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  )),
              const SizedBox(height: 20), // 타이틀과 버튼 사이의 공간을 만듭니다.

              TextButton(
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 14),
                ),
                onPressed: () {
                  Get.back();
                },
                child: const Text('확인'),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false, // 사용자가 다이얼로그 외부를 탭할 때 닫히지 않도록 합니다.
    );
  }
}

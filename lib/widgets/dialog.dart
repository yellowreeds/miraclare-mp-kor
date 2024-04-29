import 'package:flutter/material.dart';

Future<void> showDialogue(
  BuildContext context,
  String message,
  double screenWidth,
  double screenHeight,
) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: screenWidth,
          padding: EdgeInsets.only(top: 50, left: 30, right: 30, bottom: 5),
          color: Colors.black,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(
                child: Text(
                  // textScaleFactor: 0.85,
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.05,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  FocusScope.of(context).unfocus();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                ),
                child: Text(
                  // textScaleFactor: 0.8,
                  '확인',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Pretendart',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> showFailedDialog(BuildContext context, String message,
    double screenWidth, double screenHeight) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async => false, // Prevent dialog from being dismissed
        child: AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: screenWidth,
            padding: EdgeInsets.only(top: 50, left: 30, right: 30, bottom: 5),
            color: Colors.black,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Center(
                  child: Text(
                    textScaleFactor: 0.8,
                    message,
                    style: TextStyle(
                      fontFamily: 'Pretendart',
                      color: Colors.white,
                      fontSize: screenHeight * 0.02,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.05,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    FocusScope.of(context).unfocus();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                  ),
                  child: Text(
                    textScaleFactor: 0.8,
                    '확인',
                    style: TextStyle(
                      fontSize: screenHeight * 0.02,
                      fontFamily: 'Pretendart',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

import 'dart:async';
import 'dart:convert';

import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  double screenHeight = 0;
  double screenWidth = 0;
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController countryCodeController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController verifiyNewPasswordController = TextEditingController();
  TextEditingController verificationCodeController = TextEditingController();
  bool rememberLogin = false;
  bool isLoading = false;
  String ipAddress = "";
  late VideoPlayerController _controller;
  bool isVerificationCorrect = false;
  bool verificationStart = false;
  Timer? countdownTimer;
  late int remainingTime;
  late String verificationCode;
  bool isTimeRunOut = false;
  int regexConditionsPasswordMet = 0;
  int regexConditionsPasswordVerifyMet = 0;
  bool isPasswordCorrect = false;
  bool isPasswordRepeatCorrect = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/images/bglogin.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.play();
        setState(() {});
      });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      MediaQueryData mediaQueryData = MediaQuery.of(context);
      if (mediaQueryData.orientation == Orientation.portrait) {
        setState(() {
          screenHeight = mediaQueryData.size.height;
          screenWidth = mediaQueryData.size.width;
        });
      } else {
        setState(() {
          screenHeight = mediaQueryData.size.width;
          screenWidth = mediaQueryData.size.height;
        });
      }
      countryCodeController.text = "+82";
    });
  }

  @override
  void dispose() {
    stopCountdown();
    super.dispose();
  }

  void startCountdown() async {
    if (countdownTimer != null) {
      countdownTimer!.cancel();
    }
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      verificationStart = true;
      isTimeRunOut = false;
      setState(() {
        remainingTime--;
        if (remainingTime == 0) {
          stopCountdown();
          isTimeRunOut = true;
          setState(() {
            verificationStart = false;
            isVerificationCorrect = false;
            verificationCode = "";
            verificationCodeController.text = "";
          });
        }
      });
    });
  }

  void stopCountdown() {
    if (countdownTimer != null && countdownTimer!.isActive) {
      countdownTimer!.cancel();
    }
  }

  Future<void> showFailedDialog(BuildContext context, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
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
                    textScaleFactor: 0.85,
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
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                  ),
                  child: Text(
                    textScaleFactor: 0.85,
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
        );
      },
    );
  }

  Future<void> getVerificationCode(BuildContext context) async {
    try {
      final String apiUrl =
          'http://3.21.156.190:3000/api/customers/requestVerificationNumber';

      final response = await http.post(
        Uri.parse(apiUrl),
        body: {'cust_email': emailController.text.toString()},
      );

      if (response.statusCode != 500) {
        final jsonResponse = json.decode(response.body);
        verificationCode = jsonResponse.toString();
      } else {
        print("Error : ${response.body}");
      }
    } catch (error) {
      print('Error: $error');
      showFailedDialog(context, '서버에 연결할 수 없습니다. 네트워크 연결을\n확인하십시오.');
    }
  }

  Future<void> changePassword(BuildContext context) async {
    try {
      String password = BCrypt.hashpw(
        newPasswordController.text,
        BCrypt.gensalt(),
      );
      print('password: $password');
      final String apiUrl =
          'http://3.21.156.190:3000/api/customers/changePassword';
      if (phoneNumberController.text.isNotEmpty &&
          phoneNumberController.text[0] == '0') {
        phoneNumberController.text = phoneNumberController.text.substring(1);
      }
      final String fullPhoneNumber =
          countryCodeController.text + "-" + phoneNumberController.text;
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'cust_phone_num': fullPhoneNumber,
          'cust_email': emailController.text,
          'cust_password': password,
          'cust_password_original': newPasswordController.text,
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          phoneNumberController.text = "";
          emailController.text = "";
          newPasswordController.text = "";
          verifiyNewPasswordController.text = "";
          verificationCodeController.text = "";
          isPasswordCorrect = false;
          isPasswordRepeatCorrect = false;
          isVerificationCorrect = false;
          isLoading = false;
        });
        stopCountdown();
        _showSucessDialog(context, "비밀번호가 성공적으로\n변경되었습니다.");
      } else if (response.statusCode == 403) {
        _showLoginDialog(context, "새 비밀번호는 이전 비밀번호와 동일할 수 없습니다.");
      } else if (response.statusCode == 404) {
        print(
            "response: ${fullPhoneNumber}, ${emailController.text}, ${password}");
        _showLoginDialog(context, '정보가 일치하지 않습니다.');
        setState(() {
          isLoading = false;
        });
      } else {
        _showLoginDialog(context, '내부 서버 오류입니다. 다시 시도해 주십시오.');
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error: $error');
      _showLoginDialog(context, '서버에 연결할 수 없습니다. 네트워크 연결을\n확인하십시오.');
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.fill,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),
        ),
        Container(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.035),
            height: screenHeight,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: screenHeight * 0.07,
                        ),
                        Container(
                            width: screenWidth * 0.5,
                            child: Image.asset('assets/images/gdl.png')),
                        SizedBox(
                          height: screenHeight * 0.015,
                        ),
                        Container(
                          width: screenWidth,
                          padding: EdgeInsets.all(5),
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              Container(
                                width: screenWidth * 0.15,
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    inputDecorationTheme: InputDecorationTheme(
                                      counterStyle: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  child: MediaQuery(
                                    data: const MediaQueryData(
                                        textScaleFactor: 0.85),
                                    child: TextField(
                                      controller: countryCodeController,
                                      keyboardType: TextInputType.phone,
                                      maxLength: 4,
                                      decoration: InputDecoration(
                                        labelText: '국가 코드',
                                        counterStyle: TextStyle(
                                            color: Colors.transparent),
                                        labelStyle: TextStyle(
                                            fontFamily: 'Pretendart',
                                            color: Color.fromRGBO(
                                                133, 135, 140, 1),
                                            fontSize: screenHeight * 0.025),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                      ),
                                      style: TextStyle(
                                        fontFamily: 'Pretendart',
                                        color: Colors.white,
                                        fontSize: screenHeight * 0.025,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Expanded(
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    inputDecorationTheme: InputDecorationTheme(
                                      counterStyle: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  child: MediaQuery(
                                    data: const MediaQueryData(
                                        textScaleFactor: 0.85),
                                    child: TextField(
                                      controller: phoneNumberController,
                                      keyboardType: TextInputType.phone,
                                      maxLength: 15,
                                      decoration: InputDecoration(
                                        labelText: '휴대폰 번호(숫자만 입력)',
                                        labelStyle: TextStyle(
                                            fontFamily: 'Pretendart',
                                            color: Color.fromRGBO(
                                                133, 135, 140, 1),
                                            fontSize: screenHeight * 0.025),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                      ),
                                      style: TextStyle(
                                        fontFamily: 'Pretendart',
                                        color: Colors.white,
                                        fontSize: screenHeight * 0.025,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: screenWidth,
                          padding: EdgeInsets.all(5),
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              Expanded(
                                child: MediaQuery(
                                  data: const MediaQueryData(
                                      textScaleFactor: 0.85),
                                  child: TextField(
                                    controller: emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      labelText: '이메일',
                                      labelStyle: TextStyle(
                                          fontFamily: 'Pretendart',
                                          color:
                                              Color.fromRGBO(133, 135, 140, 1),
                                          fontSize: screenHeight * 0.025),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                    ),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenHeight * 0.025,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: MediaQuery(
                                    data: const MediaQueryData(
                                        textScaleFactor: 0.85),
                                    child: TextField(
                                      enabled: verificationStart ? true : false,
                                      controller: verificationCodeController,
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        isVerificationCorrect =
                                            value == verificationCode
                                                ? true
                                                : false;
                                        if (isVerificationCorrect) {
                                          stopCountdown();
                                        }
                                        setState(() {});
                                      },
                                      decoration: InputDecoration(
                                        labelText: '인증번호 입력',
                                        labelStyle: TextStyle(
                                            fontFamily: 'Pretendart',
                                            color: Color.fromRGBO(
                                                133, 135, 140, 1),
                                            fontSize: screenHeight * 0.025),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: verificationCodeController
                                                    .text.isNotEmpty
                                                ? isTimeRunOut
                                                    ? Colors.red
                                                    : !isVerificationCorrect
                                                        ? Colors.white
                                                        : Color(0xFF1BFF92)
                                                : Colors.white,
                                          ),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: verificationCodeController
                                                    .text.isNotEmpty
                                                ? isTimeRunOut
                                                    ? Colors.red
                                                    : !isVerificationCorrect
                                                        ? Colors.white
                                                        : Color(0xFF1BFF92)
                                                : Colors.white,
                                          ),
                                        ),
                                      ),
                                      style: TextStyle(
                                          fontFamily: 'Pretendart',
                                          color: Colors.white,
                                          fontSize: screenHeight * 0.025),
                                    ),
                                  ),
                                ),
                                verificationStart
                                    ? Text(
                                        textScaleFactor: 0.85,
                                        formatTime(remainingTime),
                                        style: TextStyle(
                                            fontFamily: 'Pretendart',
                                            color: Colors.white,
                                            fontSize:
                                                screenHeight * 0.025 * 0.8),
                                      )
                                    : Text(textScaleFactor: 0.85, ""),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            !verificationStart
                                ? Align(
                                    alignment: Alignment.centerLeft,
                                    child: SizedBox(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (emailController.text.isEmpty) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              content: Text(
                                                textScaleFactor: 0.85,
                                                '이메일 주소를 비워 둘 수 없습니다',
                                                style: TextStyle(
                                                  fontSize: screenHeight * 0.02,
                                                  fontFamily: 'Pretendart',
                                                ),
                                              ),
                                            ));
                                          } else {
                                            getVerificationCode(context);
                                            remainingTime = 180;
                                            startCountdown();
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFF714AC6)),
                                        child: Text(
                                          textScaleFactor: 0.85,
                                          '이메일 인증코드 전송',
                                          style: TextStyle(
                                            fontFamily: 'Pretendart',
                                            fontSize: screenHeight * 0.02,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Text(textScaleFactor: 0.85, ""),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Icon(
                                    verificationCodeController.text.isEmpty
                                        ? null
                                        : isTimeRunOut
                                            ? Icons.error
                                            : isVerificationCorrect
                                                ? Icons.check
                                                : Icons.error,
                                    color:
                                        verificationCodeController.text.isEmpty
                                            ? null
                                            : isTimeRunOut
                                                ? Color(0xFFEB5757)
                                                : isVerificationCorrect
                                                    ? Color(0xFF1BFF92)
                                                    : Color(0xFFEB5757),
                                  ),
                                  SizedBox(width: screenWidth * 0.01),
                                  Text(
                                    textScaleFactor: 0.85,
                                    verificationCodeController.text.isEmpty
                                        ? ""
                                        : isTimeRunOut
                                            ? '인증번호 입력 시간이 만료되었습니다. 재인증 해주세요.'
                                            : isVerificationCorrect
                                                ? '인증이 완료되었습니다.'
                                                : '인증번호가 일치하지 않습니다.',
                                    style: TextStyle(
                                      color: verificationCodeController
                                              .text.isEmpty
                                          ? null
                                          : isTimeRunOut
                                              ? Color(0xFFEB5757)
                                              : isVerificationCorrect
                                                  ? Color(0xFF1BFF92)
                                                  : Color(0xFFEB5757),
                                      fontSize: screenHeight * 0.018,
                                      fontFamily: 'Pretendart',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        isVerificationCorrect
                            ? Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Theme(
                                          data: Theme.of(context).copyWith(
                                            inputDecorationTheme:
                                                InputDecorationTheme(
                                              counterStyle: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          child: MediaQuery(
                                            data: const MediaQueryData(
                                                textScaleFactor: 0.85),
                                            child: TextField(
                                              maxLength: 16,
                                              enabled: isVerificationCorrect
                                                  ? true
                                                  : false,
                                              controller: newPasswordController,
                                              obscureText: true,
                                              onChanged: (value) {
                                                isPasswordRepeatCorrect =
                                                    newPasswordController
                                                            .text.isNotEmpty &&
                                                        (newPasswordController
                                                                .text
                                                                .toString() ==
                                                            verifiyNewPasswordController
                                                                .text
                                                                .toString());
                                                final regexLowerCase =
                                                    RegExp(r'^(?=.*[a-z])');
                                                final regexUpperCase =
                                                    RegExp(r'^(?=.*[A-Z])');
                                                final regexDigit =
                                                    RegExp(r'^(?=.*\d)');
                                                final regexSpecialChar =
                                                    RegExp(r'^(?=.*[\W_])');

                                                regexConditionsPasswordMet = 0;

                                                if (regexLowerCase
                                                    .hasMatch(value))
                                                  regexConditionsPasswordMet++;
                                                if (regexUpperCase
                                                    .hasMatch(value))
                                                  regexConditionsPasswordMet++;
                                                if (regexDigit.hasMatch(value))
                                                  regexConditionsPasswordMet++;
                                                if (regexSpecialChar
                                                    .hasMatch(value))
                                                  regexConditionsPasswordMet++;

                                                isPasswordCorrect =
                                                    regexConditionsPasswordMet >=
                                                            3 &&
                                                        newPasswordController
                                                                .text.length >
                                                            9;

                                                setState(() {});
                                              },
                                              decoration: InputDecoration(
                                                labelText:
                                                    '새 비밀번호 (10~16자, 영문+숫자/특수문자)',
                                                labelStyle: TextStyle(
                                                    color: Color.fromRGBO(
                                                        133, 135, 140, 1),
                                                    fontSize:
                                                        screenHeight * 0.025),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: isPasswordCorrect
                                                        ? Color(0xFF1BFF92)
                                                        : Colors.white,
                                                  ),
                                                ),
                                                focusedBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: isPasswordCorrect
                                                        ? Color(0xFF1BFF92)
                                                        : Colors.white,
                                                  ),
                                                ),
                                              ),
                                              style: TextStyle(
                                                  fontFamily: 'Pretendart',
                                                  color: Colors.white,
                                                  fontSize:
                                                      screenHeight * 0.025),
                                            ),
                                          ),
                                        ),
                                      ),
                                      newPasswordController.text.isNotEmpty &&
                                              isPasswordCorrect
                                          ? Icon(
                                              Icons.check_circle,
                                              color: Color(0xFF1BFF92),
                                            )
                                          : Icon(
                                              Icons.check_circle,
                                              color: Colors.white,
                                            ),
                                    ],
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(
                                          newPasswordController.text != ""
                                              ? isPasswordCorrect
                                                  ? null
                                                  : Icons.error
                                              : Icons.error,
                                          color:
                                              newPasswordController.text != ""
                                                  ? isPasswordCorrect
                                                      ? Color(0xFF1BFF92)
                                                      : Color(0xFFEB5757)
                                                  : Color(0xFFEB5757),
                                        ),
                                        SizedBox(width: 8.0),
                                        Text(
                                          textScaleFactor: 0.85,
                                          newPasswordController.text != ""
                                              ? isPasswordCorrect
                                                  ? ''
                                                  : '비밀번호 생성 규칙에 맞게 다시 입력해주세요.'
                                              : "비밀번호를 입력해주세요.",
                                          style: TextStyle(
                                            color:
                                                newPasswordController.text != ""
                                                    ? isPasswordCorrect
                                                        ? Color(0xFF1BFF92)
                                                        : Color(0xFFEB5757)
                                                    : Color(0xFFEB5757),
                                            fontSize: screenHeight * 0.018,
                                            fontFamily: 'Pretendart',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Text(textScaleFactor: 0.85, ""),
                        isVerificationCorrect
                            ? Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Theme(
                                          data: Theme.of(context).copyWith(
                                            inputDecorationTheme:
                                                InputDecorationTheme(
                                              counterStyle: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          child: MediaQuery(
                                            data: const MediaQueryData(
                                                textScaleFactor: 0.85),
                                            child: TextField(
                                              maxLength: 16,
                                              controller:
                                                  verifiyNewPasswordController,
                                              enabled: isVerificationCorrect
                                                  ? true
                                                  : false,
                                              obscureText: true,
                                              onChanged: (value) {
                                                isPasswordRepeatCorrect =
                                                    newPasswordController
                                                            .text.isNotEmpty &&
                                                        verifiyNewPasswordController
                                                                .text ==
                                                            newPasswordController
                                                                .text;

                                                setState(() {});
                                              },
                                              decoration: InputDecoration(
                                                labelText: '새 비밀번호 확인',
                                                labelStyle: TextStyle(
                                                    fontFamily: 'Pretendart',
                                                    color: Color.fromRGBO(
                                                        133, 135, 140, 1),
                                                    fontSize:
                                                        screenHeight * 0.025),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color:
                                                        isPasswordRepeatCorrect
                                                            ? Color(0xFF1BFF92)
                                                            : Colors.white,
                                                  ),
                                                ),
                                                focusedBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color:
                                                        isPasswordRepeatCorrect
                                                            ? Color(0xFF1BFF92)
                                                            : Colors.white,
                                                  ),
                                                ),
                                              ),
                                              style: TextStyle(
                                                fontFamily: 'Pretendart',
                                                color: Colors.white,
                                                fontSize: screenHeight * 0.025,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      verifiyNewPasswordController
                                                  .text.isNotEmpty &&
                                              isPasswordRepeatCorrect
                                          ? Icon(
                                              Icons.check_circle,
                                              color: Color(0xFF1BFF92),
                                            )
                                          : Icon(
                                              Icons.check_circle,
                                              color: Colors.white,
                                            ),
                                    ],
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(
                                          verifiyNewPasswordController.text !=
                                                  ""
                                              ? isPasswordRepeatCorrect
                                                  ? null
                                                  : Icons.error
                                              : Icons.error,
                                          color: verifiyNewPasswordController
                                                      .text !=
                                                  ""
                                              ? isPasswordRepeatCorrect
                                                  ? Color(0xFF1BFF92)
                                                  : Color(0xFFEB5757)
                                              : Color(0xFFEB5757),
                                        ),
                                        SizedBox(width: 8.0),
                                        Text(
                                          textScaleFactor: 0.85,
                                          verifiyNewPasswordController.text !=
                                                  ""
                                              ? isPasswordRepeatCorrect
                                                  ? ''
                                                  : '비밀번호가 일치하지 않습니다.'
                                              : "비밀번호를 입력해주세요.",
                                          style: TextStyle(
                                            color: verifiyNewPasswordController
                                                        .text !=
                                                    ""
                                                ? isPasswordRepeatCorrect
                                                    ? Color(0xFF1BFF92)
                                                    : Color(0xFFEB5757)
                                                : Color(0xFFEB5757),
                                            fontSize: screenHeight * 0.018,
                                            fontFamily: 'Pretendart',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Text(textScaleFactor: 0.85, ""),
                        SizedBox(
                          height: screenHeight * 0.03,
                        ),
                        isVerificationCorrect
                            ? Container(
                                width: screenWidth,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF8B6DE0),
                                      Color(0xFFAB07E4)
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (phoneNumberController.text.isEmpty ||
                                        emailController.text.isEmpty ||
                                        newPasswordController.text.isEmpty ||
                                        verifiyNewPasswordController
                                            .text.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text(
                                          textScaleFactor: 0.85,
                                          "양식을 올바르게 작성해 주세요.",
                                          style: TextStyle(
                                              fontFamily: 'Pretendart',
                                              fontSize: screenHeight * 0.020),
                                        ),
                                      ));
                                    } else if (newPasswordController.text !=
                                        verifiyNewPasswordController.text) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            textScaleFactor: 0.85,
                                            "비밀번호가 일치하지 않습니다.",
                                            style: TextStyle(
                                                fontFamily: 'Pretendart',
                                                fontSize: screenHeight * 0.020),
                                          ),
                                        ),
                                      );
                                    } else if (!isVerificationCorrect) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            textScaleFactor: 0.85,
                                            "인증번호가 일치하지 않습니다.",
                                            style: TextStyle(
                                                fontFamily: 'Pretendart',
                                                fontSize: screenHeight * 0.020),
                                          ),
                                        ),
                                      );
                                    } else {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      changePassword(context);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    textScaleFactor: 0.85,
                                    '비밀번호 변경',
                                    style: TextStyle(
                                      fontFamily: 'Pretendart',
                                      fontSize: screenHeight * 0.02,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            : Text(textScaleFactor: 0.85, ""),
                        SizedBox(
                          height: screenHeight * 0.05,
                        ),
                        isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Center(
                                    child: SizedBox(
                                      width: 25,
                                      height: 25,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: screenWidth * 0.02,
                                  ),
                                  Text(
                                    textScaleFactor: 0.85,
                                    "로딩 중",
                                    style: TextStyle(
                                        color: Color.fromRGBO(231, 231, 232, 1),
                                        fontSize: screenHeight * 0.02),
                                  )
                                ],
                              )
                            : Text(textScaleFactor: 0.85, "")
                      ],
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.05,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: screenHeight * 0.08,
                      child: Image.asset('assets/images/logotransparent.png'),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.05,
                  ),
                ],
              ),
            )),
      ],
    ));
  }

  Future<void> _showLoginDialog(BuildContext context, String text) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Container(
            padding: EdgeInsets.only(top: 50, left: 30, right: 30, bottom: 5),
            color: Colors.black,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Center(
                  child: Text(
                    textScaleFactor: 0.85,
                    text,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenHeight * 0.02,
                    ),
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.05,
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isLoading = false;
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                  ),
                  child: Text(
                    textScaleFactor: 0.85,
                    '확인',
                    style: TextStyle(fontSize: screenHeight * 0.02),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showSucessDialog(BuildContext context, String text) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Container(
            padding: EdgeInsets.only(top: 50, left: 30, right: 30, bottom: 5),
            color: Colors.black,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Center(
                  child: Text(
                    textScaleFactor: 0.85,
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenHeight * 0.02,
                    ),
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.05,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                  ),
                  child: Text(
                    textScaleFactor: 0.85,
                    '확인',
                    style: TextStyle(fontSize: screenHeight * 0.02),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

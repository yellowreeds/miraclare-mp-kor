import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_ip_address/get_ip_address.dart';
import 'package:goodeeps2/change_password_page.dart';
import 'package:goodeeps2/find_id_page.dart';
import 'package:goodeeps2/main_page.dart';
import 'package:goodeeps2/terms_agreement_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  double screenHeight = 0;
  double screenWidth = 0;
  TextEditingController idController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool rememberLogin = false;
  bool isLoading = false;
  String ipAddress = "";
  late SharedPreferences prefs;
  late VideoPlayerController _controller;

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
      prefs = await SharedPreferences.getInstance();
      String savedUsername = await prefs.getString('savedUsername') ?? "";
      String savedPassword = await prefs.getString('savedPassword') ?? "";
      bool autoLogin = await prefs.getBool('autoLogin') ?? false;
      if (autoLogin) {
        if (savedPassword != "" && savedUsername != "") {
          rememberLogin = true;
          idController.text = savedUsername;
          passwordController.text = savedPassword;
          print("password: ${passwordController.text}");
        }
      }
    });
  }

  Future<void> login(BuildContext context) async {
    try {
      var ipAddress = IpAddress(type: RequestType.json);
      dynamic data = await ipAddress.getIpAddress();
      final String apiUrl = 'http://3.21.156.190:3000/api/customers/login';
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'username': idController.text,
          'password': passwordController.text,
          'ipAddress': data['ip'],
        },
      );

      if (response.statusCode == 200) {
        isLoading = false;
        final jsonResponse = json.decode(response.body);
        prefs.setString('custUsername', idController.text);
        prefs.setString('custName', jsonResponse['message']);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MainPage(
              connectedDevice: null,
            ),
          ),
        );
      } else if (response.statusCode == 401) {
        _showLoginDialog(context, '아이디 또는 비밀번호가 일치하지 않습니다.');
        setState(() {
          isLoading = false;
        });
      } else {
        _showLoginDialog(context, '내부 서버 오류입니다.\n다시 시도해 주십시오.');
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      // Handle the error here
      print('Error: $error');
      _showLoginDialog(context, '서버에 연결할 수 없습니다. 네트워크 연결을 확인하십시오.');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
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
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                height: screenHeight,
                child: Column(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: screenHeight * 0.03,
                          ),
                          Container(
                              width: screenWidth * 0.5,
                              child: Image.asset('assets/images/gdl.png')),
                          SizedBox(
                            height: screenHeight * 0.015,
                          ),
                          Container(
                            width: screenWidth,
                            alignment: Alignment.center,
                            child: Row(
                              children: [
                                Expanded(
                                  child: MediaQuery(
                                    data: const MediaQueryData(
                                        textScaleFactor: 0.85),
                                    child: TextField(
                                      controller: idController,
                                      decoration: InputDecoration(
                                        labelText: '아이디',
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
                                          color: Colors.white,
                                          fontSize: screenHeight * 0.025),
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
                                      controller: passwordController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        labelText: '비밀번호',
                                        labelStyle: TextStyle(
                                          fontFamily: 'Pretendart',
                                          color:
                                              Color.fromRGBO(133, 135, 140, 1),
                                          fontSize: screenHeight * 0.025,
                                        ),
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
                                          fontSize: screenHeight * 0.025),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Theme(
                            data: ThemeData(
                              unselectedWidgetColor: Colors.white,
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: rememberLogin,
                                  checkColor: Colors.black,
                                  activeColor: Colors.white,
                                  onChanged: (value) {
                                    setState(() {
                                      rememberLogin = value!;
                                      if (rememberLogin) {
                                        prefs.setBool("autoLogin", true);
                                      } else {
                                        prefs.setBool("autoLogin", false);
                                      }
                                    });
                                  },
                                ),
                                Text(
                                  textScaleFactor: 0.85,
                                  '계정 정보 저장',
                                  style: TextStyle(
                                    fontFamily: 'Pretendart',
                                    fontSize: screenHeight * 0.022,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.03,
                          ),
                          Container(
                            width: screenWidth,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF8B6DE0), Color(0xFFAB07E4)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                if (rememberLogin) {
                                  prefs.setString('savedUsername',
                                      idController.text.toString());
                                  prefs.setString('savedPassword',
                                      passwordController.text.toString());
                                }
                                login(context);
                                setState(() {
                                  isLoading = true;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                              ),
                              child: Text(
                                textScaleFactor: 0.85,
                                '로그인',
                                style: TextStyle(
                                  fontFamily: 'Pretendart',
                                  fontSize: screenHeight * 0.022,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.03,
                          ),
                          Container(
                            height: screenHeight * 0.03,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => FindId()),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.04),
                                  ),
                                  child: Text(
                                    textScaleFactor: 0.85,
                                    "아이디 찾기",
                                    style: TextStyle(
                                      fontFamily: 'Pretendart',
                                      color: Colors.white,
                                      fontSize: screenHeight * 0.018,
                                    ),
                                  ),
                                ),
                                VerticalDivider(
                                  color: Colors.white,
                                  thickness: 0.5,
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ChangePassword()),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.04),
                                  ),
                                  child: Text(
                                    textScaleFactor: 0.85,
                                    "비밀번호 찾기",
                                    style: TextStyle(
                                      fontFamily: 'Pretendart',
                                      color: Colors.white,
                                      fontSize: screenHeight * 0.018,
                                    ),
                                  ),
                                ),
                                VerticalDivider(
                                  color: Colors.white,
                                  thickness: 0.5,
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              TermsAgreement()),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.04),
                                  ),
                                  child: Text(
                                    textScaleFactor: 0.85,
                                    "회원가입",
                                    style: TextStyle(
                                      fontFamily: 'Pretendart',
                                      color: Colors.white,
                                      fontSize: screenHeight * 0.018,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.02,
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
                                      "로그인 중",
                                      style: TextStyle(
                                          color:
                                              Color.fromRGBO(231, 231, 232, 1),
                                          fontSize: screenHeight * 0.02),
                                    )
                                  ],
                                )
                              : Text(textScaleFactor: 0.85, "")
                        ],
                      ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLoginDialog(BuildContext context, String text) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
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

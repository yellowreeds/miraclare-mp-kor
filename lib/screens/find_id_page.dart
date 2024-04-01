import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:goodeeps2/services/find_id.dart';

class FindId extends StatefulWidget {
  const FindId({super.key});

  @override
  State<FindId> createState() => _FindIdState();
}

class _FindIdState extends State<FindId> {
  double screenWidth = 0;
  double screenHeight = 0;
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController countryCodeController = TextEditingController();
  bool rememberLogin = false;
  bool isLoading = false;
  String ipAddress = "";
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
      countryCodeController.text = "+82";
    });
  }

  Future<void> showID() async {
    final userData = await FindingID().searchID(
        context,
        phoneNumberController.text,
        countryCodeController.text,
        emailController.text,
        screenWidth,
        screenHeight);

    if (userData != null) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              textScaleFactor: 0.8,
              "당신의 아이디는: ${userData}",
              style: TextStyle(
                  fontFamily: 'Pretendart', fontSize: screenHeight * 0.020),
            ),
          ),
        );
        phoneNumberController.text = "";
        emailController.text = "";
        countryCodeController.text = "+";
      });
    } else {
      print('Failed to load user data');
    }
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
                                      counterStyle:
                                          TextStyle(color: Colors.transparent),
                                      labelStyle: TextStyle(
                                        fontFamily: 'Pretendart',
                                        color: Color.fromRGBO(133, 135, 140, 1),
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
                                        fontFamily: 'Pretendart',
                                        color: Colors.white,
                                        fontSize: screenHeight * 0.025),
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
                                        fontFamily: 'Pretendart',
                                        color: Colors.white,
                                        fontSize: screenHeight * 0.025),
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
                                data:
                                    const MediaQueryData(textScaleFactor: 0.85),
                                child: TextField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: '이메일',
                                    labelStyle: TextStyle(
                                        fontFamily: 'Pretendart',
                                        color: Color.fromRGBO(133, 135, 140, 1),
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
                          onPressed: () async {
                            await showID();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                          ),
                          child: Text(
                            textScaleFactor: 0.8,
                            '검색',
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
                                  textScaleFactor: 0.8,
                                  "로그인 중",
                                  style: TextStyle(
                                      color: Color.fromRGBO(231, 231, 232, 1),
                                      fontSize: screenHeight * 0.02),
                                )
                              ],
                            )
                          : Text(textScaleFactor: 0.8, "")
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
                    textScaleFactor: 0.8,
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
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                  ),
                  child: Text(
                    textScaleFactor: 0.8,
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

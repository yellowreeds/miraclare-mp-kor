import 'package:flutter/material.dart';
import 'package:goodeeps2/account_edit_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AccountConfirmation extends StatefulWidget {
  const AccountConfirmation({super.key});

  @override
  State<AccountConfirmation> createState() => _AccountConfirmationState();
}

class _AccountConfirmationState extends State<AccountConfirmation> {
  double screenHeight = 0;
  double screenWidth = 0;
  bool isPasswordExist = false;
  TextEditingController passwordController = TextEditingController();
  late SharedPreferences? prefs;
  late String username = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // initiate screen height and width
    // initiate shared preferences
    // assign user's username
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
      username = await prefs!.getString('custUsername') ?? "";
    });
  }

  // check is password correct in the server
  Future<void> checkPassword(BuildContext context) async {
    try {
      final String apiUrl =
          'http://3.21.156.190:3000/api/customers/checkPassword';
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'username': username,
          'password': passwordController.text,
        },
      );

      if (response.statusCode == 200) {
        isLoading = false;
        passwordController.text = "";
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AccountEdit(),
            ));
      } else if (response.statusCode == 401) {
        print("response: ${response.body}");

        showSuccessDialog(context, '비밀번호가 일치하지 않습니다.');
        setState(() {
          isLoading = false;
        });
      } else {
        print("response: ${response.body}");

        showSuccessDialog(context, '내부 서버 오류입니다. 다시 시도해 주십시오.');
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      // Handle the error here
      print('Error: $error');
      showSuccessDialog(context, '서버에 연결할 수 없습니다. 네트워크 연결을 확인하십시오.');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "회원정보 수정",
          textScaleFactor: 0.8,
        ),
        backgroundColor: Color(0xFF0F0D2B),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg2.png'),
            fit: BoxFit.fill,
          ),
        ),
        alignment: Alignment.centerLeft,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "현재 비밀번호",
                textScaleFactor: 0.8,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenHeight * 0.025,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Pretendart',
                ),
              ),
              SizedBox(
                height: screenHeight * 0.02,
              ),
              Text(
                "안전한 사용을 위해 현재 비밀번호를 입력해주세요.",
                textScaleFactor: 0.8,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenHeight * 0.018,
                  fontFamily: 'Pretendart',
                ),
              ),
              SizedBox(
                height: screenHeight * 0.02,
              ),
              Container(
                width: screenWidth,
                padding: EdgeInsets.all(5),
                alignment: Alignment.center,
                child: Row(
                  children: [
                    Expanded(
                      child: MediaQuery(
                        data: const MediaQueryData(textScaleFactor: 0.85),
                        child: TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: '현재 비밀번호',
                            labelStyle: TextStyle(
                                fontFamily: 'Pretendart',
                                color: Color.fromRGBO(133, 135, 140, 1),
                                fontSize: screenHeight * 0.02),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          onChanged: (value) {
                            isPasswordExist =
                                passwordController.text.isNotEmpty;
                            setState(() {});
                          },
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
                height: screenHeight * 0.02,
              ),
              Container(
                width: screenWidth,
                height: screenHeight * 0.06,
                decoration: BoxDecoration(
                  color:
                      isPasswordExist ? Color(0xFF714AC6) : Color(0xFF817C99),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                    });
                    checkPassword(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                  child: Text(
                    '확인',
                    textScaleFactor: 0.8,
                    style: TextStyle(
                      fontFamily: 'Pretendart',
                      fontSize: screenHeight * 0.02,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
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
                          "로드 중",
                          textScaleFactor: 0.8,
                          style: TextStyle(
                              color: Color.fromRGBO(231, 231, 232, 1),
                              fontSize: screenHeight * 0.02),
                        )
                      ],
                    )
                  : Text(
                      "",
                      textScaleFactor: 0.8,
                    )
            ],
          ),
        ),
      ),
    );
  }

  // success dialog
  Future<void> showSuccessDialog(BuildContext context, String status) async {
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
                    status,
                    textScaleFactor: 0.8,
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
                    '확인',
                    textScaleFactor: 0.8,
                    style: TextStyle(
                        fontFamily: 'Pretendart',
                        fontSize: screenHeight * 0.02),
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

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goodeeps2/personal_information_page.dart';
import 'package:kpostal/kpostal.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemberRegistration extends StatefulWidget {
  const MemberRegistration({super.key});

  @override
  State<MemberRegistration> createState() => _MemberRegistrationState();
}

class _MemberRegistrationState extends State<MemberRegistration> {
  TextEditingController idController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordRepeatController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController countryCodeController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController verificationCodeController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController detailAddressController = TextEditingController();
  TextEditingController productKeyController = TextEditingController();

  double screenHeight = 0;
  double screenWidth = 0;
  int genderValue = 2;
  String userPassword = "";
  bool isIdTaken = false;
  bool isEmailTaken = false;
  bool isPasswordCorrect = false;
  bool isPasswordRepeatCorrect = false;
  bool isEmailCorrect = false;
  bool isVerificationCorrect = false;
  bool verificationStart = false;
  bool isTimeRunOut = false;
  DateTime selectedDate = DateTime.now();
  Timer? countdownTimer;
  late int remainingTime;
  late String verificationCode;
  late List<String>? username = [];
  late List<String>? email = [];
  bool isLoadingID = false;
  bool isLoadingEmail = false;
  late SharedPreferences prefs;
  int regexConditionsPasswordMet = 0;
  int regexConditionsPasswordVerifyMet = 0;

  @override
  void initState() {
    super.initState();
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
      countryCodeController.text = "+82";
      checkIdExist(context);
      checkEmailExist(context);
    });
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      firstDate: DateTime(1920),
      lastDate: DateTime(2101),
      locale: const Locale("ko", "KR"),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF714AC6),
              onPrimary: Color.fromRGBO(193, 193, 193, 1),
              onSurface: Color.fromRGBO(193, 193, 193, 1),
            ),
            dialogBackgroundColor: Color.fromRGBO(58, 58, 58, 1),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color.fromRGBO(193, 193, 193, 1),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        dobController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> register(BuildContext context) async {
    try {
      String password = BCrypt.hashpw(
        passwordController.text,
        BCrypt.gensalt(),
      );

      final String apiUrl = 'http://3.21.156.190:3000/api/customers/register';
      if (phoneNumberController.text.isNotEmpty &&
          phoneNumberController.text[0] == '0') {
        phoneNumberController.text = phoneNumberController.text.substring(1);
      }
      final String fullPhoneNumber =
          countryCodeController.text + "-" + phoneNumberController.text;

      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'cust_username': idController.text,
          'cust_password': password,
          'cust_name': nameController.text,
          'cust_dob': dobController.text,
          'cust_gender': genderValue.toString(),
          'cust_email': emailController.text,
          'cust_phone_num': fullPhoneNumber,
          'cust_address': addressController.text,
          'cust_detail_address': detailAddressController.text,
          'cust_join_date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'prod_registration_key': productKeyController.text,
        },
      );

      if (response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        showSuccessDialog(context, jsonResponse['cust_id']);
        prefs.setString('custName', nameController.text);
        prefs.setString('custUsername', idController.text);
      } else if (response.statusCode == 409) {
        showFailedDialog(context, '이미 사용중인 아이디입니다.');
        print("Error : ${response.body}");
      } else {
        showFailedDialog(context, 'Internal Server Error');
      }
    } catch (error) {
      print('Error: $error');
      showFailedDialog(context, '서버에 연결할 수 없습니다. 네트워크 연결을 확인하십시오.');
    }
  }

  Future<void> checkIdExist(BuildContext context) async {
    isLoadingID = true;
    final String apiUrl = 'http://3.21.156.190:3000/api/customers/checkIdExist';
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as List<dynamic>;

        username = jsonResponse
            .map((data) => data['cust_username'].toString())
            .toList();
        setState(() {
          isLoadingID = false;
        });
      } else {
        isLoadingID = false;
        print("Error: ${response.body}");
        showFailedDialog(context, 'Error fetching data from the server');
      }
    } catch (error) {
      isLoadingID = false;
      print('Error: $error');
      showFailedDialog(
          context, 'Network error: Unable to connect to the server');
    }
  }

  Future<void> checkEmailExist(BuildContext context) async {
    isLoadingEmail = true;
    final String apiUrl =
        'http://3.21.156.190:3000/api/customers/checkEmailExist';
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as List<dynamic>;

        email =
            jsonResponse.map((data) => data['cust_email'].toString()).toList();
        setState(() {
          isLoadingEmail = false;
        });
      } else {
        setState(() {
          isLoadingEmail = false;
        });
        print("Error: ${response.body}");
        showFailedDialog(context, 'Error fetching data from the server');
      }
    } catch (error) {
      setState(() {
        isLoadingEmail = false;
      });
      print('Error: $error');
      showFailedDialog(
          context, 'Network error: Unable to connect to the server');
    }
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
      showFailedDialog(context, '서버에 연결할 수 없습니다. 네트워크 연결을 확인하십시오.');
    }
  }

  @override
  void dispose() {
    stopCountdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg2.png'),
                fit: BoxFit.fill,
              ),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(15),
              child: Column(
                children: [
                  SizedBox(
                    height: screenHeight * 0.05,
                  ),
                  Center(
                    child: Container(
                      width: screenWidth * 0.5,
                      padding: EdgeInsets.all(5),
                      child: Text(
                        textScaleFactor: 0.8,
                        "회원가입",
                        style: TextStyle(
                            fontFamily: 'Pretendart',
                            fontSize: screenHeight * 0.025,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.015,
                  ),
                  Container(
                    width: screenWidth,
                    child: Column(
                      children: [
                        Row(
                          children: [
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
                                    controller: idController,
                                    maxLength: 15,
                                    onChanged: (value) {
                                      isIdTaken = username!.contains(value)
                                          ? true
                                          : false;
                                      setState(() {});
                                    },
                                    decoration: InputDecoration(
                                      labelText: '아이디',
                                      labelStyle: TextStyle(
                                        fontFamily: 'Pretendart',
                                        color: Color.fromRGBO(133, 135, 140, 1),
                                        fontSize: screenHeight * 0.025,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: idController.text.isNotEmpty &&
                                                  idController.text.length > 5
                                              ? isIdTaken
                                                  ? Colors.white
                                                  : Color(0xFF1BFF92)
                                              : Colors.white,
                                        ),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: idController.text.isNotEmpty &&
                                                  idController.text.length > 5
                                              ? isIdTaken
                                                  ? Colors.white
                                                  : Color(0xFF1BFF92)
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
                            idController.text.isNotEmpty &&
                                    !isIdTaken &&
                                    idController.text.length > 5
                                ? Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF1BFF92),
                                  )
                                : Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                  )
                          ],
                        ),
                        isLoadingID
                            ? SizedBox(
                                width: screenHeight * 0.01,
                                height: screenHeight * 0.01,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Icon(
                                      idController.text != "" &&
                                              idController.text.length > 5
                                          ? !isIdTaken
                                              ? Icons.check_circle
                                              : Icons.error
                                          : Icons.error,
                                      color: idController.text.isEmpty ||
                                              idController.text.length < 6
                                          ? Color(0xFFEB5757)
                                          : !isIdTaken
                                              ? Color(0xFF1BFF92)
                                              : Color(0xFFEB5757),
                                    ),
                                    SizedBox(width: screenWidth * 0.01),
                                    Text(
                                      textScaleFactor: 0.8,
                                      idController.text.isNotEmpty &&
                                              idController.text.length > 5
                                          ? !isIdTaken
                                              ? '사용가능한 아이디입니다.'
                                              : '이미 사용중인 아이디입니다.'
                                          : "아이디를 입력해주세요.",
                                      style: TextStyle(
                                        fontFamily: 'Pretendart',
                                        color: idController.text.isEmpty ||
                                                idController.text.length < 6
                                            ? Color(0xFFEB5757)
                                            : !isIdTaken
                                                ? Color(0xFF1BFF92)
                                                : Color(0xFFEB5757),
                                        fontSize: screenHeight * 0.018,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Container(
                    width: screenWidth,
                    child: Column(
                      children: [
                        Row(
                          children: [
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
                                    maxLength: 16,
                                    controller: passwordController,
                                    obscureText: true,
                                    onChanged: (value) {
                                      isPasswordRepeatCorrect =
                                          passwordController.text.isNotEmpty &&
                                              (passwordController.text
                                                      .toString() ==
                                                  passwordRepeatController.text
                                                      .toString());
                                      final regexLowerCase =
                                          RegExp(r'^(?=.*[a-z])');
                                      final regexUpperCase =
                                          RegExp(r'^(?=.*[A-Z])');
                                      final regexDigit = RegExp(r'^(?=.*\d)');
                                      final regexSpecialChar =
                                          RegExp(r'^(?=.*[\W_])');

                                      regexConditionsPasswordMet = 0;

                                      if (regexLowerCase.hasMatch(value))
                                        regexConditionsPasswordMet++;
                                      if (regexUpperCase.hasMatch(value))
                                        regexConditionsPasswordMet++;
                                      if (regexDigit.hasMatch(value))
                                        regexConditionsPasswordMet++;
                                      if (regexSpecialChar.hasMatch(value))
                                        regexConditionsPasswordMet++;

                                      isPasswordCorrect =
                                          regexConditionsPasswordMet >= 3 &&
                                              passwordController.text.length >
                                                  9;

                                      setState(() {});
                                    },
                                    decoration: InputDecoration(
                                      labelText: '비밀번호 (10~16자, 영문+숫자/특수문자)',
                                      labelStyle: TextStyle(
                                        color: Color.fromRGBO(133, 135, 140, 1),
                                        fontSize: screenHeight * 0.025,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: isPasswordCorrect
                                              ? Color(0xFF1BFF92)
                                              : Colors.white,
                                        ),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
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
                                      fontSize: screenHeight * 0.025,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            passwordController.text.isNotEmpty &&
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
                                passwordController.text != ""
                                    ? isPasswordCorrect
                                        ? null
                                        : Icons.error
                                    : Icons.error,
                                color: passwordController.text != ""
                                    ? isPasswordCorrect
                                        ? Color(0xFF1BFF92)
                                        : Color(0xFFEB5757)
                                    : Color(0xFFEB5757),
                              ),
                              SizedBox(width: 8.0),
                              Text(
                                textScaleFactor: 0.8,
                                passwordController.text != ""
                                    ? isPasswordCorrect
                                        ? ''
                                        : '비밀번호 생성 규칙에 맞게 다시 입력해주세요.'
                                    : "비밀번호를 입력해주세요.",
                                style: TextStyle(
                                  color: passwordController.text != ""
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
                    ),
                  ),
                  Container(
                    width: screenWidth,
                    child: Column(
                      children: [
                        Row(
                          children: [
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
                                    maxLength: 16,
                                    controller: passwordRepeatController,
                                    obscureText: true,
                                    onChanged: (value) {
                                      isPasswordRepeatCorrect =
                                          passwordController.text.isNotEmpty &&
                                              passwordRepeatController.text ==
                                                  passwordController.text;

                                      setState(() {});
                                    },
                                    decoration: InputDecoration(
                                      labelText: '비밀번호 확인',
                                      labelStyle: TextStyle(
                                        fontFamily: 'Pretendart',
                                        color: Color.fromRGBO(133, 135, 140, 1),
                                        fontSize: screenHeight * 0.025,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: isPasswordRepeatCorrect
                                              ? Color(0xFF1BFF92)
                                              : Colors.white,
                                        ),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: isPasswordRepeatCorrect
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
                            passwordRepeatController.text.isNotEmpty &&
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
                                passwordRepeatController.text != ""
                                    ? isPasswordRepeatCorrect
                                        ? null
                                        : Icons.error
                                    : Icons.error,
                                color: passwordRepeatController.text != ""
                                    ? isPasswordRepeatCorrect
                                        ? Color(0xFF1BFF92)
                                        : Color(0xFFEB5757)
                                    : Color(0xFFEB5757),
                              ),
                              SizedBox(width: 8.0),
                              Text(
                                textScaleFactor: 0.8,
                                passwordRepeatController.text != ""
                                    ? isPasswordRepeatCorrect
                                        ? ''
                                        : '비밀번호가 일치하지 않습니다.'
                                    : "비밀번호를 입력해주세요.",
                                style: TextStyle(
                                  color: passwordRepeatController.text != ""
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
                            data: const MediaQueryData(textScaleFactor: 0.85),
                            child: TextField(
                              keyboardType: TextInputType.name,
                              controller: nameController,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z가-힣ㄱ-ㅎ]+'),
                                ),
                              ],
                              decoration: InputDecoration(
                                labelText: '이름',
                                labelStyle: TextStyle(
                                  fontFamily: 'Pretendart',
                                  color: Color.fromRGBO(133, 135, 140, 1),
                                  fontSize: screenHeight * 0.025,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Pretendart',
                                fontSize: screenHeight * 0.025,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
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
                              data: const MediaQueryData(textScaleFactor: 0.85),
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
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
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
                              data: const MediaQueryData(textScaleFactor: 0.85),
                              child: TextField(
                                controller: phoneNumberController,
                                keyboardType: TextInputType.phone,
                                maxLength: 12,
                                decoration: InputDecoration(
                                  labelText: '휴대폰 번호(숫자만 입력)',
                                  labelStyle: TextStyle(
                                    fontFamily: 'Pretendart',
                                    color: Color.fromRGBO(133, 135, 140, 1),
                                    fontSize: screenHeight * 0.025,
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
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
                  SizedBox(height: screenHeight * 0.03),
                  Row(
                    children: [
                      Expanded(
                        child: MediaQuery(
                          data: const MediaQueryData(textScaleFactor: 0.85),
                          child: TextField(
                            controller: dobController,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: '생년월일',
                              labelStyle: TextStyle(
                                color: Color.fromRGBO(133, 135, 140, 1),
                                fontSize: screenHeight * 0.025,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
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
                      IconButton(
                        icon: Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                        ),
                        onPressed: () => _selectDate(context),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Theme(
                        data: ThemeData(
                          unselectedWidgetColor:
                              genderValue == 0 ? Colors.white : Colors.grey,
                        ),
                        child: Radio(
                          value: 0,
                          groupValue: genderValue,
                          focusColor:
                              genderValue == 0 ? Colors.white : Colors.grey,
                          activeColor:
                              genderValue == 0 ? Colors.white : Colors.grey,
                          onChanged: (value) {
                            setState(() {
                              genderValue = value!;
                            });
                          },
                        ),
                      ),
                      Text(
                        textScaleFactor: 0.8,
                        '남자',
                        style: TextStyle(
                          fontFamily: 'Pretendart',
                          fontSize: screenHeight * 0.020,
                          color: genderValue == 0 ? Colors.white : Colors.grey,
                        ),
                      ),
                      SizedBox(width: 20),
                      Theme(
                        data: ThemeData(
                          unselectedWidgetColor:
                              genderValue == 1 ? Colors.white : Colors.grey,
                        ),
                        child: Radio(
                          value: 1,
                          groupValue: genderValue,
                          focusColor:
                              genderValue == 1 ? Colors.white : Colors.grey,
                          activeColor:
                              genderValue == 1 ? Colors.white : Colors.grey,
                          onChanged: (value) {
                            setState(() {
                              genderValue = value!;
                            });
                          },
                        ),
                      ),
                      Text(
                        textScaleFactor: 0.8,
                        '여자',
                        style: TextStyle(
                          fontFamily: 'Pretendart',
                          fontSize: screenHeight * 0.020,
                          color: genderValue == 1 ? Colors.white : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
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
                                data:
                                    const MediaQueryData(textScaleFactor: 0.85),
                                child: TextField(
                                  maxLength: 50,
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: (value) {
                                    verificationStart = false;
                                    final regex = RegExp(
                                        r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
                                    if (regex.hasMatch(value)) {
                                      isEmailCorrect = true;
                                    } else {
                                      isEmailCorrect = false;
                                    }
                                    isEmailTaken =
                                        email!.contains(value) ? true : false;

                                    setState(() {});
                                  },
                                  decoration: InputDecoration(
                                    labelText: '이메일',
                                    labelStyle: TextStyle(
                                      fontFamily: 'Pretendart',
                                      color: Color.fromRGBO(133, 135, 140, 1),
                                      fontSize: screenHeight * 0.025,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: isEmailCorrect && !isEmailTaken
                                            ? Color(0xFF1BFF92)
                                            : Colors.white,
                                      ),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: isEmailCorrect && !isEmailTaken
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
                          isEmailCorrect && !isEmailTaken
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
                      isLoadingID
                          ? SizedBox(
                              height: screenHeight * 0.01,
                              width: screenHeight * 0.01,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Icon(
                                    emailController.text != "" &&
                                            emailController.text.length > 5
                                        ? !isEmailTaken && isEmailCorrect
                                            ? Icons.check_circle
                                            : Icons.error
                                        : Icons.error,
                                    color: emailController.text.isEmpty ||
                                            emailController.text.length < 6
                                        ? Color(0xFFEB5757)
                                        : !isEmailTaken && isEmailCorrect
                                            ? Color(0xFF1BFF92)
                                            : Color(0xFFEB5757),
                                  ),
                                  SizedBox(width: screenWidth * 0.01),
                                  Text(
                                    textScaleFactor: 0.8,
                                    emailController.text.isNotEmpty &&
                                            emailController.text.length > 5
                                        ? isEmailCorrect
                                            ? !isEmailTaken
                                                ? '사용가능한 이메일입니다.'
                                                : '이미 사용중인 이메일입니다.'
                                            : "이메일를 입력해주세요."
                                        : "이메일를 입력해주세요.",
                                    style: TextStyle(
                                      fontFamily: 'Pretendart',
                                      color: emailController.text.isEmpty ||
                                              emailController.text.length < 6
                                          ? Color(0xFFEB5757)
                                          : !isEmailTaken && isEmailCorrect
                                              ? Color(0xFF1BFF92)
                                              : Color(0xFFEB5757),
                                      fontSize: screenHeight * 0.018,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: MediaQuery(
                              data: const MediaQueryData(textScaleFactor: 0.85),
                              child: TextField(
                                controller: verificationCodeController,
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  isVerificationCorrect =
                                      value == verificationCode ? true : false;
                                  if (isVerificationCorrect) {
                                    stopCountdown();
                                  }
                                  setState(() {});
                                },
                                decoration: InputDecoration(
                                  labelText: '인증번호 입력',
                                  labelStyle: TextStyle(
                                    fontFamily: 'Pretendart',
                                    color: Color.fromRGBO(133, 135, 140, 1),
                                    fontSize: screenHeight * 0.025,
                                  ),
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
                                  fontSize: screenHeight * 0.025,
                                ),
                              ),
                            ),
                          ),
                          verificationStart
                              ? Text(
                                  textScaleFactor: 0.8,
                                  formatTime(remainingTime),
                                  style: TextStyle(
                                    fontFamily: 'Pretendart',
                                    color: Colors.white,
                                    fontSize: screenHeight * 0.025,
                                  ),
                                )
                              : Text(textScaleFactor: 0.8, ""),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
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
                              color: verificationCodeController.text.isEmpty
                                  ? null
                                  : isTimeRunOut
                                      ? Color(0xFFEB5757)
                                      : isVerificationCorrect
                                          ? Color(0xFF1BFF92)
                                          : Color(0xFFEB5757),
                            ),
                            SizedBox(width: 8.0),
                            Text(
                              textScaleFactor: 0.8,
                              verificationCodeController.text.isEmpty
                                  ? ""
                                  : isTimeRunOut
                                      ? '인증번호 입력 시간이 만료되었습니다. 재인증 해주세요.'
                                      : isVerificationCorrect
                                          ? '인증이 완료되었습니다.'
                                          : '인증번호가 일치하지 않습니다.',
                              style: TextStyle(
                                color: verificationCodeController.text.isEmpty
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
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          child: ElevatedButton(
                            onPressed: () {
                              if (emailController.text.isEmpty) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                    textScaleFactor: 0.8,
                                    '이메일 주소를 비워 둘 수 없습니다',
                                    style: TextStyle(
                                      fontSize: screenHeight * 0.02,
                                      fontFamily: 'Pretendart',
                                    ),
                                  ),
                                ));
                              } else {
                                if (!email!.contains(
                                    emailController.text.toString())) {
                                  getVerificationCode(context);
                                  remainingTime = 180;
                                  startCountdown();
                                } else {
                                  showFailedDialog(context, "이미 사용중인 이메일입니다.");
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF714AC6)),
                            child: Text(
                              textScaleFactor: 0.8,
                              '이메일 인증코드 전송',
                              style: TextStyle(
                                fontFamily: 'Pretendart',
                                fontSize: screenHeight * 0.02,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: screenWidth,
                    child: Row(
                      children: [
                        Expanded(
                          child: MediaQuery(
                            data: const MediaQueryData(textScaleFactor: 0.85),
                            child: TextField(
                              controller: addressController,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: '주소 검색',
                                labelStyle: TextStyle(
                                  fontFamily: 'Pretendart',
                                  color: Color.fromRGBO(133, 135, 140, 1),
                                  fontSize: screenHeight * 0.025,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Pretendart',
                                fontSize: screenHeight * 0.025,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => KpostalView(
                                  callback: (Kpostal result) {
                                    setState(
                                      () {
                                        addressController.text = result.address;
                                      },
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
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
                              controller: detailAddressController,
                              decoration: InputDecoration(
                                labelText: '상세주소',
                                labelStyle: TextStyle(
                                  fontFamily: 'Pretendart',
                                  color: Color.fromRGBO(133, 135, 140, 1),
                                  fontSize: screenHeight * 0.025,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Pretendart',
                                fontSize: screenHeight * 0.025,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
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
                              controller: productKeyController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: '제품 등록(제품키 입력)',
                                labelStyle: TextStyle(
                                  fontFamily: 'Pretendart',
                                  color: Color.fromRGBO(133, 135, 140, 1),
                                  fontSize: screenHeight * 0.025,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Pretendart',
                                fontSize: screenHeight * 0.025,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.08),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.4,
                        height: screenHeight * 0.07,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(129, 124, 154, 1),
                          ),
                          child: Text(
                            textScaleFactor: 0.8,
                            '취소',
                            style: TextStyle(
                                fontFamily: 'Pretendart',
                                fontSize: screenHeight * 0.02,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * 0.05,
                      ),
                      SizedBox(
                        width: screenWidth * 0.4,
                        height: screenHeight * 0.07,
                        child: ElevatedButton(
                          onPressed: () {
                            if (isVerificationCorrect &&
                                isPasswordCorrect &&
                                isPasswordRepeatCorrect &&
                                passwordController.text.toString() ==
                                    passwordRepeatController.text.toString() &&
                                isEmailCorrect &&
                                !isIdTaken &&
                                !email!.contains(
                                    emailController.text.toString()) &&
                                idController.text.length > 5 &&
                                nameController.text.isNotEmpty &&
                                phoneNumberController.text.isNotEmpty &&
                                countryCodeController.text.isNotEmpty &&
                                dobController.text.isNotEmpty &&
                                addressController.text.isNotEmpty &&
                                detailAddressController.text.isNotEmpty &&
                                productKeyController.text.isNotEmpty &&
                                genderValue != 2) {
                              register(context);
                            } else if (email!
                                .contains(emailController.text.toString())) {
                              showFailedDialog(context, "이미 사용중인 이메일 입니다.");
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                  textScaleFactor: 0.8,
                                  '등록 양식을 다시 확인해 주세요.',
                                  style: TextStyle(
                                    fontSize: screenHeight * 0.02,
                                    fontFamily: 'Pretendart',
                                  ),
                                ),
                              ));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF714AC6),
                          ),
                          child: Text(
                            textScaleFactor: 0.8,
                            '회원가입',
                            style: TextStyle(
                                fontFamily: 'Pretendart',
                                fontSize: screenHeight * 0.02,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * 0.03,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> showFailedDialog(BuildContext context, String message) async {
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

  Future<void> showSuccessDialog(BuildContext context, String custID) async {
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
                      '회원가입이 완료되었습니다.\n설문조사 항목으로 이동됩니다.',
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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PersonalInformation(
                            custID: custID,
                          ),
                        ),
                      );
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
}

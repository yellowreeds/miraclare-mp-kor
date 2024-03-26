import 'dart:async';

import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:kpostal/kpostal.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AccountEdit extends StatefulWidget {
  const AccountEdit({super.key});

  @override
  State<AccountEdit> createState() => _AccountEditState();
}

class _AccountEditState extends State<AccountEdit> {
  double screenWidth = 0;
  double screenHeight = 0;
  TextEditingController idController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordRepeatController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController countryCodeController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController verificationCodeController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController detailAddressController = TextEditingController();
  TextEditingController productKeyController = TextEditingController();
  late int? genderValue = null;
  String userPassword = "";
  bool isIdTaken = false;
  bool isPasswordCorrect = false;
  bool isPasswordRepeatCorrect = false;
  bool isEmailCorrect = false;
  bool isVerificationCorrect = false;
  bool verificationStart = false;
  bool isTimeRunOut = false;
  DateTime selectedDate = DateTime.now();
  Timer? countdownTimer;
  late int remainingTime;
  late SharedPreferences prefs;
  Map<String, dynamic> userData = {};
  late String username = "";
  int regexConditionsPasswordMet = 0;
  int regexConditionsPasswordVerifyMet = 0;

  @override
  void initState() {
    super.initState();
    // initiate screen height and width
    // initiate shared preferences
    // assign user's username
    // get user's profile information
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
      username = await prefs.getString('custUsername') ?? "";
      getProfileInfo(username);
    });
  }

  // get user's profile information from server
  Future<void> getProfileInfo(String custUsername) async {
    final String apiUrl =
        'http://3.21.156.190:3000/api/customers/getProfileInfo';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'cust_username': custUsername,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        userData = jsonResponse['data'];
        setState(() {
          idController.text = userData['cust_username'];
          nameController.text = userData['cust_name'];
          countryCodeController.text = userData['cust_phone_num'].split("-")[0];
          phoneNumberController.text = userData['cust_phone_num'].split("-")[1];
          dobController.text = userData['cust_dob'].split("T")[0];
          genderValue = userData['cust_gender'];
          emailController.text = userData['cust_email'];
          addressController.text = userData['cust_address'];
          detailAddressController.text = userData['cust_detail_address'];
        });
      } else if (response.statusCode == 404) {
        throw Exception('User not found');
      } else {
        throw Exception('Error fetching profile information');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  // update the user's profile in the server
  // password encryption using BCrypt library
  Future<void> update(BuildContext context) async {
    try {
      String password = "";
      if (passwordController.text.isNotEmpty) {
        password = BCrypt.hashpw(
          passwordController.text,
          BCrypt.gensalt(),
        );
      }

      final String apiUrl = 'http://3.21.156.190:3000/api/customers/update';
      final String fullPhoneNumber =
          countryCodeController.text + "-" + phoneNumberController.text;
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'cust_username': idController.text,
          'cust_password': password,
          'cust_password_original': passwordController.text,
          'cust_phone_num': fullPhoneNumber,
          'cust_address': addressController.text,
          'cust_detail_address': detailAddressController.text,
        },
      );

      if (response.statusCode == 200) {
        showSuccessDialog(context, '수정되었습니다.');
      } else if (response.statusCode == 403) {
        showWarningDialog(context, "새 비밀번호는 이전 비밀번호와 동일할 수\n없습니다.");
      } else if (response.statusCode == 404) {
        showWarningDialog(context, 'Customer not found');
        print("Error: Customer not found");
      } else {
        showWarningDialog(context, 'Error during registration');
        print("Error : ${response.body}");
      }
    } catch (error) {
      print('Error: $error');
      showSuccessDialog(
          context, 'Failed to update. Please check your network connection.');
    }
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
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
              child: Column(
                children: [
                  SizedBox(
                    height: screenHeight * 0.08,
                  ),
                  Center(
                    child: Container(
                      width: screenWidth * 0.5,
                      padding: EdgeInsets.all(5),
                      child: Text(
                        textScaleFactor: 0.8,
                        "회원정보 수정",
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
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFF9D9FA3),
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: MediaQuery(
                            data: const MediaQueryData(textScaleFactor: 0.85),
                            child: TextField(
                              controller: idController,
                              decoration: InputDecoration(
                                labelText: '아이디',
                                labelStyle: TextStyle(
                                  fontFamily: 'Pretendart',
                                  color: Color.fromRGBO(133, 135, 140, 1),
                                  fontSize: screenHeight * 0.02,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF9D9FA3),
                                  ),
                                ),
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF9D9FA3),
                                  ),
                                ),
                              ),
                              style: TextStyle(
                                fontFamily: 'Pretendart',
                                color: Colors.white,
                                fontSize: screenHeight * 0.025,
                              ),
                              enabled: false,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.warning,
                          color: Color(0xFF9D9FA3),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
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
                                  maxLength: 16,
                                  controller: passwordController,
                                  obscureText: true,
                                  onChanged: (value) {
                                    // set password regext to match requirements
                                    isPasswordRepeatCorrect =
                                        passwordController.text.toString() ==
                                            passwordRepeatController.text
                                                .toString();
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
                                        regexConditionsPasswordMet >= 3;

                                    setState(() {});
                                  },
                                  decoration: InputDecoration(
                                    labelText: '비밀번호 (10~16자, 영문+숫자/특수문자)',
                                    labelStyle: TextStyle(
                                      color: Color.fromRGBO(133, 135, 140, 1),
                                      fontSize: screenHeight * 0.02,
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
                            Expanded(
                              child: Text(
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
                                  fontSize: screenHeight * 0.02,
                                  fontFamily: 'Pretendart',
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
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
                                      fontSize: screenHeight * 0.02,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: passwordRepeatController
                                                .text.isEmpty
                                            ? Colors.white
                                            : passwordController.text ==
                                                    passwordRepeatController
                                                        .text
                                                ? Color(0xFF1BFF92)
                                                : Colors.white,
                                      ),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: passwordRepeatController
                                                .text.isEmpty
                                            ? Colors.white
                                            : passwordController.text ==
                                                    passwordRepeatController
                                                        .text
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
                                fontSize: screenHeight * 0.02,
                                fontFamily: 'Pretendart',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFF9D9FA3),
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: MediaQuery(
                            data: const MediaQueryData(textScaleFactor: 0.85),
                            child: TextField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: '이름',
                                labelStyle: TextStyle(
                                  fontFamily: 'Pretendart',
                                  color: Color.fromRGBO(133, 135, 140, 1),
                                  fontSize: screenHeight * 0.02,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF9D9FA3),
                                  ),
                                ),
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF9D9FA3),
                                  ),
                                ),
                              ),
                              style: TextStyle(
                                fontFamily: 'Pretendart',
                                color: Colors.white,
                                fontSize: screenHeight * 0.025,
                              ),
                              enabled: false,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.warning,
                          color: Color(0xFF9D9FA3),
                        )
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
                                    fontSize: screenHeight * 0.02,
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
                                maxLength: 15,
                                decoration: InputDecoration(
                                  labelText: '휴대폰 번호(숫자만 입력)',
                                  labelStyle: TextStyle(
                                    fontFamily: 'Pretendart',
                                    color: Color.fromRGBO(133, 135, 140, 1),
                                    fontSize: screenHeight * 0.02,
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
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFF9D9FA3),
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Row(
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
                                    fontSize: screenHeight * 0.02),
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
                                  fontSize: screenHeight * 0.025),
                            ),
                          ),
                        ),
                        Icon(
                          Icons.warning,
                          color: Color(0xFF9D9FA3),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFF9D9FA3),
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Theme(
                                data: ThemeData(
                                  unselectedWidgetColor: genderValue == 0
                                      ? Colors.white
                                      : Colors.grey,
                                ),
                                child: Radio(
                                  // male = 0, female = 1
                                  value: 0,
                                  groupValue: genderValue,
                                  focusColor: genderValue == 0
                                      ? Colors.white
                                      : Colors.grey,
                                  activeColor: genderValue == 0
                                      ? Colors.white
                                      : Colors.grey,
                                  onChanged: (value) {},
                                ),
                              ),
                              Text(
                                textScaleFactor: 0.8,
                                '남자',
                                style: TextStyle(
                                  fontFamily: 'Pretendart',
                                  fontSize: screenHeight * 0.020,
                                  color: genderValue == 0
                                      ? Colors.white
                                      : Colors.grey,
                                ),
                              ),
                              SizedBox(width: 20),
                              Theme(
                                data: ThemeData(
                                  unselectedWidgetColor: genderValue == 1
                                      ? Colors.white
                                      : Colors.grey,
                                ),
                                child: Radio(
                                  value: 1,
                                  groupValue: genderValue,
                                  focusColor: genderValue == 1
                                      ? Colors.white
                                      : Colors.grey,
                                  activeColor: genderValue == 1
                                      ? Colors.white
                                      : Colors.grey,
                                  onChanged: (value) {},
                                ),
                              ),
                              Text(
                                textScaleFactor: 0.8,
                                '여자',
                                style: TextStyle(
                                  fontFamily: 'Pretendart',
                                  fontSize: screenHeight * 0.020,
                                  color: genderValue == 1
                                      ? Colors.white
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.warning,
                          color: Color(0xFF9D9FA3),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
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
                            data: const MediaQueryData(textScaleFactor: 0.85),
                            child: TextField(
                              maxLength: 50,
                              controller: emailController,
                              readOnly: true,
                              onChanged: (value) {
                                // set regex for email
                                final regex = RegExp(
                                    r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
                                if (regex.hasMatch(value)) {
                                  isEmailCorrect = true;
                                } else {
                                  isEmailCorrect = false;
                                }
                                setState(() {});
                              },
                              decoration: InputDecoration(
                                labelText: '이메일',
                                labelStyle: TextStyle(
                                  fontFamily: 'Pretendart',
                                  color: Color(0xFF9D9FA3),
                                  fontSize: screenHeight * 0.02,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF9D9FA3),
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF9D9FA3),
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
                      Icon(
                        Icons.warning,
                        color: Color(0xFF9D9FA3),
                      )
                    ],
                  ),
                  Row(
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
                                  fontSize: screenHeight * 0.02),
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
                                fontSize: screenHeight * 0.025),
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
                              // use KPostal library to get address
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
                                    fontSize: screenHeight * 0.02),
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
                                  fontSize: screenHeight * 0.025),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Container(
                    width: screenWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: (screenWidth / 2) -
                              (screenWidth * 0.02) -
                              (screenWidth * 0.025 * 2),
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
                          width: screenWidth * 0.02,
                        ),
                        SizedBox(
                          width: (screenWidth / 2) -
                              (screenWidth * 0.02) -
                              (screenWidth * 0.025 * 2),
                          height: screenHeight * 0.07,
                          child: ElevatedButton(
                            onPressed: () {
                              if (passwordController.text ==
                                  passwordRepeatController.text) {
                                update(context);
                              } else {
                                showWarningDialog(context, "비밀번호가 일치하지 않습니다.");
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF714AC6),
                            ),
                            child: Text(
                              textScaleFactor: 0.8,
                              '저장',
                              style: TextStyle(
                                  fontFamily: 'Pretendart',
                                  fontSize: screenHeight * 0.02,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
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

  // show sucess dialog
  Future<void> showSuccessDialog(BuildContext context, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false, // prevent dialog from being dismissed
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
                      FocusScope.of(context).unfocus(); // Hide the keyboard
                      Navigator.of(context)
                          .pop(); // Return to the previous page
                      Navigator.of(context)
                          .pop(); // Return to the page before the previous page
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

  // show warning dialog
  Future<void> showWarningDialog(BuildContext context, String message) async {
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
        );
      },
    );
  }
}

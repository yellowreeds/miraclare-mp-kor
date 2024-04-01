import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:goodeeps2/widgets/dialog.dart';

class RegistrationServices {
  static Future<List<String>?> checkEmailExist(
      BuildContext context, double screenWidth, double screenHeight) async {
    final String apiUrl =
        'http://3.21.156.190:3000/api/customers/checkEmailExist';
    List<String>? email = [];
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as List<dynamic>;

        email =
            jsonResponse.map((data) => data['cust_email'].toString()).toList();
      } else {
        print("Error: ${response.body}");
        showFailedDialog(context, 'Error fetching data from the server',
            screenWidth, screenHeight);
      }
    } catch (error) {
      print('Error: $error');
      showFailedDialog(
          context,
          'Network error: Unable to connect to the server',
          screenWidth,
          screenHeight);
    }
    return email;
  }

  static Future<String?> getVerificationCode(BuildContext context, String email,
      double screenWidth, double screenHeight) async {
    String? verificationCode;
    final String apiUrl =
        'http://3.21.156.190:3000/api/customers/requestVerificationNumber';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {'cust_email': email},
      );

      if (response.statusCode != 500) {
        final jsonResponse = json.decode(response.body);
        verificationCode = jsonResponse.toString();
      } else {
        print("Error : ${response.body}");
      }
    } catch (error) {
      print('Error: $error');
      showFailedDialog(context, '서버에 연결할 수 없습니다. 네트워크 연결을 확인하십시오.', screenWidth,
          screenHeight);
    }
    return verificationCode;
  }

  static Future<List<String>?> checkIdExist(
      BuildContext context, double screenWidth, double screenHeight) async {
    final String apiUrl = 'http://3.21.156.190:3000/api/customers/checkIdExist';
    List<String>? username = [];
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as List<dynamic>;

        username = jsonResponse
            .map((data) => data['cust_username'].toString())
            .toList();
      } else {
        print("Error: ${response.body}");
        showFailedDialog(context, 'Error fetching data from the server',
            screenWidth, screenHeight);
      }
    } catch (error) {
      print('Error: $error');
      showFailedDialog(
          context,
          'Network error: Unable to connect to the server',
          screenWidth,
          screenHeight);
    }
    return username;
  }

  static Future<void> register(
      BuildContext context,
      String id,
      String password,
      String name,
      String dob,
      int genderValue,
      String email,
      String address,
      String detailAddress,
      String productKey,
      String phoneNumber,
      String countryCode,
      SharedPreferences prefs,
      double screenWidth,
      double screenHeight) async {
    try {
      String newPassword = BCrypt.hashpw(
        password,
        BCrypt.gensalt(),
      );

      final String apiUrl = 'http://3.21.156.190:3000/api/customers/register';
      if (phoneNumber.isNotEmpty && phoneNumber[0] == '0') {
        phoneNumber = phoneNumber.substring(1);
      }
      final String fullPhoneNumber = countryCode + "-" + phoneNumber;

      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'cust_username': id,
          'cust_password': newPassword,
          'cust_name': name,
          'cust_dob': dob,
          'cust_gender': genderValue.toString(),
          'cust_email': email,
          'cust_phone_num': fullPhoneNumber,
          'cust_address': address,
          'cust_detail_address': detailAddress,
          'cust_join_date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'prod_registration_key': productKey,
        },
      );

      if (response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        showDialogue(
            context, jsonResponse['cust_id'], screenWidth, screenHeight);
        prefs.setString('custName', name);
        prefs.setString('custUsername', id);
      } else if (response.statusCode == 409) {
        showFailedDialog(context, '이미 사용중인 아이디입니다.', screenWidth, screenHeight);
        print("Error : ${response.body}");
      } else {
        showFailedDialog(
            context, 'Internal Server Error', screenWidth, screenHeight);
      }
    } catch (error) {
      print('Error: $error');
      showFailedDialog(context, '서버에 연결할 수 없습니다. 네트워크 연결을 확인하십시오.', screenWidth,
          screenHeight);
    }
  }
}

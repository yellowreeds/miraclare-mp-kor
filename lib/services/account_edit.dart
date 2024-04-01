import 'dart:convert';

import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:goodeeps2/screens/account_edit_page.dart';
import 'package:goodeeps2/widgets/dialog.dart';

class AccountEditService {
  static Future<void> checkPassword(BuildContext context, String username,
      String password, double screenWidth, double screenHeight) async {
    try {
      final String apiUrl =
          'http://3.21.156.190:3000/api/customers/checkPassword';
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AccountEdit(),
            ));
      } else if (response.statusCode == 401) {
        print("response: ${response.body}");
        showDialogue(context, '비밀번호가 일치하지 않습니다.', screenWidth, screenHeight);
      } else {
        print("response: ${response.body}");
        showDialogue(
          context,
          '내부 서버 오류입니다. 다시 시도해 주십시오.',
          screenWidth,
          screenHeight,
        );
      }
    } catch (error) {
      // Handle the error here
      print('Error: $error');
      showDialogue(
        context,
        '서버에 연결할 수 없습니다. 네트워크 연결을 확인하십시오.',
        screenWidth,
        screenHeight,
      );
    }
  }

  static Future<void> update(
      BuildContext context,
      String password,
      String countryCode,
      String phoneNumber,
      String id,
      String address,
      String detailAddress,
      double screenWidth,
      double screenHeight) async {
    try {
      String newPassword = "";
      if (password.isNotEmpty) {
        password = BCrypt.hashpw(
          password,
          BCrypt.gensalt(),
        );
      }

      final String apiUrl = 'http://3.21.156.190:3000/api/customers/update';
      final String fullPhoneNumber = countryCode + "-" + phoneNumber;
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'cust_username': id,
          'cust_password': newPassword,
          'cust_password_original': password,
          'cust_phone_num': fullPhoneNumber,
          'cust_address': address,
          'cust_detail_address': detailAddress,
        },
      );

      if (response.statusCode == 200) {
        showDialogue(context, '수정되었습니다.', screenWidth, screenHeight);
      } else if (response.statusCode == 403) {
        showDialogue(context, "새 비밀번호는 이전 비밀번호와 동일할 수\n없습니다.", screenWidth,
            screenHeight);
      } else if (response.statusCode == 404) {
        showDialogue(context, 'Customer not found', screenWidth, screenHeight);
        print("Error: Customer not found");
      } else {
        showDialogue(
            context, 'Error during registration', screenWidth, screenHeight);
        print("Error : ${response.body}");
      }
    } catch (error) {
      print('Error: $error');
      showDialogue(
          context,
          'Failed to update. Please check your network connection.',
          screenWidth,
          screenHeight);
    }
  }

  Future<Map<String, dynamic>?> getProfileInfo(String custUsername) async {
    final String apiUrl =
        'http://3.21.156.190:3000/api/customers/getProfileInfo';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {'cust_username': custUsername},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['data'];
      } else if (response.statusCode == 404) {
        throw Exception('User not found');
      } else {
        throw Exception('Error fetching profile information');
      }
    } catch (error) {
      print('Error: $error');
      return null;
    }
  }
}

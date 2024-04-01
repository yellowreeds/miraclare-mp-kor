import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get_ip_address/get_ip_address.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:goodeeps2/main_page.dart';
import 'package:goodeeps2/widgets/dialog.dart';

class LoginServices {
  static Future<void> login(BuildContext context, String id, String password,
      SharedPreferences prefs, double screenWidth, double screenHeight) async {
    try {
      var ipAddress = IpAddress(type: RequestType.json);
      dynamic data = await ipAddress.getIpAddress();
      final String apiUrl = 'http://3.21.156.190:3000/api/customers/login';
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'username': id,
          'password': password,
          'ipAddress': data['ip'],
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        prefs.setString('custUsername', id);
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
        showDialogue(
            context, '아이디 또는 비밀번호가 일치하지 않습니다.', screenWidth, screenHeight);
      } else {
        showDialogue(
            context, '내부 서버 오류입니다.\n다시 시도해 주십시오.', screenWidth, screenHeight);
      }
    } catch (error) {
      // Handle the error here
      print('Error: $error');
      showDialogue(context, '서버에 연결할 수 없습니다. 네트워크 연결을 확인하십시오.', screenWidth,
          screenHeight);
    }
  }
}

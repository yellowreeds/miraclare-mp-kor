import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../widgets/alerts.dart';

class FindingID {
  Future<String?> searchID(BuildContext context, String phoneNumber,
      String countryCode, String email) async {
    String? jsonResponse;
    try {
      final String apiUrl = 'http://3.21.156.190:3000/api/customers/searchID';
      if (phoneNumber.isNotEmpty && phoneNumber[0] == '0') {
        phoneNumber = phoneNumber.substring(1);
      }
      final String fullPhoneNumber = countryCode + "-" + phoneNumber;

      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'cust_phone_num': fullPhoneNumber,
          'cust_email': email,
        },
      );
      if (response.statusCode == 200) {
        jsonResponse = json.decode(response.body)['message'];
      } else if (response.statusCode == 404) {
        GoodeepsSnackBar.show("오류", '이메일 또는 전화번호가 일치하지 않습니다.');
      } else {
        GoodeepsSnackBar.show("오류", '내부 서버 오류입니다. 다시 시도해 주십시오.');
      }
    } catch (error) {
      print('Error: $error');
      GoodeepsSnackBar.show("오류", '서버에 연결할 수 없습니다. 네트워크 연결을\n확인하십시오.');
    }
    return jsonResponse;
  }
}

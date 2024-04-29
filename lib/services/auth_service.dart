import 'dart:convert';

import 'package:get_ip_address/get_ip_address.dart';
import 'package:goodeeps2/models/base_response.dart';
import 'package:goodeeps2/models/verification_code_model.dart';
import 'package:goodeeps2/services/api_request.dart';
import 'package:goodeeps2/utils/shared_preferences_helper.dart';
import 'package:goodeeps2/widgets/goodeeps_alert.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/token_model.dart';

class AuthService {
  static Future verificationCode(String email, String password) async {
    RequestBody body = {
      BodyParam.email: email,
    };

    final response = await APIRequest.request<VerificationCodeModel>(
        method: HTTPMethod.post,
        path: APIPath.verificationCode,
        body: body,
        fromJsonT: (json) =>
            VerificationCodeModel.fromJson(json as  Map<String, dynamic>));
    if (response.result != null) {
      logger.i(response.result!.verificationCode);
      return;
    }
  }

  void signup() async {}

  // Future<BaseResponse<TokenModel>> login(String email, String password) async {
  //   RequestBody body = {BodyParam.email: email, BodyParam.password: password};
  //
  //   final response = await APIRequest.request<TokenModel>(
  //       method: HTTPMethod.post,
  //       path: APIPath.login,
  //       body: body,
  //       fromJsonT: (json) => TokenModel.fromJson(json as Map<String, dynamic>));
  //
  //   if (response.result != null) {
  //     await SharedPreferencesHelper.saveData(
  //         SharedPreferencesKey.accessToken, response.result!.accessToken);
  //     await SharedPreferencesHelper.saveData(
  //         SharedPreferencesKey.refreshToken, response.result!.refreshToken);
  //   }
  //   return response;
  // }

  Future<void> login(String id, String password) async {
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
      // loggerNoStack.i(response);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        loggerNoStack.i(jsonResponse);
        // prefs.setString('custUsername', id);
        // prefs.setString('custName', jsonResponse['message']);
      } else if (response.statusCode == 401) {
        GoodeepsDialog.showError("아이디 또는 비밀번호가 일치하지 않습니다.");

        // GoodeepsSnackBar.show("오류", "아이디 또는 비밀번호가 일치하지 않습니다.");
        // showDialogue(
        //     context, '아이디 또는 비밀번호가 일치하지 않습니다.', screenWidth, screenHeight);
      } else {
        // GoodeepsSnackBar.show("오류", '내부 서버 오류입니다.\n다시 시도해 주십시오.');
        // showDialogue(
        //     context, '내부 서버 오류입니다.\n다시 시도해 주십시오.', screenWidth, screenHeight);
      }
    } catch (error) {
      // Handle the error here
      print('Error: $error');
      // GoodeepsSnackBar.show("오류", '서버에 연결할 수 없습니다. 네트워크 연결을 확인하십시오.');
      // showDialogue(context, '서버에 연결할 수 없습니다. 네트워크 연결을 확인하십시오.', screenWidth,
      //     screenHeight);
    }
  }
}

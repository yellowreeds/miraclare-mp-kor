import 'dart:convert';

import 'package:get_ip_address/get_ip_address.dart';
import 'package:goodeeps2/models/base_response.dart';
import 'package:goodeeps2/models/signup_request_model.dart';
import 'package:goodeeps2/models/user_model.dart';
import 'package:goodeeps2/models/verification_code_model.dart';
import 'package:goodeeps2/services/api_request.dart';
import 'package:goodeeps2/utils/shared_preferences_helper.dart';
import 'package:goodeeps2/widgets/alerts.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/token_model.dart';

class AuthService {
  Future<void> login(String email, String password) async {
    RequestBody body = {
      BodyParam.email: email,
      BodyParam.password: password,
    };

    final item = await APIRequest.request<TokenModel>(
        method: HTTPMethod.post,
        path: APIPath.login,
        body: body,
        fromJsonT: (json) => TokenModel.fromJson(json as Map<String, dynamic>));
    if (item != null) {
      SharedPreferencesHelper.saveData(
          SharedPreferencesKey.accessToken, item.accessToken);
      SharedPreferencesHelper.saveData(
          SharedPreferencesKey.refreshToken, item.refreshToken);
      SharedPreferencesHelper.saveData(
          SharedPreferencesKey.userId, item.extractSubFromJWT());
    }
  }

  Future<VerificationCodeModel?> verificationCode(String email) async {
    RequestBody body = {
      BodyParam.email: email,
    };

    final item = await APIRequest.request<VerificationCodeModel>(
        method: HTTPMethod.post,
        path: APIPath.verificationCode,
        body: body,
        fromJsonT: (json) =>
            VerificationCodeModel.fromJson(json as Map<String, dynamic>));
    if (item != null) {
      logger.i(item.verificationCode);
      return item;
    }
    return null;
  }

  Future<TokenModel?> signup(
      String email,
      String password,
      String name,
      String phone,
      String birthDate,
      String gender,
      String address,
      String detailAddress) async {
    RequestBody body = {
      BodyParam.email: email,
      BodyParam.password: password,
      BodyParam.name: name,
      BodyParam.phone: phone,
      BodyParam.birthDate: birthDate,
      BodyParam.gender: gender,
      BodyParam.address: address,
      BodyParam.detailAddress: detailAddress,
    };

    final item = await APIRequest.request<TokenModel>(
        method: HTTPMethod.post,
        path: APIPath.signup,
        body: body,
        fromJsonT: (json) => TokenModel.fromJson(json as Map<String, dynamic>));
    if (item != null) {
      SharedPreferencesHelper.saveData(
          SharedPreferencesKey.accessToken, item.accessToken);
      SharedPreferencesHelper.saveData(
          SharedPreferencesKey.refreshToken, item.refreshToken);
      SharedPreferencesHelper.saveData(
          SharedPreferencesKey.userId, item.extractSubFromJWT());
    }
    return null;
  }

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

// Future login(String id, String password) async {
//   try {
//     var ipAddress = IpAddress(type: RequestType.json);
//     dynamic data = await ipAddress.getIpAddress();
//     final String apiUrl = 'http://3.21.156.190:3000/api/customers/login';
//     final response = await http.post(
//       Uri.parse(apiUrl),
//       body: {
//         'username': id,
//         'password': password,
//         'ipAddress': data['ip'],
//       },
//     );
//     // loggerNoStack.i(response);
//
//     if (response.statusCode == 200) {
//       final jsonResponse = json.decode(response.body);
//       loggerNoStack.i(jsonResponse);
//       // prefs.setString('custUsername', id);
//       // prefs.setString('custName', jsonResponse['message']);
//     } else if (response.statusCode == 401) {
//       GoodeepsDialog.showError("아이디 또는 비밀번호가 일치하지 않습니다.");
//
//       // GoodeepsSnackBar.show("오류", "아이디 또는 비밀번호가 일치하지 않습니다.");
//       // showDialogue(
//       //     context, '아이디 또는 비밀번호가 일치하지 않습니다.', screenWidth, screenHeight);
//     } else {
//       // GoodeepsSnackBar.show("오류", '내부 서버 오류입니다.\n다시 시도해 주십시오.');
//       // showDialogue(
//       //     context, '내부 서버 오류입니다.\n다시 시도해 주십시오.', screenWidth, screenHeight);
//     }
//   } catch (error) {
//     // Handle the error here
//     print('Error: $error');
//     // GoodeepsSnackBar.show("오류", '서버에 연결할 수 없습니다. 네트워크 연결을 확인하십시오.');
//     // showDialogue(context, '서버에 연결할 수 없습니다. 네트워크 연결을 확인하십시오.', screenWidth,
//     //     screenHeight);
//   }
// }
}

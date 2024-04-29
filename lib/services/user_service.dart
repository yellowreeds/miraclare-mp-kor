import 'package:goodeeps2/pages/auth/login_page.dart';
import 'package:goodeeps2/services/api_request.dart';
import 'package:goodeeps2/utils/shared_preferences_helper.dart';

import '../models/token_model.dart';

class UserService {

  static Future signup() async {




  }

  static Future login(String email,String password) async {

    RequestBody body = {
      BodyParam.email: email,
      BodyParam.password: password
    };

    final response = await APIRequest.request<TokenModel>(
        method: HTTPMethod.post,
        path: APIPath.login,
        body: body,
        fromJsonT: (json) => TokenModel.fromJson(json as Map<String, dynamic>));

    if (response.result != null) {
      return;
    }

  }

}
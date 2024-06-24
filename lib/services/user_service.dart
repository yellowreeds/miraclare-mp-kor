import 'package:goodeeps2/constants.dart';
import 'package:goodeeps2/models/user_model.dart';
import 'package:goodeeps2/pages/auth/login_page.dart';
import 'package:goodeeps2/services/api_request.dart';
import 'package:goodeeps2/utils/shared_preferences_helper.dart';

import '../models/token_model.dart';

class UserService {
  Future<UserModel?> getMe() async {
    final item = await APIRequest.request<UserModel>(
        method: HTTPMethod.get,
        path: APIPath.me,
        headers:[HTTPHeader.authorization],
        fromJsonT: (json) => UserModel.fromJson(json as Map<String, dynamic>));
    if (item != null) {
      return item;
    }
    return null;
  }
}

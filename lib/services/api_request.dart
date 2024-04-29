import 'dart:io';
import 'dart:convert';
import 'package:goodeeps2/constants.dart';
import "package:goodeeps2/models/user.dart";
import 'package:goodeeps2/models/base_response.dart';
import 'package:goodeeps2/models/token_model.dart';
import 'package:goodeeps2/pages/auth/login_page.dart';
import 'package:goodeeps2/utils/shared_preferences_helper.dart';

typedef RequestBody = Map<BodyParam, dynamic>;

enum APIPath {
  /*Auth*/
  refreshAccessToken("/auth/access-token/refresh"),
  login("/auth/login"),
  signup("/auth/signup"),
  verificationCode("/auth/verification-code"),

  /*User*/
  user("/users");


  final String rawValue;

  const APIPath(this.rawValue);
}

enum BodyParam {
  accessToken("access_token"),
  refreshToken("refresh_token"),
  email("email"),
  password("password"),
  name("name"),
  age("age"),
  address("address"),
  detailAddress("detail_address");

  final String rawValue;

  const BodyParam(this.rawValue);
}

enum QueryParam {
  page("page"),
  offset("offset");

  final String rawValue;

  const QueryParam(this.rawValue);
}

enum HTTPHeader {
  applicationJson,
  authorization;
}

extension HTTPHeaderExtension on HTTPHeader {
  Future<Map<String, String>> value() async {
    switch (this) {
      case HTTPHeader.applicationJson:
        return {HttpHeaders.contentTypeHeader: "application/json"};
      case HTTPHeader.authorization:
        final token = await SharedPreferencesHelper.fetchData(
            SharedPreferencesKey.accessToken) as String?;
        return {HttpHeaders.authorizationHeader: "Bearer $token"};
      default:
        throw Exception('Unsupported HTTPHeader type');
    }
  }
}

enum HTTPMethod { get, post, patch, put, delete }

class APIRequest {
  static Future<BaseResponse<T>> request<T>(
      {List<HTTPHeader> headers = const [],
      HTTPMethod method = HTTPMethod.get,
      required APIPath path,
      RequestBody body = const {},
      required T Function(Object?) fromJsonT}) async {
    final httpClient = HttpClient();
    HttpClientRequest? request;

    try {
      final url = Uri.parse(domain + path.rawValue);
      switch (method) {
        case HTTPMethod.get:
          request = await httpClient.getUrl(url);
          break;

        case HTTPMethod.post:
          request = await httpClient.postUrl(url);
          request.add(APIRequest.encodeBody(body));
          break;

        case HTTPMethod.patch:
          request = await httpClient.patchUrl(url);
          request.add(APIRequest.encodeBody(body));
          break;
        case HTTPMethod.put:
          request = await httpClient.putUrl(url);
          request.add(APIRequest.encodeBody(body));
          break;

        case HTTPMethod.delete:
          request = await httpClient.deleteUrl(url);
          request.add(APIRequest.encodeBody(body));
          break;
      }

      /// set default header [content-type : application/json]
      request.headers.set(HttpHeaders.contentTypeHeader, "application/json");

      // set headers
      if (headers.isNotEmpty) {
        await Future.forEach<HTTPHeader>(headers, (header) async {
          final headerValue = await header.value();
          headerValue.forEach((key, value) {
            request?.headers.set(key, value);
          });
        });
      }

      final response = await request.close();
      if (response.statusCode == HttpStatus.unauthorized) {}

      final jsonString = await response.transform(utf8.decoder).join();
      final jsonData = jsonDecode(jsonString);

      final baseResponse = BaseResponse<T>.fromJson(
          jsonData as Map<String, dynamic>, fromJsonT); // 수정된 부분
      loggerNoStack.i(baseResponse);
      return baseResponse;
    } catch (exception) {
      final errorResponse = BaseResponse<T>(
        status: -1, // 오류 상태 코드를 표현할 임의의 값
        message: 'Failed to fetch data: $exception', // 오류 메시지
        result: null, // 실패 시 result는 null
        time: DateTime.now().toIso8601String(), // 현재 시간
      );
      loggerNoStack.w(errorResponse);
      return errorResponse;
    } finally {
      httpClient.close();
    }
  }

  static requestRefreshAccessToken() async {
    // fetch tokens
    final accessToken = await SharedPreferencesHelper.fetchData(
        SharedPreferencesKey.accessToken) as String?;
    final refreshToken = await SharedPreferencesHelper.fetchData(
        SharedPreferencesKey.refreshToken) as String?;

    RequestBody body = {
      BodyParam.accessToken: accessToken,
      BodyParam.refreshToken: refreshToken
    };

    final response = await APIRequest.request<TokenModel>(
        method: HTTPMethod.post,
        path: APIPath.refreshAccessToken,
        body: body,
        fromJsonT: (json) => TokenModel.fromJson(json as Map<String, dynamic>));

    if (response.result != null) {
      return;
    }

    TokenModel tokenModel = response.result!;
    // save tokens
    SharedPreferencesHelper.saveData(
        SharedPreferencesKey.accessToken, tokenModel.accessToken);
    SharedPreferencesHelper.saveData(
        SharedPreferencesKey.refreshToken, tokenModel.refreshToken);
  }

  static List<int> encodeBody(RequestBody requestBody) {
    final Map<String, dynamic> body = {};
    requestBody.forEach((key, value) {
      body[key.rawValue] = value;
    });

    final encodedBody = utf8.encode(json.encode(body));
    return encodedBody;
  }
}

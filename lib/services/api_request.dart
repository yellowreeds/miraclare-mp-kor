import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:goodeeps2/constants.dart';
import 'package:goodeeps2/models/base_response.dart';
import 'package:goodeeps2/models/token_model.dart';
import 'package:goodeeps2/routes.dart';
import 'package:goodeeps2/utils/network_exception.dart';
import 'package:goodeeps2/utils/shared_preferences_helper.dart';
import 'package:goodeeps2/widgets/alerts.dart';

typedef RequestBody = Map<BodyParam, dynamic>;

enum APIPath {
  /*Auth*/
  refreshTokens("/auth/refresh-tokens"),
  login("/auth/login"),
  signup("/auth/signup"),
  verificationCode("/auth/verification-code"),

  /*SleepAnalysis*/
  sleepAnalysis("/sleep-analysis/files"),

  /*User*/
  users("/users"),
  me("/users/me"),

  /*Evaluation*/
  alignProcess("/align-process"),

  /*Evaluation*/
  evaluation("/evaluation");

  final String rawValue;

  const APIPath(this.rawValue);
}

enum BodyParam {
  accessToken("access_token"),
  refreshToken("refresh_token"),
  id("id"),
  email("email"),
  password("password"),
  name("name"),
  phone("phone"),
  age("age"),
  address("address"),
  birthDate("birth_date"),
  gender("gender"),
  detailAddress("detail_address"),
  painIntensity("pain_intensity"),
  vibrationItensity("vibration_intensity"),
  vibrationFrequency("vibration_frequency"),
  userId("user_id"),
  meanRaw("mean_raw"),
  stdRaw("std_raw"),
  meanEmg("mean_raw"),
  max("max"),
  min("min"),
  stdEmg("std_emg"),
  maa("maa");

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
  authorization;

  // final String key;
  // const HTTPHeader(this.rawValue);
}

extension HTTPHeaderExtension on HTTPHeader {
  Future<Map<String, String>> value() async {
    switch (this) {
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
  static Future<void> setHeader(
      HttpClientRequest request, List<HTTPHeader> headers) async {
    request.headers.contentType = ContentType.json;

    if (headers.isNotEmpty) {
      await Future.forEach<HTTPHeader>(headers, (header) async {
        final headerValue = await header.value();
        headerValue.forEach((key, value) {
          request.headers.add(key, value);
        });
      });
    }
  }

  static Future<T?> request<T>(
      {List<HTTPHeader> headers = const [],
      HTTPMethod method = HTTPMethod.get,
      required APIPath path,
      RequestBody body = const {},
      required T Function(Object?) fromJsonT}) async {
    final httpClient = HttpClient();
    HttpClientRequest request;

    try {
      final url = Uri.parse(domain + path.rawValue);
      logger.i(url);
      switch (method) {
        case HTTPMethod.get:
          request = await httpClient.getUrl(url);
          await APIRequest.setHeader(request, headers);
          break;

        case HTTPMethod.post:
          request = await httpClient.postUrl(url);
          await APIRequest.setHeader(request, headers);
          logger.i(body);
          request.add(APIRequest.encodeBody(body));
          break;

        case HTTPMethod.patch:
          request = await httpClient.patchUrl(url);
          await APIRequest.setHeader(request, headers);
          logger.i(body);
          request.add(APIRequest.encodeBody(body));

          break;
        case HTTPMethod.put:
          request = await httpClient.putUrl(url);
          await APIRequest.setHeader(request, headers);
          logger.i(body);
          request.add(APIRequest.encodeBody(body));
          break;

        case HTTPMethod.delete:
          request = await httpClient.deleteUrl(url);
          await APIRequest.setHeader(request, headers);
          request.add(APIRequest.encodeBody(body));
          break;
      }

      final response = await request.close();

      if (response.statusCode == HttpStatus.unauthorized) {
        // 토큰 리프레시 시도
        final success = await requestRefreshTokens();
        if (success) {
          // 리프레시 성공 시 이전 요청 다시 시도
          final item = await APIRequest.request<T>(
              method: method,
              path: path,
              headers: [HTTPHeader.authorization],
              body: body,
              fromJsonT: fromJsonT);
          return item;
        } else {
          throw Exception('Unauthorized');
        }
      }

      final jsonString = await response.transform(utf8.decoder).join();
      final jsonData = jsonDecode(jsonString);
      logger.i(jsonData);
      final baseResponse = BaseResponse<T>.fromJson(
          jsonData as Map<String, dynamic>, fromJsonT); // 수정된 부분
      if (baseResponse.status < 200 || baseResponse.status >= 300) {
        throw NetworkException(baseResponse.status, baseResponse.message!);
      }
      return baseResponse.result;
    } catch (exception) {
      final errorResponse = BaseResponse<T>(
        status: -1, // 오류 상태 코드를 표현할 임의의 값
        message: 'Failed to fetch data: $exception', // 오류 메시지
        result: null, // 실패 시 result는 null
        time: DateTime.now().toIso8601String(), // 현재 시간
      );
      logger.e(exception);
      GoodeepsSnackBar.showError(exception.toString());
      return null;
    } finally {
      httpClient.close();
    }
  }

  static Future<T?> uploadFile<T>(
      {required APIPath path,
      required File file,
      required T Function(Object?) fromJsonT}) async {
    final httpClient = HttpClient();
    try {
      final url = Uri.parse(domain + path.rawValue);
      final request = await httpClient.postUrl(url);
      final headers = [HTTPHeader.authorization];
      await APIRequest.setHeader(request, headers);

      final boundary = '----WebKitFormBoundary7MA4YWxkTrZu0gW';
      request.headers.set(HttpHeaders.contentTypeHeader,
          'multipart/form-data; boundary=$boundary');

      final fileBytes = await file.readAsBytes();
      final fileName = file.path.split('/').last;

      // Multipart body
      final multipartBody = [
        '--$boundary\r\n',
        'Content-Disposition: form-data; name="file"; filename="$fileName"\r\n',
        'Content-Type: application/octet-stream\r\n\r\n',
        fileBytes,
        '\r\n--$boundary--\r\n',
      ];

      // 요청에 바이트 데이터를 추가합니다.
      multipartBody.forEach((element) {
        if (element is String) {
          request.add(utf8.encode(element));
        } else if (element is List<int>) {
          request.add(element);
        }
      });

      final response = await request.close();
      if (response.statusCode == HttpStatus.unauthorized) {
        throw Exception('Unauthorized');
      }

      final jsonString = await response.transform(utf8.decoder).join();
      final jsonData = jsonDecode(jsonString);
      logger.i(jsonData);
      final baseResponse = BaseResponse<T>.fromJson(
          jsonData as Map<String, dynamic>, fromJsonT); // 수정된 부분
      if (baseResponse.status < 200 || baseResponse.status >= 300) {
        throw NetworkException(baseResponse.status, baseResponse.message!);
      }

      return baseResponse.result;
    } catch (exception) {
      final errorResponse = BaseResponse<T>(
        status: -1, // 오류 상태 코드를 표현할 임의의 값
        message: 'Failed to fetch data: $exception', // 오류 메시지
        result: null, // 실패 시 result는 null
        time: DateTime.now().toIso8601String(), // 현재 시간
      );
      logger.e(exception);
      GoodeepsSnackBar.showError(exception.toString());
      return null;
    } finally {
      httpClient.close();
    }
    return null;
  }

  static Future<bool> requestRefreshTokens() async {
    // fetch tokens
    final accessToken = await SharedPreferencesHelper.fetchData(
        SharedPreferencesKey.accessToken) as String?;
    final refreshToken = await SharedPreferencesHelper.fetchData(
        SharedPreferencesKey.refreshToken) as String?;

    RequestBody body = {
      BodyParam.accessToken: accessToken,
      BodyParam.refreshToken: refreshToken
    };

    final tokenModel = await APIRequest.request<TokenModel>(
        method: HTTPMethod.post,
        path: APIPath.refreshTokens,
        body: body,
        fromJsonT: (json) => TokenModel.fromJson(json as Map<String, dynamic>));

    if (tokenModel != null) {
      await SharedPreferencesHelper.saveData(
          SharedPreferencesKey.accessToken, tokenModel.accessToken);
      await SharedPreferencesHelper.saveData(
          SharedPreferencesKey.refreshToken, tokenModel.refreshToken);
      return true;
    }
    Get.offAllNamed(PageRouter.login.rawValue);
    return false;
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

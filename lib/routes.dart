import 'package:get/get.dart';
import 'package:goodeeps2/bindings.dart';
import 'package:goodeeps2/pages/auth/login_page.dart';
import 'package:goodeeps2/pages/auth/signup_page.dart';
import 'package:goodeeps2/pages/auth/terms_agreement_page.dart';
import 'package:goodeeps2/pages/auth/find_id_page.dart';
import 'package:goodeeps2/pages/evaluation/evaluation_page.dart';
import 'package:goodeeps2/pages/home/bluetooth_connection_page.dart';
import 'package:goodeeps2/pages/info/info_page.dart';
import 'package:goodeeps2/pages/main_navigation_page.dart';
import 'package:goodeeps2/pages/setting/setting_page.dart';

import 'pages/auth/find_password_page.dart';
import 'pages/home/home_page.dart';

enum PageRouter {
  login("/login"),
  findId("/find-id"),
  findPassword("/find-password"),
  termsAgreement("/terms-agreement"),
  signup("/signup"),
  home("/home"),
  mainNavigation("/main-navigation"),
  evaluation("/evaluation"),
  setting("/setting"),
  info("/info"),
  bluetoothConnection("/bluetooth-connection");

  final String rawValue;

  const PageRouter(this.rawValue);
}

class AppRoutes {
  static final routes = [
    GetPage(
      name: PageRouter.login.rawValue,
      page: () => LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: PageRouter.findId.rawValue,
      page: () => FindIdPage(),
      binding: FindIdBinding(),
    ),
    GetPage(
      name: PageRouter.findPassword.rawValue,
      page: () => FindPasswordPage(),
      binding: FindPasswordBinding(),
    ),
    GetPage(
      name: PageRouter.termsAgreement.rawValue,
      page: () => TermsAgreementPage(),
      binding: TermsAgreementBinding(),
    ),
    GetPage(
      name: PageRouter.signup.rawValue,
      page: () => SignupPage(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: PageRouter.mainNavigation.rawValue,
      page: () => MainNavigationPage(),
      binding: MainNavigationBinding(),
    ),
    GetPage(
      name: PageRouter.home.rawValue,
      page: () => HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: PageRouter.evaluation.rawValue,
      page: () => EvaluationPage(),
      binding: EvaluationBinding(),
    ),
    GetPage(
      name: PageRouter.setting.rawValue,
      page: () => SettingPage(),
      binding: SettingBinding(),
    ),
    GetPage(
      name: PageRouter.info.rawValue,
      page: () => InfoPage(),
      binding: InfoBinding(),
    ),
    GetPage(
      name: PageRouter.bluetoothConnection.rawValue,
      page: () => BluetoothConnectionPage(),
      binding: BluetoothConnectionBinding(),
    ),
  ];
}

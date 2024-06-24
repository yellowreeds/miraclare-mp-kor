import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/pages/setting/camera_page.dart';
import 'package:goodeeps2/routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


void main() {
  FlutterBluePlus.setLogLevel(LogLevel.none, color:false);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // initialRoute: PageRouter.mainNavigation.rawValue,
      // initialRoute: PageRouter.intro.rawValue,
      home: CameraScreen(),
      localizationsDelegates: [GlobalMaterialLocalizations.delegate],
      supportedLocales: [const Locale('en'), const Locale('kr')],
      getPages: AppRoutes.routes,
    );
    // return MaterialApp(
    //   localizationsDelegates: [GlobalMaterialLocalizations.delegate],
    //   supportedLocales: [const Locale('en'), const Locale('kr')],
    //   title: 'GooDeeps',
    //   theme: ThemeData(
    //     primarySwatch: Colors.blue,
    //   ),
    //   home: const IntroPage(),
    //   // home: const MyHomePage(title: 'GooDeeps'),
    //   debugShowCheckedModeBanner: false,
    // );
  }
}

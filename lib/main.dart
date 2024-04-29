import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/pages/auth/login_page.dart';
import 'package:goodeeps2/pages/intro_page.dart';
import 'package:goodeeps2/routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: PageRouter.mainNavigation.rawValue,
      // initialRoute: PageRouter.bleConnection.rawValue,
      // home: HomePage(),
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

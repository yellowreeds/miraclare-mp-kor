import 'package:flutter/material.dart';
import 'package:goodeeps2/login_page.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [GlobalMaterialLocalizations.delegate],
      supportedLocales: [const Locale('en'), const Locale('kr')],
      title: 'GooDeeps',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'GooDeeps'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double screen = 0;
  late VideoPlayerController _controllerVideo;

  @override
  void initState() {
    super.initState();
    // load the splash screen background
    _controllerVideo = VideoPlayerController.asset('assets/images/bglogin.mp4')
      ..initialize().then((_) {
        _controllerVideo.setLooping(true);
        _controllerVideo.play();
        setState(() {});
      });
    // initate the screen size
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      MediaQueryData mediaQueryData = MediaQuery.of(context);
      if (mediaQueryData.orientation == Orientation.portrait) {
        setState(() {
          screen = MediaQuery.of(context).size.height;
        });
      } else {
        setState(() {
          screen = MediaQuery.of(context).size.width;
        });
      }

      // delay the splash screen for 5 seconds
      Future.delayed(Duration(seconds: 5), () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
          (route) => false,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.fill,
              child: SizedBox(
                width: _controllerVideo.value.size.width,
                height: _controllerVideo.value.size.height,
                child: VideoPlayer(_controllerVideo),
              ),
            ),
          ),
          Container(
            height: screen,
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Container(
                            width: screen * 0.25,
                            child: Image.asset(
                                'assets/images/gdl.png') // goodeeps logo,
                            ),
                      ),
                      SizedBox(
                        height: screen * 0.02,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          "My only one doctor for the Deep Sleep", // jargon text
                          textAlign: TextAlign.center,
                          textScaleFactor: 0.8,
                          style: TextStyle(
                            fontFamily: 'Pretendart',
                            fontSize: screen * 0.02,
                            color: Color.fromRGBO(206, 207, 209, 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: screen * 0.08,
                    child: Image.asset(
                        'assets/images/logotransparent.png'), // miraclare logo
                  ),
                ),
                SizedBox(
                  height: screen * 0.05,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

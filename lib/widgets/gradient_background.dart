import 'package:flutter/material.dart';
import 'package:goodeeps2/utils/goodeeps_color.dart';

class GradientBackground extends StatelessWidget {
  final Widget? child; // child 위젯을 저장할 필드 추가
  GradientBackground({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(16, statusBarHeight, 16, 0),
      decoration: BoxDecoration(gradient: GoodeepsColor.backgroundGradient),
      child: child,
    );
  }
}

class ImageBackground extends StatelessWidget {
  final Widget? child; // child 위젯을 저장할 필드 추가
  ImageBackground({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(16, statusBarHeight, 16, 0),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bg2.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:my_gallery/modules/flu_app/config/printer.dart';

class Paint6Page extends StatefulWidget {
  const Paint6Page({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _Paint6PageState();
  }

}

class _Paint6PageState extends State<Paint6Page> with SingleTickerProviderStateMixin{

  AnimationController? animationController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    animationController = AnimationController(vsync: this, duration: Duration(seconds: 5));
    animationController!.forward();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Paint6 动画绘制"),
      ),
      body: CustomPaint(
        painter: Paint6CustomPainter(animationController),
      ),
    );
  }

}

class Paint6CustomPainter extends CustomPainter {

  Animation<double>? animation;
  Paint6CustomPainter(this.animation):super(repaint: animation);

  late List<Offset> points;
  _initPoints() {
    points = [];
    for(int i = 0; i < 360; i++) {
      double t = _convert(i);
      double p = _calY(t);
      //points.add(Offset(p * cos(t), p * sin(t)));
      points.add(Offset(i + cos(i) * 10.0, i * 1.0));
    }
  }

  double _calY(double x) {
    return 50 * (pow(e, cos(x)) - 2 * cos(4 * x)) + pow(sin(x / 12), 5);
  }

  double _convert(int x) {
    return pi / 180 * x;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _initPoints();
    Paint paint = Paint();
    paint.color = Colors.green;
    paint.strokeWidth = 10;
    paint.style = PaintingStyle.stroke;
    printer("${animation!.value}");
    canvas.drawLine(Offset(20, 60), Offset(20 + 200.0 * animation!.value, 60), paint);

    Path path = Path();
    path.moveTo(200, 200);
    for (int i = 0; i < points.length; i++) {
      path.lineTo(points[i].dx + 10.0 * animation!.value, points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
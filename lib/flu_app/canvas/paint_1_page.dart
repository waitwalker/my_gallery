import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image/image.dart';

class Paint1Page extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Paint1PageState();
  }

}

class _Paint1PageState extends State<Paint1Page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Paint1绘制"),
      ),
      body: Container(
        color: Colors.orange,
        // width: MediaQuery.of(context).size.width,
        // height: MediaQuery.of(context).size.height,
        child: CustomPaint(
          foregroundPainter: Paint1CustomPainter(),
          //child: Text("data"),/// child在画布后面
        ),
      ),
    );
  }

}

class Paint1CustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    /// 画笔初始化
    Paint paint = Paint();
    paint.color = Colors.lightBlue;
    paint.strokeWidth = 20;
    // 保存状态
    canvas.save();
    /// 画布平移 x,y
    canvas.translate(100, 200);
    canvas.drawLine(Offset(100, 100), Offset(350, 350), paint);

    paint.color = Colors.green;
    canvas.translate(-100, -200);
    canvas.drawRect(Rect.fromCircle(center: Offset(150, 150), radius: 100), paint);

    /// 旋转画布
    canvas.rotate(- pi / 8);
    paint.color = Colors.amber;
    canvas.drawLine(Offset(0,300), Offset(300,600), paint);

    /// 缩放画布
    canvas.scale(0.5);
    paint.color = Colors.deepPurpleAccent;
    /// 是否填充
    paint.style = PaintingStyle.stroke;
    canvas.drawRect(Rect.fromCircle(center: Offset(300, 500), radius: 200), paint);

    /// 画点
    List<Offset> points = [
      Offset(100, 900),
      Offset(100, 950),
      Offset(100, 1030),
      Offset(100, 1060),
      Offset(100, 1190),
      Offset(100, 1320),
    ];
    paint.color = Colors.black54;
    canvas.drawPoints(PointMode.points, points, paint);

    /// 画圆
    paint.color = Colors.deepOrange;
    canvas.drawCircle(Offset(100, 500), 300, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}




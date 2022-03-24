import 'dart:math';

import 'package:flutter/material.dart';

class Paint3Page extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Paint3PageState();
  }

}

class _Paint3PageState extends State<Paint3Page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Paint3绘制路径-贝塞尔曲线"),
      ),
      body: Container(
        child: CustomPaint(
          painter: Paint3CustomPainter(),
        ),
      ),
    );
  }

}

class Paint3CustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    Paint paint = Paint();
    paint.color = Colors.deepOrange;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 10;
    
    /// 从点（0，,400）开始绘制
    path.moveTo(0, 400);
    /// 二阶贝塞尔曲线 有做一个控制点:(x1,y1)，端点(x2,y2)
    path.quadraticBezierTo(200, 0, 400, 400);

    /// 移动到点（0，400）
    path.moveTo(0, 400);
    path.quadraticBezierTo(100, 0, 400, 200);

    /// 移动到点（0，600）
    path.moveTo(0, 600);
    /// 三阶贝塞尔曲线 有两个控制点(x1,y1),(x2,y2)，端点（x3,y3）
    path.cubicTo(100, 100, 200, 300, 400, 400);

    Rect rect = Rect.fromPoints(Offset(0, 0), Offset(300, 500));

    /// 绘制椭圆
    path.addOval(rect);

    /// 绘制圆弧
    path.addArc(rect.translate(100, 100), 0, pi);

    /// 绘制矩形
    path.addRect(rect.translate(30, 200));

    /// 绘制多边形 参数是否闭合
    path.addPolygon([Offset(100, 600),Offset(150,510),Offset(150,340),Offset(150,200),Offset(300,200)], false);
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
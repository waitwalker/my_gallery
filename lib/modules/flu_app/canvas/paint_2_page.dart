import 'package:flutter/material.dart';

class Paint2Page extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Paint2PageState();
  }

}

class _Paint2PageState extends State<Paint2Page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Paint2绘制路径"),
      ),
      body: Container(
        color: Colors.orange,
        child: CustomPaint(
          painter: Paint2CustomPainter(),
        ),
      ),
    );
  }

}

class Paint2CustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    Path path = Path();
    paint.style = PaintingStyle.stroke;
    paint.color = Colors.deepPurpleAccent;
    paint.strokeWidth = 10;
    
    /// 绘制直线到（100，100）
    path.lineTo(100, 100);
    canvas.save();

    /// 移动到点（0，,100）坐标
    path.moveTo(0, 200);

    paint.color = Colors.amber;
    /// 移动到点（300，100）
    path.lineTo(300, 200);

    /// 相对于（300，,200）坐标，增长（0，200）
    path.relativeLineTo(0, 200);

    /// 相对于原来的点，减少（200，0）
    path.relativeLineTo(-200, 0);

    /// 绘制线段
    canvas.drawPath(path, paint);

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
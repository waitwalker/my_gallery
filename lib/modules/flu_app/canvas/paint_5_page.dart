import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class Paint5Page extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Paint5PageState();
  }

}

class _Paint5PageState extends State<Paint5Page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Paint5文本绘制"),
      ),
      body: Container(
        child: CustomPaint(
          painter: Paint5CustomPainter(),
        ),
      ),
    );
  }

}

class Paint5CustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = Colors.lightBlue;
    /// 绘制文本
    ui.ParagraphStyle style = ui.ParagraphStyle(fontSize: 24, fontWeight: FontWeight.bold);
    ui.ParagraphBuilder paragraphBuilder = ui.ParagraphBuilder(style);
    paragraphBuilder.pushStyle(ui.TextStyle(color: Colors.red));
    paragraphBuilder.addText("蓝蓝的天，我看不到边");
    ui.Paragraph paragraph = paragraphBuilder.build();
    paragraph.layout(ui.ParagraphConstraints(width: 300));
    canvas.drawParagraph(paragraph, Offset.zero);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
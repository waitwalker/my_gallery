import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

class Paint4Page extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Paint4PageState();
  }

}

class _Paint4PageState extends State<Paint4Page> {

  ui.Image? image;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getImage();
  }

  getImage() async {
    image = await loadImage("static/images/avatar.png");
    setState(() {

    });
  }

  Future<ui.Image> loadImage(String imagePath) async {
    ByteData data = await rootBundle.load(imagePath);
    Uint8List bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    return decodeImageFromList(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Paint4图片绘制"),
      ),
      body: image == null ? Center(child: CircularProgressIndicator(),) : Container(
        child: CustomPaint(
          painter: Paint4CustomPainter(
            image: image,
          ),
        ),
      ),
    );
  }

}

class Paint4CustomPainter extends CustomPainter {
  ui.Image? image;
  Paint4CustomPainter({this.image});
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    /// 矩阵变换
    paint.imageFilter = ui.ImageFilter.matrix(Matrix4.diagonal3Values(2, 2, 1).storage);
    canvas.drawImage(image!, Offset.zero, paint);

    /// 高斯模糊
    paint.imageFilter = ui.ImageFilter.blur(sigmaX: 2, sigmaY: 2);
    canvas.drawImage(image!, ui.Offset(0, 300), paint);

    /// 绘制图片区域
    canvas.drawImageRect(image!, Rect.fromLTWH(30, 30, 20, 20), Rect.fromLTWH(200, 300, 20, 20), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
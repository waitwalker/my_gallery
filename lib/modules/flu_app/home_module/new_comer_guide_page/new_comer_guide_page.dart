
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:my_gallery/modules/flu_app/config/img.dart';

enum ChildShape {
  CIRCLE, //圆形
  RECTANGLE, //矩形
  OVAL, //椭圆
  ROUND_RECTANGLE //圆角矩形
}

class GuideChild {
  //突出显示的widget的大小
  late Size childSize;

  //突出显示widget的位置（偏移量）
  late Offset offset;

  //突出显示widget的形状
  ChildShape childShape = ChildShape.RECTANGLE;

  //用于解释说明突出显示widget的组件
  late Widget descWidget;

  //用于解释说明突出显示widget的组件位置
  late Offset descOffset;

  //点击组件的回调
  late GestureTapCallback callback;

  //仅点击组件可关闭
  bool closeByClickChild = false;

  double padding = 5;
}

class GuideLayout extends StatefulWidget {
  final List<GuideChild> children;
  final GestureTapCallback onCompete;

  const GuideLayout(this.children, {Key? key, required this.onCompete}): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return GuideLayoutState();
  }

  static void showGuide(BuildContext context, List<GuideChild> children,
      GestureTapCallback onComplete) {
    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secAnim) {
          return FadeTransition(
            ///渐变过渡 0.0-1.0
            opacity: Tween(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                ///动画样式
                parent: animation,

                ///动画曲线
                curve: Curves.fastOutSlowIn,
              ),
            ),
            child: GuideLayout(
              children,
              onCompete: onComplete,
            ),
          );
        },
        opaque: false));
  }
}

class GuideLayoutState extends State<GuideLayout> {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Material(
      color: const Color(0x00ffffff),
      type: MaterialType.transparency,
      child: GestureDetector(
        onTapUp: tapUp,
        child: CustomPaint(
          size: screenSize,
          painter: BgPainter(
              offset: widget.children.first.offset,
              childSize: widget.children.first.childSize,
              shape: widget.children.first.childShape,
              padding: widget.children.first.padding),
          child: Stack(
            children: [
              Positioned(
                child: widget.children.first.descWidget,
                left: widget.children.first.descOffset.dx,
                top: widget.children.first.descOffset.dy,
              ),
              Positioned(
                child: Container(height: 30, width: 30, color: Colors.red,),
                left: widget.children.first.descOffset.dx,
                top: widget.children.first.descOffset.dy - 30,
              ),
              Positioned(
                child: Container(
                  height: widget.children.first.childSize.height + 40,
                  width: MediaQuery.of(context).size.width - 6,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage(
                        Img.newComerBgBorder,
                      ),
                    ),
                  ),
                ),
                left: 3,
                top: widget.children.first.offset.dy - 15,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void tapChild() {
    widget.children.first.callback.call();

    setState(() {
      if (widget.children.length == 1) {
        widget.onCompete.call();
        Navigator.of(context).pop();
      } else if (widget.children.length > 1) {
        widget.children.removeAt(0);
      }
    });
  }

  void tapUp(TapUpDetails details) {
    if (widget.children.first.closeByClickChild) {
      Path path = Path();
      path.addRect(Rect.fromLTWH(
          widget.children.first.offset.dx,
          widget.children.first.offset.dy,
          widget.children.first.childSize.width,
          widget.children.first.childSize.height));
      if (!path.contains(details.globalPosition)) {
        return;
      }
    }

    widget.children.first.callback.call();
    widget.children.removeAt(0);
    if (widget.children.isEmpty) {
      widget.onCompete.call();
      Navigator.of(context).pop();
    } else {
      setState(() {});
    }
  }
}

class BgPainter extends CustomPainter {
  late Offset offset;
  late Size childSize;

  late Path path1;
  late Path path2;
  late Path path3;
  late Paint _paint;

  late ChildShape shape;
  late double padding;

  BgPainter({required this.offset, required this.childSize, required this.shape, required this.padding}) {
    path1 = Path();
    path2 = Path();
    path3 = Path();
    _paint = Paint()
      ..color = const Color(0x90000000)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    path1.reset();
    path2.reset();

    path1.addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    switch (shape) {
      case ChildShape.RECTANGLE:
        path2.addRect(Rect.fromLTWH(offset.dx - padding, offset.dy - padding,
            childSize.width + padding * 2, childSize.height + padding * 2));
        break;
      case ChildShape.CIRCLE:
        double length;
        double left;
        double top;
        double radius = sqrt(childSize.width * childSize.width +
            childSize.height * childSize.height);
        length = radius + padding * 2;
        left = offset.dx - (radius - childSize.width) / 2 - padding;
        top = offset.dy - (radius - childSize.height) / 2 - padding;
        path2.addOval(Rect.fromLTWH(left, top, length, length));

        break;
      case ChildShape.OVAL:
        double length;
        double left;
        double top;
        double radius = sqrt(childSize.width * childSize.width +
            childSize.height * childSize.height);
        length = radius + padding * 2;
        left =
            offset.dx - (radius + padding * 4 - childSize.width) / 2 - padding;
        top = offset.dy - (radius - childSize.height) / 2 - padding;
        path2.addOval(Rect.fromLTWH(
            left, top, length + padding * 6, length + padding * 2));
        break;
      case ChildShape.ROUND_RECTANGLE:
        path2.addRRect(RRect.fromRectXY(
            Rect.fromLTWH(offset.dx - padding, offset.dy - padding, childSize.width + padding * 2, childSize.height + padding * 2), padding * 2, padding * 2));
        break;
    }

    Path result = Path.combine(PathOperation.difference, path1, path2);

    canvas.drawPath(result, _paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

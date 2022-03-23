import 'package:my_gallery/modules/my_course/my_course.dart';
import 'package:my_gallery/common/tools/screen_adapt/screen_utils.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class RaisedGradientRippleButton extends StatelessWidget {
  RaisedGradientRippleButton(
      {Key? key,
      required this.child,
      required this.onPressed,
      this.radius = 4.0,
      this.gradient,
      this.boxShadow})
      : assert(child != null),
        super(key: key);

  Widget child;
  OnPress? onPressed;
  double radius = 4.0;
  Gradient? gradient;
  List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    var borderRadius = BorderRadius.all(Radius.circular(radius));
    return ElevatedButton(
      style: ButtonStyle(
        padding: MaterialStateProperty.resolveWith<EdgeInsetsGeometry>(
              (Set<MaterialState> states) {
            return EdgeInsets.all(0);
          },
        ),
        shape: ButtonStyleButton.allOrNull<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: borderRadius)),
        backgroundColor: ButtonStyleButton.allOrNull<Color>(Colors.transparent),
      ),
      child: Container(
        height: 41,
        width: ScreenUtil.getInstance().setWidth(176),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          // color: Colors.white,
          boxShadow: boxShadow,
          gradient: gradient,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
              borderRadius: borderRadius,
              onTap: onPressed,
              child: Center(
                child: child,
              )),
        ),
      ),
      onPressed: onPressed,
    );
  }
}

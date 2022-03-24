import 'package:flutter/material.dart';

///
/// @description 自定义按钮封装
/// @author waitwalker
/// @time 2021/5/11 15:09
///
class WrappedButton extends StatelessWidget {
  final BoxDecoration? decoration;
  final double circular;
  final double height;
  final double width;
  final Widget? child;
  final Function? onPressed;
  WrappedButton({
    this.decoration,
    this.circular = 6,
    this.child,
    this.onPressed,
    this.height = 44,
    this.width = 80,
  });

  @override
  Widget build(BuildContext context) {
    return _wrappedButton();
  }

  ///
  /// @description 私有实现
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 2021/5/11 15:09
  ///
  Widget _wrappedButton() {
    return Container(
      decoration: decoration,
      height: height,
      width: width,
      child: ElevatedButton(
        style: ButtonStyle(
          padding: MaterialStateProperty.resolveWith<EdgeInsetsGeometry>(
                (Set<MaterialState> states) {
              return EdgeInsets.all(0);
            },
          ),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(circular)
          )),
          backgroundColor: MaterialStateProperty.all(Colors.transparent,),
          elevation: MaterialStateProperty.all(0), // 正常时阴影隐藏
        ),
        onPressed: onPressed as void Function()?,
        child: child,
      ),
    );
  }
}
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:flutter/material.dart';

///
/// @name EmptyPlaceholderPage
/// @description 没有数据站位
/// @author waitwalker
/// @date 2020-01-11
///
// ignore: must_be_immutable
class EmptyPlaceholderPage extends StatelessWidget {
  String assetsPath;
  String? message;
  OnPressedHolder? onPress;
  double topPadding;
  double fontSize;

  EmptyPlaceholderPage(
      {this.assetsPath = 'static/images/empty.png',
      this.message = '没有数据',
      this.onPress,
      this.topPadding = 50,
      this.fontSize = 18,
      });

  @override
  Widget build(BuildContext context) {
    return InkWell(
        child: Container(
          padding: EdgeInsets.all(81.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  assetsPath,
                  fit: BoxFit.cover,
                ),
                Padding(padding: EdgeInsets.only(top: topPadding)),
                Text(message!, style: TextStyle(
                    fontSize: fontSize,
                    color: Color(MyColors.black333),
                    fontWeight: FontWeight.normal)),
              ],
            ),
          ),
        ),
        onTap: onPress);
  }
}

typedef void OnPressedHolder();

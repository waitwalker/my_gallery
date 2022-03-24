import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ExtendButton extends StatelessWidget {
  ExtendButton(
      {this.imgUrl = "",
      this.tips = "",
      this.onTap,
      this.imgHeight = 0,
      this.imgColor,
      Key? key})
      : super(key: key);
  final String imgUrl;
  final double imgHeight;
  final Color? imgColor;
  final String tips;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        this.onTap!();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imgUrl,
            height: imgHeight > 0 ? this.imgHeight : 52.0,
            color: imgColor != null ? imgColor : null,
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            child: Text(
              tips,
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

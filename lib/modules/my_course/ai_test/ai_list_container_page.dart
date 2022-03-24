import 'dart:io';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///
/// @name AIContainerPage
/// @description AI页面 容器页面
/// @author waitwalker
/// @date 2020-01-10
///
class AIListContainerPage extends StatefulWidget {
  final Widget? innerWidget;
  final String? title;

  AIListContainerPage({this.innerWidget, this.title});

  @override
  _AIListContainerPageState createState() => _AIListContainerPageState();
}

class _AIListContainerPageState extends State<AIListContainerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(MyColors.background),
      appBar: AppBar(
        title: Text(widget.title!, style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xff73b2f3),
        leading: IconButton(icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back, color: Colors.white,), onPressed: (){
          Navigator.pop(context);
        }),
        elevation: 1,
        centerTitle: Platform.isIOS ? true : false,
      ),
      body: widget.innerWidget,
    );
  }
}

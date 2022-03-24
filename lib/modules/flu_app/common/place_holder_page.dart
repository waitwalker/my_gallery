import 'package:flutter/material.dart';

class PlaceholderPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PlaceholderPageState();
  }
}

class _PlaceholderPageState extends State<PlaceholderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("404,页面不存在"),
      ),
      body: Column(children: [
        Text("当前页面不存在"),
      ],),
    );
  }

}
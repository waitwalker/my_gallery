import 'package:flutter/material.dart';

class PlaceholderPage extends StatefulWidget {
  const PlaceholderPage({Key? key}) : super(key: key);

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
      body: Column(children: const [
        Text("当前页面不存在"),
      ],),
    );
  }
}
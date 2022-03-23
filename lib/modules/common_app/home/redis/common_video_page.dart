import 'package:flutter/material.dart';


class CommonVideoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CommonVideoState();
  }
}

class _CommonVideoState extends State<CommonVideoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("视频"),
      ),
      body: Column(
        children: <Widget>[
          Text("视频"),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';


class CommonWhiteBoardPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CommonWhiteBoardState();
  }
}

class _CommonWhiteBoardState extends State<CommonWhiteBoardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("白板"),
      ),
      body: Column(
        children: <Widget>[
          Text("白板"),
        ],
      ),
    );
  }
}
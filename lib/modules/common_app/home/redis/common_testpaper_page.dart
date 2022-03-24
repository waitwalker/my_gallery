import 'package:flutter/material.dart';


class CommonTestPaperPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CommonTestPaperState();
  }
}

class _CommonTestPaperState extends State<CommonTestPaperPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("试卷"),
      ),
      body: Column(
        children: <Widget>[
          Text("试卷"),
        ],
      ),
    );
  }
}
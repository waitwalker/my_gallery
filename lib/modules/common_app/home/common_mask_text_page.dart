import 'package:flutter/material.dart';

class CommonMaskTextPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CommonMaskTextState();
  }
}

class _CommonMaskTextState extends State<CommonMaskTextPage> {
  // var controller = MaskedTextController(mask: '000.000.000-00');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Masked Text"),
      ),
      body: Column(
        children: <Widget>[
          // TextField(controller: controller,),// <--- here
        ],
      ),
    );
  }
}
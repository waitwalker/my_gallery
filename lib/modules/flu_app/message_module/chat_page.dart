import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {

  String? userName;
  String? userIcon;
  ChatPage(Map<String,String> arguments, {Key? key}) {
    userName = arguments['userName'];
    userIcon = arguments['userIcon'];
  }

  @override
  State<StatefulWidget> createState() {
    return _ChatPageState();
  }
}

class _ChatPageState extends State<ChatPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("聊天页面"),
      ),
    );
  }
}
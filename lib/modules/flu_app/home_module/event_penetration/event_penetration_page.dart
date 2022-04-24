import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_gallery/modules/flu_app/config/k_printer.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// @fileName event_penetration_page.dart
/// @description 事件穿透
/// @date 2022/4/24 15:02
/// @author LiuChuanan
class EventPenetrationPage extends StatefulWidget {
  const EventPenetrationPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EventPenetrationPage();
  }
}

class _EventPenetrationPage extends State<EventPenetrationPage> {

  /// 是否需要事件穿透
  bool shouldPenetration = false;
  final GlobalKey _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      appBar: AppBar(
        title: const Text("事件传递"),
      ),
      body: Stack(
        children: <Widget>[
          InkWell(
            child: Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              height: 200,
              color: Colors.deepOrange,
              child: const Text("我是下面一层的2", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,),),
            ),
            onTap: (){
              Fluttertoast.showToast(msg: "点击的是第2层");
              kPrinter("object");
              if (shouldPenetration) {
                shouldPenetration = false;
              }
              setState(() {

              });
            },
          ),

          ConstrainedBox(
            constraints: BoxConstraints.tight(Size(MediaQuery.of(context).size.width, 100.0)),
            child: WebView(
              onWebViewCreated: (c){

              },
              initialUrl: "https://www.baidu.com/",
              javascriptMode: JavascriptMode.unrestricted,
            ),
          ),

          /// IgnorePointer 事件穿透处理
          IgnorePointer(
            ignoring: shouldPenetration,
            child: InkWell(
              child: Container(
                alignment: Alignment.center,
                color: const Color(0x4dffbbcf),
                padding: EdgeInsets.zero,
                height: 452,
                width: MediaQuery.of(context).size.width - 32,
                child: const Text("登录",style: TextStyle(fontSize: 50, color: Colors.amber, fontWeight: FontWeight.bold),),
              ),
              onTap: (){
                Fluttertoast.showToast(msg: "登录按钮响应了");
                shouldPenetration = !shouldPenetration;
                setState(() {

                });
                kPrinter("点击登录了");
              },
            ),
          ),
        ],
      ),
    );
  }
}
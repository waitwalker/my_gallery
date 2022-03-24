import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlatformViewPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PlatformViewPageState();
  }
}

class _PlatformViewPageState extends State<PlatformViewPage> {

  MethodChannel methodChannel = MethodChannel("cn.waitwalker/platformview");
  String? nativeToFlutterMessage = "";
  int flutterToNativeCount = 0;
  @override
  void initState() {
    methodChannel.setMethodCallHandler(_handlerMethodCall);
    super.initState();
  }
  Future<dynamic> _handlerMethodCall(MethodCall? call) {
    String methodName = call!.method;
    if (methodName == "nativeCount") {
      String? nativeCount = call.arguments["count"];
      setState(() {
        nativeToFlutterMessage = nativeCount;
      });
    }
    var a;
    return a;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PlatformView"),
      ),
      body: Column(
        children: [
          Expanded(child: ListView(
            children: [
              Padding(padding: EdgeInsets.only(top: 20)),
              InkWell(
                child: Padding(padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: MediaQuery.of(context).size.width, height: 60,
                    child: Text("Flutter向原生发送消息", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                  ),
                ),
                onTap: (){
                  flutterToNativeCount++;
                  Map<String,String> map = {"flutterToNativeCount" : "$flutterToNativeCount"};
                  methodChannel.invokeListMethod("flutterToNativeMessage", map);
                },
              ),

              Padding(padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: MediaQuery.of(context).size.width, height: Platform.isAndroid ? 160 : 200,
                  child: Platform.isAndroid ? AndroidView(
                    viewType: "cn.waitwalker/android_view",
                    creationParams: "Flutter这边初始化传递给原生的message",
                    creationParamsCodec: StandardMessageCodec(),
                  ) : UiKitView(
                    viewType: "cn.waitwalker/android_view",
                    creationParams: "Flutter这边初始化传递给原生的message",
                    creationParamsCodec: StandardMessageCodec(),
                  ),
                ),
              ),

              Padding(padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: MediaQuery.of(context).size.width, height: 60,
                  child: Text("原生发给Flutter的消息：$nativeToFlutterMessage", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),),
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }
}
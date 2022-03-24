import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_gallery/modules/flu_app/isolate/isolate_event.dart';
import 'package:my_gallery/modules/flu_app/isolate/isolate_fire.dart';

class IsolatePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _IsolatePageState();
  }
}


Isolate? newIsolate;
/// newIsolate的发送端口 由rootIsolate持有，这样rootIsolate就能利用newIsolatePort向rootIsolate发送消息
SendPort? newIsolateSendPort;

String rootSendToNewMessage = "";

class _IsolatePageState extends State<IsolatePage> {

  String message1 = "";
  String message2 = "";


  @override
  void initState() {

    /// 监听消息
    IsolateFire.eventBus.on().listen((event) {
      IsolateEvent isolateEvent = event;
      /// newIsolate接收到的消息
      if (isolateEvent.code == 1) {
        message1 = message1 + "\n" + isolateEvent.message!;
      } else {
        /// rootIsolate接收到的消息
        message2 = message2 + "\n" + isolateEvent.message!;
      }
      setState(() {

      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Isolate使用"),
      ),
      body: Column(children: [
        Expanded(child: ListView(
          children: [
            Padding(padding: EdgeInsets.only(top: 18)),
            InkWell(
              child: Padding(padding: EdgeInsets.only(left: 20, right: 20, bottom: 20,),
                child: Container(width: MediaQuery.of(context).size.width, height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text("创建Isolate", style: TextStyle(fontSize: 20, color: Colors.white,),),
                ),
              ),
              onTap: () {
                _createIsolate();
              },
            ),

            InkWell(
              child: Padding(padding: EdgeInsets.only(left: 20, right: 20, bottom: 20,),
                child: Container(width: MediaQuery.of(context).size.width, height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text("主线程发送任务给newIsolate", style: TextStyle(fontSize: 20, color: Colors.pink, fontWeight: FontWeight.bold),),
                ),
              ),
              onTap: () async {
                await _createIsolate();
                rootSendToNewMessage = "newIsolate帮我rootIsolate干点耗时的活";
                sendMessageToNewIsolate(newIsolateSendPort!);
              },
            ),

            Padding(padding: EdgeInsets.only(left: 20, right: 20, bottom: 20,),
              child: Container(width: MediaQuery.of(context).size.width, height: 260,
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                  color: Colors.lightBlue,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text("newIsolate接收到的消息:$message1", style: TextStyle(fontSize: 20, color: Colors.white,),),
              ),
            ),

            Padding(padding: EdgeInsets.only(left: 20, right: 20, bottom: 20,),
              child: Container(width: MediaQuery.of(context).size.width, height: 260,
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                  color: Colors.lightBlue,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text("主线程接收到的消息:$message2", style: TextStyle(fontSize: 20, color: Colors.white,),),
              ),
            ),

            InkWell(
              child: Padding(padding: EdgeInsets.only(left: 20, right: 20, bottom: 20,),
                child: Container(width: MediaQuery.of(context).size.width, height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text("没有使用compute优化", style: TextStyle(fontSize: 20, color: Colors.white,),),
                ),
              ),
              onTap: () {
                _count1(100000000000);
              },
            ),

            InkWell(
              child: Padding(padding: EdgeInsets.only(left: 20, right: 20, bottom: 20,),
                child: Container(width: MediaQuery.of(context).size.width, height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text("使用compute优化", style: TextStyle(fontSize: 20, color: Colors.white,),),
                ),
              ),
              onTap: () async {
                var value = await compute(_count2,10000000);
                print("计算完的结果：$value");
              },
            ),
          ],
        ),),
      ],),
    );
  }

  /// 没有使用compute优化的耗时任务会阻塞主线程
  _count1(int num) {
    int count = num;
    while (count > 0){
      print("当前count值：$count");
      count--;
    }
  }

  /// 使用compute优化的耗时任务会阻塞主线程
  static int _count2(int num) {
    int count = num;
    while (count > 0){
      print("当前count值：$count");
      count--;
    }
    return count;
  }

  @override
  void dispose() {
    if (newIsolate != null) {
      /// 销毁isolate
      newIsolate!.kill(priority: Isolate.immediate);
    }
    super.dispose();
  }

}


/// 创建Isolate
_createIsolate() async {
  ///1. 默认环境下是rootIsolate，所以创建一个rootReceivePort
  ReceivePort rootIsolateReceivePort = ReceivePort();

  ///2. 获取rootReceiverSendPort, 因为sendPort只能由receivePort获取
  SendPort rootIsolateSendPort = rootIsolateReceivePort.sendPort;

  ///3. 创建一个newIsolate实例，并把rootIsolateSendPort传递给newIsolate实例，为了让newIsolate实例持有rootIsolateSendPort，
  ///这样newIsolate就能利用rootIsolateSendPort向rootIsolate发送消息。所以发送消息的本质都是自己Isolate的收发端口进行的
  newIsolate = await Isolate.spawn(isolateDoWork, rootIsolateSendPort);

  ///7. 通过rootIsolateReceivePort接收到newIsolate的消息（本质还是rootIsolateSendPort发送的），这里首先将newIsolate的newIsolateSendPort端口发过来，让rootIsolate持有
  ///rootIsolate获取到newIsolate的newIsolateSendPort
  newIsolateSendPort = await (rootIsolateReceivePort.first as FutureOr<SendPort?>);

}

///8. rootIsolate执行环境，向newIsolate发送消息
void sendMessageToNewIsolate(SendPort newIsolateSendPort) {
  /// 创建专门来应答消息的rootIsolateReceivePort
  ReceivePort rootIsolateReceiverPort = ReceivePort();
  /// 从rootReceivePort中获取rootSendPort
  SendPort rootIsolateSendPort = rootIsolateReceiverPort.sendPort;

  newIsolateSendPort.send([rootSendToNewMessage,rootIsolateSendPort]);

  /// rootIsolateReceivePort监听消息
  rootIsolateReceiverPort.listen((message) {
    print("rootIsolate收到了消息：$message");
    IsolateFire.sendNotify(2, message as String?);
  });
}

/// 新创建的isolate去处理任务
void isolateDoWork(SendPort rootIsolateSendPort) async{
  ///4. 这个callBack函数执行环境会变为newIsolate，所以这里创建一个newIsolateReceivePort
  ReceivePort newIsolateReceivePort = ReceivePort();

  ///5. 获取newIsolateSendPort,这里不能拿全局的newIsolateSendPort，因为这里额执行环境不是rootIsolate
  SendPort newIsolateSendPort = newIsolateReceivePort.sendPort;

  ///6. 利用传递进来的rootIsolateSendPort将newIsolateSendPort发送给rootIsolate，这样rootIsolate就能持有newIsolateSendPort了
  ///收发消息只能是同一个isolate的sendPort和receivePort之间进行
  rootIsolateSendPort.send(newIsolateSendPort);

  ///9. newIsolateReceivePort监听来自rootIsolate的消息
  receiveMessageFromRootIsolate(newIsolateReceivePort);
}

/// 这里的执行环境是newIsolate，接收到rootIsolate发送来的任务，协助处理，处理完了把消息发送给rootIsolate
void receiveMessageFromRootIsolate(ReceivePort newIsolateReceivePort) {
  newIsolateReceivePort.listen((message) {
    /// rootIsolate发送给newIsolate的消息，这里rootIsolate会把自己的sendPort发送过来
    print("rootIsolate发送过来的消息：$message");
    var messageList = message as List;
    print("messageList[0]:${messageList[0]}");
    String msg = messageList[0] as String;
    IsolateFire.sendNotify(1, msg);
    /// 这里处理rootIsolate让newIsolate帮忙处理的工作
    sleep(Duration(seconds: 3));
    SendPort rootIsolateSendPort = messageList[1] as SendPort;
    /// 消息传递方式1）send
    //rootIsolateSendPort.send("newIsolate已经把活干完了");
    /// 消息传递方式2） exit
    Isolate.exit(rootIsolateSendPort,"newIsolate已经把活干完了");
    newIsolate!.kill(priority: Isolate.immediate);
  });
}
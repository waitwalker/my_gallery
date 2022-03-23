import 'package:flutter/material.dart';

class CommonRedisPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CommonRedisState();
  }
}

class _CommonRedisState extends State<CommonRedisPage> {

  String setValueStr = "";
  String getValueStr = "";
  String message1 = "";
  String message2 = "";
  String message3 = "";
  String message4 = "";
  String receivedMessage = "";
  @override
  void initState() {

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Redis"),
      ),
      body: ListView(
        children: <Widget>[
          connect(),
          Padding(padding: EdgeInsets.only(top: 10)),
          setValue(),
          Padding(padding: EdgeInsets.only(top: 10)),
          getValue(),

          Padding(padding: EdgeInsets.only(top: 10)),
          pubSub(),
        ],
      ),
    );
  }

  connect() {
//    return InkWell(
//      child: Container(
//        width: MediaQuery.of(context).size.width,
//        height: 44,
//        child: Text("连接"),
//        alignment: Alignment.center,
//        color: Colors.cyan,
//      ),
//      onTap: () async {
//        RedisConnection redisConnection = RedisConnection();
//        Command command = await redisConnection.connect("localhost", 6379);
//        print("redis connect state:$command");
//
//      },
//    );
  }

  setValue() {
//    return InkWell(
//      child: Container(
//        width: MediaQuery.of(context).size.width,
//        height: 44,
//        child: Row(
//          mainAxisAlignment: MainAxisAlignment.center,
//          children: <Widget>[
//            Text("SET"),
//            Padding(padding: EdgeInsets.only(right: 20)),
//            Text(setValueStr),
//          ],
//        ),
//        alignment: Alignment.center,
//        color: Colors.cyan,
//      ),
//      onTap: () async {
//        String value = "网校";
//        RedisConnection conn = new RedisConnection();
//        conn.connect('localhost',6379).then((Command command){
//          command.set("Flutter_Key1", value).then((var response){
//            print("response:$response");
//            setState(() {
//              setValueStr = value;
//            });
//            return response;
//          });
//        });
//      },
//    );
  }

  getValue() {
//    return InkWell(
//      child: Container(
//        width: MediaQuery.of(context).size.width,
//        height: 44,
//        child: Row(
//          mainAxisAlignment: MainAxisAlignment.center,
//          children: <Widget>[
//            Text("GET"),
//            Padding(padding: EdgeInsets.only(right: 20)),
//            Text(getValueStr),
//          ],
//        ),
//        alignment: Alignment.center,
//        color: Colors.cyan,
//      ),
//      onTap: () async {
//        RedisConnection conn = new RedisConnection();
//        conn.connect('localhost',6379).then((Command command){
//          command.get("Flutter_Key1").then((var response){
//            print("response:$response");
//            setState(() {
//              getValueStr = "$response";
//            });
//            return response;
//          });
//        });
//      },
//    );
  }

  pubSub() {
//    if (SingletonManager.sharedInstance.screenHeight < 815) {
//      return Column(
//        children: <Widget>[
//          Container(
//            width: MediaQuery.of(context).size.width,
//            color: Colors.lightGreen,
//            child: Row(
//              mainAxisAlignment: MainAxisAlignment.center,
//              children: <Widget>[
//                InkWell(
//                  child: Container(
//                    height: 80,
//                    child: Text("频道1发布消息: "),
//                    alignment: Alignment.center,
//                  ),
//                  onTap: (){
//                    String message = "试卷";
//                    RedisConnection conn = new RedisConnection();
//                    conn.connect('localhost',6379).then((Command command){
//                      command.send_object(["PUBLISH", "channel_1", message]).then((var response){
//                        print("publish state:$response");
//                        setState(() {
//                          message1 = message;
//                        });
//                        return response;
//                      });
//
//                    });
//                  },
//                ),
//                Padding(padding: EdgeInsets.only(right: 20),),
//                Text(message1),
//              ],
//            ),
//          ),
//
//          Padding(padding: EdgeInsets.only(top: 20),),
//
//          Container(
//            width: MediaQuery.of(context).size.width,
//            color: Colors.lightGreen,
//            child: Row(
//              mainAxisAlignment: MainAxisAlignment.center,
//              children: <Widget>[
//                InkWell(
//                  child: Container(
//                    alignment: Alignment.center,
//                    height: 80,
//                    child: Text("频道1发布消息: "),
//                  ),
//                  onTap: (){
//                    String message = "视频";
//                    RedisConnection conn = new RedisConnection();
//                    conn.connect('localhost',6379).then((Command command){
//                      command.send_object(["PUBLISH", "channel_1", message]).then((var response){
//                        print("publish state:$response");
//                        setState(() {
//                          message2 = message;
//                        });
//                        return response;
//                      });
//
//                    });
//                  },
//                ),
//                Padding(padding: EdgeInsets.only(right: 20),),
//                Text(message2),
//              ],
//            ),
//          ),
//          Padding(padding: EdgeInsets.only(top: 20),),
//
//          Container(
//            width: MediaQuery.of(context).size.width,
//            color: Colors.lightGreen,
//            child: Row(
//              mainAxisAlignment: MainAxisAlignment.center,
//              children: <Widget>[
//                InkWell(
//                  child: Container(
//                    alignment: Alignment.center,
//                    height: 80,
//                    child: Text("频道1发布消息: "),
//                  ),
//                  onTap: (){
//                    String message = "白板";
//                    RedisConnection conn = new RedisConnection();
//                    conn.connect('localhost',6379).then((Command command){
//                      command.send_object(["PUBLISH", "channel_1", message]).then((var response){
//                        print("publish state:$response");
//                        setState(() {
//                          message4 = message;
//                        });
//                        return response;
//                      });
//
//                    });
//                  },
//                ),
//                Padding(padding: EdgeInsets.only(right: 20),),
//                Text(message4),
//              ],
//            ),
//          ),
//          Padding(padding: EdgeInsets.only(top: 20),),
//
//          Container(
//            width: MediaQuery.of(context).size.width,
//            color: Colors.lightGreen,
//            child: Row(
//              mainAxisAlignment: MainAxisAlignment.center,
//              children: <Widget>[
//                InkWell(
//                  child: Container(
//                    alignment: Alignment.center,
//                    height: 80,
//                    child: Text("频道1随机发布消息: "),
//                  ),
//                  onTap: (){
//                    String message = randomString(8);
//                    RedisConnection conn = new RedisConnection();
//                    conn.connect('localhost',6379).then((Command command){
//                      command.send_object(["PUBLISH", "channel_1", message]).then((var response){
//                        print("publish state:$response");
//                        setState(() {
//                          message3 = message;
//                        });
//                        return response;
//                      });
//
//                    });
//                  },
//                ),
//                Padding(padding: EdgeInsets.only(right: 20),),
//                Text(message3),
//              ],
//            ),
//          ),
//
//          Padding(padding: EdgeInsets.only(top: 20),),
//        ],
//      );
//    } else {
//      return Column(
//        children: <Widget>[
//          Container(
//            width: MediaQuery.of(context).size.width,
//            height: 44,
//            alignment: Alignment.center,
//            color: Colors.amber,
//            child: InkWell(
//              child: Text("开始订阅频道1"),
//              onTap: (){
//                RedisConnection conn = new RedisConnection();
//                conn.connect('localhost',6379).then((Command command){
//                  PubSub pubSub = PubSub(command);
//                  pubSub.subscribe(["channel_1"]);
//                  pubSub.getStream().listen((event) {
//                    List channelMessage = event;
//                    if (channelMessage.length > 2) {
//                      String me = channelMessage.first;
//                      String channelName = channelMessage[1];
//                      var messageValue = channelMessage.last;
//
//                      if (messageValue != 1) {
//                        setState(() {
//                          receivedMessage = "最新的消息:" + messageValue + "\n" + receivedMessage;
//                        });
//                      }
//                    }
//                  });
//                });
//              },
//            ),
//          ),
//
//          Padding(padding: EdgeInsets.only(top: 20)),
//          Text(receivedMessage),
//        ],
//      );
//    }
  }
}
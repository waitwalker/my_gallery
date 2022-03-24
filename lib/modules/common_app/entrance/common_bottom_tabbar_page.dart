import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:my_gallery/modules/common_app/add/common_add_page.dart';
import 'package:my_gallery/modules/common_app/home/common_home_page.dart';
import 'package:my_gallery/modules/common_app/search/common_search_page.dart';

class CommonBottomTabBarPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CommonBottomTabBarState();
  }
}

class _CommonBottomTabBarState extends State<CommonBottomTabBarPage> {

  // 默认选中页面
  int _selectedIndex = 0;

  // 内容页面列表
  List<Widget> _contentPages = [];

  @override
  void initState() {
    _contentPages
      ..add(CommonHomePage())
      ..add(CommonSearchPage());

    // 学生接到redis命令后,处理相关消息
    //studentRedisManager();
    super.initState();
  }

  // 学生接到redis命令后,处理相关消息
//  studentRedisManager() {
//    RedisConnection conn = new RedisConnection();
//    conn.connect('localhost',6379).then((Command command){
//      PubSub pubSub = PubSub(command);
//      pubSub.subscribe(["channel_1"]);
//      pubSub.getStream().listen((event) {
//        List channelMessage = event;
//        if (channelMessage.length > 2) {
//          String me = channelMessage.first;
//          String channelName = channelMessage[1];
//          var messageValue = channelMessage.last;
//
//          if (messageValue != 1 && SingletonManager.sharedInstance.screenHeight > 813 || Platform.isAndroid) {
//            if (messageValue == "视频") {
//              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context){
//                return CommonVideoPage();
//              }));
//            } else if (messageValue == "白板") {
//              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context){
//                return CommonWhiteBoardPage();
//              }));
//            } else if (messageValue == "试卷") {
//              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context){
//                return CommonTestPaperPage();
//              }));
//            }
//
//          }
//        }
//      });
//    });
//  }

  void _itemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _contentPages[_selectedIndex],
      bottomNavigationBar: BottomAppBar(
        color: Colors.teal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home, size: 30,),
              color: Colors.white,
              onPressed: () => _itemTapped(0),
            ),

            SizedBox(),

            Badge(
              child: IconButton(
                icon: Icon(Icons.search, size: 30),
                color: Colors.white,
                onPressed: () => _itemTapped(1),
              ),
              badgeColor: Colors.deepOrangeAccent,
              shape: BadgeShape.circle,
              borderRadius: BorderRadius.circular(20),
              toAnimate: false,
              position: BadgePosition.topEnd(top: 5, end: 5),
              badgeContent: Text('2', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        shape: CircularNotchedRectangle(),
      ),
      floatingActionButton: FloatingActionButton(child: Icon(Icons.add),
        onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
              return CommonAddPage();
            }));
        },
      ),
      // 设置floatingActionButton 在底部导航栏中间
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:my_gallery/flu_app/home_module/home_page.dart';
import 'package:my_gallery/flu_app/message_module/contact_page.dart';
import 'package:my_gallery/flu_app/personal/personal_page.dart';

class FluBottomNavigationBarPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FluBottomNavigationBarPageState();
  }
}

class _FluBottomNavigationBarPageState extends State<FluBottomNavigationBarPage> {

  /// 当前页面索引
  int _currentIndex = 0;

  /// 当前页面列表
  List<Widget> pages = [
    HomePage(),
    ContactPage(),
    PersonalPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index){
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            label: "首页",
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: "联系人",
            icon: Icon(Icons.contact_mail),
          ),
          BottomNavigationBarItem(
            label: "我的",
            icon: Icon(Icons.person),
          ),
        ],
      ),
    );
  }
}
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_gallery/modules/flu_app/home_module/home_page.dart';
import 'package:my_gallery/modules/flu_app/message_module/contact_page.dart';
import 'package:my_gallery/modules/flu_app/personal/personal_page.dart';

class FluBottomNavigationBarPage extends StatefulWidget {
  const FluBottomNavigationBarPage({Key? key}) : super(key: key);

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
    ScreenUtil.init(
      BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
          maxHeight: MediaQuery.of(context).size.height),
      designSize: const Size(375, 812),
      context: context,
      minTextAdapt: true,
    );
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
            icon: Badge(
              position: BadgePosition.topEnd(top: -10, end: -25),
              badgeContent: const Text(
                "99+",
                style: TextStyle(color: Colors.white),
              ),
              child: const Icon(Icons.home),
            ),
          ),

          const BottomNavigationBarItem(
            label: "联系人",
            icon: Icon(Icons.contact_mail),
          ),
          const BottomNavigationBarItem(
            label: "我的",
            icon: Icon(Icons.person),
          ),
        ],
      ),
    );
  }
}
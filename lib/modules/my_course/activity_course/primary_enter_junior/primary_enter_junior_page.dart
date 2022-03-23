import 'dart:io';
import 'package:my_gallery/common/config/config.dart';
import 'package:my_gallery/common/network/network_manager.dart';
import 'package:my_gallery/common/tools/screen_adapt/screen_utils.dart';
import 'package:my_gallery/modules/widgets/webviews/common_webview_page.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:flutter/material.dart';

///
/// @name PrimaryEnterJuniorPage
/// @description 小升初活动课
/// @author waitwalker
/// @date 2020/5/28
///
class PrimaryEnterJuniorPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PrimaryEnterJuniorState();
  }
}

class _PrimaryEnterJuniorState extends State<PrimaryEnterJuniorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "小升初暑期课",
          style: TextStyle(fontSize: 20, color: MyColors.normalTextColor),
        ),
        backgroundColor: Color(MyColors.white),
        elevation: 1,
        ///阴影高度
        titleSpacing: 0,
        centerTitle: Platform.isIOS ? true : false,
      ),
      body: _builderListView(),
    );
  }

  Widget _builderListView() {
    return ListView.builder(
      itemBuilder: _itemBuilderContext,
      itemCount: tmpImages.length,
    );
  }

  /// 活动课图片
  List < Map<String,dynamic>> tmpImages = [
    {
      "image" : "static/images/p_banner_chinese.png",
      "tagId" : Config.DEBUG ? 100355988705 : 100355988705
    },
    {
      "image" : "static/images/p_banner_mathematics.png",
      "tagId" : Config.DEBUG ? 100355988706 : 100355988706
    },
    {
      "image" : "static/images/p_banner_english.png",
      "tagId" : Config.DEBUG ? 100355988707 : 100355988707
    },
  ];

  /// 单个item
  Widget _itemBuilderContext(BuildContext context, int index) {
    Map map = tmpImages[index];
    String imagePath = map["image"];
    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.only(top: 16, left: 16, right: 16),
        child: Hero(
            tag: 'hero_$index',
            child: Container(
              height: ScreenUtil.getInstance().setHeight(136),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(6.0)),
                image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.fill),),
            )),
      ),
      onTap: () {
        if (index == 0) {
          var token = NetworkManager.getAuthorization();
          String url = Config.DEBUG ? "http://huodongt.etiantian.com/activity01/mobile10.html?token=" : "https://huodong.etiantian.com/activity01/mobile10.html?token=";
          String fullUrl = "$url$token";
          Navigator.of(context).push(MaterialPageRoute(builder: (_) {
            return CommonWebviewPage(initialUrl: fullUrl, title: "小升初暑期课程--语文",);
          }));
        } else if (index == 1) {
          var token = NetworkManager.getAuthorization();
          String url = Config.DEBUG ? "http://huodongt.etiantian.com/activity01/mobile11.html?token=" : "https://huodong.etiantian.com/activity01/mobile11.html?token=";
          String fullUrl = "$url$token";
          Navigator.of(context).push(MaterialPageRoute(builder: (_) {
            return CommonWebviewPage(initialUrl: fullUrl, title: "小升初暑期课程--数学",);
          }));
        } else if (index == 2) {
          var token = NetworkManager.getAuthorization();
          String url = Config.DEBUG ? "http://huodongt.etiantian.com/activity01/mobile12.html?token=" : "https://huodong.etiantian.com/activity01/mobile12.html?token=";
          String fullUrl = "$url$token";
          Navigator.of(context).push(MaterialPageRoute(builder: (_) {
            return CommonWebviewPage(initialUrl: fullUrl, title: "小升初暑期课程--英语",);
          }));
        }
      },
    );
  }
}
import 'dart:io';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:my_gallery/modules/widgets/webviews/common_webview_page.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

///
/// @name AboutPage
/// @description 关于页面
/// @author waitwalker
/// @date 2020-01-11
///
class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String? versionName;

  @override
  void initState() {
    super.initState();
    initVersion();
  }

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateTime.now();
    String year = formatDate(dateTime, [yyyy]);
    return Scaffold(
      appBar: AppBar(
        title: Text('关于'),
        elevation: 1.0,
        backgroundColor: Colors.white,
        centerTitle: Platform.isIOS ? true : false,
      ),
      backgroundColor: Color(MyColors.background),
      body: Container(
        padding: EdgeInsets.all(22),
        child: Center(
          child: Column(
            children: <Widget>[
              Image.asset(
                "static/images/logo.png",
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
              Padding(padding: EdgeInsets.only(top: 10)),
              Text('版本号:$versionName', style: textStyleLargeNormal),
              Padding(padding: EdgeInsets.only(top: 20)),
              Text(
                  '北京四中网校是依托现代教育技术与现代教育理念，以北京四中为核心，集全国各地名校名师的优质教育教学资源于一体的在线学习平台。四中网校以促进中国教育均衡发展为己任，致力于传播先进的教育理念，促进教师的专业化发展，提高学生的综合素养和智慧学习能力，是没有围墙的北京四中。',
                  style: TextStyle(fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 18 : 16, color: Color(MyColors.black666,), wordSpacing: 1.0, textBaseline: TextBaseline.ideographic),),
              Spacer(),
              InkWell(
                child: Text('400-661-6666', style: textStyleLargeMediumPrimary),
                onTap: () => launch('tel:400-661-6666'),
              ),
              Padding(padding: EdgeInsets.only(top: 3)),
              Text('客服电话', style: textStyle12ccc),
              Padding(padding: EdgeInsets.only(top: 47)),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(fullscreenDialog: true, builder: (BuildContext context) {
                        return CommonWebviewPage(initialUrl: 'https://www.etiantian.com/about/mobile/servandpriv.html', title: '用户协议');
                      }));
                    },
                    child: Container(
                      height: 28,
                      child: Text("《用户协议》", style: TextStyle(fontSize: 12, color: Color.fromRGBO(0, 170, 125, 1.0),),),),
                  ),
                  InkWell(
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(fullscreenDialog: true, builder: (BuildContext context) {
                        return CommonWebviewPage(initialUrl: 'https://www.etiantian.com/privacy.html', title: '隐私政策');
                      }));
                    },
                    child: Container(
                      height: 28,
                      child: Text("《隐私政策》", style: TextStyle(fontSize: 12, color: Color.fromRGBO(0, 170, 125, 1.0),),),),
                  ),
                ],
              ),
              Text('© $year 北京四中网校', style: TextStyle(fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 13 : 11, color: Color(MyColors.black999))),
            ],
          ),
        ),
      ),
    );
  }

  Future initVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    versionName = packageInfo.version;
    setState(() {});
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_universalad/flutter_universalad.dart';

class AdSplashPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AdSplashPage();
  }
}

class _AdSplashPage extends State<AdSplashPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: FlutterUniversalad.splashAdView(
          //穿山甲广告android id
          pAndroidId: "887367774",
          //穿山甲广告ios id
          pIosId: "887367774",
          //优量汇广告android id
          tAndroidId: "4052216802299999",
          //优量汇广告ios id
          tIosId: "8012030096434021",
          //交替加载
          loadType: UniversalLoadType.INTURN,
          //穿山甲出现的几率
          probability: 0.5,
          callBack: USplashCallBack(
            onShow: (sdkType) {
              print("$sdkType  开屏广告显示");
            },
            onFail: (sdkType, code, message) {
              print("$sdkType  开屏广告失败  $code $message");
              Navigator.pop(context);
            },
            onClick: (sdkType) {
              print("$sdkType  开屏广告点击");
            },
            onClose: (sdkType) {
              print("$sdkType  开屏广告关闭");
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
}
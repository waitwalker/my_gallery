import 'package:flutter/material.dart';
import 'package:flutter_universalad/flutter_universalad.dart';
import 'package:my_gallery/modules/flu_app/router/flu_router_delegate.dart';
import 'package:my_gallery/modules/flu_app/router/flu_router_page_api.dart';
import 'package:my_gallery/modules/flu_app/router/router_delegate_manager.dart';

class ADPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ADPageState();
  }
}

class _ADPageState extends State<ADPage> {

  String _registerPenetrationResult = "";
  String _registerTecentResult = "";
  String _sdkVersion = "";


  @override
  void initState() {
    super.initState();
    _register();
    _initListener();
  }

  /// 初始化
  void _register() async {
    await FlutterUniversalad.register(
      pAndroidId: "5098580", /// 穿山甲Android id
      pIosId: "5098580", /// 穿山甲iOS id
      tAndroidId: "1200082163", /// 优量汇 Android id
      tIosId: "1200082163", 
      appName: "Flu App",
      debug: true,
      callBack: RegisterCallBack(
        pangolinInit: (result){
          setState(() {
            _registerPenetrationResult = "头条穿山甲初始化： $result";
          });
        }, tencentInit:(result){
          setState(() {
            _registerTecentResult = "腾讯优量汇初始化： $result";
            _getSdkVersion();
          });
        }
      ),
    );
  }

  void _getSdkVersion() async {
    VersionEntity versionEntity = await FlutterUniversalad.getSDKVersion();
    _sdkVersion = "穿山甲SDK version:${versionEntity.pangolinVersion} \n优量汇SDK version：${versionEntity.tencentVersion}";
  }

  ///
  /// @MethodName 广告监听
  /// @Parameter
  /// @ReturnType
  /// @Description
  /// @Author waitwalker
  /// @Date 2022/1/29
  ///
  void _initListener() {
    FlutterUniversalAdStream.initAdStream(
      uRewardCallBack: URewardCallBack(
        onShow: (sdkType) {
          print("$sdkType  激励广告开始显示");
        },
        onFail: (sdkType, code, message) {
          print("$sdkType  激励广告失败 $code $message");
        },
        onClick: (sdkType) {
          print("$sdkType  激励广告点击");
        },
        onClose: (sdkType) {
          print("$sdkType  激励广告关闭");
        },
        onReady: (sdkType) {
          print("$sdkType  激励广告预加载完成");
          FlutterUniversalad.showRewardVideoAd();
        },
        onUnReady: (sdkType) {
          print("$sdkType  激励广告未预加载");
        },
        onVerify: (sdkType, transId, verify, amount, name) {
          print(
              "$sdkType  激励广告观看成功 transId=$transId verify=$verify amount=$amount name=$name");
        },
      ),
      uInteractionCallBack: UInteractionCallBack(
        onShow: (sdkType) {
          print("$sdkType  插屏广告开始显示");
        },
        onFail: (sdkType, code, message) {
          print("$sdkType  插屏广告失败 $code $message");
        },
        onClick: (sdkType) {
          print("$sdkType  插屏广告点击");
        },
        onClose: (sdkType) {
          print("$sdkType  插屏广告关闭");
        },
        onReady: (sdkType) {
          print("$sdkType  插屏广告预加载完成");
          FlutterUniversalad.showInterstitialAd();
        },
        onUnReady: (sdkType) {
          print("$sdkType  插屏广告未预加载");
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("广告页面"),
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
                      color: Color(0xFFC0CA33),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: MediaQuery.of(context).size.width, height: 60,
                    child: Text(_registerPenetrationResult, style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                  ),
                ),
                onTap: (){

                },
              ),
              InkWell(
                child: Padding(padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color(0xFFC0CA33),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: MediaQuery.of(context).size.width, height: 60,
                    child: Text(_registerTecentResult, style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                  ),
                ),
                onTap: (){

                },
              ),
              InkWell(
                child: Padding(padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color(0xFFC0CA33),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: MediaQuery.of(context).size.width, height: 60,
                    child: Text(_sdkVersion, style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold,),),
                  ),
                ),
                onTap: (){

                },
              ),

              InkWell(
                child: Padding(padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: MediaQuery.of(context).size.width, height: 60,
                    child: Text("1.穿山甲激励广告", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                  ),
                ),
                onTap: (){
                  FlutterUnionad.loadRewardVideoAd(
                    mIsExpress: true,
                    //是否个性化 选填
                    androidCodeId: "945418088",
                    //Android 激励视频广告id  必填
                    iosCodeId: "945418088",
                    //ios 激励视频广告id  必填
                    supportDeepLink: true,
                    //是否支持 DeepLink 选填
                    rewardName: "穿山甲奖励金币",
                    //奖励名称 选填
                    rewardAmount: 199,
                    //奖励数量 选填
                    userID: "123",
                    //  用户id 选填
                    orientation: FlutterUnionadOrientation.VERTICAL,
                    //视屏方向 选填
                    mediaExtra: null, //扩展参数 选填
                  );
                },
              ),

              InkWell(
                child: Padding(padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: MediaQuery.of(context).size.width, height: 60,
                    child: Text("2.优量汇激励广告", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                  ),
                ),
                onTap: () async{
                  await FlutterTencentad.loadRewardVideoAd(
                    androidId: "5042816813706194",
                    //广告id
                    iosId: "8062535056034159",
                    rewardName: "优量汇奖励金币",
                    rewardAmount: 299,
                    userID: "123",
                  );
                },
              ),

              InkWell(
                child: Padding(padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.lightBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: MediaQuery.of(context).size.width, height: 60,
                    child: Text("3.聚合激励广告", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                  ),
                ),
                onTap: () async{
                  await FlutterUniversalad.loadRewardVideoAd(
                    //穿山甲广告android id
                    pAndroidId: "945418088",
                    //穿山甲广告ios id
                    pIosId: "945418088",
                    //优量汇广告android id
                    tAndroidId: "5042816813706194",
                    //优量汇广告ios id
                    tIosId: "8062535056034159",
                    //奖励名称
                    rewardName: "聚合奖励金币",
                    //奖励数量
                    rewardAmount: 399,
                    //用户id
                    userID: "123",
                    //交替加载
                    loadType: UniversalLoadType.INTURN,
                    //穿山甲出现的几率
                    probability: 0.5,
                    //扩展参数，开启服务器验证时上报
                    customData: "",
                  );
                },
              ),

              InkWell(
                child: Padding(padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.brown,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: MediaQuery.of(context).size.width, height: 60,
                    child: Text("4.穿山甲插屏广告", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                  ),
                ),
                onTap: () async{
                  FlutterUnionad.loadFullScreenVideoAdInteraction(
                    androidCodeId: "946201351", //android 全屏广告id 必填
                    iosCodeId: "946201351", //ios 全屏广告id 必填
                    supportDeepLink: true, //是否支持 DeepLink 选填
                    orientation: FlutterUnionadOrientation.VERTICAL, //视屏方向 选填
                  );
                },
              ),
              InkWell(
                child: Padding(padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: MediaQuery.of(context).size.width, height: 60,
                    child: Text("5.优量汇插屏广告", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                  ),
                ),
                onTap: () async{
                  await FlutterTencentad.loadUnifiedInterstitialAD(
                    //android广告id
                    androidId: "9062813863614416",
                    //广告id
                    iosId: "1052938046031440",
                    //是否全屏
                    isFullScreen: false,
                  );
                },
              ),

              InkWell(
                child: Padding(padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: MediaQuery.of(context).size.width, height: 60,
                    child: Text("6.聚合插屏广告", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                  ),
                ),
                onTap: () async{
                  await FlutterUniversalad.loadInterstitialAd(
                    //穿山甲广告android id
                    pAndroidId: "946201351",
                    //穿山甲广告ios id
                    pIosId: "946201351",
                    //优量汇广告android id
                    tAndroidId: "9062813863614416",
                    //优量汇广告ios id
                    tIosId: "1052938046031440",
                    //是否全屏 仅优量汇起效
                    isFullScreen: false,
                    //交替加载
                    loadType: UniversalLoadType.INTURN,
                    //穿山甲出现的几率
                    probability: 0.5,
                  );
                },
              ),

              InkWell(
                child: Padding(padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.cyanAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: MediaQuery.of(context).size.width, height: 60,
                    child: Text("7.开屏广告", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                  ),
                ),
                onTap: (){
                  kFluRouterDelegate.push(name: FluRouterPageAPI.adSplashPage);
                },
              ),

              InkWell(
                child: Padding(padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: MediaQuery.of(context).size.width, height: 60,
                    child: Text("8.1 穿山甲信息流广告", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                  ),
                ),
                onTap: (){

                },
              ),

              FlutterUnionad.nativeAdView(
                androidCodeId: "945417699",
                //android 信息流广告id 必填
                iosCodeId: "945417699",
                //ios banner广告id 必填
                supportDeepLink: true,
                //是否支持 DeepLink 选填
                expressViewWidth: 375.5,
                // 期望view 宽度 dp 必填
                expressViewHeight: 275.5,
                //期望view高度 dp 必填
                expressNum: 2,
                mIsExpress: true,
                //一次请求广告数量 大于1小于3 必填
                callBack: FlutterUnionadNativeCallBack(
                  onShow: () {
                    print("信息流广告显示");
                  },
                  onFail: (error) {
                    print("信息流广告失败 $error");
                  },
                  onDislike: (message) {
                    print("信息流广告不感兴趣 $message");
                  },
                  onClick: () {
                    print("信息流广告点击");
                  },
                ),
              ),
              InkWell(
                child: Padding(padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: MediaQuery.of(context).size.width, height: 60,
                    child: Text("8.2 聚合信息流广告", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                  ),
                ),
                onTap: (){

                },
              ),
              FlutterUniversalad.nativeAdView(
                //穿山甲广告android id
                pAndroidId: "945417699",
                //穿山甲广告ios id
                pIosId: "945417699",
                //优量汇广告android id
                tAndroidId: "4072918853903023",
                //优量汇广告ios id
                tIosId: "7082132016439065",
                width: 400.0,
                height: 260.0,
                loadType: UniversalLoadType.INTURN,
                probability: 0.5,
                callBack: UNativeCallBack(
                  onShow: (sdkType) {
                    print("$sdkType  Native广告显示");
                  },
                  onFail: (sdkType, code, message) {
                    print("$sdkType  Native广告失败  $code $message");
                  },
                  onClick: (sdkType) {
                    print("$sdkType  Native广告点击");
                  },
                  onClose: (sdkType) {
                    print("$sdkType  Native广告关闭");
                  },
                ),
              ),

              InkWell(
                child: Padding(padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color(0xFFC0CA33),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: MediaQuery.of(context).size.width, height: 60,
                    child: Text("9.1 穿山甲Banner广告", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                  ),
                ),
                onTap: (){

                },
              ),

              FlutterUnionad.bannerAdView(
                //andrrid banner广告id 必填
                androidCodeId: "945410197",
                //ios banner广告id 必填
                iosCodeId: "945410197",
                //是否使用个性化模版
                mIsExpress: true,
                //是否支持 DeepLink 选填
                supportDeepLink: true,
                //一次请求广告数量 大于1小于3 必填
                expressAdNum: 3,
                //轮播间隔事件 30-120秒  选填
                expressTime: 30,
                // 期望view 宽度 dp 必填
                expressViewWidth: 600.5,
                //期望view高度 dp 必填
                expressViewHeight: 150.5,
                //广告事件回调 选填
                callBack: FlutterUnionadBannerCallBack(
                    onShow: () {
                      print("banner广告加载完成");
                    },
                    onDislike: (message){
                      print("banner不感兴趣 $message");
                    },
                    onFail: (error){
                      print("banner广告加载失败 $error");
                    },
                    onClick: (){
                      print("banner广告点击");
                    }
                ),
              ),

              InkWell(
                child: Padding(padding: EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 16),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color(0xFFC0CA33),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: MediaQuery.of(context).size.width, height: 60,
                    child: Text("9.2 聚合Banner广告", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                  ),
                ),
                onTap: (){

                },
              ),
              FlutterUniversalad.bannerAdView(
                //穿山甲广告android id
                pAndroidId: "945410197",
                //穿山甲广告ios id
                pIosId: "945410197",
                //优量汇广告android id
                tAndroidId: "8042711873318113",
                //优量汇广告ios id
                tIosId: "6062430096832369",
                width: 300.0,
                height: 150.0,
                loadType: UniversalLoadType.INTURN,
                probability: 0.5,
                callBack: UBannerCallBack(
                  onShow: (sdkType) {
                    print("$sdkType  Banner广告显示");
                  },
                  onFail: (sdkType, code, message) {
                    print("$sdkType  Banner广告失败  $code $message");
                  },
                  onClick: (sdkType) {
                    print("$sdkType  Banner广告点击");
                  },
                  onClose: (sdkType) {
                    print("$sdkType  Banner广告关闭");
                  },
                ),
              )

            ],
          ))
        ],
      ),
    );
  }
}
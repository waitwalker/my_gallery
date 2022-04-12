import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:my_gallery/modules/flu_app/home_module/home_change_notifier.dart';
import 'package:my_gallery/modules/flu_app/inherited_widget/inherited_widget_page.dart';
import 'package:my_gallery/modules/flu_app/router/flu_router_page_api.dart';
import 'package:my_gallery/modules/flu_app/router/router_delegate_manager.dart';
import 'package:my_gallery/modules/flu_app/theme/theme_change_notifier.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }

}

class _HomePageState extends State<HomePage> with RouteAware, WidgetsBindingObserver{


  @override
  void initState() {
    super.initState();
    /// 添加观察者
    print(context);
    WidgetsBinding.instance!.addObserver(this);
    Provider.of<HomeChangeNotifier>(context,listen: false).loadHomeData(-2);

    // SchedulerBinding.instance.addPersistentFrameCallback((timeStamp) {
    //   print("object");
    // });
    //
    // WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) {
    //
    // });
    //
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //
    // });
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
    super.didChangeAppLifecycleState(state);
  }

  /// 内存警告回调
  @override
  void didHaveMemoryPressure() {
    super.didHaveMemoryPressure();
  }

  
  @override
  void didChangeDependencies() {
    kRouteObserver.subscribe(this, ModalRoute.of(context) as PageRoute<dynamic>);
    super.didChangeDependencies();
  }

  @override
  void didPush() {
    print("home页面被push出来了，home在最顶层了");
    super.didPush();
  }

  @override
  void didPop() {
    print("home页面被pop掉了");
    super.didPop();
  }

  @override
  void didPushNext() {
    print("home页面被didPushNext覆盖了");
    super.didPushNext();
  }

  @override
  void didPopNext() {
    print("home页面被didPopNext 又重新出现了");
    super.didPopNext();
  }

  @override
  void dispose() {
    kRouteObserver.unsubscribe(this);
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    int themeIndex = Provider.of<ThemeChangeNotifier>(context).themeIndex;
    return Consumer<HomeChangeNotifier>(builder: (context, homeChangeNotifier, child){
      HomeChangeNotifier homeChangeN = homeChangeNotifier;
      bool isLoading = homeChangeN.loading;
      bool hasError = homeChangeN.hasError;
      return Scaffold(
        appBar: AppBar(
          title: Text("首页"),
          backgroundColor: themeColorList[themeIndex],
        ),
        body: isLoading ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(child: CircularProgressIndicator(),),
        ],) : hasError ? Container(child: InkWell(
          child: Text("有错误",style: TextStyle(fontSize: 30),),
          onTap: (){
            Provider.of<HomeChangeNotifier>(context, listen: false).loadHomeData(2);
          },
        ),) :Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(child: ListView(
              children: [
                Padding(padding: EdgeInsets.only(top: 20),),
                InkWell(
                  child: Padding(padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: MediaQuery.of(context).size.width, height: 60,
                      child: Text("1.腾讯直播页面", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                    ),
                  ),
                  onTap: (){
                    kFluRouterDelegate.push(name: FluRouterPageAPI.tLoginPage);
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
                      child: Text("2.Isolate页面", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                    ),
                  ),
                  onTap: (){
                    kFluRouterDelegate.push(name: FluRouterPageAPI.isolatePage);
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
                      child: Text("3.联系人列表页面", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                    ),
                  ),
                  onTap: (){
                    kFluRouterDelegate.push(name: FluRouterPageAPI.contactPage);
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
                      child: Text("4.PlatformView页面", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                    ),
                  ),
                  onTap: (){
                    kFluRouterDelegate.push(name: FluRouterPageAPI.platformViewPage);
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
                      child: Text("5.Notification页面", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                    ),
                  ),
                  onTap: (){
                    kFluRouterDelegate.push(name: FluRouterPageAPI.notificationPage);
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
                      child: Text("6.mixin页面", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                    ),
                  ),
                  onTap: (){
                    kFluRouterDelegate.push(name: FluRouterPageAPI.mixinPage);
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
                      child: Text("7.动画页面", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                    ),
                  ),
                  onTap: (){
                    kFluRouterDelegate.push(name: FluRouterPageAPI.animationPage);
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
                      child: Text("8.事件穿透页面", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                    ),
                  ),
                  onTap: (){
                    kFluRouterDelegate.push(name: FluRouterPageAPI.eventPenetrationPage);
                  },
                ),

                InkWell(
                  child: Padding(padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.tealAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: MediaQuery.of(context).size.width, height: 60,
                      child: Text("9.广告页面", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                    ),
                  ),
                  onTap: (){
                    kFluRouterDelegate.push(name: FluRouterPageAPI.adPage);
                  },
                ),

                InkWell(
                  child: Padding(padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: MediaQuery.of(context).size.width, height: 60,
                      child: Text("10.Sliver页面", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                    ),
                  ),
                  onTap: (){
                    kFluRouterDelegate.push(name: FluRouterPageAPI.sliverEntrancePage);
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
                      child: Text("11.TabBar页面", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                    ),
                  ),
                  onTap: (){
                    kFluRouterDelegate.push(name: FluRouterPageAPI.tabBarPage);
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
                      child: Text("12.Chart页面", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                    ),
                  ),
                  onTap: (){
                    kFluRouterDelegate.push(name: FluRouterPageAPI.chartPage);
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
                      child: Text("13.贝壳优化ListView页面", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                    ),
                  ),
                  onTap: (){
                    kFluRouterDelegate.push(name: FluRouterPageAPI.keFramePage);
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
                      child: Text("14.绘制入口页面", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                    ),
                  ),
                  onTap: (){
                    kFluRouterDelegate.push(name: FluRouterPageAPI.canvasPage);
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
                      child: Text("15.PositionAnimation页面", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                    ),
                  ),
                  onTap: (){
                    kFluRouterDelegate.push(name: FluRouterPageAPI.positionAnimationPage);
                  },
                ),
                // InheritedWidgetPage(
                //   child: Text("${(context.getElementForInheritedWidgetOfExactType<InheritedWidgetPage>() as InheritedElementPage).value}"),
                // ),
              ],
            ))
          ],
        )
      );
    });
  }

}
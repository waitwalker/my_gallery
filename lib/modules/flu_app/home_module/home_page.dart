import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:my_gallery/modules/flu_app/config/k_printer.dart';
import 'package:my_gallery/modules/flu_app/game/custom_game.dart';
import 'package:my_gallery/modules/flu_app/home_module/home_change_notifier.dart';
import 'package:my_gallery/modules/flu_app/router/flu_router_page_api.dart';
import 'package:my_gallery/modules/flu_app/router/navigator_view_model.dart';
import 'package:my_gallery/modules/flu_app/router/router_delegate_manager.dart';
import 'package:my_gallery/modules/flu_app/theme/theme_change_notifier.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

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
    kPrinter(context);
    WidgetsBinding.instance!.addObserver(this);
    Provider.of<HomeChangeNotifier>(context,listen: false).loadHomeData(-2);

    // SchedulerBinding.instance.addPersistentFrameCallback((timeStamp) {
    //   printer("object");
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
    kPrinter(state);
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
    kPrinter("home页面被push出来了，home在最顶层了");
    super.didPush();
  }

  @override
  void didPop() {
    kPrinter("home页面被pop掉了");
    super.didPop();
  }

  @override
  void didPushNext() {
    kPrinter("home页面被didPushNext覆盖了");
    super.didPushNext();
  }

  @override
  void didPopNext() {
    kPrinter("home页面被didPopNext 又重新出现了");
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
          title: const Text("首页"),
          backgroundColor: themeColorList[themeIndex],
        ),
        body: isLoading ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Center(child: CircularProgressIndicator(),),
        ],) : hasError ? InkWell(
          child: const Text("有错误",style: TextStyle(fontSize: 30),),
          onTap: (){
            Provider.of<HomeChangeNotifier>(context, listen: false).loadHomeData(2);
          },
        ) :Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(child: ListView(
              children: [
                const Padding(padding: EdgeInsets.only(top: 20),),
                InkWell(
                  child: Padding(padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: MediaQuery.of(context).size.width, height: 60,
                      child: const Text("1.腾讯直播页面", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                    ),
                  ),
                  onTap: (){
                    Provider.of<NavigatorViewModel>(context,listen: false).setHomeTabCount(50);
                    // kFluRouterDelegate.push(name: FluRouterPageAPI.orderPage);
                    // CommonEventManager.coinEventAction(context: context, title: "Quer mais ouro?", content: "3000～5000", subTitle: "Assista aos anúncios", buttonTitle: "Assista agora", onTap: (){
                    //   Navigator.pop(context);
                    // });
                    // CommonEventManager.rewardEventAction(context: context, title: "Parabéns", content: "30000", buttonTitle: "Assista ao vídeo e ganhe 200% a mais", imagePath: "static/images/dialog_bg_common_icon.webp", onTap: (){
                    //   Navigator.pop(context);
                    // });
                  },
                ),

                InkWell(
                  child: Padding(padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: MediaQuery.of(context).size.width, height: 60,
                      child: const Text("2.Isolate页面", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                    ),
                  ),
                  onTap: (){
                    kFluRouterDelegate.push(name: FluRouterPageAPI.isolatePage);
                  },
                ),

                InkWell(
                  child: Padding(padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: MediaQuery.of(context).size.width, height: 60,
                      child: const Text("3.联系人列表页面", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                    ),
                  ),
                  onTap: (){
                    kFluRouterDelegate.push(name: FluRouterPageAPI.contactPage);
                  },
                ),

                InkWell(
                  child: Padding(padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.brown,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: MediaQuery.of(context).size.width, height: 60,
                      child: const Text("4.PlatformView页面", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                    ),
                  ),
                  onTap: (){
                    kFluRouterDelegate.push(name: FluRouterPageAPI.platformViewPage);
                  },
                ),
                InkWell(
                  child: Padding(padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: MediaQuery.of(context).size.width, height: 60,
                      child: const Text("5.Notification页面", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                    ),
                  ),
                  onTap: (){
                    kFluRouterDelegate.push(name: FluRouterPageAPI.notificationPage);
                  },
                ),

                InkWell(
                  child: Padding(padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: MediaQuery.of(context).size.width, height: 60,
                      child: const Text("6.mixin页面", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                    ),
                  ),
                  onTap: (){
                    kFluRouterDelegate.push(name: FluRouterPageAPI.mixinPage);
                  },
                ),

                InkWell(
                  child: Padding(padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.pinkAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: MediaQuery.of(context).size.width, height: 60,
                      child: const Text("7.动画页面", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                    ),
                  ),
                  onTap: (){
                    kFluRouterDelegate.push(name: FluRouterPageAPI.animationPage);
                  },
                ),

                InkWell(
                  child: Padding(padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC0CA33),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: MediaQuery.of(context).size.width, height: 60,
                      child: const Text("8.事件穿透页面", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                    ),
                  ),
                  onTap: (){
                    kFluRouterDelegate.push(name: FluRouterPageAPI.eventPenetrationPage);
                  },
                ),

                InkWell(
                  child: Padding(padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.tealAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: MediaQuery.of(context).size.width, height: 60,
                      child: const Text("9.广告页面", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                    ),
                  ),
                  onTap: (){
                    kFluRouterDelegate.push(name: FluRouterPageAPI.adPage);
                  },
                ),

                InkWell(
                  child: Padding(padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: MediaQuery.of(context).size.width, height: 60,
                      child: const Text("10.Sliver页面", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                    ),
                  ),
                  onTap: (){
                    kFluRouterDelegate.push(name: FluRouterPageAPI.sliverEntrancePage);
                  },
                ),

                InkWell(
                  child: Padding(padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: MediaQuery.of(context).size.width, height: 60,
                      child: const Text("11.TabBar页面", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                    ),
                  ),
                  onTap: (){
                    kFluRouterDelegate.push(name: FluRouterPageAPI.tabBarPage);
                  },
                ),

                InkWell(
                  child: Padding(padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: MediaQuery.of(context).size.width, height: 60,
                      child: const Text("12.Chart页面", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
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
                      child: const Text("13.贝壳优化ListView页面", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                    ),
                  ),
                  onTap: (){
                    kFluRouterDelegate.push(name: FluRouterPageAPI.keFramePage);
                  },
                ),

                InkWell(
                  child: Padding(padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: MediaQuery.of(context).size.width, height: 60,
                      child: const Text("14.绘制入口页面", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
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
                InkWell(
                  child: Padding(padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: MediaQuery.of(context).size.width, height: 60,
                      child: Text("16.Game页面", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                    ),
                  ),
                  onTap: (){
                    final game = CustomGame();
                    runApp(GameWidget(game: game));
                  },
                ),
              ],
            ))
          ],
        )
      );
    });
  }

}
import 'package:flutter/material.dart';
import 'package:my_gallery/modules/flu_app/router/flu_router_page_api.dart';
import 'package:my_gallery/modules/flu_app/router/router_delegate_manager.dart';

class SliverEntrancePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SliverEntrancePageState();
  }
}

class _SliverEntrancePageState extends State<SliverEntrancePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sliver入口页面"),
      ),
      body: Column(
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
                    child: Text("1.SliverList页面", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                  ),
                ),
                onTap: (){
                  kFluRouterDelegate.push(name: FluRouterPageAPI.sliverListPage);
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
                    child: Text("2.SliverAppBar页面", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                  ),
                ),
                onTap: (){
                  kFluRouterDelegate.push(name: FluRouterPageAPI.sliverAppBarPage);
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
                    child: Text("3.SliverSticky页面", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                  ),
                ),
                onTap: (){
                  kFluRouterDelegate.push(name: FluRouterPageAPI.sliverStickyPage);
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
                    child: Text("4.SliverCustomHeader页面", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                  ),
                ),
                onTap: (){
                  kFluRouterDelegate.push(name: FluRouterPageAPI.sliverCustomHeaderPage);
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
                    child: Text("5.类似美团滚动嵌套页面", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                  ),
                ),
                onTap: (){
                  kFluRouterDelegate.push(name: FluRouterPageAPI.meituanShopPage);
                },
              ),
            ],
          ))
        ],
      ),
    );
  }
}
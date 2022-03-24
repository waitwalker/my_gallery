import 'package:flutter/material.dart';

import '../router/flu_router_page_api.dart';
import '../router/router_delegate_manager.dart';

class CanvasEntrancePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CanvasEntrancePageState();
  }

}

class _CanvasEntrancePageState extends State<CanvasEntrancePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Paint1绘制"),
      ),
      body: Column(
        children: [
          InkWell(
            child: Padding(padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                width: MediaQuery.of(context).size.width, height: 60,
                child: Text("1普通绘制", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
              ),
            ),
            onTap: (){
              kFluRouterDelegate.push(name: FluRouterPageAPI.paint1Page);
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
                child: Text("2线段绘制", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
              ),
            ),
            onTap: (){
              kFluRouterDelegate.push(name: FluRouterPageAPI.paint2Page);
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
                child: Text("3贝塞尔曲线绘制", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
              ),
            ),
            onTap: (){
              kFluRouterDelegate.push(name: FluRouterPageAPI.paint3Page);
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
                child: Text("4图片绘制", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
              ),
            ),
            onTap: (){
              kFluRouterDelegate.push(name: FluRouterPageAPI.paint4Page);
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
                child: Text("5文本绘制", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
              ),
            ),
            onTap: (){
              kFluRouterDelegate.push(name: FluRouterPageAPI.paint5Page);
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
                child: Text("6动画绘制", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
              ),
            ),
            onTap: (){
              kFluRouterDelegate.push(name: FluRouterPageAPI.paint6Page);
            },
          ),

        ],
      ),
    );
  }

}
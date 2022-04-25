import 'package:flutter/material.dart';
import 'package:my_gallery/modules/flu_app/router/flu_router_page_api.dart';
import 'package:my_gallery/modules/flu_app/router/router_delegate_manager.dart';
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
        title: const Text("Paint1绘制"),
      ),
      body: Column(
        children: [
          InkWell(
            child: Padding(padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                width: MediaQuery.of(context).size.width, height: 60,
                child: const Text("1普通绘制", style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
              ),
            ),
            onTap: (){
              kRouterDelegate.push(name: RouterPageAPI.paint1Page);
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
                child: const Text("2线段绘制", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
              ),
            ),
            onTap: (){
              kRouterDelegate.push(name: RouterPageAPI.paint2Page);
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
                child: const Text("3贝塞尔曲线绘制", style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
              ),
            ),
            onTap: (){
              kRouterDelegate.push(name: RouterPageAPI.paint3Page);
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
                child: const Text("4图片绘制", style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
              ),
            ),
            onTap: (){
              kRouterDelegate.push(name: RouterPageAPI.paint4Page);
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
                child: const Text("5文本绘制", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
              ),
            ),
            onTap: (){
              kRouterDelegate.push(name: RouterPageAPI.paint5Page);
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
                child: const Text("6动画绘制", style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
              ),
            ),
            onTap: (){
              kRouterDelegate.push(name: RouterPageAPI.paint6Page);
            },
          ),

        ],
      ),
    );
  }

}
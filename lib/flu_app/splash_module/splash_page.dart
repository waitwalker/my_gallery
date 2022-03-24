import 'package:flutter/material.dart';
import 'package:my_gallery/flu_app/router/flu_router_page_api.dart';
import 'package:my_gallery/flu_app/router/router_delegate_manager.dart';

class SplashPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SplashState();
  }

}

class _SplashState extends State<SplashPage> {

  @override
  void initState() {
    Future.delayed(Duration(seconds: 2),(){
      kFluRouterDelegate.replaceLastPage(name: FluRouterPageAPI.bottomNavigationBarPage);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("启动页"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_tree, color: Colors.amber, size: 200,),
          TextButton(onPressed: (){
            kFluRouterDelegate.replaceLastPage(name: FluRouterPageAPI.bottomNavigationBarPage);
          }, child: Text("跳到首页"))
        ],
      ),
    );
  }

}
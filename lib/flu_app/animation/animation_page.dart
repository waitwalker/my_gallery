import 'dart:math';
import 'package:flutter/material.dart';
import 'package:my_gallery/flu_app/router/flu_router_page_api.dart';
import 'package:my_gallery/flu_app/router/router_delegate_manager.dart';

class AnimationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AnimationPageState();
  }
}

class _AnimationPageState extends State<AnimationPage> with SingleTickerProviderStateMixin{

  double _opacityValue = 1.0;
  double _width = 0.0;
  double _height = 0.0;
  Color _color = Colors.green;
  bool changeColor = false;

  late AnimationController _animationController;
  late Animation<double> _turns;
  bool _playing = false;

  String image1 = "static/images/ai_entrance_top.png";
  String image2 = "static/images/ai_test_back_top.png";
  GestureDetector buildRowItem(BuildContext context, String image){
    return GestureDetector(
      child: Container(
        width: 100,
        height: 100,
        child: Hero(
          tag: image,
          child: ClipOval(
            child: Image.asset(image),
          ),
        ),
      ),
      onTap: (){
        Map<String,String> map = {"image":image};
        kFluRouterDelegate.push(name: FluRouterPageAPI.heroPage, arguments: map);
      },
    );
  }

  /// 控制动画运行状态
  void _toggle() {
    /// 正在运行动画 点击结束动画
    if (_playing) {
      _playing = false;
      _animationController.stop();
    } else {
      /// 没有运行 点击开始运行
      _playing = true;
      _animationController.forward()..whenComplete(() => _animationController.reverse());
      //_animationController.repeat();
    }
    setState(() {

    });
  }

  @override
  void initState() {
    _width = 300;
    _height = 70.0;
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3)
    );
    /// 设置动画的取值范围和时间曲线
    _turns = Tween(begin: 0.0, end: pi * 2).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
    
    _animationController.addListener(() { 
      
    });
    
    _turns.addStatusListener((status) { 
      print("当前动画状态：$status)");
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Animation页面"),
      ),
      body: Column(children: [
        Expanded(child: ListView(children: [
          Padding(padding: EdgeInsets.only(top: 20)),
          InkWell(
            child: Padding(padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.lightBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                width: MediaQuery.of(context).size.width, height: 60,
                child: Text("透明隐式动画调试", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
              ),
            ),
            onTap: (){
              setState(() {
                _opacityValue = _opacityValue > 0 ? 0.0 : 1.0;
              });
            },
          ),
          AnimatedOpacity(
            opacity: _opacityValue,
            duration: Duration(seconds: 2),
            child: Padding(padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.amberAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                width: MediaQuery.of(context).size.width, height: 60,
                child: Text("透明动画", style: TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold,),),
              ),
            ),
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
                child: Text("容器隐式动画调试", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
              ),
            ),
            onTap: (){
              setState(() {
                _width = _width > 50 ? 50 : 300;
                //_height = _height > 30 ? 30 : 70;
                changeColor = !changeColor;
                _color = changeColor ? Colors.green : Colors.deepOrange;
              });
            },
          ),
          Padding(padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: AnimatedContainer(
              duration: Duration(seconds: 3),
              curve: Curves.bounceInOut,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _color,
                borderRadius: BorderRadius.circular(10),
              ),
              width: _width, height: _height,
              child: Text("容器动画", style: TextStyle(fontSize: 20, color: Colors.lightBlueAccent, fontWeight: FontWeight.bold,),),
            ),
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
                child: Text("旋转显式动画调试", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
              ),
            ),
            onTap: _toggle,
          ),
          Padding(padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: RotationTransition(
              turns: _turns,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                width: 150, height: 150,
                child: Image.asset("static/images/circle.png"),
              ),
            ),
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
                child: Text("Hero动画", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
              ),
            ),
            onTap: (){

            },
          ),
          Padding(padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(children: [
              buildRowItem(context, image1),
              buildRowItem(context, image2),
            ],),
          ),
        ],)),
      ],),
    );
  }
}
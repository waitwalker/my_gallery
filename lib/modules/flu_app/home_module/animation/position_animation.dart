import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'position_animation_view_model.dart';

class PositionAnimationPage extends StatefulWidget {
  const PositionAnimationPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PositionAnimationPageState();
  }
}


class _PositionAnimationPageState extends State<PositionAnimationPage> with TickerProviderStateMixin{
  double top = 60.0;
  late Animation animation;
  late AnimationController controller;


  @override
  void initState() {
    controller = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    final CurvedAnimation curve = CurvedAnimation(parent: controller, curve: Curves.easeIn);
    animation = Tween<double>(begin: 120, end: -300.0).animate(curve);
    animation.addListener(() {
      setState(() {

      });
      if (animation.isCompleted) {
        Provider.of<PositionAnimationViewModel>(context,listen: false).setShow(false);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<PositionAnimationViewModel, PositionAnimationViewModel>(builder: (con,chid,model){
      return Scaffold(
        appBar: AppBar(
          title: Text("Position动画"),
        ),
        body: Stack(children: [
          Container(color: Colors.orange,),
          Provider.of<PositionAnimationViewModel>(context,listen: false).show ? Positioned(
            child: Dismissible(
              key: ObjectKey("${DateTime.now()} + 1"),
              direction: DismissDirection.up,
              child: Dismissible(key: ObjectKey("${DateTime.now()}"), child:Container(
                height: 100,
                width: MediaQuery.of(context).size.width,
                color: Colors.deepPurpleAccent,
              )),
            ),
            top: animation.value,
          ): Container(),

          Positioned(
            child: InkWell(
            child: Container(
              color: Colors.lightBlue,
              height: 80,
              width: MediaQuery.of(context).size.width,
              child: Text("data"),
            ),
            onTap: (){
              controller.forward();
            },
          ),
            top: 200,
          ),

          Positioned(
            child: InkWell(
              child: Container(
                color: Colors.lightGreenAccent,
                height: 80,
                width: MediaQuery.of(context).size.width,
                child: Text("show"),
              ),
              onTap: (){

                Provider.of<PositionAnimationViewModel>(context,listen: false).setShow(true);
                controller.reset();
              },
            ),
            top: 380,
          ),
        ],),
      );
    }, selector: (ctx,model){
      return model;
    },);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
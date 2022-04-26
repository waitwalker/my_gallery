import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class BottomSheetPage extends StatefulWidget {
  const BottomSheetPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BottomSheetPageState();
}

class _BottomSheetPageState extends State<BottomSheetPage> {

  final GFBottomSheetController controller = GFBottomSheetController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("bottom sheet"),
      ),
      bottomSheet: GFBottomSheet(
        animationDuration: 300,
        controller: controller,
        maxContentHeight: 150,
        stickyHeaderHeight: 100,
        stickyFooterHeight: 50,
        stickyHeader: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: const [
              BoxShadow(color: Colors.black54, blurRadius: 0)
            ],
          ),
          child: const GFListTile(
            avatar: GFAvatar(
              backgroundImage: AssetImage("assets/images/Anchor-exp.jpg"),
            ),
            titleText: "晚夜",
            subTitleText: "Flutter",
          ),
        ),
        contentBody: Container(
          height: 250.0,
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: ListView(
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            children: const [
              Center(
                child: Text("Flutter 是 Google 开源的应用开发框架，拥有120fps的刷新率，也是目前非常流行的跨平台UI开发框架。\n本专栏为大家收集了Github上近70个优秀开源库，后续也将持续更新。希望可以帮助大家提升搬砖效率，同时祝愿Flutter的生态越来越完善🎉🎉。",
                  style: TextStyle(
                    fontSize: 15, wordSpacing: 0.3, letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
        stickyFooter: Container(
          color: GFColors.SUCCESS,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Text("Flutter轮子推荐",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              Text("GetWidget", style: TextStyle(fontSize: 15, color: Colors.white),),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: GFColors.SUCCESS,
        child: controller.isBottomSheetOpened
            ? Icon(Icons.keyboard_arrow_down)
            : Icon(Icons.keyboard_arrow_up),
        onPressed: (){
          controller.isBottomSheetOpened
              ? controller.hideBottomSheet()
              : controller.showBottomSheet();
        },
      ),
    );
  }
}